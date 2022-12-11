kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
kubectl get secret kruta.link -o json | jq -r '.data."tls.crt"' | base64 -d
kubectl get secret kruta.link -o json | jq -r '.data."tls.key"' | base64 -d


```yml
# kubectl create secret tls test-tls --key="tls.key" --cert="tls.crt"

apiVersion: v1
data:
  tls.crt:
  tls.key:
kind: Secret
metadata:
  name: test-tls
  namespace: default
type: kubernetes.io/tls
```

```h
resource "kubernetes_secret" "tls" {
   metadata {
     name = "tls"
     namespace = "default"
   }
   type = "tls"
   data = {
     "tls.crt" = var.tlscrt
     "tls.key" = var.tlskey
   }
 }
```