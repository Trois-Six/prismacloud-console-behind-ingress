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

You will then be able to access to Prisma Cloud Compute console from your browser on http://twistlock-console.127.0.0.1.sslip.io/console/ or https://twistlock-console.127.0.0.1.sslip.io/console/.

# To deploy a defender

## First download a manifest created by the console

Go to Prisma Cloud Compute console, eventually set your admin login/password, then eventually set your license.

Then Go to Manage => Defenders => Names, and add SAN for `twistlock-console`, as we are going the internal Kubernetes service to communicate between defenders and the mgmt console.

Then Go to Manage => Defenders => Deploy => Defenders, choose (options not defined were not modified):
- Deployment method: **Orchestrator**
- Choose the orchestrator type: **Kubernetes**
- Choose the name that Defender will use to connect to this console: **twistlock-console**
- Specify a cluster name: **prismacloud**
- Specify a customer docker socket path: **/run/k3s/containerd/containerd.sock**
- Run Defenders as privileged: **off**
- Nodes use Container Runtime Interface (CRI), not Docker: **on**
- Nodes run inside containerized environment: **on**

And now download the YAML manifest.

## Then tweak it a little bit

- Remove the readOnly volumeMount named "passwd"
- Set readOnlyRootFilesystem to false

An apply `kubectl apply -f defender.yml`. You should now have a somewhat working defender.