#!/bin/bash -e

usage()
{
    echo -e "\nUsage: $(basename $0) [-auto-approve <auto approve terraform destroy (default = prompt for approval)>]"
    exit 1
} 

autoapprove=false
while [[ $# -gt 0 ]]
do
   key="$1"
   case $key in
      -auto-approve)
         autoapprove=true
         shift;
      ;;
      *)
         usage
         shift;
      ;;
   esac
done

pushd ../terraform > /dev/null
if [ "$autoapprove" = true  ]; then
       terraform destroy -auto-approve -parallelism=30
else  
       terraform destroy -parallelism=30
fi 
popd > /dev/null