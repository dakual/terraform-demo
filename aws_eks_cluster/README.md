```sh
aws eks update-kubeconfig --region eu-central-1 --name test
```

```sh
KUBE_EDITOR="nano" kubectl edit configmap aws-auth -n kube-system

mapUsers: |
  - userarn: arn:aws:iam::632296647497:root
    groups:
    - system:masters
```