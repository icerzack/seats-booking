#!/bin/bash

# Script to update ingress IP in ConfigMap for Telegram bot and backend
set -e

NAMESPACE="seats-booking"
CONFIGMAP_NAME="ingress-config"

echo "🔍 Getting ingress IP address from NGINX controller..."

# Wait for NGINX ingress controller to get an IP address (up to 5 minutes)
for i in {1..30}; do
    INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [ -z "$INGRESS_IP" ] || [ "$INGRESS_IP" = "null" ]; then
        # Try to get hostname instead of IP
        INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    fi
    
    if [ -n "$INGRESS_IP" ] && [ "$INGRESS_IP" != "null" ]; then
        echo "✅ Found ingress IP/hostname: $INGRESS_IP"
        break
    fi
    
    echo "⏳ Waiting for ingress controller to get IP address... (attempt $i/30)"
    sleep 10
done

if [ -z "$INGRESS_IP" ] || [ "$INGRESS_IP" = "null" ]; then
    echo "❌ Failed to get ingress controller IP address after 5 minutes"
    echo "🔍 NGINX Ingress Controller status:"
    kubectl get svc ingress-nginx-controller -n ingress-nginx
    kubectl describe svc ingress-nginx-controller -n ingress-nginx
    exit 1
fi

# Update ConfigMap with the bot URL
echo "🔄 Updating ConfigMap with bot URL: http://$INGRESS_IP/bot"

# Check if ConfigMap exists, if not create it first
if ! kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE >/dev/null 2>&1; then
    echo "⚠️ ConfigMap $CONFIGMAP_NAME not found, creating it first..."
    kubectl apply -f k8s/telegram-config.yaml
fi

kubectl patch configmap $CONFIGMAP_NAME -n $NAMESPACE --type merge -p "{\"data\":{\"BOT_URL\":\"http://$INGRESS_IP/bot\"}}"

echo "✅ ConfigMap updated successfully!"

# Restart deployments to pick up new environment variables
echo "🔄 Restarting deployments to pick up new environment variables..."

kubectl rollout restart deployment/bot -n $NAMESPACE
kubectl rollout restart deployment/backend -n $NAMESPACE

echo "⏳ Waiting for deployments to be ready..."

kubectl rollout status deployment/bot -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/backend -n $NAMESPACE --timeout=300s

echo "✅ All deployments restarted successfully!"
echo "🎉 Telegram bot webhook URL: http://$INGRESS_IP/bot"
echo "🎉 Backend telegram server URL: http://$INGRESS_IP/bot" 