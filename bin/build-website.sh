#!/bin/bash
set -e

cd website
hugo --gc --minify --cleanDestinationDir

cd ..
bin/build-toml.sh