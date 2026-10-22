#!/bin/bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#

docker exec valkyrja_docker sh -c 'kill -USR2 1'
docker exec valkyrja_docker nginx -s reload

#docker exec valkyrja_docker ./var/www/sync-site.sh
#docker exec valkyrja_docker ./var/www/sync.sh
