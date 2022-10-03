#!/bin/bash

# expecting to be in $tmp_dir
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

scripts/cyclecli_install.sh "10.21.1.5" "hpcadmin" "+ODgyZjBiOWUwOWQ4" "8" >> install/08_cyclecli_install.log 2>&1

