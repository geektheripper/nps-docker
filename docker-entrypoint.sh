#!/bin/sh

conf_files=$(find /etc/nps-docker -name '*.conf')

for file in $conf_files; do
  while read line || [ -n "$line" ]; do
    eval echo "$line"
  done < "$file">"/etc/nps/conf/$(basename $file)"
done

nps_config_source=/etc/nps-docker/nps.conf
npc_config_source=/etc/nps-docker/npc.conf

npc_config=/etc/nps/conf/npc.conf

mkdir -p /var/log/nps/
touch /var/log/nps/nps.log

tail_log() {
  tail -f /var/log/nps/nps.log
}

run_nps() {
  case $NPS_MODE in
    npc|nps-client)
      npc -config $npc_config
      return 0
      ;;
    nps|nps-server)
      nps start && tail_log
      return 0
      ;;
    both)
      npc -c $npc_config
      nps start && tail_log
      return 0
      ;;
    *)
      if [ ! -f $npc_config_source ] && [ ! -f $nps_config_source ]; then
        if [ ! -z $NPS_SERVER ] && [ ! -z $NPS_VKEY ]; then
          npc -server=$NPS_SERVER -vkey=$NPS_VKEY -type=${NPC_TYPE:-tcp}
        else
          echo "Error: config file not found"
          return 1
        fi
      fi
      echo "\$NPS_MODE not set, run as existed config file"
      [ -f $npc_config_source ] && npc -config $npc_config
      [ -f $nps_config_source ] && nps start && tail_log
      return 0
      ;;
  esac
}

run_nps
