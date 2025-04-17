#!/bin/bash

# Exit on any error
set -e

# Check if kubectl is installed
if ! command -v kubectl &>/dev/null; then
  echo "kubectl is not installed. Please install it first."
  exit 1
fi

# Check if we have a valid kubeconfig
if ! kubectl cluster-info &>/dev/null; then
  echo "No valid kubeconfig found. Please set up your kubeconfig first."
  echo "If your cluster is on a remote server, run:"
  echo "scp root@<server-ip>:/root/k8s/config ~/.kube/config"
  exit 1
fi

# Set repository owner - replace with your GitHub username
REPO_OWNER=${GITHUB_USERNAME:-"icerzack"}

# Function to replace placeholder in yaml files
replace_placeholder() {
  find k8s -type f -name "*.yaml" -exec sed -i.bak "s/REPOSITORY_OWNER/$REPO_OWNER/g" {} \;
  find k8s -name "*.bak" -delete
}

# Apply k8s manifests
deploy() {
  echo "Checking if namespace exists..."
  kubectl get namespace seats-booking >/dev/null 2>&1 || kubectl create namespace seats-booking

  echo "Deploying application to Kubernetes..."
  
  # Replace placeholder with actual repository owner
  replace_placeholder
  
  # Apply k8s manifests
  kubectl apply -f k8s/namespace.yaml
  
  echo "Deploying PostgreSQL database..."
  kubectl apply -f k8s/postgres-deployment.yaml
  
  echo "Waiting for PostgreSQL to be ready..."
  kubectl -n seats-booking wait --for=condition=available --timeout=120s deployment/postgres || true
  
  echo "Deploying backend and frontend..."
  kubectl apply -f k8s/backend-deployment.yaml
  kubectl apply -f k8s/frontend-deployment.yaml
  kubectl apply -f k8s/backend-hpa.yaml
  
  # Check if ingress controller is installed
  if kubectl get deployment -n ingress-nginx ingress-nginx-controller &>/dev/null; then
    echo "Ingress controller found, applying ingress resource..."
    kubectl apply -f k8s/ingress.yaml
  else
    echo "No ingress controller found. Installing nginx-ingress controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    
    echo "Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=120s
    
    echo "Applying ingress resource..."
    kubectl apply -f k8s/ingress.yaml
  fi
  
  echo "Deployment completed successfully!"
}

# Show application status
status() {
  echo "Checking application status..."
  echo "---------------------------------"
  echo "Deployments:"
  kubectl get deployments -n seats-booking
  echo "---------------------------------"
  echo "Services:"
  kubectl get services -n seats-booking
  echo "---------------------------------"
  echo "Persistent Volume Claims:"
  kubectl get pvc -n seats-booking
  echo "---------------------------------"
  echo "Pods:"
  kubectl get pods -n seats-booking
  echo "---------------------------------"
  echo "Ingress:"
  kubectl get ingress -n seats-booking
  
  # Get the ingress IP or hostname
  INGRESS_HOST=$(kubectl get ingress -n seats-booking seats-booking-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
  if [ "$INGRESS_HOST" == "pending" ]; then
    INGRESS_HOST=$(kubectl get ingress -n seats-booking seats-booking-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
  fi
  
  if [ "$INGRESS_HOST" != "pending" ]; then
    echo "---------------------------------"
    echo "Application URLs:"
    echo "Frontend: http://$INGRESS_HOST"
    echo "Backend API: http://$INGRESS_HOST/api"
  else
    echo "---------------------------------"
    echo "Ingress is still pending. You may need to wait a bit longer."
    echo "Once ready, you can access the application at:"
    echo "Frontend: http://<ingress-ip-or-hostname>"
    echo "Backend API: http://<ingress-ip-or-hostname>/api"
  fi
}

# Clean up
clean() {
  echo "Removing all application resources..."
  kubectl delete namespace seats-booking --ignore-not-found
  echo "All resources removed."
}

# Show help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Options:"
  echo "  deploy   Deploy the application to Kubernetes"
  echo "  status   Show application status"
  echo "  clean    Remove all application resources"
  echo "  help     Show this help message"
}

# Process command line arguments
case "$1" in
  deploy)
    deploy
    ;;
  status)
    status
    ;;
  clean)
    clean
    ;;
  help|*)
    show_help
    ;;
esac 