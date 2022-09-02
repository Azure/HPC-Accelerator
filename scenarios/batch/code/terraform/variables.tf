#-- name of the application (resource names will all be prefixed with this string)
variable "prefix" {
  default = "terawedev"
  description = "Prefix to use for selected resources."
  type = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
#  type = list(string)
  type = string
}

variable "address_space" {
  default = ["10.0.0.0/16"]
  description = "Batch pool VNET network address range"
  type = list
}

variable "compute_subnet" {
  default = ["10.0.0.0/20"]
  description = "Batch compute subnet"
  type = list
}

variable "start_task" {
  default = "AzFinSimStartTask.sh"
  description = "Azure Batch Start Task Name"
  type = string
}

variable "vm_size" {
  default = "Standard_D8s_v3"
  type = string
}
variable "max_tasks_per_node" {
  default = "8"
  type = string
}
