#!/bin/bash

while true; do
  change=$(inotifywait -r -e close_write,moved_to,create .)
  change=${change#./ * }
  mocha --compilers coffee:coffee-script/register
done