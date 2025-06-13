#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Environment Variables Check Script ===${NC}"
echo ""

# Function to check if service is running
check_service() {
    local service_name=$1
    local port=$2
    local health_endpoint=$3
    
    echo -e "${YELLOW}Checking $service_name...${NC}"
    
    # Check if port is open
    if nc -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}✓ $service_name is running on port $port${NC}"
        
        # Try to get health info
        if curl -s "http://localhost:$port$health_endpoint" > /dev/null; then
            echo -e "${GREEN}✓ Health endpoint is accessible${NC}"
            
            # Get environment variables
            echo -e "${BLUE}Environment Variables for $service_name:${NC}"
            curl -s "http://localhost:$port$health_endpoint" | jq '.' 2>/dev/null || echo "Could not parse JSON response"
            echo ""
        else
            echo -e "${RED}✗ Health endpoint not accessible${NC}"
        fi
    else
        echo -e "${RED}✗ $service_name is not running on port $port${NC}"
    fi
    echo ""
}

# Function to check environment variables from system
check_system_env() {
    echo -e "${YELLOW}System Environment Variables:${NC}"
    
    # Backend variables
    echo -e "${BLUE}Backend Variables:${NC}"
    echo "DB_URL: ${DB_URL:-'Not set (using default)'}"
    echo "DB_USERNAME: ${DB_USERNAME:-'Not set (using default)'}"
    echo "DB_PASSWORD: ${DB_PASSWORD:+'***SET***'}"
    echo "BOOKING_START_HOUR: ${BOOKING_START_HOUR:-'Not set (using default: 9)'}"
    echo "BOOKING_END_HOUR: ${BOOKING_END_HOUR:-'Not set (using default: 18)'}"
    echo "SERVER_PORT: ${SERVER_PORT:-'Not set (using default: 10101)'}"
    echo "TELEGRAM_SERVER_URL: ${TELEGRAM_SERVER_URL:-'Not set (using default: http://localhost:8080)'}"
    echo ""
    
    # Bot variables
    echo -e "${BLUE}Bot Variables:${NC}"
    echo "DB_HOST: ${DB_HOST:-'Not set (using default: localhost)'}"
    echo "DB_PORT: ${DB_PORT:-'Not set (using default: 5432)'}"
    echo "DB_NAME: ${DB_NAME:-'Not set (using default: meeting_rooms)'}"
    echo "DB_USER: ${DB_USER:-'Not set (using default: devops)'}"
    echo "DB_PASS: ${DB_PASS:+'***SET***'}"
    echo "TELEGRAM_BOT_TOKEN: ${TELEGRAM_BOT_TOKEN:+'***SET***'}"
    echo "TELEGRAM_BOT_WEBHOOK_PATH: ${TELEGRAM_BOT_WEBHOOK_PATH:-'Not set'}"
    echo ""
}

# Main execution
echo -e "${YELLOW}1. Checking System Environment Variables...${NC}"
check_system_env

echo -e "${YELLOW}2. Checking Backend Service...${NC}"
check_service "Backend" "10101" "/api/v1/health/env"

echo -e "${YELLOW}3. Checking Bot Service...${NC}"
check_service "Bot" "8080" "/health/env"

echo -e "${YELLOW}4. Additional Bot Configuration Check...${NC}"
if nc -z localhost 8080 2>/dev/null; then
    echo -e "${BLUE}Bot Telegram Configuration:${NC}"
    curl -s "http://localhost:8080/health/telegram-config" | jq '.' 2>/dev/null || echo "Could not parse JSON response"
    echo ""
fi

echo -e "${BLUE}=== Check Complete ===${NC}"
echo ""
echo -e "${YELLOW}Usage Tips:${NC}"
echo "- If services are not running, start them with: make run-backend and make run-bot"
echo "- Check logs if services fail to start"
echo "- Ensure all required environment variables are set"
echo "- Use 'docker-compose logs' to check container logs if running in Docker" 