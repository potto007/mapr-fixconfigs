#!/bin/bash

FPM=/Users/potto/dev/fpm/bin/fpm

# TODO: Add better CLI argument parsing

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
#echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -lt 4 ]; then
  echo "Must provide version (-v) and iteration (-i)."
  exit 1
fi

while getopts ":v:i:" opt; do
  case $opt in
    v)
      rpm_version=$OPTARG;;
    i)
      rpm_iteration=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

$FPM -s dir -t rpm -a noarch --rpm-os linux -n mapr-fixconfigs -v $rpm_version --iteration $rpm_iteration --prefix /opt/mapr-fixconfigs --config-files /etc/mapr-fixconfigs.conf --rpm-user mapr --rpm-group mapr --directories /opt/mapr-fixconfigs -m paul@ottoops.com -x package.sh -x ".git/**" -x "**gitignore" -x "**git" -x ".gitignore" -x ".git" mapr-fixconfigs.conf=/etc/ mapr-fixconfigs.sh
