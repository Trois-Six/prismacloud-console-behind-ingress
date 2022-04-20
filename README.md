# How to get Prisma Cloud Compute Mgmt Console behind an ingress in Kubernetes
Following a need from a customer, I did a POC, and you can find here the environment.

If you want to test, you will need
- docker
- k3d
- kubectl

and the Prisma Cloud tar.gz package (```prisma_cloud_compute_edition_*.tar.gz```).

Then you will be able to launch:
```bash
$ ./create_prisma_cloud_env.sh
```

You will then be able to access to Prisma Cloud Compute console from your browser on http://twistlock-console.127.0.0.1.sslip.io/ or https://twistlock-console.127.0.0.1.sslip.io/.
