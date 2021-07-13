package main

import (
	_ "embed"

	"github.com/wailsapp/wails"

	"github.com/gamesonwhales/gow/docker"
	"github.com/gamesonwhales/gow/frontend"
)

func main() {
	// TODO: process index.html to replace href/src with data urls
	// instead of using the JS/CSS embedding
	assets := &frontend.Assets{}
	html, err := assets.GetString("index.html")
	if err != nil {
		panic(err)
	}

	js, err := assets.GetString("bundle.js")
	if err != nil {
		panic(err)
	}

	css, err := assets.GetString("bundle.css")
	if err != nil {
		panic(err)
	}

	app := wails.CreateApp(&wails.AppConfig{
		Title:  "Games on Whales",
		Resizable: true,
		Width:  1024,
		Height: 768,
		HTML:   html,
		JS:     js,
		CSS:    css,
		Colour: "#131313",
	})
	app.Bind(assets)
	app.Bind(&docker.Containers{})
	app.Run()
}
