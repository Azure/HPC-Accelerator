#!/bin/bash

# expecting to be in $tmp_dir
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

tag=${1:-jumpbox}

if [ ! -f "hostlists/tags/$tag" ]; then
    echo "    Tag is not assigned to any resource (not running)"
    exit 0
fi

if [ "$(wc -l < hostlists/tags/$tag)" = "0" ]; then
    echo "    Tag does not contain any resources (not running)"
    exit 0
fi

pssh -p 50 -t 0 -i -h hostlists/tags/$tag "cd azhpc_install_config_pyxis_enroot; test -f marker-"'$(hostname)'"-03-auto_netappfiles_mount && echo 'script already run' || ( sudo scripts/auto_netappfiles_mount.sh && ( touch marker-"'$(hostname)'"-03-auto_netappfiles_mount || true ) ) " >> install/03_auto_netappfiles_mount.log 2>&1
