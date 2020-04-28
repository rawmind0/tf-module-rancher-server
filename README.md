# Rancher HA server terraform module 

Terraform module for installing Rancher HA on a K8s cluster. 

Module will do following tasks:
- Connect to k8s cluster
- Create cert-manager and rancher namespaces
- Configure cert-manager and rancher helm repositories
- Install cert-manager and rancher helm charts

## Variables

### Input

This module accept the following variables as input:

```
# Required variables
variable "rancher_hostname" {
	type = string
	description = "Rancher server hostname to set on deployment"
}

variable "rancher_k8s" {
  type = object({
    host = string
    client_certificate = string
    client_key = string
    cluster_ca_certificate = string
  })
  description = "K8s cluster client configuration"
}

# Optional variables 
variable "cert_manager" {
  default = {
    ns = "cert-manager"
    version = "v0.14.2"
    crd_url = "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml"
    chart_set = []
  }
  description = "Cert-manager helm chart properties. Chart sets can be added using chart_set param"
}

variable "rancher_server" {
  default = {
    ns = "cattle-system"
    version = "v2.4.2"
    branch = "latest"
    chart_set = []
  }
  description = "Rancher server helm chart properties. Chart sets can be added using chart_set param"
}

variable "rancher_replicas" {
  type = number
  description = "Rancher server replicas to set on deployment"
  default = 3
}

variable "kubectl_image" {
  default     = "bitnami/kubectl:1.17.4"
  description = "Kubectl docker image"
}
```

### Output

This module use the following variables as ouput:

```
output "rancher_server_url" {
  value = "https://${var.rancher_hostname}"
}
```

## How to use

This tf module can be used standalone or combined with other tf modules.

Requirements for use standalone:
* K8s cluster up and running
* Rancher hostname

Add the following to your tf file:

```
module "rancher_server" {
  source = "github.com/rawmind0/tf-module-rancher-server"

  rancher_hostname = "rancher.my.org"
  rancher_k8s = {
    host = module.rke-cluster.kubeconfig_api_server_url
    client_certificate     = module.rke-cluster.kubeconfig_client_cert
    client_key             = module.rke-cluster.kubeconfig_client_key
    cluster_ca_certificate = module.rke-cluster.kubeconfig_ca_crt
  }
}
```

