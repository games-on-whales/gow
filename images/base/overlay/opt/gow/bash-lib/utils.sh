#!/bin/bash

gow_log() {
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $*"
}

join_by() { local IFS="$1"; shift; echo "$*"; }
