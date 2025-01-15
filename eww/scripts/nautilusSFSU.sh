#!/usr/bin/env bash

# Opens nautilus terminal in the SFSU directory. Also detaches the process and send warnings to /dev/null
nohup nautilus -w "${HOME}/Desktop/SFSU" > /dev/null &