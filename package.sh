#!/bin/bash

fpm -s dir -t rpm -a noarch -n mapr-fixconfigs -v 0.1 --iteration 1 --config-files /etc/mapr-fixconfigs.conf --prefix /opt/mapr-fixconfigs --rpm-user mapr --rpm-group mapr --directories /opt/mapr-fixconfigs -m paul@ottoops.com -x package.sh -x ".git/**" -x "**gitignore" -x "**git" -x ".gitignore" -x ".git" mapr-fixconfigs.conf=/etc/ mapr-fixconfigs.sh
