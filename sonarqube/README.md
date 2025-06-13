# 🔍 SonarQube Setup for Seats Booking Project

This document provides step-by-step instructions for setting up SonarQube on a cloud server and integrating it with GitHub Actions.

## 📋 Prerequisites

- Cloud server with Ubuntu/Debian
- Docker and Docker Compose
- GitHub repository

## 🚀 Step 1: Install SonarQube on Server

### 1.1 Connect to Server
```bash
ssh your_user@your_server_ip
```

### 1.2 Download Installation Files
```bash
# Create directory
mkdir -p /opt/sonarqube
cd /opt/sonarqube

# Download files from repository
wget https://raw.githubusercontent.com/YOUR_USERNAME/seats-booking/main/sonarqube/docker-compose.yml
wget https://raw.githubusercontent.com/YOUR_USERNAME/seats-booking/main/sonarqube/install-sonarqube.sh

# Make script executable
chmod +x install-sonarqube.sh
```

### 1.3 Run Installation
```bash
sudo ./install-sonarqube.sh
```

### 1.4 Verify Installation
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs sonarqube
```

## 🔧 Step 2: Initial SonarQube Configuration

### 2.1 Access SonarQube
1. Open browser and navigate to: `http://your_server_ip:9000`
2. Login with default credentials:
   - **Username**: `admin`
   - **Password**: `admin`
3. Change password on first login

### 2.2 Create Token for GitHub Actions
1. Go to **My Account** → **Security** → **Generate Tokens**
2. Enter token name: `github-actions`
3. Copy the generated token (needed for GitHub)

### 2.3 Create Projects
1. Click **Create Project** → **Manually**
2. Create backend project:
   - **Project key**: `seats-booking-backend`
   - **Display name**: `Seats Booking Backend`
3. Create frontend project:
   - **Project key**: `seats-booking-frontend`
   - **Display name**: `Seats Booking Frontend`

### 2.4 Configure Quality Gate
1. Go to **Quality Gates**
2. Create new Quality Gate or edit existing one
3. Set the following conditions:
   - **Coverage**: >= 80%
   - **Duplicated Lines**: <= 3%
   - **Maintainability Rating**: A
   - **Reliability Rating**: A
   - **Security Rating**: A

## 🔐 Step 3: Configure GitHub Secrets

In your GitHub repository settings, add the following secrets:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add secrets:

```
SONAR_HOST_URL: http://your_server_ip:9000
SONAR_TOKEN: your_token_from_sonarqube
```

## 🏗️ Step 4: Configure Projects for Analysis

### 4.1 Backend (Maven)
JaCoCo plugin is already added to `pom.xml`. Test coverage locally:
```bash
cd backend
mvn clean test jacoco:report
```

### 4.2 Frontend (Jest)
Ensure `package.json` has coverage configured:
```json
{
  "scripts": {
    "test:coverage": "react-scripts test --coverage --watchAll=false"
  }
}
```

## 🚀 Step 5: Test CI/CD Pipeline

1. Create a commit and push to `main` or `develop` branch
2. Go to **Actions** in your GitHub repository
3. Check the execution of `CI/CD Pipeline with SonarQube` workflow

## 📊 Step 6: Monitor and Analyze

### 6.1 View Results in SonarQube
1. Open your SonarQube at `http://your_server_ip:9000`
2. Open projects `seats-booking-backend` and `seats-booking-frontend`
3. Review:
   - **Code Coverage** (should be >= 80%)
   - **Code Smells**
   - **Bugs**
   - **Security Vulnerabilities**
   - **Duplications**

### 6.2 Interpret Results
- **🟢 Green**: Quality Gate passed, all good
- **🟡 Yellow**: Warnings present, but no critical issues
- **🔴 Red**: Quality Gate failed, critical issues found

## 🛠️ SonarQube Management

### Useful Commands:
```bash
# Stop SonarQube
cd /opt/sonarqube && docker-compose down

# Start SonarQube
cd /opt/sonarqube && docker-compose up -d

# View logs
cd /opt/sonarqube && docker-compose logs -f sonarqube

# Update SonarQube
cd /opt/sonarqube && docker-compose pull && docker-compose up -d

# Backup data
docker run --rm -v sonarqube_sonarqube_data:/data -v $(pwd):/backup ubuntu tar czf /backup/sonarqube-backup.tar.gz /data
```

## 🔥 Troubleshooting

### Problem: SonarQube won't start
```bash
# Check logs
docker-compose logs sonarqube

# Increase memory limits
echo 'vm.max_map_count=524288' >> /etc/sysctl.conf
sysctl -p
```

### Problem: GitHub Actions can't connect to SonarQube
1. Check `SONAR_HOST_URL` in secrets is correct
2. Ensure `SONAR_TOKEN` is valid
3. Verify SonarQube is accessible externally
4. Check firewall settings (port 9000 should be open)

### Problem: Low code coverage
1. Add more unit tests
2. Check coverage exclusions in settings
3. Ensure tests are running correctly

## 📈 Code Quality Recommendations

1. **Test Coverage**: Aim for 80%+ coverage
2. **Code Duplication**: Avoid repetitive code
3. **Complexity**: Break down complex methods
4. **Security**: Follow security recommendations
5. **Performance**: Optimize critical code sections

## 🎯 Next Steps

1. Set up notifications in Slack/Teams for analysis results
2. Integrate SonarQube with PR checks
3. Configure automated fixes for simple issues
4. Create dashboards for code quality monitoring

## 🔄 CI/CD Pipeline Flow

The pipeline follows this sequence:

1. **Build Stage**: Both frontend and backend must build successfully
2. **Test Stage**: All tests must pass with coverage reports generated
3. **SonarQube Analysis**: Code quality and coverage checks (80% minimum)
4. **Deploy Stage**: Docker images are built and pushed to GitHub Container Registry

### Pipeline Features:
- ✅ Parallel execution of frontend and backend jobs
- ✅ Automatic failure if coverage < 80%
- ✅ Quality gate enforcement
- ✅ Docker image publishing only after all checks pass
- ✅ Detailed pipeline status reporting

## 📊 Local Testing

Use the provided Makefile commands for local testing:

```bash
# Start SonarQube locally
make sonar-start

# Run backend tests with coverage
make sonar-backend

# Run frontend tests with coverage
make sonar-frontend

# Run all tests
make sonar-test

# Stop SonarQube
make sonar-stop
```

## 🔒 Security Considerations

- SonarQube analyzes code for security vulnerabilities
- Authentication tokens are stored as GitHub secrets
- Container runs with security best practices
- Regular updates recommended for security patches

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review SonarQube and GitHub Actions logs
3. Verify all prerequisites are met
4. Ensure proper network connectivity 