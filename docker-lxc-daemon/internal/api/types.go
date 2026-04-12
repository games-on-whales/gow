// Package api implements the Docker Engine HTTP API surface that is consumed
// by the raw docker CLI and GoW tooling.
package api

import "time"

// --- Container Create ---

// ContainerCreateRequest mirrors the relevant subset of the Docker Engine
// POST /containers/create body.
type ContainerCreateRequest struct {
	Image      string            `json:"Image"`
	Cmd        []string          `json:"Cmd"`
	Entrypoint []string          `json:"Entrypoint"`
	Env        []string          `json:"Env"`
	Labels     map[string]string `json:"Labels"`
	WorkingDir string            `json:"WorkingDir"`
	HostConfig HostConfig        `json:"HostConfig"`
}

// HostConfig holds the host-level container options.
type HostConfig struct {
	Binds       []string             `json:"Binds"`       // "host:container[:ro]"
	Devices     []DeviceMapping      `json:"Devices"`
	Memory      int64                `json:"Memory"`      // bytes, 0=unlimited
	CPUShares   int64                `json:"CpuShares"`
	NanoCPUs    int64                `json:"NanoCpus"`
	NetworkMode string               `json:"NetworkMode"`
	PortBindings map[string][]PortBinding `json:"PortBindings"`
	RestartPolicy RestartPolicy      `json:"RestartPolicy"`
}

// DeviceMapping is a single host→container device mapping.
type DeviceMapping struct {
	PathOnHost        string `json:"PathOnHost"`
	PathInContainer   string `json:"PathInContainer"`
	CgroupPermissions string `json:"CgroupPermissions"`
}

// PortBinding maps a container port to a host port.
type PortBinding struct {
	HostIP   string `json:"HostIp"`
	HostPort string `json:"HostPort"`
}

// RestartPolicy mirrors Docker's restart policy field.
type RestartPolicy struct {
	Name              string `json:"Name"`
	MaximumRetryCount int    `json:"MaximumRetryCount"`
}

// ContainerCreateResponse is the body returned by POST /containers/create.
type ContainerCreateResponse struct {
	ID       string   `json:"Id"`
	Warnings []string `json:"Warnings"`
}

// --- Container Inspect ---

// ContainerJSON is the body returned by GET /containers/{id}/json.
type ContainerJSON struct {
	ID              string          `json:"Id"`
	Created         string          `json:"Created"`
	Name            string          `json:"Name"`
	State           ContainerState  `json:"State"`
	Image           string          `json:"Image"`
	Config          *ContainerConfig `json:"Config"`
	HostConfig      *HostConfig     `json:"HostConfig"`
	NetworkSettings NetworkSettings `json:"NetworkSettings"`
}

// ContainerState holds the runtime state of a container.
type ContainerState struct {
	Status     string `json:"Status"`   // "running", "exited", "created"
	Running    bool   `json:"Running"`
	Paused     bool   `json:"Paused"`
	Restarting bool   `json:"Restarting"`
	Dead       bool   `json:"Dead"`
	Pid        int    `json:"Pid"`
	ExitCode   int    `json:"ExitCode"`
	StartedAt  string `json:"StartedAt"`
	FinishedAt string `json:"FinishedAt"`
}

// ContainerConfig is the image-level config embedded in ContainerJSON.
type ContainerConfig struct {
	Image      string            `json:"Image"`
	Cmd        []string          `json:"Cmd"`
	Entrypoint []string          `json:"Entrypoint"`
	Env        []string          `json:"Env"`
	Labels     map[string]string `json:"Labels"`
	WorkingDir string            `json:"WorkingDir"`
}

// NetworkSettings holds the IP and network info for a container.
type NetworkSettings struct {
	IPAddress string                     `json:"IPAddress"`
	Networks  map[string]EndpointSettings `json:"Networks"`
}

// EndpointSettings is a per-network settings block.
type EndpointSettings struct {
	IPAddress   string `json:"IPAddress"`
	Gateway     string `json:"Gateway"`
	MacAddress  string `json:"MacAddress"`
	NetworkID   string `json:"NetworkID"`
}

// --- Container List ---

// ContainerSummary is a single item in the GET /containers/json response.
type ContainerSummary struct {
	ID      string            `json:"Id"`
	Names   []string          `json:"Names"`
	Image   string            `json:"Image"`
	ImageID string            `json:"ImageID"`
	Command string            `json:"Command"`
	Created int64             `json:"Created"` // Unix timestamp
	Status  string            `json:"Status"`
	State   string            `json:"State"`
	Ports   []Port            `json:"Ports"`
	Labels  map[string]string `json:"Labels"`
}

// Port describes a mapped port.
type Port struct {
	IP          string `json:"IP,omitempty"`
	PrivatePort uint16 `json:"PrivatePort"`
	PublicPort  uint16 `json:"PublicPort,omitempty"`
	Type        string `json:"Type"`
}

// --- Images ---

// ImageSummary is a single item in GET /images/json.
type ImageSummary struct {
	ID          string            `json:"Id"`
	ParentID    string            `json:"ParentId"`
	RepoTags    []string          `json:"RepoTags"`
	RepoDigests []string          `json:"RepoDigests"`
	Created     int64             `json:"Created"`
	Size        int64             `json:"Size"`
	Labels      map[string]string `json:"Labels"`
}

// ImageInspect is the body returned by GET /images/{name}/json.
type ImageInspect struct {
	ID           string            `json:"Id"`
	RepoTags     []string          `json:"RepoTags"`
	Created      string            `json:"Created"`
	Architecture string            `json:"Architecture"`
	Os           string            `json:"Os"`
	Labels       map[string]string `json:"Labels"`
}

// --- Exec ---

// ExecCreateRequest is the body of POST /containers/{id}/exec.
type ExecCreateRequest struct {
	Cmd          []string `json:"Cmd"`
	AttachStdin  bool     `json:"AttachStdin"`
	AttachStdout bool     `json:"AttachStdout"`
	AttachStderr bool     `json:"AttachStderr"`
	Tty          bool     `json:"Tty"`
	Env          []string `json:"Env"`
	WorkingDir   string   `json:"WorkingDir"`
}

// ExecCreateResponse is the body returned by POST /containers/{id}/exec.
type ExecCreateResponse struct {
	ID string `json:"Id"`
}

// ExecStartRequest is the body of POST /exec/{id}/start.
type ExecStartRequest struct {
	Detach bool `json:"Detach"`
	Tty    bool `json:"Tty"`
}

// ExecInspect is the body returned by GET /exec/{id}/json.
type ExecInspect struct {
	ID          string `json:"ID"`
	ContainerID string `json:"ContainerID"`
	Running     bool   `json:"Running"`
	ExitCode    int    `json:"ExitCode"`
	ProcessConfig ExecProcessConfig `json:"ProcessConfig"`
}

// ExecProcessConfig holds the command run via exec.
type ExecProcessConfig struct {
	Tty        bool     `json:"tty"`
	Entrypoint string   `json:"entrypoint"`
	Arguments  []string `json:"arguments"`
}

// --- System ---

// VersionResponse is the body of GET /version.
type VersionResponse struct {
	Version       string `json:"Version"`
	APIVersion    string `json:"ApiVersion"`
	MinAPIVersion string `json:"MinAPIVersion"`
	GitCommit     string `json:"GitCommit"`
	GoVersion     string `json:"GoVersion"`
	Os            string `json:"Os"`
	Arch          string `json:"Arch"`
	KernelVersion string `json:"KernelVersion"`
	BuildTime     string `json:"BuildTime"`
}

// InfoResponse is a trimmed body for GET /info.
type InfoResponse struct {
	ID                 string `json:"ID"`
	Containers         int    `json:"Containers"`
	ContainersRunning  int    `json:"ContainersRunning"`
	ContainersStopped  int    `json:"ContainersStopped"`
	Images             int    `json:"Images"`
	Driver             string `json:"Driver"`
	MemoryLimit        bool   `json:"MemoryLimit"`
	SwapLimit          bool   `json:"SwapLimit"`
	KernelVersion      string `json:"KernelVersion"`
	OperatingSystem    string `json:"OperatingSystem"`
	OSType             string `json:"OSType"`
	Architecture       string `json:"Architecture"`
	NCPU               int    `json:"NCPU"`
	MemTotal           int64  `json:"MemTotal"`
	DockerRootDir      string `json:"DockerRootDir"`
	ServerVersion      string `json:"ServerVersion"`
}

// ErrorResponse is the standard Docker API error body.
type ErrorResponse struct {
	Message string `json:"message"`
}

// execRecord tracks an in-flight or completed exec instance.
type execRecord struct {
	ID          string
	ContainerID string
	Cmd         []string
	Tty         bool
	Env         []string
	ExitCode    int
	Running     bool
	StartedAt   time.Time
}
