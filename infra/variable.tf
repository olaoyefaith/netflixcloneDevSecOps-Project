variable "node_count" {
  default = 1
}

variable "dns_prefix" {
  default = "aks-k8s-2022"

}

variable "cluster_name" {

}

variable "kubernetes_version" {

}
variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string

}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}