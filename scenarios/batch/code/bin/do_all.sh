#!/bin/bash -e

#-- execute all steps 
./deploy.sh --silent
./build.sh
./generator.sh
./submit.sh
./destroy.sh --silent