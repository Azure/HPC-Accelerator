# HPC + AI Lab

Large Scale Deep Learning Hands On Lab for NDv4 VM Series

# Intended Use

 These hands-on exercises are intended to *follow* the presentation on large-scale Deep Learning.

 Refer to the presentation for:

·    Knowledge, skills and objectives

·    An introduction to the NDv4 VM on Azure

 # Prerequisites

- GitHub CodeSpaces
  - To learn more about Codespaces, go to GitHub Codespaces [Documentation - GitHub Docs](https://docs.github.com/en/codespaces).

OR

- Azure Cloud Shell
  - To learn more about Azure Cloud Shell go to [Overview of Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview).

## Deploying the Lab with Github Codespaces

- Go to the GitHub repository for this Lab: [HPC-Accelerator](https://github.com/Azure/HPC-Accelerator)
- Click the `Code` button on this repo
  - Select `Codespaces` tab

![Create Codespace](./images/0-CodespacesTab.png)

- Click `Create codespace`
- Choose the `2 core` option

![Create Codespace](./images/create-codespace.png)

- If you don't see `Codespaces` tab, you will need to first [link your Microsoft alias to your GitHub account](https://docs.opensource.microsoft.com/github/accounts/linking/)

![Create Codespace](./images/0-OpenWithCodespaces.jpg)

- Install azure cli: </br> 
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
- Log in to Azure from a Bash or SSH terminal utilizing the following command:</br> 
```
az login --tenant 'PASTE YOUR TENANT ID HERE' --use-device-code
```
- Add the required SSH extension by using the following command:</br>
```
az extension add --name ssh
```
- As the deployment is going to be automated through Bicep, we need to accept the terms for Cycle Cloud Marketplace image in advance by running the following command::</br> 
```
az vm image terms accept --urn azurecyclecloud:azure-cyclecloud:cyclecloud8:latest
```
- Proceed to overview </br> 

## Deploying the Lab with Azure Cloud Shell

1. Open Cloud Shell in the portal selecting Bash.
2. Upgrade Bicep:</br>
```
az bicep upgrade
```
3. Login into your Github account:</br>
```
gh auth login
```
4. Follow the instructions to login with the following configuration:

![GitHub Login Setup](./images/0-A-GithubConfig.png)

5. Clone the repository:</br>
```
gh repo clone Azure/HPC-Accelerator
```
6. Switch to the created folder:</br>
```
cd HPC-Accelerator
```
7. As the deployment is going to be automated through Bicep, we need to accept the terms for Cycle Cloud Marketplace image in advance by running the following command:</br>
```
az vm image terms accept --urn azurecyclecloud:azure-cyclecloud:cyclecloud8:latest
```

# Overview

 These hands-on exercises emphasize the development of **skills** in support of the large-scale Deep Learning module. Once complete, a clearer understanding of this scenario is a reasonable outcome, as is the use of GPUs for Deep Learning on Azure.

 After becoming familiar with the NDv4 VM on Azure, the exercises here place emphasis on tuning in a distributed-computing setting. Specifically, use is made here of Azure CycleCloud (see architectural schematic below) to create a Slurm cluster for distributed processing on interconnected NDv4 VMs.

![Orchestration Diagram](./images/clip_image002.jpg)

 Advisory: The NDv4 is a relatively new and extremely powerful offering on Azure. Consequently, it can be a challenge to secure one or more of these VMs for the purpose of working through these exercises. Although there will definitely be some differences and limitations, the NDv2 VMs may serve as a reasonable substitute – e.g., in gaining basic familiarity with isolated to interconnected NVIDIA GPUs on Azure.

 **Procedures**

The following steps have been identified for this procedure.

Azure CycleCloud installation will use an User Managed Identity with Contributor access.

1. Navigate to the directory where the Bicep source code is located by running in the console where you cloned the repo:</br>
```
cd scenarios/deeplearning/code/bicep/
```

2. Then we are going to define the parameters to use in Bicep for the deployment. First, the location of the resources to deploy. The regions available are: *westeurope, southcentralus, eastus, eastus2 and westus2*.</br>
*Notice that:</br>
    i. There are no spaces between the name of the variable and the equal sign.</br>
    ii. Theare are no spaces after the equal sign.</br>
    iii. We are going to use “southcentralus” ONLY for the lab.*</br>
```
region=southcentralus
```

3.  Finally, we proceed with the deployment by running the command below.</br>
*Please Note that the system will require inputting a prefix, username and password for the VMs.*</br>
```
az deployment sub create -l $region --template-file deploy.bicep
```

4. After the deployment has been completed, we need to login to the Cycle Cloud VM using the Azure Bastion Service through SSH by running the commands below.</br>
*Note: Replace the values of the “prefix” and “myuser” with the values you set during the deployment process in the code below.*
```
prefix=bs002

myuser=alpha

VMID=$(az vm show --resource-group $prefix-rg --name $prefix-vm-cc --query id -o tsv)

az network bastion ssh --name $prefix-bastion --resource-group $prefix-rg --auth-type password --target-resource-id $VMID --username $myuser
```
5. Once in the Cycle Cloud server you need to execute a script that will create a Slurm custom cluster template with Nvidia NGC containers running the code below.</br>
*Note: Replace the values of “myuser”, “maypass”, “prefix” and “region” variables with the ones you set during the deployment process.*</br>
```
myuser=alpha

mypass=Password1

prefix=bs002

region=southcentralus

wget https://raw.githubusercontent.com/Azure/HPC-Accelerator/main/scenarios/deeplearning/code/script/createclustertemp.sh

chmod u+x createclustertemp.sh ; ./createclustertemp.sh $myuser $mypass $prefix $region
```

![Upload completed](./images/cc-cluster-template.png)

Verify that you have completed the project upload successfully and have a message like the one on the picture above showing the private IP of the Cycle Cloud Portal


6. Start the Slurm Cluster deeplearning:

    i. Go to the azure portal and locate the Windows Jumpbox. The VM name will have the following name "prefix"-vm-jb.

    ii. Connect to the VM going to Operations>Bastion  and then input the username and password set during the deployment process.

    iii. Once in the Bastion session opened in the new tab, open Microsoft Edge and type the Cycle Cloud private IP obtained during the deployment process that showed up in the terminal.
 
    iv. Log in to Azure Cycle Cloud using the same credentials on the web GUI.

    ![Put your username and password.](./images/ui_cc01.png)

    v. Then click "start" on the cluster.

    ![Clusters templates.](./images/ui_cc06.png)

7. While we still have the SSH session open in Cycle Cloud using the Bastion Host, we are going to create a pair of SSHKeys to run a test job.</br>
*Note: Make sure to replace “USERNAME” with the username you used during the deployment.*</br>

```
scheduler=$(cyclecloud show_cluster deeplearning |grep -i scheduler|awk '//{print $4}')

sudo ssh -q -o "StrictHostKeyChecking no" -i /opt/cycle_server/.ssh/cyclecloud.pem cyclecloud@$scheduler "sudo cp /shared/home/USERNAME/.ssh/id_rsa USERNAMEkey;sudo chown cyclecloud USERNAMEkey"

sudo scp -q -o "StrictHostKeyChecking no" -i /opt/cycle_server/.ssh/cyclecloud.pem cyclecloud@$scheduler: USERNAMEkey .ssh/id_rsa

sudo chown USERNAME .ssh/id_rsa

ls -l .ssh/id_rsa
```

![Slurm test job.](./images/slurmjob01.png)


8. After that configuration is done, we are going to run the scheduler to test the configuration of Cycle Cloud utilizing the following code:

```
scheduler=$(cyclecloud show_cluster deeplearning |grep -i scheduler|awk '//{print $4}')

ssh -q -o "StrictHostKeyChecking no" $scheduler

wget https://raw.githubusercontent.com/Azure/HPC-Accelerator/main/scenarios/deeplearning/code/script/simpleslurmjob.sh

sbatch simpleslurmjob.sh
```

i. After you run the commands above, Azure Cycle Cloud will show “Creating VM” like the image shown below:</br>

![Slurm test job.](./images/slurmjob02.png)</br>

ii. Wait until the process finishes to continue.</br>

## Running a NCCL test

i. First, we make sure that the nodes are active and ready by running.

```
sudo /opt/cycle/slurm/resume_program.sh deeplearning-hpc-pg0-[1-2]
```

ii. Then we download the script that we are going to use during the test.

```
wget https://raw.githubusercontent.com/Azure/azurehpc/master/experimental/run_nccl_tests_ndv4/run_nccl_tests_slurm_enroot.slrm
```
iii. Finally, we provide permissions to the file and execute the batch process that will run the SLURM test file.

```
chmod +x run_nccl_tests_slurm_enroot.slrm

sbatch -N 2 -p htc ./run_nccl_tests_slurm_enroot.slrm
```

 By running a NCCL allreduce and/or alltoall benchmark (as above), at the scale you plan on running your deep learning training job, you have arrived at a great way to identify problems with the InfiniBand inter-node network or with NCCL performance.

 For additional details, consult the performance considerations blog post [here](https://techcommunity.microsoft.com/t5/azure-global/performance-considerations-for-large-scale-deep-learning/ba-p/2693834).

For futher detatils on Production deployment please review blog post [here](
https://techcommunity.microsoft.com/t5/azure-global/e2e-deployment-of-a-production-ready-ndv4-a100-cluster-targeting/ba-p/3580003).

##  OPTIONAL

Running a NCCL test check for NDv2 series.</br>

1. Click on the Tab for "Array", then select the "hpc" name for the nodearray, then click the "edit" so you can edit the current configuration for that node array.

![Slurm Ndv4 job.](./images/edit-nodearray.png)

 2. Replace the '$HPCMachineType' with 'Standard_ND40rs_v2'.

![Slurm Ndv4 job.](./images/edit-machinetype.png)

3. Then go to the bottom of that window and expand the section called “Other Settings”.

In that window go to the bottom and click on the + button to add the “ClusterInitSpecs” text box as shown below and paste the following text on it:

```
=['slurm:default'=[Order=1000;Name="cyclecloud/slurm:default:2.6.4";Spec="default";Project="slurm";Version="2.6.4";SourceLocker="cyclecloud";Optional=true];'slurm_pyxis_enroot:default:1.0.0'=[Order=10010;Name="slurm_pyxis_enroot:default:1.0.0";Spec="default";Project="slurm_pyxis_enroot";Version="1.0.0";Locker="azure-storage";AdditionalSpec=true];'misc_ndv4:default:1.0.0'=[Order=10000;Name="misc_ndv4:default:1.0.0";Spec="default";Project="misc_ndv4";Version="1.0.0";Locker="azure-storage";AdditionalSpec=true];'slurm:execute'=[Order=1003;Name="cyclecloud/slurm:execute:2.6.4";Spec="execute";Project="slurm";Version="2.6.4";SourceLocker="cyclecloud"]]
```

![Slurm Ndv4 job.](./images/edit-clusterinispec.png)

4. Go back to the Linux shell on the scheduler and execute the code below.
```
sudo /opt/cycle/slurm/cyclecloud_slurm.sh scale
```
You should see a message like the picture below. 

![Slurm Ndv4 job.](./images/edit-cmdmsg.png)

Now you are ready to run another NCCL test.
Run the CMDs below to download the job script and submit the SLURM pyxis job.

```
wget https://raw.githubusercontent.com/Azure/HPC-Accelerator/main/scenarios/deeplearning/code/nccl%20test%20ND40rs_v2/run_nccl_tests_slurm_enroot.slrm

chmod +x run_nccl_tests_slurm_enroot.slrm

sbatch -N 1 -p hpc ./run_nccl_tests_slurm_enroot.slrm
```

## Clean up

If you want to clean up the environment, you can delete the resource group created on the portal. If you want to retain the cycle cloud deployment for future use, then just terminate the cluster at the Cycle Cloud UI.

***
Revised 11/28/2022 by Brian Santacruz