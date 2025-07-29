#!/bin/bash

# TEOS Network Deployment Script
# This script handles the deployment of all TEOS Network components

set -e

echo "🏛️  TEOS Network Deployment Script"
echo "From Egypt to the World - Powering the Digital Pharaohs"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-development}
DEPLOY_CONTRACTS=${2:-true}
DEPLOY_FRONTEND=${3:-true}
DEPLOY_BACKEND=${4:-true}
DEPLOY_MOBILE=${5:-false}

echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Deploy Contracts: ${DEPLOY_CONTRACTS}${NC}"
echo -e "${BLUE}Deploy Frontend: ${DEPLOY_FRONTEND}${NC}"
echo -e "${BLUE}Deploy Backend: ${DEPLOY_BACKEND}${NC}"
echo -e "${BLUE}Deploy Mobile: ${DEPLOY_MOBILE}${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Node.js is not installed${NC}"
        exit 1
    fi
    
    # Check Rust (for smart contracts)
    if [[ "$DEPLOY_CONTRACTS" == "true" ]] && ! command -v rustc &> /dev/null; then
        echo -e "${RED}Rust is not installed${NC}"
        exit 1
    fi
    
    # Check Anchor (for Solana contracts)
    if [[ "$DEPLOY_CONTRACTS" == "true" ]] && ! command -v anchor &> /dev/null; then
        echo -e "${RED}Anchor is not installed${NC}"
        exit 1
    fi
    
    # Check Solana CLI
    if [[ "$DEPLOY_CONTRACTS" == "true" ]] && ! command -v solana &> /dev/null; then
        echo -e "${RED}Solana CLI is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed!${NC}"
}

# Install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm run install:all
    echo -e "${GREEN}Dependencies installed!${NC}"
}

# Deploy smart contracts
deploy_contracts() {
    if [[ "$DEPLOY_CONTRACTS" == "true" ]]; then
        echo -e "${YELLOW}Deploying smart contracts...${NC}"
        
        cd smart-contracts/token-contracts
        
        # Build contracts
        anchor build
        
        # Deploy to specified network
        if [[ "$ENVIRONMENT" == "production" ]]; then
            anchor deploy --provider.cluster mainnet
        elif [[ "$ENVIRONMENT" == "staging" ]]; then
            anchor deploy --provider.cluster testnet
        else
            anchor deploy --provider.cluster devnet
        fi
        
        cd ../..
        echo -e "${GREEN}Smart contracts deployed!${NC}"
    fi
}

# Deploy backend services
deploy_backend() {
    if [[ "$DEPLOY_BACKEND" == "true" ]]; then
        echo -e "${YELLOW}Deploying backend services...${NC}"
        
        cd web-platforms/teospump-backend
        
        # Build backend
        npm run build
        
        # Deploy based on environment
        if [[ "$ENVIRONMENT" == "production" ]]; then
            # Production deployment (customize based on your hosting)
            echo "Deploying to production server..."
            # Add your production deployment commands here
        elif [[ "$ENVIRONMENT" == "staging" ]]; then
            # Staging deployment
            echo "Deploying to staging server..."
            # Add your staging deployment commands here
        else
            # Development - just start the server
            npm run dev &
        fi
        
        cd ../..
        echo -e "${GREEN}Backend services deployed!${NC}"
    fi
}

# Deploy frontend applications
deploy_frontend() {
    if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
        echo -e "${YELLOW}Deploying frontend applications...${NC}"
        
        cd web-platforms/teospump-frontend
        
        # Build frontend
        npm run build
        
        # Deploy based on environment
        if [[ "$ENVIRONMENT" == "production" ]]; then
            # Production deployment
            echo "Deploying frontend to production..."
            # Add your production deployment commands here
            # Example: aws s3 sync build/ s3://your-bucket --delete
        elif [[ "$ENVIRONMENT" == "staging" ]]; then
            # Staging deployment
            echo "Deploying frontend to staging..."
            # Add your staging deployment commands here
        else
            # Development - serve locally
            npm run dev &
        fi
        
        cd ../..
        echo -e "${GREEN}Frontend applications deployed!${NC}"
    fi
}

# Deploy mobile applications
deploy_mobile() {
    if [[ "$DEPLOY_MOBILE" == "true" ]]; then
        echo -e "${YELLOW}Building mobile applications...${NC}"
        
        cd mobile-apps/teos-mining-app
        
        if [[ "$ENVIRONMENT" == "production" ]]; then
            # Production mobile build
            echo "Building for production..."
            eas build --platform all --non-interactive
        else
            # Development build
            echo "Building for development..."
            expo build:android
            expo build:ios
        fi
        
        cd ../..
        echo -e "${GREEN}Mobile applications built!${NC}"
    fi
}

# Run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"
    npm test
    echo -e "${GREEN}All tests passed!${NC}"
}

# Health check
health_check() {
    echo -e "${YELLOW}Performing health check...${NC}"
    
    # Check if services are running
    if [[ "$DEPLOY_BACKEND" == "true" ]]; then
        # Wait a moment for services to start
        sleep 5
        
        # Check backend health
        if curl -f http://localhost:3000/health > /dev/null 2>&1; then
            echo -e "${GREEN}Backend service is healthy${NC}"
        else
            echo -e "${RED}Backend service health check failed${NC}"
        fi
    fi
    
    if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
        # Check frontend
        if curl -f http://localhost:3001 > /dev/null 2>&1; then
            echo -e "${GREEN}Frontend service is healthy${NC}"
        else
            echo -e "${RED}Frontend service health check failed${NC}"
        fi
    fi
}

# Main deployment flow
main() {
    echo -e "${BLUE}Starting TEOS Network deployment...${NC}"
    
    check_prerequisites
    install_dependencies
    run_tests
    deploy_contracts
    deploy_backend
    deploy_frontend
    deploy_mobile
    health_check
    
    echo ""
    echo -e "${GREEN}🎉 TEOS Network deployment completed successfully!${NC}"
    echo -e "${BLUE}From the wisdom of the pharaohs to the innovation of the digital age${NC}"
    
    if [[ "$ENVIRONMENT" == "development" ]]; then
        echo ""
        echo -e "${YELLOW}Development services running:${NC}"
        if [[ "$DEPLOY_BACKEND" == "true" ]]; then
            echo -e "${BLUE}Backend: http://localhost:3000${NC}"
        fi
        if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
            echo -e "${BLUE}Frontend: http://localhost:3001${NC}"
        fi
    fi
}

# Handle script interruption
trap 'echo -e "\n${RED}Deployment interrupted${NC}"; exit 1' INT

# Run main function
main

exit 0

