# Install cert-manager helm chart
resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_job.create_cert_manager_ns,
  ]

  repository = data.helm_repository.cert_manager.metadata[0].name
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = var.cert_manager.version
  namespace  = var.cert_manager.ns

  dynamic set {
    for_each = var.cert_manager.chart_set
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

# Install Rancher helm chart
resource "helm_release" "rancher_server" {
  depends_on = [
    kubernetes_job.create_cattle_system_ns,
    helm_release.cert_manager,
  ]

  repository = data.helm_repository.rancher.metadata[0].name
  name       = "rancher"
  chart      = "rancher"
  version    = var.rancher_server.version
  namespace  = var.rancher_server.ns

  set {
    name  = "hostname"
    value = var.rancher_hostname
  }

  set {
    name  = "replicas"
    value = var.rancher_replicas
  }

  dynamic set {
    for_each = var.rancher_server.chart_set
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}


  