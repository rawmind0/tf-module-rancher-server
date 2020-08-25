# Kubernetes provider
provider "kubernetes" {
  host = var.rancher_k8s.host
  client_certificate     = var.rancher_k8s.client_certificate
  client_key             = var.rancher_k8s.client_key
  cluster_ca_certificate = var.rancher_k8s.cluster_ca_certificate

  load_config_file = false
}

# Helm provider
provider "helm" {
  kubernetes {
    host = var.rancher_k8s.host
    client_certificate     = var.rancher_k8s.client_certificate
    client_key             = var.rancher_k8s.client_key
    cluster_ca_certificate = var.rancher_k8s.cluster_ca_certificate

    load_config_file = false
  }
}
