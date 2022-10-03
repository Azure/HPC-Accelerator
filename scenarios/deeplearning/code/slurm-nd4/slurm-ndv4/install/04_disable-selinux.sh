#!/bin/bash

# expecting to be in $tmp_dir
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

tag=${1:-cycle}

if [ ! -f "hostlists/tags/$tag" ]; then
    echo "    Tag is not assigned to any resource (not running)"
    exit 0
fi

if [ "$(wc -l < hostlists/tags/$tag)" = "0" ]; then
    echo "    Tag does not contain any resources (not running)"
    exit 0
fi

pssh -p 50 -t 0 -i -h hostlists/tags/$tag "cd azhpc_install_config_pyxis_enroot; test -f marker-"'$(hostname)'"-04-disable-selinux && echo 'script already run' || ( sudo scripts/disable-selinux.sh && ( touch marker-"'$(hostname)'"-04-disable-selinux || true ) ) " >> install/04_disable-selinux.log 2>&1
