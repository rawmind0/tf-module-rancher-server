# Create rancher-installer service account
resource "kubernetes_service_account" "rancher_installer" {
  metadata {
    name      = "rancher-intaller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

# Bind rancher-intall service account to cluster-admin
resource "kubernetes_cluster_role_binding" "rancher_installer_admin" {
  metadata {
    name = "${kubernetes_service_account.rancher_installer.metadata[0].name}-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rancher_installer.metadata[0].name
    namespace = "kube-system"
  }
}

# Create and run job to install cert-manager CRDs
resource "kubernetes_job" "install_cert_manager_crds" {
  depends_on = [kubernetes_cluster_role_binding.rancher_installer_admin]

  metadata {
    name      = "install-certmanager-crds"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = var.kubectl_image
          command = ["kubectl", "apply", "-f", var.cert_manager.crd_url]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.rancher_installer.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
  provisioner "local-exec" {
    command = "sleep 30s"
  }
}

# Create cert-manager namespace
resource "kubernetes_job" "create_cert_manager_ns" {
  depends_on = [kubernetes_job.install_cert_manager_crds]

  metadata {
    name      = "create-cert-manager-ns"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = var.kubectl_image
          command = ["kubectl", "create", "namespace", var.cert_manager.ns]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.rancher_installer.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
  provisioner "local-exec" {
    command = "sleep 30s"
  }
}

# Create cattle-system namespace for Rancher
resource "kubernetes_job" "create_cattle_system_ns" {
  depends_on = [kubernetes_job.create_cert_manager_ns]

  metadata {
    name      = "create-cattle-system-ns"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = var.kubectl_image
          command = ["kubectl", "create", "namespace", var.rancher_server.ns]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.rancher_installer.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
  provisioner "local-exec" {
    command = "sleep 30s"
  }
}
