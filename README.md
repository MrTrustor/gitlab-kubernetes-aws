# Gitlab on Kubernetes on AWS - with High Availability

This is the source code for the "Gitlab on Kubernetes + AWS" blog post.
If you have a Kubernetes cluster on AWS (maybe created by
[Kops](https://github.com/kubernetes/kops)), this will allow you to create a
highly available Gitlab installation, leveraging two AWS managed services: EFS
and RDS.

References:

* [Gitlab on Kubernetes + AWS](http://blog.mrtrustor.net/post/gitlab-on-k8s/),
  English version,
* [Gitlab on Kubernetes + AWS](http://www.tocomplete.com), version française,
* [Kubernetes sur AWS - Kops](http://blog.mrtrustor.net/post/k8s-aws-kops/),
  English version,
* [Kubernetes sur AWS - Kops](http://www.oxalide.com/2016/11/kubernetes-sur-aws-kops/),
  version française.

## HowTo

**You WILL be charged by AWS for the resources created by this code.** If you
are just testing, the charges should be minimal, but neither Oxalide nor the
maintainers of this code are responsible for your incurred costs.

The code assumes an AWS region with 3 AZ, just delete the code for AZ ``c`` if
you don't need it.

### Terraform

As described in the blog post, you need to import the existing AWS VPC and
subnets used by your K8s cluster in Terraform:

```bash
terraform import aws_vpc.kops_vpc vpc-xxxxxx
terraform import aws_subnet.kops_suba subnet-xxxxxx
terraform import aws_subnet.kops_subb subnet-xxxxxx
terraform import aws_subnet.kops_subc subnet-xxxxxx
```

Once imported, edit the ``terraform/kops.tf`` file to fill the correct values
for your use case (look for ``TO_CHANGE`` comments).
You will also need to change the PostgreSQL password in the
``terraform/gitlab.tf`` file.

When everything is ready, you can create the resources by runnning:

```bash
terraform plan
terraform apply
```

Terraform will output the PostgreSQL server address and the EFS endpoints. Note
them somewhere.

### Kubernetes

You will need to edit the following files with your values:

* ``kubernetes/pv.yml`` for the EFS endpoints,
* ``kubernetes/secrets.yml`` with your base64 encoded secrets (including the
  PostgreSQL password),
* ``kubernetes/gitlab.yml`` with the PostgreSQL endpoint.

When everything is ready, create all the resources by running:

```bash
kubectl apply -f pv.yml \
    -f secrets.yml \
    -f redis.yml \
    -f gitlab-pvc.yml \
    -f gitlab.yml \
    -f gitlab-svc.yml
```

Gitlab will be available through an ELB created by ``gitlab-svc.yml``. The
address of this ELB will be available by running the following command:

```bash
kubectl describe service gitlab
```
