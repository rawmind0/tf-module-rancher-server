# Cert manager Helm repository
data "helm_repository" "cert_manager" {
  name = "cert_manager"
  url  = "https://charts.jetstack.io"
}

# Rancher Helm repository
data "helm_repository" "rancher" {
  name = "rancher"
  url  = "https://releases.rancher.com/server-charts/${var.rancher_server.branch}"
}
