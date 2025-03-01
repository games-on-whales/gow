# README

This is an early-stage WIP prototype to test out the tech, make sure the various pieces work together, etc. Nothing is final yet :grin:

To build:
* Install Go 1.16
* Install [Wails](https://github.com/wailsapp/wails/) and dependencies

Then, run:
```console
$ wails build -t src/wails.d.ts -d
```

This will install all of the NPM dependencies, build and bundle the Typescript code, build the Go code, and generate a binary in `./build`.  To launch, run:
```console
$ ./build/games-on-whales
```

I have only tried this on Linux. It will probably not work on Windows because the Webview component is based on IE11 and doesn't support required features.

