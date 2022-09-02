#-- Upload the batch start task (must be in ../src)
resource "azurerm_storage_blob" "start_task" {
  name                   = var.start_task
  storage_account_name   = azurerm_storage_account.azfinsim.name
  storage_container_name = azurerm_storage_container.azfinsim.name
  type                   = "Block"
  source                 = format("../src/%s",var.start_task)
}

#-- Azure Batch Account Configuration
resource "azurerm_batch_account" "azfinsim" {
  name                 = format("%sbatch", var.prefix)
  resource_group_name  = azurerm_resource_group.azfinsim.name
  location             = azurerm_resource_group.azfinsim.location
#  pool_allocation_mode = "BatchService"
  pool_allocation_mode = "UserSubscription"
  storage_account_id   = azurerm_storage_account.azfinsim.id
  key_vault_reference {
    id                 = azurerm_key_vault.azfinsim.id
    url                = azurerm_key_vault.azfinsim.vault_uri
  }
  tags                 = local.resource_tags
}

#-- Autoscaling Batch Pool
resource "azurerm_batch_pool" "autoscale" {
  name                = format("%s-batch-pool", var.prefix)
  resource_group_name = azurerm_resource_group.azfinsim.name
  account_name        = azurerm_batch_account.azfinsim.name
  display_name        = "AzFinSim Batch Pool"
  vm_size             = var.vm_size
  max_tasks_per_node  = var.max_tasks_per_node
  node_agent_sku_id   = "batch.node.ubuntu 20.04"
  
  network_configuration {
    subnet_id         = azurerm_subnet.azfinsim.id
  }

  auto_scale {
    #-- defaults to 15 minutes; set to 5 minutes: 
    evaluation_interval = "PT5M"

    formula = <<EOF
      startingNumberOfVMs = 0;
      maxNumberofVMs = 200;
      pendingTaskSamplePercent = $PendingTasks.GetSamplePercent(180 * TimeInterval_Second);
      pendingTaskSamples = pendingTaskSamplePercent < 70 ? startingNumberOfVMs : avg($PendingTasks.GetSample(180 *   TimeInterval_Second));
      $TargetDedicatedNodes=min(maxNumberofVMs, pendingTaskSamples);
      $NodeDeallocationOption=taskcompletion 
EOF

  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }

  container_configuration {
    type = "DockerCompatible"
    container_registries {
      registry_server = azurerm_container_registry.azfinsim.login_server
      user_name       = azurerm_container_registry.azfinsim.admin_username
      password        = azurerm_container_registry.azfinsim.admin_password
    }
    # define if container image already exists, and you want it installed at pool creation
    #    container_image_names = [ "" ]
  }


  start_task {
    #    command_line = "/bin/bash -c './AzFinSimStartTask.sh'"
    command_line         = format("/bin/bash -c './%s'", var.start_task)
    #max_task_retry_count = 1
    wait_for_success     = true
    #environment = {
      #APP_INSIGHTS_APP_ID              = azurerm_application_insights.azfinsim.app_id
      #APP_INSIGHTS_INSTRUMENTATION_KEY = azurerm_application_insights.azfinsim.instrumentation_key
      #BATCH_INSIGHTS_DOWNLOAD_URL      = "https://github.com/Azure/batch-insights/releases/download/v1.3.0/batch-insights"
    #}
    user_identity {
      auto_user {
        elevation_level = "Admin"
        scope           = "Pool"
      }
    }
    resource_file {
      file_path = var.start_task
      http_url  = format("%s%s", azurerm_storage_blob.start_task.url, data.azurerm_storage_account_blob_container_sas.azfinsim.sas)
    }
  }
}

#-- Static Realtime Calculation Pool - Manual Resize
resource "azurerm_batch_pool" "realtimestatic" {
  name                = format("%s-realtime-pool", var.prefix)
  resource_group_name = azurerm_resource_group.azfinsim.name
  account_name        = azurerm_batch_account.azfinsim.name
  display_name        = "AzFinSim Realtime Pool"
  vm_size             = var.vm_size
  max_tasks_per_node  = var.max_tasks_per_node
  node_agent_sku_id   = "batch.node.ubuntu 20.04"

  fixed_scale {
    target_dedicated_nodes    = 0
    target_low_priority_nodes = 0
    resize_timeout            = "PT5M"
  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }

  container_configuration {
    type = "DockerCompatible"
    container_registries {
      registry_server = azurerm_container_registry.azfinsim.login_server
      user_name       = azurerm_container_registry.azfinsim.admin_username
      password        = azurerm_container_registry.azfinsim.admin_password
    }
    # define if container image already exists, and you want it installed at pool creation
    #    container_image_names = [ "" ]
  }

  start_task {
    #    command_line = "/bin/bash -c './AzFinSimStartTask.sh'"
    command_line         = format("/bin/bash -c './%s'", var.start_task)
    #max_task_retry_count = 1
    wait_for_success     = true
    #environment = {
      #APP_INSIGHTS_APP_ID              = azurerm_application_insights.azfinsim.app_id
      #APP_INSIGHTS_INSTRUMENTATION_KEY = azurerm_application_insights.azfinsim.instrumentation_key
      #BATCH_INSIGHTS_DOWNLOAD_URL      = "https://github.com/Azure/batch-insights/releases/download/v1.3.0/batch-insights"
    #}
    user_identity {
      auto_user {
        elevation_level = "Admin"
        scope           = "Pool"
      }
    }
    resource_file {
      file_path = var.start_task
      http_url  = format("%s%s", azurerm_storage_blob.start_task.url, data.azurerm_storage_account_blob_container_sas.azfinsim.sas)
    }
  }
}
