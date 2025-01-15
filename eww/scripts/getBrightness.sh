#!/usr/bin/env bash

tail -F ${HOME}/.config/eww/scripts/output/brightness -n -1 | cut -d "," -f 4

