#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )/.."

tag=linux

if [ ! -f "hostlists/$tag" ]; then
    echo "no hostlist ($tag), exiting"
    exit 0
fi

if [ "$1" != "" ]; then
    tag=tags/$1
else
    retry=0
    while ! rpm -q epel-release
    do
        if ! sudo yum install -y epel-release >> install/00_install_node_setup.log 2>&1
        then
            if [ "$retry" -eq "10" ]; then
                echo "ERROR: Unable to install epel-release package after 10 retries"
                exit 1
            fi
            sleep 10
            sudo yum clean metadata
            retry=$(($retry + 1))
        fi
    done
    sudo yum install -y pssh nc >> install/00_install_node_setup.log 2>&1

    # setting up keys
    cat <<EOF > ~/.ssh/config
    Host *
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        LogLevel ERROR
EOF
    cp hpcadmin_id_rsa.pub ~/.ssh/id_rsa.pub
    cp hpcadmin_id_rsa ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/config
    chmod 644 ~/.ssh/id_rsa.pub

fi

# check sshd is up on all nodes
for h in $(<hostlists/$tag); do
    retry=0
    until ssh $h hostname >/dev/null 2>&1; do
        if [ "$retry" -eq "10" ]; then
            echo "ERROR: Unable to contact $h after 10 retries"
            exit 1
        fi
        echo "Waiting for sshd on host - $h (sleeping for 10 seconds)"
        sleep 10
        retry=$(($retry + 1))
    done
done

pssh -p 50 -t 0 -i -h hostlists/$tag 'rpm -q rsync || sudo yum install -y rsync' >> install/00_install_node_setup.log 2>&1

prsync -p 50 -a -h hostlists/$tag ~/azhpc_install_config_pyxis_enroot ~ >> install/00_install_node_setup.log 2>&1
prsync -p 50 -a -h hostlists/$tag ~/.ssh ~ >> install/00_install_node_setup.log 2>&1

pssh -p 50 -t 0 -i -h hostlists/$tag 'echo "AcceptEnv PSSH_NODENUM PSSH_HOST" | sudo tee -a /etc/ssh/sshd_config' >> install/00_install_node_setup.log 2>&1
pssh -p 50 -t 0 -i -h hostlists/$tag 'sudo systemctl restart sshd' >> install/00_install_node_setup.log 2>&1
pssh -p 50 -t 0 -i -h hostlists/$tag "echo 'Defaults env_keep += \"PSSH_NODENUM PSSH_HOST\"' | sudo tee -a /etc/sudoers" >> install/00_install_node_setup.log 2>&1
