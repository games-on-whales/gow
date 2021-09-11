# Terraform AWS deploy

Largely inspired by https://github.com/buildo/terraform-aws-dockercomposehost

```
terraform init
terraform apply
```

```
ssh -i ... ubuntu@<IP>
...
watch tail /var/log/cloud-init-output.log
```