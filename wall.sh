#!/bin/bash

while true; do
  mocha $@ --compilers coffee:coffee-script/register
  change=$(inotifywait -r -e close_write,moved_to,create .)
  change=${change#./ * }
done
