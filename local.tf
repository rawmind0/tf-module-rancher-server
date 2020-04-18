locals {
  kubectl = "docker run -it --rm ${var.kubectl_image} kubectl --client-certificate -<<EOF\n${var.rancher_k8s.client_certificate}\nEOF --client-key -<<EOF\n${var.rancher_k8s.client_key}\nEOF --certificate-authority -<<EOF\n${var.rancher_k8s.cluster_ca_certificate}\nEOF --server ${var.rancher_k8s.host}"
}