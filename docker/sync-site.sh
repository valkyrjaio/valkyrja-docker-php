#!/bin/bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#

syncDir="/var/www/sync"
siteDir="/var/www/site"

echo -e "\e[96mCopying sync to site\e[0m"
rm -rf $siteDir
cp -r $syncDir $siteDir
chmod -R 777 "${siteDir}/storage"
