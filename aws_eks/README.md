aws eks --region eu-central-1 update-kubeconfig --name dev-cluster
kubectl get svc

kubectl apply -f 01-example/deployment-01.yml
kubectl get deploy,svc,pods