# Seats Booking Application

A cloud-native microservices application for seat booking management, built with Java Spring Boot, React, and PostgreSQL, deployed on Kubernetes with autoscaling capabilities.

## 🏗️ Architecture

- **Backend**: Java 17 Spring Boot REST API with actuator endpoints
- **Frontend**: React SPA served by Nginx  
- **Database**: PostgreSQL 14 with persistent storage
- **Infrastructure**: Kubernetes with NGINX Ingress Controller
- **Autoscaling**: Horizontal Pod Autoscaler (HPA) with smart scaling behavior
- **Monitoring**: Built-in metrics via Spring Boot Actuator

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster access with kubeconfig file
- kubectl installed locally
- make utility

### Full Deployment

Deploy the entire application stack with a single command:

```bash
make k8s-deploy-full KUBECONFIG_PATH=/path/to/your/kubeconfig.yaml
```

This command will:
1. Create the `seats-booking` namespace
2. Deploy PostgreSQL with persistent storage
3. Deploy the backend API with health checks
4. Deploy the frontend web application
5. Install NGINX Ingress Controller (if not present)
6. Configure Ingress routing
7. Set up Horizontal Pod Autoscaler with delayed scaling
8. Display access URLs when ready

### Check Application Status

```bash
make k8s-status KUBECONFIG_PATH=/path/to/your/kubeconfig.yaml
```

### Clean Up

Remove all application resources:

```bash
make k8s-clean KUBECONFIG_PATH=/path/to/your/kubeconfig.yaml
```

## 📋 Available Commands

### Infrastructure Management

```bash
# Terraform operations
make init          # Initialize Terraform
make plan          # Show Terraform execution plan
make apply         # Apply Terraform configuration
make destroy       # Destroy infrastructure
make output        # Show Terraform outputs
```

### Kubernetes Deployment

```bash
# Core deployment commands
make k8s-deploy-full KUBECONFIG_PATH=/path/to/kubeconfig     # Full deployment
make k8s-status KUBECONFIG_PATH=/path/to/kubeconfig          # Check status
make k8s-clean KUBECONFIG_PATH=/path/to/kubeconfig           # Clean up
make k8s-restart-backend KUBECONFIG_PATH=/path/to/kubeconfig # Restart backend
```

### Autoscaling and Load Testing

```bash
# HPA management
make k8s-apply-smart-hpa KUBECONFIG_PATH=/path/to/kubeconfig # Apply improved HPA
make k8s-watch-hpa KUBECONFIG_PATH=/path/to/kubeconfig       # Monitor HPA real-time
make k8s-load-test KUBECONFIG_PATH=/path/to/kubeconfig       # Run load testing
```

### Monitoring and Debugging

```bash
# Logging and monitoring
make k8s-logs-backend KUBECONFIG_PATH=/path/to/kubeconfig         # Follow backend logs
make k8s-show-requests KUBECONFIG_PATH=/path/to/kubeconfig        # Show request distribution
make k8s-demo-load-distribution KUBECONFIG_PATH=/path/to/kubeconfig # Demo load balancing
```

### Kubernetes Dashboard (Web UI)

```bash
# Dashboard setup
make k8s-install-dashboard KUBECONFIG_PATH=/path/to/kubeconfig    # Install dashboard
make k8s-dashboard-proxy KUBECONFIG_PATH=/path/to/kubeconfig      # Start proxy
make k8s-dashboard-token KUBECONFIG_PATH=/path/to/kubeconfig      # Get login token
```

### Help

```bash
make help          # Show all available commands
```

## 🌐 Application Access

After successful deployment, your application will be available at:

- **Frontend**: `http://<external-ip>/`
- **Backend API**: `http://<external-ip>/api/v1/`
- **Health Check**: `http://<external-ip>/api/v1/actuator/health`
- **Metrics**: `http://<external-ip>/api/v1/actuator/prometheus`

The external IP is automatically displayed after deployment completion.

## 📁 Project Structure

```
├── backend/                 # Java Spring Boot application
├── frontend/               # React application
├── k8s/                   # Kubernetes manifests
│   ├── namespace.yaml
│   ├── postgres-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── ingress.yaml
│   ├── backend-hpa.yaml
│   ├── backend-hpa-delayed.yaml
│   └── dashboard-admin.yaml
├── terraform/             # Infrastructure as Code
├── cloud-init.yaml       # VM initialization script
├── Makefile              # Deployment automation
└── README.md            # This file
```

## 🔧 Configuration Details

### Database Configuration
- **Database**: `meeting_rooms`
- **User**: `devops`
- **Storage**: Persistent volume with `fast.ru-1c` storage class
- **Port**: 5432

### Backend Configuration
- **Port**: 10101
- **Context Path**: `/api/v1`
- **Java Version**: 17
- **Spring Profiles**: Kubernetes-optimized

### Autoscaling Configuration
- **Minimum Replicas**: 1
- **Maximum Replicas**: 5
- **Target CPU**: 15%
- **Scale Up**: Gradual (1 pod every 60 seconds)
- **Scale Down**: Conservative (1 pod every 300 seconds)

## 🐛 Troubleshooting

### Common Issues

1. **Pods stuck in Pending**
   ```bash
   kubectl describe pods -n seats-booking
   # Check for resource constraints or storage issues
   ```

2. **External IP not assigned**
   ```bash
   kubectl get svc -n ingress-nginx
   # Verify LoadBalancer service status
   ```

3. **Backend pods crashing**
   ```bash
   make k8s-logs-backend KUBECONFIG_PATH=/path/to/kubeconfig
   # Check application logs for errors
   ```

4. **HPA not scaling**
   ```bash
   make k8s-watch-hpa KUBECONFIG_PATH=/path/to/kubeconfig
   # Monitor HPA decisions and metrics
   ```

### Health Checks

The application includes comprehensive health checks:
- **Liveness Probe**: `/actuator/health/liveness`
- **Readiness Probe**: `/actuator/health/readiness`
- **Startup Probe**: `/actuator/health` (180-second timeout)

## 📊 Monitoring and Observability

### Built-in Metrics
- Spring Boot Actuator metrics available at `/actuator/prometheus`
- HPA metrics for CPU utilization
- Pod resource usage monitoring

### Load Testing
The project includes built-in load testing capabilities using Apache Bench:
```bash
make k8s-load-test KUBECONFIG_PATH=/path/to/kubeconfig
```

### Real-time Monitoring
Monitor your application in real-time:
```bash
# Watch HPA scaling decisions
make k8s-watch-hpa KUBECONFIG_PATH=/path/to/kubeconfig

# Follow application logs
make k8s-logs-backend KUBECONFIG_PATH=/path/to/kubeconfig

# Demo load distribution
make k8s-demo-load-distribution KUBECONFIG_PATH=/path/to/kubeconfig
```

## 🔐 Security

- RBAC configured for Kubernetes Dashboard
- Network policies via Ingress Controller
- Resource limits and quotas
- Health check endpoints for service monitoring

## 🚀 CI/CD Integration

The project is designed to work with GitHub Actions for:
- Automated Docker image building
- Container registry publishing
- Kubernetes deployment automation

## 📝 Development

For local development:

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

## 📞 Support

For help with specific commands, run:
```bash
make help
```

This will display all available commands with usage examples.
