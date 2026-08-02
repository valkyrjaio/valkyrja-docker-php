#!/bin/bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#

./stop.sh

# Remove all images
docker rm $(docker ps -a -q)

# Remove all networks
docker network rm $(docker network ls -q)
