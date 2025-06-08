TERRAFORM_DIR=$(CURDIR)/terraform
VARS_FILE=$(CURDIR)/terraform/vars.tfvars

.PHONY: init
init:
	@echo "------Initializing Terraform modules------"
	cd $(TERRAFORM_DIR); terraform init

.PHONY: plan
plan:
	@echo "------Running Terraform plan------"
	cd $(TERRAFORM_DIR); terraform plan --var-file="$(VARS_FILE)"

.PHONY: apply
apply:
	@echo "------Running Terraform apply------"
	cd $(TERRAFORM_DIR); terraform apply --var-file="$(VARS_FILE)" -auto-approve

.PHONY: destroy
destroy:
	@echo "------Running Terraform destroy------"
	cd $(TERRAFORM_DIR); terraform destroy --var-file="$(VARS_FILE)" -auto-approve

.PHONY: output
output:
	@echo "------Showing Terraform outputs------"
	cd $(TERRAFORM_DIR); terraform output

.PHONY: k8s-clean
k8s-clean:
	@echo "🧹 Cleaning up Kubernetes resources..."
	@echo ""
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Please specify kubeconfig file path"; \
		echo "Usage: make k8s-clean KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		echo "Example: make k8s-clean KUBECONFIG_PATH=/Users/kuznetsovmaksim/Downloads/testdevops.yaml"; \
		exit 1; \
	fi
	@if [ ! -f "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Kubeconfig file not found: $(KUBECONFIG_PATH)"; \
		exit 1; \
	fi
	@echo "✅ Using kubeconfig: $(KUBECONFIG_PATH)"
	@echo ""
	@echo "🗑️  Removing application resources..."
	@echo "Deleting Ingress..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f k8s/ingress.yaml 2>/dev/null || echo "Ingress not found"
	@echo "Deleting HPA..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f k8s/backend-hpa.yaml 2>/dev/null || echo "HPA not found"
	@echo "Deleting Frontend..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f k8s/frontend-deployment.yaml 2>/dev/null || echo "Frontend not found"
	@echo "Deleting Backend..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f k8s/backend-deployment.yaml 2>/dev/null || echo "Backend not found"
	@echo "Deleting PostgreSQL..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f k8s/postgres-deployment.yaml 2>/dev/null || echo "PostgreSQL not found"
	@echo "Deleting Namespace..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f k8s/namespace.yaml 2>/dev/null || echo "Namespace not found"
	@echo ""
	@echo "🌐 Removing NGINX Ingress Controller..."
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml 2>/dev/null || echo "NGINX Ingress Controller not found"
	@echo ""
	@echo "⏳ Waiting for resources to be fully deleted..."
	@sleep 10
	@echo ""
	@echo "🔍 Checking remaining resources..."
	@echo "Pods in seats-booking namespace:"
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) get pods -n seats-booking 2>/dev/null || echo "No pods found (namespace deleted)"
	@echo ""
	@echo "Ingress Controllers:"
	-kubectl --kubeconfig=$(KUBECONFIG_PATH) get pods -n ingress-nginx 2>/dev/null || echo "No ingress controllers found"
	@echo ""
	@echo "✅ Cleanup completed! You can now run: make k8s-deploy-full KUBECONFIG_PATH=$(KUBECONFIG_PATH)"

.PHONY: k8s-deploy-full
k8s-deploy-full:
	@echo "🚀 Starting full Kubernetes deployment..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-deploy-full KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	
	@echo "📁 Creating namespace..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/namespace.yaml
	
	@echo "🗄️ Deploying PostgreSQL..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/postgres-deployment.yaml
	@echo "⏳ Waiting for PostgreSQL to be ready..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl wait --for=condition=ready pod -l app=postgres -n seats-booking --timeout=300s
	
	@echo "🚀 Deploying Backend..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/backend-deployment.yaml
	@echo "⏳ Waiting for Backend to be ready..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl wait --for=condition=ready pod -l app=backend -n seats-booking --timeout=300s
	
	@echo "🖥️ Deploying Frontend..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/frontend-deployment.yaml
	@echo "⏳ Waiting for Frontend to be ready..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl wait --for=condition=ready pod -l app=frontend -n seats-booking --timeout=300s
	
	@echo "⏱️ Waiting for backend pods to stabilize (60 seconds)..."
	@sleep 60
	
	@echo "📈 Setting up autoscaling (HPA)..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/backend-hpa-delayed.yaml
	
	@echo "🌐 Installing NGINX Ingress Controller..."
	@if ! KUBECONFIG=$(KUBECONFIG_PATH) kubectl get deployment ingress-nginx-controller -n ingress-nginx >/dev/null 2>&1; then \
		echo "🔧 Installing NGINX Ingress Controller..."; \
		KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml; \
		echo "⏳ Waiting for Ingress Controller to be ready..."; \
		KUBECONFIG=$(KUBECONFIG_PATH) kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s; \
	else \
		echo "✅ NGINX Ingress Controller already installed"; \
	fi
	
	@echo "🔗 Setting up Ingress..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/ingress.yaml
	
	@echo "⏳ Waiting for external IP..."
	@timeout=300; \
	while [ $$timeout -gt 0 ]; do \
		EXTERNAL_IP=$$(KUBECONFIG=$(KUBECONFIG_PATH) kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
		if [ ! -z "$$EXTERNAL_IP" ] && [ "$$EXTERNAL_IP" != "null" ]; then \
			echo "🎉 External IP obtained: $$EXTERNAL_IP"; \
			echo "🌐 Application available at: http://$$EXTERNAL_IP"; \
			echo "🔌 API available at: http://$$EXTERNAL_IP/api/v1"; \
			break; \
		fi; \
		echo "⏳ Waiting for external IP... ($$timeout seconds remaining)"; \
		sleep 10; \
		timeout=$$((timeout-10)); \
	done; \
	if [ $$timeout -le 0 ]; then \
		echo "⚠️ External IP not obtained within timeout. Check status:"; \
		echo "kubectl --kubeconfig=$(KUBECONFIG_PATH) get svc -n ingress-nginx"; \
	fi
	
	@echo "✅ Deployment completed!"
	@echo "📊 Check status: make k8s-status KUBECONFIG_PATH=$(KUBECONFIG_PATH)"

.PHONY: help
help:
	@echo "🚀 Seats Booking - Deployment Commands"
	@echo ""
	@echo "📦 Containers:"
	@echo "  make build-all                    - Build all images"
	@echo "  make push-all                     - Push all images to registry"
	@echo ""
	@echo "☸️  Kubernetes:"
	@echo "  make k8s-deploy-full              - Full application deployment"
	@echo "  make k8s-status                   - Check pod status"
	@echo "  make k8s-restart-backend          - Restart backend deployment"
	@echo "  make k8s-clean                    - Remove all resources"
	@echo ""
	@echo "🌐 Web UI:"
	@echo "  make k8s-install-dashboard        - Install Kubernetes Dashboard"
	@echo "  make k8s-dashboard-proxy          - Start Dashboard proxy"
	@echo "  make k8s-dashboard-token          - Get Dashboard login token"
	@echo ""
	@echo "📈 Autoscaling and Testing:"
	@echo "  make k8s-apply-smart-hpa          - Apply improved HPA configuration"
	@echo "  make k8s-load-test                - Run load testing"
	@echo "  make k8s-watch-hpa                - Monitor HPA in real-time"
	@echo ""
	@echo "📊 Monitoring and Demo:"
	@echo "  make k8s-logs-backend             - Monitor backend logs in real-time"
	@echo "  make k8s-show-requests            - Show request distribution across pods"
	@echo "  make k8s-demo-load-distribution   - Demo load distribution for presentation"
	@echo ""
	@echo "🔧 Usage Examples:"
	@echo "  make k8s-deploy-full KUBECONFIG_PATH=/Users/kuznetsovmaksim/Downloads/testdevops.yaml"
	@echo "  make k8s-dashboard-proxy KUBECONFIG_PATH=/Users/kuznetsovmaksim/Downloads/liz.yaml"
	@echo "  make k8s-demo-load-distribution KUBECONFIG_PATH=/Users/kuznetsovmaksim/Downloads/liz.yaml"

# Load testing to check HPA functionality
k8s-load-test:
	@echo "🔥 Starting load testing to verify HPA..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-load-test KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	
	@EXTERNAL_IP=$$(KUBECONFIG=$(KUBECONFIG_PATH) kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ -z "$$EXTERNAL_IP" ] || [ "$$EXTERNAL_IP" = "null" ]; then \
		echo "❌ External IP not found. Make sure Ingress Controller is deployed"; \
		exit 1; \
	fi; \
	echo "🎯 Testing: http://$$EXTERNAL_IP/api/v1"; \
	echo "📊 Current pod status:"; \
	KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -l app=backend; \
	echo ""; \
	echo "🚀 Starting load test (500 requests, 10 concurrent)..."; \
	if command -v ab >/dev/null 2>&1; then \
		ab -n 500 -c 10 http://$$EXTERNAL_IP/api/v1/api/v1/rooms?page=0&size=20; \
	else \
		echo "⚠️ Apache Bench (ab) not installed. Installing..."; \
		if [[ "$$OSTYPE" == "darwin"* ]]; then \
			if command -v brew >/dev/null 2>&1; then \
				brew install httpd; \
			else \
				echo "❌ Homebrew not found. Please install Apache Bench manually"; \
				exit 1; \
			fi; \
		elif [[ "$$OSTYPE" == "linux"* ]]; then \
			sudo apt-get update && sudo apt-get install -y apache2-utils; \
		fi; \
		ab -n 500 -c 10 http://$$EXTERNAL_IP/api/v1/api/v1/rooms?page=0&size=20; \
	fi; \
	echo ""; \
	echo "📈 Pod status after load test:"; \
	KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -l app=backend; \
	echo ""; \
	echo "📊 HPA status:"; \
	KUBECONFIG=$(KUBECONFIG_PATH) kubectl get hpa -n seats-booking

# Monitor HPA in real-time
k8s-watch-hpa:
	@echo "👀 Monitoring HPA in real-time..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-watch-hpa KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "Press Ctrl+C to exit"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get hpa backend-hpa -n seats-booking --watch

# Apply improved HPA configuration with delayed scaling
k8s-apply-smart-hpa:
	@echo "📈 Applying improved HPA configuration..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-apply-smart-hpa KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "🔧 Removing old HPA..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl delete hpa backend-hpa -n seats-booking --ignore-not-found=true
	@echo "⏱️ Waiting 10 seconds..."
	@sleep 10
	@echo "✨ Applying improved HPA configuration..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/backend-hpa-delayed.yaml
	@echo "✅ New HPA applied!"
	@echo "📊 HPA status:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get hpa -n seats-booking

# Restart backend deployment (useful when image is updated)
k8s-restart-backend:
	@echo "🔄 Restarting backend deployment..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-restart-backend KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "🚀 Rolling out restart for backend deployment..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl rollout restart deployment/backend -n seats-booking
	@echo "⏳ Waiting for rollout to complete..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl rollout status deployment/backend -n seats-booking --timeout=300s
	@echo "📊 Current pod status:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -l app=backend
	@echo "✅ Backend restart completed!"

# Check status of all application components
k8s-status:
	@echo "📊 Checking Kubernetes application status..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-status KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo ""
	@echo "🏷️  Namespace:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get namespace seats-booking 2>/dev/null || echo "❌ Namespace not found"
	@echo ""
	@echo "🚀 Pods:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -o wide 2>/dev/null || echo "❌ No pods found"
	@echo ""
	@echo "🔗 Services:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get services -n seats-booking 2>/dev/null || echo "❌ No services found"
	@echo ""
	@echo "🌐 Ingress:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get ingress -n seats-booking 2>/dev/null || echo "❌ No ingress found"
	@echo ""
	@echo "📈 HPA:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get hpa -n seats-booking 2>/dev/null || echo "❌ No HPA found"
	@echo ""
	@echo "💾 PVC:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pvc -n seats-booking 2>/dev/null || echo "❌ No PVC found"
	@echo ""
	@echo "🔧 Ingress Controller:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller 2>/dev/null || echo "❌ Ingress controller not found"
	@echo ""
	@EXTERNAL_IP=$$(KUBECONFIG=$(KUBECONFIG_PATH) kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ ! -z "$$EXTERNAL_IP" ] && [ "$$EXTERNAL_IP" != "null" ]; then \
		echo "🌐 Application URLs:"; \
		echo "   Frontend: http://$$EXTERNAL_IP"; \
		echo "   API: http://$$EXTERNAL_IP/api/v1"; \
		echo "   Health: http://$$EXTERNAL_IP/api/v1/actuator/health"; \
		echo "   Metrics: http://$$EXTERNAL_IP/api/v1/actuator/prometheus"; \
	else \
		echo "⚠️ External IP not available"; \
	fi

# Monitor logs from all backend pods in real-time
k8s-logs-backend:
	@echo "📋 Monitoring backend logs in real-time..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-logs-backend KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "🚀 Following logs from all backend pods (Press Ctrl+C to exit)..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl logs -f -l app=backend -n seats-booking --prefix=true --timestamps=true

# Show request distribution across pods
k8s-show-requests:
	@echo "📊 Showing request distribution across backend pods..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-show-requests KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo ""
	@echo "🏷️  Current backend pods:"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -l app=backend -o custom-columns="POD NAME:.metadata.name,NODE:.spec.nodeName,IP:.status.podIP,STATUS:.status.phase"
	@echo ""
	@echo "📈 Recent HTTP requests (last 50 lines from each pod):"
	@for pod in $$(KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -l app=backend -o jsonpath='{.items[*].metadata.name}'); do \
		echo ""; \
		echo "🔸 Pod: $$pod"; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		KUBECONFIG=$(KUBECONFIG_PATH) kubectl logs $$pod -n seats-booking --tail=10 | grep -E "(GET|POST|PUT|DELETE|Started|Completed)" || echo "No recent HTTP requests"; \
	done

# Generate load and show real-time distribution
k8s-demo-load-distribution:
	@echo "🎭 Demo: Load distribution across pods"
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-demo-load-distribution KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@EXTERNAL_IP=$$(KUBECONFIG=$(KUBECONFIG_PATH) kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ -z "$$EXTERNAL_IP" ] || [ "$$EXTERNAL_IP" = "null" ]; then \
		echo "❌ External IP not found"; \
		exit 1; \
	fi; \
	echo "🎯 Target: http://$$EXTERNAL_IP/api/v1"; \
	echo "📊 Current pods:"; \
	KUBECONFIG=$(KUBECONFIG_PATH) kubectl get pods -n seats-booking -l app=backend --no-headers | awk '{print "   🔸 " $$1 " (" $$3 ")"}'; \
	echo ""; \
	echo "🚀 Generating load (20 requests)..."; \
	echo "💡 Run 'make k8s-logs-backend KUBECONFIG_PATH=$(KUBECONFIG_PATH)' in another terminal to see real-time logs"; \
	echo ""; \
	for i in {1..20}; do \
		echo "Request $$i..."; \
		curl -s http://$$EXTERNAL_IP/api/v1/actuator/health > /dev/null; \
		sleep 1; \
	done; \
	echo ""; \
	echo "📋 Checking request distribution:"; \
	make k8s-show-requests KUBECONFIG_PATH=$(KUBECONFIG_PATH)

# Install Kubernetes Dashboard Web UI
k8s-install-dashboard:
	@echo "🌐 Installing Kubernetes Dashboard..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-install-dashboard KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "📦 Installing Dashboard..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
	@echo "👤 Creating admin user..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl apply -f k8s/dashboard-admin.yaml
	@echo "⏳ Waiting for Dashboard to be ready..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl wait --namespace kubernetes-dashboard --for=condition=ready pod --selector=k8s-app=kubernetes-dashboard --timeout=300s
	@echo "✅ Dashboard installed successfully!"
	@echo ""
	@echo "🔑 Access token (save this):"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl -n kubernetes-dashboard create token admin-user
	@echo ""
	@echo "💡 To access Dashboard:"
	@echo "   1. Run: make k8s-dashboard-proxy KUBECONFIG_PATH=$(KUBECONFIG_PATH)"
	@echo "   2. Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
	@echo "   3. Use the token above to login"

# Start Dashboard proxy
k8s-dashboard-proxy:
	@echo "🚀 Starting Kubernetes Dashboard proxy..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-dashboard-proxy KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "🔗 Dashboard will be available at:"
	@echo "   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
	@echo ""
	@echo "🔑 Get login token in another terminal:"
	@echo "   KUBECONFIG=$(KUBECONFIG_PATH) kubectl -n kubernetes-dashboard create token admin-user"
	@echo ""
	@echo "Press Ctrl+C to stop the proxy..."
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl proxy

# Get Dashboard login token
k8s-dashboard-token:
	@echo "🔑 Getting Dashboard login token..."
	@if [ -z "$(KUBECONFIG_PATH)" ]; then \
		echo "❌ Error: KUBECONFIG_PATH must be specified"; \
		echo "Example: make k8s-dashboard-token KUBECONFIG_PATH=/path/to/kubeconfig.yaml"; \
		exit 1; \
	fi
	@echo "Copy this token for Dashboard login:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@KUBECONFIG=$(KUBECONFIG_PATH) kubectl -n kubernetes-dashboard create token admin-user
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
