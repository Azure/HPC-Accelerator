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

pssh -p 50 -t 0 -i -h hostlists/tags/$tag "cd azhpc_install_config_pyxis_enroot; test -f marker-"'$(hostname)'"-07-cc_install_managed_identity && echo 'script already run' || ( sudo scripts/cc_install_managed_identity.sh 'cycleserver' 'hpcadmin' '+ODgyZjBiOWUwOWQ4' 'jrs02' '8' && ( touch marker-"'$(hostname)'"-07-cc_install_managed_identity || true ) ) " >> install/07_cc_install_managed_identity.log 2>&1
