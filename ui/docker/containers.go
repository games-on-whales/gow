package docker

import (
	"github.com/teris-io/shortid"
	"github.com/wailsapp/wails"
	"github.com/wailsapp/wails/lib/logger"
)

type Container struct {
	Name string
	Id string
}

type Containers struct {
	log *logger.CustomLogger
	containers []Container
}

func (c *Containers) WailsInit(runtime *wails.Runtime) error {
	c.log = runtime.Log.New("Containers")

	c.log.Debugf("GENERATING CONTAINERS");

	c.containers = []Container{
		{ Name: "Steam", Id: shortid.MustGenerate() },
		{ Name: "Firefox", Id: shortid.MustGenerate() },
		{ Name: "Other App", Id: shortid.MustGenerate() },
	}

	return nil
}

func (c *Containers) ListInstalled() ([]Container, error) {
	c.log.Debugf("listing installed containers\n")
	return c.containers, nil
}

func (c *Containers) ListAvailable() ([]Container, error) {
	c.log.Debugf("listing available containers\n")
	return []Container{}, nil
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
