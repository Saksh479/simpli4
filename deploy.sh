#!/bin/bash

# Spring Boot CI/CD Demo - Deployment Script
# This script helps deploy the application to AWS EC2

set -e  # Exit on any error

# Configuration
APP_NAME="spring-boot-cicd-demo"
JAR_NAME="demo-0.0.1-SNAPSHOT.jar"
DEPLOY_USER="ec2-user"
DEPLOY_HOST=""  # Set your EC2 instance IP here
DEPLOY_PATH="/opt/production"
APP_PORT="8080"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if EC2 host is configured
check_config() {
    if [ -z "$DEPLOY_HOST" ]; then
        log_error "Please set DEPLOY_HOST variable with your EC2 instance IP"
        exit 1
    fi
}

# Build the application
build_app() {
    log_info "Building the application..."
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        log_success "Application built successfully"
    else
        log_error "Build failed"
        exit 1
    fi
}

# Deploy to EC2
deploy_to_ec2() {
    log_info "Deploying to EC2 instance: $DEPLOY_HOST"
    
    # Stop existing application
    log_info "Stopping existing application..."
    ssh ${DEPLOY_USER}@${DEPLOY_HOST} "pkill -f '${JAR_NAME}' || true"
    
    # Create deployment directory if it doesn't exist
    ssh ${DEPLOY_USER}@${DEPLOY_HOST} "mkdir -p ${DEPLOY_PATH}"
    
    # Copy JAR file to EC2
    log_info "Copying JAR file to EC2..."
    scp target/${JAR_NAME} ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/
    
    # Start the application
    log_info "Starting the application..."
    ssh ${DEPLOY_USER}@${DEPLOY_HOST} "cd ${DEPLOY_PATH} && nohup java -jar ${JAR_NAME} --server.port=${APP_PORT} > app.log 2>&1 &"
    
    # Wait for application to start
    log_info "Waiting for application to start..."
    sleep 30
    
    # Health check
    log_info "Performing health check..."
    if ssh ${DEPLOY_USER}@${DEPLOY_HOST} "curl -f http://localhost:${APP_PORT}/actuator/health"; then
        log_success "Application deployed and health check passed!"
        log_success "Application is available at: http://${DEPLOY_HOST}:${APP_PORT}"
    else
        log_error "Health check failed!"
        log_info "Check application logs: ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'tail -f ${DEPLOY_PATH}/app.log'"
        exit 1
    fi
}

# Main deployment process
main() {
    log_info "Starting deployment process for ${APP_NAME}"
    
    check_config
    build_app
    deploy_to_ec2
    
    log_success "Deployment completed successfully!"
}

# Handle script arguments
case "${1:-deploy}" in
    "build")
        build_app
        ;;
    "deploy")
        main
        ;;
    "health")
        if [ -z "$DEPLOY_HOST" ]; then
            log_error "Please set DEPLOY_HOST variable with your EC2 instance IP"
            exit 1
        fi
        log_info "Checking application health..."
        curl -f http://${DEPLOY_HOST}:${APP_PORT}/actuator/health
        ;;
    "logs")
        if [ -z "$DEPLOY_HOST" ]; then
            log_error "Please set DEPLOY_HOST variable with your EC2 instance IP"
            exit 1
        fi
        log_info "Showing application logs..."
        ssh ${DEPLOY_USER}@${DEPLOY_HOST} "tail -f ${DEPLOY_PATH}/app.log"
        ;;
    "stop")
        if [ -z "$DEPLOY_HOST" ]; then
            log_error "Please set DEPLOY_HOST variable with your EC2 instance IP"
            exit 1
        fi
        log_info "Stopping application..."
        ssh ${DEPLOY_USER}@${DEPLOY_HOST} "pkill -f '${JAR_NAME}' || true"
        log_success "Application stopped"
        ;;
    *)
        echo "Usage: $0 {build|deploy|health|logs|stop}"
        echo "  build  - Build the application only"
        echo "  deploy - Build and deploy to EC2 (default)"
        echo "  health - Check application health"
        echo "  logs   - Show application logs"
        echo "  stop   - Stop the application"
        exit 1
        ;;
esac
