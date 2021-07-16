package docker

import (
	"context"
	"errors"

	dockerTypes "github.com/docker/docker/api/types"
	dockerFilters "github.com/docker/docker/api/types/filters"
	docker "github.com/docker/docker/client"
	"github.com/wailsapp/wails"
	"github.com/wailsapp/wails/lib/logger"
)

type cleanupFunc func() error

type Container struct {
	Name string
	Id string
}

type containerStore map[string]Container

type Containers struct {
	log *logger.CustomLogger
	store *wails.Store

	client *docker.Client

	cleanupFuncs []cleanupFunc
}

func (c *Containers) WailsInit(runtime *wails.Runtime) error {
	c.log = runtime.Log.New("Containers")

	c.store = runtime.Store.New("Containers", make(containerStore))

	c.log.Debug("Creating docker client...")
	cli, err := docker.NewClientWithOpts(docker.FromEnv)
	if err == nil {
		c.client = cli

		runtime.Events.Once("frontend-ready", func(_ ...interface{}) {
			go c.loadContainerList()
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

func (c *Containers) loadContainerList() error {
	c.log.Debugf("listing installed containers\n")
	if c.client != nil {
		filters := dockerFilters.NewArgs(dockerFilters.Arg("label", "io.github.games-on-whales.type"))

		containers, err := c.client.ContainerList(context.Background(), dockerTypes.ContainerListOptions{ All: true, Filters: filters })
		if err != nil {
			return err
		}

		for _, ctr := range containers {
			container := Container{ Name: ctr.Names[0], Id: ctr.ID }
			c.store.Update(func (data containerStore) containerStore {
				data[ctr.ID] = container
				return data
			})
		}
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
