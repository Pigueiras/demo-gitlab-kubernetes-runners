# demo-gitlab-kubernetes-runners

This is a quick (dirty) demo that builds a GitLab instance and a GitLab runner in AWS with
a prebuilt dashboard in Grafana to monitor CPU/RAM/Network/Disk utilization.

Terraform will:

1. Build two virtual machines in AWS
2. Install with a GitLab Enterprise instance in one of the VM
3. Install K3s and Helm in the other VM
4. Add Prometheus, Grafana to K3s, and connect a K8s GitLab runner to the GitLab instance

## Requirements

- `~/.aws/credentials` with
```
aws_access_key_id = XXXX
aws_secret_access_key = YYYY
```
- You need to have `ansible` installed in your computer

## How to apply the terraform code in this repository?

It takes around ~20 minutes to create everything. Do this (specifying your IP,
it will be used to add security groups to restrict the access to only your IP in
aws):

```console
$ cd terraform/
$ time terraform apply -auto-approve -var="myip=A.B.C.D"
...
Outputs:

gitlab-public-dns = "<node1>.compute-1.amazonaws.com"
kubernetes-public-dns = "<node2>.compute-1.amazonaws.com"

________________________________________________________
Executed in   19.39 mins    fish           external
   usr time   74.12 secs   75.00 micros   74.12 secs
   sys time   13.49 secs  829.00 micros   13.49 secs
```

Using the outputs access Grafana and Gitlab using:
- GitLab: http://\<gitlab-public-dns>. User: `root` and password: `mydemo123`
- Grafana (exposed via NodePort in 31000): http://\<kubernetes-public-dns>:31000. User: `admin` and password: `mydemo123`. There is a dashboard included in Grafana to visualize the metrics from the CI jobs.
