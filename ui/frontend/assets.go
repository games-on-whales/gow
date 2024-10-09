package frontend

import (
	"embed"
	"encoding/base64"
	"fmt"
	"mime"
	"path/filepath"
	"strings"

	"github.com/wailsapp/wails"
	"github.com/wailsapp/wails/lib/logger"
)

//go:embed build/*
var files embed.FS

type Assets struct {
	log *logger.CustomLogger
}

func (assets *Assets) WailsInit(runtime *wails.Runtime) error {
	assets.log = runtime.Log.New("Containers")
	return nil
}

func (assets *Assets) GetNumbers() []int32 {
	return []int32{1,2,3,4}
}

func (assets *Assets) GetBytes(filename string) ([]byte, error) {
	if strings.HasPrefix(filename, "build") {
		return files.ReadFile(filename)
	} else {
		return files.ReadFile(filepath.Join("build", filename))
	}
}

func (assets *Assets) GetString(filename string) (string, error) {
	data, err := assets.GetBytes(filename)
	if err != nil {
		return "", err
	}

	return string(data), nil
}

func (assets *Assets) GetDataUri(filename string) (string, error) {
	data, err := assets.GetBytes(filename)
	if err != nil {
		assets.log.Errorf("There was an error getting bytes: %s", err)
		return "", err
	}

	mimeType := mime.TypeByExtension(filepath.Ext(filename))
	if mimeType == "" {
		return "", fmt.Errorf("Couldn't get mime type for %s", filename)
	}

	encoded := base64.StdEncoding.EncodeToString(data)
	if mimeType == "" {
		return "", fmt.Errorf("Couldn't encode %s to base64", filename)
	}

	return fmt.Sprintf("data:%s;base64,%s", mimeType, encoded), nil
}


