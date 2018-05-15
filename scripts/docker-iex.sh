#!/bin/bash

set -e

docker exec -it $(docker ps | grep "uelli_main" | awk '{print $1;}') /app/scripts/remote-iex.sh
