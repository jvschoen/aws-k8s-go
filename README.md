1. Set Up EKS Cluster with Terraform, files in `eks-tf`:
    - `provider.tf`
    - `vpc.tf`
    - `iam.tf`
    - `eks-cluster.tf`
    - `worker-nodes.tf`
    - `outputs.tf`
2. Configure `kubectl`
3. Set up IAM roles policies to allow EKS to interact with AWS Services

# Terraform
1. Install For Mac**:
```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

2. Execute Build
```
terraform init
terraform validate
terraform apply
```

# Kubectl
1. Configure `kubectl` to use the cluster
```
aws eks --region us-west-2 update-kubeconfig --name eks-cluster
```
Verify:
```
kubectl get nodes
```

# HTTP Endpoint (Go)
1. Download Go:
- https://go.dev/dl/go1.23.0.darwin-arm64.pkg

# K8s + Helm
- the `k8s/deployment.yaml` is a streamlined single file approach
- the `helm/telemetry-api` dir uses helm for organizing the service and deployments
```
brew install helm
cd helm
helm create telemetry-api
```