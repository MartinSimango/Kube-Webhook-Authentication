provider "kind" {}

provider "kubernetes" {
  config_path = pathexpand(var.kind_cluster_config_path)
}

resource "kind_cluster" "default" {
  name            = var.kind_cluster_name
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  node_image = "kindest/node:v1.23.5"
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_address = "127.0.0.1"
      api_server_port = "6443"
    }

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        <<EOT
        kind: InitConfiguration
        nodeRegistration:  
            kubeletExtraArgs:    
              node-labels: "ingress-ready=true"
        EOT
        ,
        <<EOT
        kind: ClusterConfiguration
        apiServer:
          extraArgs:
            authentication-token-webhook-config-file: /etc/kubernetes/pki/authentication/authentication-webhook.yaml        
        EOT
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
      extra_mounts {
        host_path = "../k8s/authentication-webhook.yaml"
        container_path = "/etc/kubernetes/pki/authentication/authentication-webhook.yaml"
      }

      extra_mounts {
          host_path = "../certs/ca.crt"
          container_path = "/usr/local/share/ca-certificates/ca.crt"
      }
      
    }

    node {
      role = "worker"
    }
  }
}