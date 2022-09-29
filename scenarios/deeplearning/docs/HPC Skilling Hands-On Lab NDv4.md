# HPC Skilling Hands-On Lab

Large Scale Deep Learning Hands On Lab for NDv4 VM Series

# Intended Use

 These hands-on exercises are intended to *follow* the presentation on large-scale Deep Learning.

 Refer to the presentation for:

·    Knowledge, skills and objectives

·    An introduction to the NDv4 VM on Azure

 # Prerequisites

This lab will leverage Codespaces to perform the module. To learn more about Codespaces, go to [GitHub Codespaces Documentation - GitHub Docs](https://docs.github.com/en/codespaces).

**Note:** If you cannot use Codespaces, you can use WSL2 with the following tools installed: [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), [Bicep Tools](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

## Running the Labs in Github Codespace

- Go to the GitHub repository for this Lab: [HPC-Accelerator](https://github.com/Azure/HPC-Accelerator)
- Click the `Code` button on this repo
  - Select `Codespaces` tab

![Create Codespace](./images/0-CodespacesTab.png)  

- Click `Create codespace`
- Choose the `2 core` option

![Create Codespace](./images/create-codespace.png)

- If you don't see `Codespaces` tab, you will need to first [link your Microsoft alias to your GitHub account](https://docs.opensource.microsoft.com/github/accounts/linking/) 

![Create Codespace](./images/0-OpenWithCodespaces.jpg)

- Install azure cli `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash` 
- Log in to Azure from a bash or zsh terminal via: `az login --use-device-code`
- Add require additional extension `az extension add --name ssh`
- Accept the terms for CycleCloud Marketplace image `az vm image terms accept --urn azurecyclecloud:azure-cyclecloud:cyclecloud8:latest`
- Proceed to overview 

# Overview

 These hands-on exercises emphasize the development of **skills** in support of the large-scale Deep Learning module. Once complete, a clearer understanding of this scenario is a reasonable outcome, as is the use of GPUs for Deep Learning on Azure.

 After becoming familiar with the NDv4 VM on Azure, the exercises here place emphasis on tuning in a distributed-computing setting. Specifically, use is made here of Azure CycleCloud (see architectural schematic below) to create a Slurm cluster for distributed processing on interconnected NDv4 VMs.

![Orchestration Diagram](./images/clip_image002.jpg)

 Advisory: The NDv4 is a relatively new and extremely powerful offering on Azure. Consequently, it can be a challenge to secure one or more of these VMs for the purpose of working through these exercises. Although there will definitely be some differences and limitations, the NDv2 VMs may serve as a reasonable substitute – e.g., in gaining basic familiarity with isolated to interconnected NVIDIA GPUs on Azure.

 **Procedures**

 The following steps have been identified for this procedure.

 Azure CycleCloud installation will use an User Managed Identity with Contributor access.

1. Deploy the environment solution to a location `westeurope, southcentralus, eastus, eastus2, westus2` and with bicep:
```
region=southcentralus
```
```
cd scenarios/deeplearning/code/bicep/
az deployment sub create -l $region --template-file deploy.bicep
```

**Note**.You need to specify: 
- prefix
- virtualMachineSize (Standard_D2s_v4)
- adminUsername
- adminPassword

![Bicep deployment](./images/bicep_deployment01.png)

2. After the deployment has been completed you need to login to the CycleCloud VM using Azure Bastion throught ssh.

Note: Please replace jcodespace and ccadmin with you own used on the bicep deployment.

```
PREFIX=codespace01
myuser=ccadmin
```
```
VMID=$(az vm show --resource-group $PREFIX-rg --name $PREFIX-vm-cc --query id -o tsv)
az network bastion ssh --name $PREFIX-bastion --resource-group $PREFIX-rg --auth-type password --target-resource-id $VMID --username $myuser
```

3. Once in the cyclecloud server you need to execute a script that will create a slurm custom cluster template with Nvidia NGC containers:

Note: Please replace ccadmin and S3tu9P@ssw0rd with you own credentials use on the bicep deployment.

```
myuser=ccadmin
mypass=S3tu9P@ssw0rd
PREFIX=codespace01
region=southcentralus
```
```
wget https://raw.githubusercontent.com/Azure/HPC-Accelerator/main/scenarios/deeplearning/code/script/createclustertemp.sh
chmod u+x createclustertemp.sh ; ./createclustertemp.sh $myuser $mypass $PREFIX $region
```

![Upload completed](./images/cc-cluster-template.png)

Make sure you have completed the project upload succesfully and have a message like the one on the picture above.

4. Start the Slurm Cluster deeplearning:

  - a.Go to the azure portal and locate the Windows Jumpbox. The VM name will have the following name "prefix"-vm-jb. 
 
  - b.Next Connect to the VM using the Bastion mode. Using the username and passoword you already gave on the deployment process. 

  - c.Using Bastion RDP session open the browser on the remote VM and put the of the "CycleCloud UI IP" that came up in the terminal. 
 
  - d.Log in to Azure CycleCloud using the same credentials on the web GUI.

![Put your username and password.](./images/ui_cc01.png)


  - e.Then click "start" on the cluster.

![Clusters templates.](./images/ui_cc06.png)

### Note. If you don't have access to ND A100 v4 Series (Standard_ND96amsr_A100_v4 or Standard_ND96asr_A100_v4) you would only be able to do succesfully up to step 5. If you have access to NDv2 please jump to step 7.   

5. Configure sshkey, login to Slurm cluster scheduler and run a test job.

  - a.Go back to the ssh terminal and run the following:

Note. My below my username is ccadmin, if you used another username please update commands appropriately.

```
scheduler=$(cyclecloud show_cluster deeplearning |grep -i scheduler|awk '//{print $4}')
sudo ssh -q -o "StrictHostKeyChecking no" -i /opt/cycle_server/.ssh/cyclecloud.pem cyclecloud@$scheduler "sudo cp /shared/home/ccadmin/.ssh/id_rsa ccadminkey; sudo chown cyclecloud ccadminkey"
sudo scp -q -o "StrictHostKeyChecking no" -i /opt/cycle_server/.ssh/cyclecloud.pem cyclecloud@$scheduler:ccadminkey .ssh/id_rsa
sudo chown ccadmin .ssh/id_rsa
ls -l .ssh/id_rsa
```

![Slurm test job.](./images/slurmjob01.png)

  - b.Now ssh to the scheduler node.

 ```
scheduler=$(cyclecloud show_cluster deeplearning |grep -i scheduler|awk '//{print $4}')
ssh -q -o "StrictHostKeyChecking no" $scheduler
 ```

```
wget https://raw.githubusercontent.com/Azure/HPC-Accelerator/main/scenarios/deeplearning/code/script/simpleslurmjob.sh
sbatch simpleslurmjob.sh
```

![Slurm test job.](./images/slurmjob02.png)

![Slurm test job.](./images/slurmjob03.png)

6. Run a nccl check.

  - a.Run the following to submit a test slurm job to the HPC partition but before you bring at least 2 nodes online.

```
sudo /opt/cycle/slurm/resume_program.sh deeplearning-hpc-pg0-[1-2]
```
wget https://raw.githubusercontent.com/Azure/azurehpc/master/experimental/run_nccl_tests_ndv4/run_nccl_tests_slurm_enroot.slrm

- b.Run a script for testing nccl. Then execute the job via Slurm as follows:

```
wget https://raw.githubusercontent.com/Azure/azurehpc/master/experimental/run_nccl_tests_ndv4/run_nccl_tests_slurm_enroot.slrm

chmod +x run_nccl_tests_slurm_enroot.slrm

sbatch -N 2 -p hpc ./run_nccl_tests_slurm_enroot.slrm

```

 By running a NCCL allreduce and/or alltoall benchmark (as above), at the scale you plan on running your deep learning training job, you have arrived at a great way to identify problems with the InfiniBand inter-node network or with NCCL performance.

 For additional details, consult the performance considerations blog post [here](https://techcommunity.microsoft.com/t5/azure-global/performance-considerations-for-large-scale-deep-learning/ba-p/2693834).**
For futher detatils on Production deployment please review blog post [here]
https://techcommunity.microsoft.com/t5/azure-global/e2e-deployment-of-a-production-ready-ndv4-a100-cluster-targeting/ba-p/3580003

**Optional: Cleanup**

If you want to clean up the environment, you can run the destroy script to complete this as a final step.

To delete your files, run destroy script. While the destroy script is running, that will ask for approval. Enter yes to accept.

Output: All the resources are deleted in the resource group.

<u>***Schedule cleanup***</u>

To avoid risk of not destroying the files on time, which will result in additional usage costs, you can configure the Destroy script to be run automatically after specific number of days, such as, for example, run the destroy script automatically after 7 days. This can be accomplished using Azure Automation. Refer [this article](https://docs.microsoft.com/en-us/azure/event-grid/ensure-tags-exists-on-new-virtual-machines) for an example scenario.