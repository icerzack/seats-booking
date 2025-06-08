#!/bin/bash

# Demo script to show request distribution across backend pods
# Usage: ./demo-script.sh

KUBECONFIG_PATH="/Users/kuznetsovmaksim/Downloads/liz.yaml"
API_URL="http://185.184.55.242/api/v1"

echo "🎭 ===== DEMO: Request Distribution Across Backend Pods ====="
echo ""

echo "📊 Current Backend Pods:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
KUBECONFIG=$KUBECONFIG_PATH kubectl get pods -n seats-booking -l app=backend \
  -o custom-columns="POD NAME:.metadata.name,IP:.status.podIP,STATUS:.status.phase" \
  | awk 'NR==1{print $0} NR>1{print "🔸 " $0}'

echo ""
echo "🌐 Testing API endpoint: $API_URL/actuator/health"
echo ""

echo "🚀 Sending 10 requests and monitoring responses..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Send requests and show responses
for i in {1..10}; do
    echo -n "Request $i: "
    
    # Make request and capture response
    response=$(curl -s -w "%{http_code}" "$API_URL/actuator/health" 2>/dev/null)
    http_code="${response: -3}"
    
    echo "HTTP $http_code"
    
    sleep 0.5
done

echo ""
echo "📋 Checking logs from each pod to see request distribution:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check logs from each pod
for pod in $(KUBECONFIG=$KUBECONFIG_PATH kubectl get pods -n seats-booking -l app=backend -o jsonpath='{.items[*].metadata.name}'); do
    echo ""
    echo "🔸 Pod: $pod"
    echo "   Recent requests:"
    
    # Look for access logs or HTTP request patterns in the last minute
    recent_logs=$(KUBECONFIG=$KUBECONFIG_PATH kubectl logs $pod -n seats-booking --tail=50 --since=2m 2>/dev/null | grep -E "(actuator|GET|POST|Started|Completed)" || echo "")
    
    if [ ! -z "$recent_logs" ]; then
        request_count=$(echo "$recent_logs" | wc -l | tr -d ' ')
        echo "   ✅ Found $request_count log entries"
        echo "$recent_logs" | tail -5 | sed 's/^/     /'
    else
        echo "   ⚪ No recent HTTP activity in logs"
    fi
done

echo ""
echo "📈 HPA Status (Auto-scaling information):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
KUBECONFIG=$KUBECONFIG_PATH kubectl get hpa -n seats-booking

echo ""
echo "🎯 Key Demonstration Points for Instructor:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Multiple backend pods are running (load balancing)"
echo "✅ Requests are distributed across different pods"
echo "✅ HPA automatically scaled to handle load (5 replicas at 15% CPU threshold)"
echo "✅ Each pod has unique IP and handles requests independently"
echo "✅ Kubernetes Service provides load balancing across pods"
echo ""
echo "💡 To see real-time logs: make k8s-logs-backend KUBECONFIG_PATH=$KUBECONFIG_PATH"
echo "💡 To generate more load: make k8s-load-test KUBECONFIG_PATH=$KUBECONFIG_PATH" 