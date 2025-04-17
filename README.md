# Seats Booking Application

A microservices-based application for seat booking management, deployed on Kubernetes.

## Project Structure

- **Backend**: Java Spring Boot application for managing seats and bookings
- **Frontend**: React application for the user interface
- **Database**: PostgreSQL for data persistence
- **CI/CD**: GitHub Actions workflows for building and publishing Docker images
- **Infrastructure**: Terraform for provisioning cloud infrastructure and Kubernetes cluster
- **Kubernetes**: Manifests for deploying the application to Kubernetes

## Build and Deployment

### 1. Build and Publish Docker Images

The application uses two separate Docker images for the backend and frontend, which are built and published to GitHub Container Registry (ghcr.io) using GitHub Actions workflows.

The build and publish is initiated by `workflow_dispatch` event.

Triggering the workflow will build the corresponding Docker image and push it to:
- `ghcr.io/your-github-username/seats-booking/backend:latest`
- `ghcr.io/your-github-username/seats-booking/frontend:latest`

### 2. Provision Infrastructure with Terraform

The Terraform configuration will provision necessary cloud resources and install Kubernetes on the VM:

```bash
make init # Initialize Terraform
make apply # Apply Terraform configuration
```

After the infrastructure is provisioned, you'll receive instructions for accessing your Kubernetes cluster.

### 3. Deploy to Kubernetes

1. First, get the kubeconfig file from your server:
```bash
scp root@<server-ip>:/root/k8s/config ~/.kube/config
```

2. Replace `REPOSITORY_OWNER` in the Kubernetes manifests with your GitHub username or use the deployment script, which handles this automatically:
```bash
# Set your GitHub username
export GITHUB_USERNAME="your-github-username"

# Deploy the application
./deploy-to-k8s.sh deploy
```

3. Check the status:
```bash
./deploy-to-k8s.sh status
```

## Application Components

The application consists of three main components:

1. **Frontend**: React SPA served by Nginx
2. **Backend**: Spring Boot REST API running on port 10101
3. **Database**: PostgreSQL for data persistence

All components are deployed as Kubernetes resources:

- **Deployments**: For running the application containers
- **Services**: For internal communication between components
- **Ingress**: For external access to the application
- **ConfigMap**: For PostgreSQL configuration
- **PersistentVolumeClaim**: For PostgreSQL data persistence

## Application Access

Once deployed, you can access the application through the Ingress endpoint:

- **Frontend**: `http://<ingress-ip-or-hostname>/`
- **Backend API**: `http://<ingress-ip-or-hostname>/api/`

## Useful Commands

```bash
# Deploy the application
./deploy-to-k8s.sh deploy

# Check application status
./deploy-to-k8s.sh status

# Remove all application resources
./deploy-to-k8s.sh clean

# See help for deployment script
./deploy-to-k8s.sh help
```

## Local Development

To run the application locally:

1. **Database**:
```bash
docker run -d --name postgres -p 5432:5432 \
  -e POSTGRES_DB=meeting_rooms \
  -e POSTGRES_USER=devops \
  -e POSTGRES_PASSWORD=devops \
  postgres:14-alpine
```

2. **Backend**:
```bash
cd backend
mvn spring-boot:run -Dserver.port=10101
```

3. **Frontend**:
```bash
cd frontend
npm install
npm start
```

## Architecture

This application follows a microservices architecture:

- **Backend**: RESTful API service built with Spring Boot
- **Frontend**: React SPA that consumes the backend API
- **Database**: PostgreSQL for data persistence
- **Deployment**: Kubernetes for container orchestration
- **CI/CD**: GitHub Actions for automated builds and deployments
- **Infrastructure**: Terraform for infrastructure as code
