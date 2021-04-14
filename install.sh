#!/bin/bash

show_help() {
cat << EOF
Usage: $(basename "$0") <options>
    -h, --help          Display help
    -d, --deploy-only   Skip docker build and deploy the Kubernetes manifest
EOF
}

main() {
  local build="true"

  parse_command_line "$@"

  set +e
  checkMinikube
  checkDocker
  checkKubectl
  set -e

  eval $(minikube -p minikube docker-env)

  if [[ $build == "true" ]]; then
    buildDockerImage
  fi

  deployHelloworld
  minikubeSvc
}

parse_command_line() {
    while :; do
        case "${1:-}" in
            -h|--help)
                show_help
                exit
                ;;
            -d|--deploy-only)
                build="false"
                ;;
            *)
                break
                ;;
        esac

        shift
    done
}

checkMinikube() {
  minikubeVersion="$(minikube version -o json | jq -r '.minikubeVersion' | cut -c 2-)"
  if [ -z $minikubeVersion ]; then
    echo "Could not find Minikube version. Is Minikube installed?"
    exit 1
  fi
  requiredver="1.19.0"
  if [ "$(printf '%s\n' "$requiredver" "$minikubeVersion" | sort -V | head -n1)" = "$requiredver" ]; then
    echo "Using a compatable version of Minikube $minikubeVersion 👍"
  else
    echo "Please update your version of Minikube to at least v${requiredver}"
    exit 1
  fi
}

checkDocker() {
  dockerVersion="$(docker --version | grep -Eo "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}")"
  if [ -z $dockerVersion ]; then
    echo "Could not find Docker version. Is Docker installed?"
    exit 1
  fi
  requiredver="20.10.5"
  if [ "$(printf '%s\n' "$requiredver" "$dockerVersion" | sort -V | head -n1)" = "$requiredver" ]; then
    echo "Using a compatable version of Docker $dockerVersion 👍"
  else
    echo "Please update your version of Docker to at least v${requiredver}"
    exit 1
  fi
}

checkKubectl() {
  kubectlVersion="$(kubectl version -o json | jq -r ".clientVersion.gitVersion" | cut -c 2-)"
  if [ -z $kubectlVersion ]; then
    echo "Could not find Kubectl version. Is Kubectl installed?"
    exit 1
  fi
  requiredver="1.19.7"
  if [ "$(printf '%s\n' "$requiredver" "$kubectlVersion" | sort -V | head -n1)" = "$requiredver" ]; then
    echo "Using a compatable version of Kubectl $kubectlVersion 👍"
  else
    echo "Please update your version of Kubectl to at least v${requiredver}"
    exit 1
  fi
}

buildDockerImage() {
  echo "Building Docker image hello-world:0.0.1. Docker is currently connected to the Minkikube Docker daemon, so this may take longer than usual..."
  docker build -t hello-world:0.0.1 .
}

deployHelloworld() {
  echo "Deploying the Hello World application to Minikube in the namespace helloworld..."
  kubectl apply -f k8s/deployment.yaml
}

minikubeSvc() {
  echo -e "\n\nStarting Minikube Service for hello world. You should be able to access the container from your browser or via curl on the ip and port given...\n"
  minikube service --url helloworld-svc -n helloworld
}

set -ufe -o pipefail

main "$@"
