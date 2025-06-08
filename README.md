# Seats Booking - Laboratory Work Repository

This repository contains a series of laboratory works demonstrating the development and deployment of a cloud-native application using modern DevOps practices.

## Application Overview

**Seats Booking** - A microservices application for managing seat reservations and bookings.

**Technology Stack:**
- **Backend**: Spring Boot (Java)
- **Frontend**: React
- **Database**: PostgreSQL

## Laboratory Structure

### Lab 1 - Application Development
**Branch:** `lab/1`

Contains the core application implementation:
- Spring Boot REST API backend
- React frontend application
- PostgreSQL database integration
- Basic application functionality for seat booking management

### Lab 2 - Infrastructure as Code
**Branch:** `lab/2`

Extends Lab 1 with cloud infrastructure deployment:
- All components from Lab 1
- Terraform configuration for Selectel cloud deployment
- Infrastructure as Code (IaC) implementation
- Automated cloud resource provisioning

### Lab 3 - Kubernetes Deployment
**Branch:** `lab/3`

Extends Lab 2 with Kubernetes orchestration:
- All components from Lab 2
- Kubernetes manifests and configurations
- Application deployment to Selectel Kubernetes cluster
- Container orchestration and scaling

### Lab 4 - CI/CD and Code Quality
**Branch:** `lab/4`

Extends Lab 3 with continuous integration and code quality:
- All components from Lab 3
- Continuous Deployment (CD) pipeline implementation
- SonarQube integration for code quality analysis
- Automated testing and deployment workflows

## Getting Started

To explore each laboratory work:

1. Switch to the desired lab branch:
   ```bash
   git checkout lab/1  # For Lab 1
   git checkout lab/2  # For Lab 2
   git checkout lab/3  # For Lab 3
   git checkout lab/4  # For Lab 4
   ```

2. Follow the README instructions in each branch for specific setup and deployment steps.

## Learning Objectives

Through these laboratory works, you will learn:

- **Lab 1**: Modern web application development with Spring Boot and React
- **Lab 2**: Infrastructure as Code practices using Terraform
- **Lab 3**: Container orchestration and Kubernetes deployment
- **Lab 4**: CI/CD pipeline implementation and code quality management

Each lab builds upon the previous one, creating a comprehensive DevOps learning experience from application development to production deployment.