```sh
aws eks update-kubeconfig --region eu-central-1 --name demo-cluster
```

```sh
# https://aws.amazon.com/tr/premiumsupport/knowledge-center/eks-kubernetes-object-access-error/
kubectl apply -f eks-console-full-access.yaml
KUBE_EDITOR="nano" kubectl edit configmap aws-auth -n kube-system

# for user
mapUsers: |
- userarn: arn:aws:iam::632296647497:user/dev
    username: dev
    groups:
    - system:bootstrappers
    - system:nodes
    - eks-console-dashboard-full-access-group

# for group
mapRoles: |
- rolearn: arn:aws:iam::632296647497:role/testrole
    username: testrole    
    groups:
    - system:bootstrappers
    - system:nodes
    - eks-console-dashboard-full-access-group

mapUsers: |
  - userarn: arn:aws:iam::632296647497:root
    groups:
    - system:masters
```

```sh
# https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
kubectl get pods --all-namespaces | grep -i running | wc -l
kubectl get nodes <node_name> -o json | jq -r '.status.capacity.pods'

N * (M-1) + 2

Where:
N is the number of Elastic Network Interfaces (ENI) of the instance type
M is the number of IP addresses per ENI

As an example, for a t3.small instance, this calculation is 3 * (4-1) + 2 = 11 Pods.
```

```sh
kubectl proxy
kubectl port-forward service/echoserver 8080:http
```