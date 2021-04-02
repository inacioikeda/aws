# Provisionando Cluster EKS (15 min média)

1. terraform init
2. terraform plan
3. terraform apply --auto-approve
4. mkdir ~\.kube
5. terraform output kubeconfig > ~\.kube\config
6. kubectl cluster-info

# A configuração esta apenas para 1 worker
# Para alterar:

Edit eks-worker.tf

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }