package docker

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"

	dockerTypes "github.com/docker/docker/api/types"
	dockerFilters "github.com/docker/docker/api/types/filters"
	docker "github.com/docker/docker/client"
	"github.com/wailsapp/wails"
	"github.com/wailsapp/wails/lib/logger"
)

type cleanupFunc func() error

type ContainerList struct {
	Name string
	Contents []string
}

type Container struct {
	Name string
	Id string
	Icon string
	Banner string
	Summary string
	Description string
}

type Catalog struct {
	Containers []Container
	Featured []string
	Lists []ContainerList
}

type ExpandedContainerList struct {
	Name string
	Contents []Container
}

type installedStoreType map[string]Container

type containerStore struct {
	Installed installedStoreType
	Featured []Container
	Lists []ExpandedContainerList
	Available map[string]Container
}

type Containers struct {
	log *logger.CustomLogger
	store *wails.Store

	client *docker.Client

	catalog Catalog
	cleanupFuncs []cleanupFunc
}

func (c *Containers) WailsInit(runtime *wails.Runtime) error {
	c.log = runtime.Log.New("Containers")

	c.store = runtime.Store.New("Containers", containerStore{
		Available: make(map[string]Container),
		Installed: make(installedStoreType),
		Featured: []Container{},
		Lists: []ExpandedContainerList{},
	})

	c.log.Debug("Creating docker client...")
	cli, err := docker.NewClientWithOpts(docker.FromEnv)
	if err == nil {
		c.client = cli

		runtime.Events.Once("frontend-ready", func(_ ...interface{}) {
			c.log.Debug("frontend ready; about to load containers")
			go c.loadContainerList()
			go c.loadCatalog()
			// go c.watchDockerContainers()
		})
	}

	return nil
}

func (c *Containers) WailsShutdown() {
	for _, f := range c.cleanupFuncs {
		defer f()
	}
}

// TODO: consider if using a store for catalog data is really the best way.
// One issue is that Subscribe()-ing to a store after data has already been
// added to it does _not_ call the subscriber with that data, and if the data
// is loaded on WailsInit() it will always be loaded before the frontend is up
// and running, so there always has to be some way for the frontend to manually
// trigger a dummy update

func (c *Containers) loadCatalog() error {
	res, err := http.Get("http://localhost:8081/catalog.json")
	if err != nil {
		return err
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return err
	}

	json.Unmarshal([]byte(body), &c.catalog)

	c.log.Debugf("Got catalog: %v", c.catalog)

	c.store.Update(func (data containerStore) containerStore {
		// first, update the "available" map
		for _, item := range c.catalog.Containers {
			data.Available[item.Id] = item
		}

		// then, expand the lists. go with the simple naive algorithm for now
		data.Lists = make([]ExpandedContainerList, len(c.catalog.Lists))
		for idx, list := range c.catalog.Lists {
			data.Lists[idx] = ExpandedContainerList{
				Name: list.Name,
				Contents: make([]Container, len(list.Contents)),
			}

			for itemIdx, itemId := range list.Contents {
				data.Lists[idx].Contents[itemIdx] = data.Available[itemId]
			}
		}

		// finally, the featured items
		data.Featured = make([]Container, len(c.catalog.Featured))
		for idx, itemId := range c.catalog.Featured {
			data.Featured[idx] = data.Available[itemId]
		}

		return data
	})

	return nil
}

func (c *Containers) loadContainerList() error {
	c.log.Debugf("listing installed containers\n")
	if c.client != nil {
		filters := dockerFilters.NewArgs(dockerFilters.Arg("label", "io.github.games-on-whales.type"))

		containers, err := c.client.ContainerList(context.Background(), dockerTypes.ContainerListOptions{ All: true, Filters: filters })
		if err != nil {
			return err
		}

		c.log.Debugf("Found %d containers", len(containers))

		for _, ctr := range containers {
			// TODO: it's probably not the right thing to do to use docker's ID
			// here, since they won't match up with the catalog. maybe the
			// catalog id should be added as a label when the container is
			// created?
			container := Container{ Name: ctr.Names[0], Id: ctr.ID }
			c.store.Update(func (data containerStore) containerStore {
				c.log.Debugf("Updating with a container: %s", ctr.ID)

				data.Installed[ctr.ID] = container
				return data
			})
		}
	} else {
		c.log.Debug("no docker client; can't list containers")
	}

	return nil
}

func (c *Containers) watchDockerContainers() {
		ctx, cancelFunc := context.WithCancel(context.Background())
		c.cleanupFuncs = append(c.cleanupFuncs, func() error { cancelFunc(); return nil })

		msgs, errs := c.client.Events(ctx, dockerTypes.EventsOptions{})

		for {
			select {
				case err := <-errs: {
					if err != nil && !errors.Is(err, context.Canceled) {
						c.log.Errorf("error receiving docker event: %v", err)
					}
				}

				case msg := <-msgs: {
					c.log.Infof("docker message: %s", msg)
				}
			}
		}
}

// TODO: this is a total hack just so i can see something on the screen tonight
func (c *Containers) TriggerStoreUpdate() error {
	c.store.Update(func (data containerStore) containerStore {
		return data
	})
	return nil
}

func (c *Containers) StartContainer(ctr Container) error {
	c.log.Debugf("starting container %s\n", ctr.Name)
	return nil
}

func (c *Containers) StopContainer(ctr Container) error {
	c.log.Debugf("stopping container %s\n", ctr.Name)
	return nil
}

func (c *Containers) InstallContainer(ctr Container) error {
	c.log.Debugf("installing container %s\n", ctr.Name)
	return nil
}

func (c *Containers) RemoveContainer(ctr Container) error {
	c.log.Debugf("removing container %s\n", ctr.Name)
	return nil
}
