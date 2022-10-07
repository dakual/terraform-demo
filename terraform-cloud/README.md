```sh
git init --initial-branch=main
git add .
git commit -m "first commit"
git remote add origin https://github.com/dakual/terraform-cloud.git
git push -u origin main
```

- add new workspace on the "app.terraform.io"
- add aws credentials on the variables

```sh
terraform login
terraform init
terraform apply --auto-approve
```