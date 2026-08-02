#!/bin/bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#

docker exec valkyrja_docker service php7.1-fpm start
docker exec valkyrja_docker service nginx restart

#docker exec valkyrja_docker ./var/www/sync-site.sh
#docker exec valkyrja_docker ./var/www/sync.sh
