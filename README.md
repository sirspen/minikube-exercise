# Minikube Exercise

This repository contains a Go application that is a simple Hello World application that displays the name of the pod it's running on. The application is contained in a Docker container. A Kubernetes manifest is used to deploy the application to a Minikube cluster behind a load balancer in a new Namespace.

## Prerequisites

- [Docker v20.10.5+](https://docs.docker.com/get-docker/)
- [Minikube v1.19.0+](https://minikube.sigs.k8s.io/docs/start/) - running
- [Kubectl v1.19.7+](https://kubernetes.io/docs/tasks/tools/#kubectl) - configured for Minikube
- [Bash v4.3.4+](https://www.gnu.org/software/bash/)
- [jq 1.5-1-a5b5cbe+](https://stedolan.github.io/jq/download/)

## TL;DR

Use the installer script to build and deploy the hello world application and host it using `minikube service`:

```sh
$ ./install.sh
```

## Docker
### Configure Docker Daemon with Minikube

Docker must be configured to use the Minikube Docker daemon as it has its own. To do this, run:

```sh
$ eval $(minikube -p minikube docker-env)
```

If this step is not run the pods will have a `ImagePullBackOff` error as the docker images will be on the host machines Docker daemon and not Minikubes.

### Build HelloWorld Docker Image

Docker is used to build and run the application. The official `golang` `alpine` docker image is used as the foundation of the image.

```sh
$ docker build -t hello-world:0.0.1 .
```

> NOTE: The kubernetes manifest expects the Docker image to be named `hello-world:0.0.1`. If you change this name or tag, you will need to update the `.spec.template.spec.containers[0].image` field in `k8s/deployment.yaml` file to reflect the change.

You can pass the build arguments `alpine_version` and `go_version` to modify the `alpine` and `golang` version used, respectively. For example if you wanted to use golang version `1.15.11` and alpine version `3.12` you would do:

```sh
$ docker build -t hello-world:0.0.1 --build-arg go_version=1.15.11 --build-arg alpine_version=3.12 .
```

Defaults are set to `alpine 3.13` and `golang 1.16.3`.

## Minikube
### Start Minikube

If Minikube is not already running, make sure to start it:

```sh
$ minikube start
```

### Deploying Application to Minikube

The Kubernetes manifest is located in the `/k8s` directory. It creates several resources on the Minikube cluster:

- A Kubernetes [Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) named `helloworld`
- A Kubernetes [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) named `helloworld-app` with 2 [replicas](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas)
- A Kubernetes [Service](https://kubernetes.io/docs/concepts/services-networking/service/) named `helloworld-svc` using the [Loadbalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) type

You can deploy the application to Minikube using `kubectl`:

```sh
$ kubectl apply -f k8s/deployment.yaml
```

### Accessing the Application From the Host Machine

Using Minikube, you can [access a pod using the minikube cli](https://minikube.sigs.k8s.io/docs/handbook/accessing/). For this application, you can run:

```sh
$ minikube service --url helloworld-svc -n helloworld
```

This will start a tunnel from your host machine to the minikube cluster and provide access to the `Service` through the IP and  Port shown in the output:

```sh
🏃  Starting tunnel for service helloworld-svc.
|------------|----------------|-------------|------------------------|
| NAMESPACE  |      NAME      | TARGET PORT |          URL           |
|------------|----------------|-------------|------------------------|
| helloworld | helloworld-svc |             | http://127.0.0.1:41371 |
|------------|----------------|-------------|------------------------|
http://127.0.0.1:41371
❗  Because you are using a Docker driver on linux, the terminal needs to be open to run it.
```

In this example output, you should be able to access the pods by navigating to `http://127.0.0.1:41371` in your local browser or via the curl command.

## Install Script

The `install.sh` script is an easy way to build and deploy the application to a Minikube cluster. It checks and makes sure that `Docker`, `Minikube`, and `Kubectl` are all installed with the minimum versions. Builds the docker container from the `Dockerfile`. Deploys the Kubernetes manifest to Minikube. Creates a Minikube tunnel to the `helloworld-svc` Service.

### Flags

There are a couple Flags available for the install script.

| Flag               | Description              |
|:------------------:| ------------------------ |
| -h, --help         | `Display the Help page`  |
| -d, --deploy-only  | `Skip docker build`      |
