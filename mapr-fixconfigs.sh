#!/bin/bash

source mapr-fixconfigs.conf

###-SED-ARGUMENTS-FUNCTIONS-###
SED_SEPARATOR='/'
KEY_ESCAPE_ARG='s/[]\/'${SED_SEPARATOR}'$*.^|[]/\\&/g'
function sed_keyword_escape() {
    echo $1 | sed -e ${KEY_ESCAPE_ARG}
}
ESCAPED_SED_SEPARATOR=$(sed_keyword_escape $SED_SEPARATOR)
REPL_ESCAPE_ARG='s/['${ESCAPED_SED_SEPARATOR}'&]/\\&/g'
function sed_repl_esc() {
# sed_replacement_escape
    echo $1 | sed -e ${REPL_ESCAPE_ARG}
}

containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

containsElement "$(hostname)" "${cldb_nodes[@]}"
if [ $? -ne 0 ]; then
  services_string="services=nfs:all:fileserver;fileserver:all;hoststats:all:fileserver"
  is_cldb=false
else
  services_string="services=webserver:all:cldb;nfs:all:cldb;kvstore:all;cldb:all:kvstore;hoststats:all:kvstore"
  is_cldb=true
fi

# Copy files that conf.new doesn't create
cp ${conf_dir}.old/clusterid ${conf_dir}
cp ${conf_dir}.old/disktab ${conf_dir}
cp ${conf_dir}.old/mapr-clusters.conf ${conf_dir}

# Copy files not requiring sed
cp ${conf_dir}.old/cldb.conf ${conf_dir}

# Fix env.sh
sed -i.bak \
  -e "s/^#export MAPR_SUBNETS=.*/export MAPR_SUBNETS=$(sed_repl_esc ${mapr_subnet})/" \
  $conf_dir/env.sh

# Fix mapr.login.conf
sed -i.bak \
  -e "s/SUBSTITUTE_CLUSTER_NAME_HERE/${cluster_name}/" \
  -e "s/SUBSTITUTE_FQDN_HERE/$(hostname -f)/" \
  $conf_dir/mapr.login.conf

# Fix warden.conf
sed -i.bak \
  -e "s/services=.*/$(sed_repl_esc ${services_string})/" \
  -e "s/zookeeper.servers=.*/zookeeper.servers=$(sed_repl_esc ${zk_string})/" \
  -e "s/^service.command.mfs.heapsize.percent=.*/service.command.mfs.heapsize.percent=${mfs_heapsize_percent}/" \
  -e "s/^service.command.mfs.heapsize.maxpercent=.*/service.command.mfs.heapsize.maxpercent=${mfs_heapsize_maxpercent}/" \
  $conf_warden

# Fix mapred.tasktracker.ephemeral.tasks.ulimit in mapred-site.xml
sed -i.bak \
  -e "s/4294967296>/4294967296/" \
  $mapr_dir/hadoop/hadoop-0.20.2/conf/mapred-site.xml
