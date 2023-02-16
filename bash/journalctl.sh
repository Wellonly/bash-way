#!/bin/bash

function journal-today() {
    sudo journalctl -S today -f "$@"
}

