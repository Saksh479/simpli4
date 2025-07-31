# CI/CD Pipeline Documentation

## Overview

This document provides step-by-step instructions for setting up and managing the CI/CD pipeline for the Spring Boot demo application.

## Prerequisites

### Local Development Environment

- Java JDK 21
- Maven 3.9.0+
- Git
- IDE (Eclipse, IntelliJ IDEA, or VS Code)

### CI/CD Infrastructure

- GitHub account
- Jenkins server
- AWS EC2 instance

## Step-by-Step Setup Process

### 1. Source Code Management (GitHub)

#### 1.1 Create GitHub Repository

```bash
# Initialize local git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Spring Boot CI/CD demo application"

# Add remote origin (replace with your repository URL)
git remote add origin https://github.com/yourusername/spring-boot-cicd-demo.git

# Push to GitHub
git push -u origin main
```

#### 1.2 Repository Structure

The repository includes the following tracked files:

- **Source Code**: `src/` directory with Java classes and resources
- **Build Configuration**: `pom.xml` for Maven dependencies and build settings
- **CI/CD Pipeline**: `Jenkinsfile` defining the automated pipeline
- **Containerization**: `Dockerfile` for containerized deployments
- **Documentation**: `README.md` and this CI/CD documentation
- **Configuration**: `application.properties` for Spring Boot settings

#### 1.3 Ignored Files (.gitignore)

The following files are excluded from version control:

- Build artifacts (`target/` directory)
- IDE-specific files (`.idea/`, `.vscode/`, etc.)
- Log files and temporary files
- Environment-specific configurations
- Compiled class files

### 2. Jenkins Server Setup

#### 2.1 Install Jenkins

```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install openjdk-21-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

#### 2.2 Jenkins Initial Configuration

1. Access Jenkins web interface: `http://your-jenkins-server:8080`
2. Retrieve initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
3. Install suggested plugins
4. Create admin user

#### 2.3 Install Required Plugins

Navigate to **Manage Jenkins** → **Manage Plugins** → **Available** and install:

- Git Plugin
- GitHub Plugin
- Maven Integration Plugin
- Pipeline Plugin
- Publish Over SSH Plugin
- Blue Ocean (optional, for better UI)

#### 2.4 Configure Global Tools

Navigate to **Manage Jenkins** → **Global Tool Configuration**:

**JDK Configuration:**

- Name: `JDK-21`
- Installation: Automatic installation from oracle.com
- Version: Java 21

**Maven Configuration:**

- Name: `Maven-3.9.0`
- Installation: Automatic installation from Apache
- Version: 3.9.0

**Git Configuration:**

- Should be automatically detected if Git is installed on Jenkins server

### 3. AWS EC2 Instance Setup

#### 3.1 Launch EC2 Instance

1. **AMI**: Amazon Linux 2 or Ubuntu 20.04+
2. **Instance Type**: t2.micro (free tier) or larger based on needs
3. **Storage**: 8GB default (increase if needed)
4. **Security Group**: Configure inbound rules:
   - SSH (22) - Your IP
   - HTTP (80) - Anywhere (0.0.0.0/0)
   - HTTPS (443) - Anywhere (0.0.0.0/0)
   - Custom TCP (8080) - Anywhere (0.0.0.0/0)

#### 3.2 Connect to EC2 Instance

```bash
# Connect via SSH
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

#### 3.3 Install Prerequisites on EC2

```bash
# Update system packages
sudo yum update -y  # Amazon Linux
# OR
sudo apt update && sudo apt upgrade -y  # Ubuntu

# Install Java 21
sudo yum install -y java-21-amazon-corretto  # Amazon Linux
# OR
sudo apt install -y openjdk-21-jdk  # Ubuntu

# Verify Java installation
java -version

# Create deployment directories
sudo mkdir -p /opt/staging /opt/production
sudo chown ec2-user:ec2-user /opt/staging /opt/production  # Amazon Linux
# OR
sudo chown ubuntu:ubuntu /opt/staging /opt/production  # Ubuntu

# Install curl for health checks
sudo yum install -y curl  # Amazon Linux
# OR
sudo apt install -y curl  # Ubuntu
```

### 4. Pipeline Configuration

#### 4.1 Create Jenkins Pipeline Job

1. Navigate to Jenkins dashboard
2. Click **New Item**
3. Enter item name: `spring-boot-cicd-demo`
4. Select **Pipeline**
5. Click **OK**

#### 4.2 Configure Pipeline Job

**General Settings:**

- Description: Spring Boot CI/CD Demo Pipeline
- ✓ GitHub project: Enter your repository URL

**Build Triggers:**

- ✓ GitHub hook trigger for GITScm polling

**Pipeline Settings:**

- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: Your GitHub repository URL
- Credentials: Add GitHub credentials if repository is private
- Branch: `*/main`
- Script Path: `Jenkinsfile`

#### 4.3 Configure SSH Access to EC2

1. Generate SSH key pair on Jenkins server:

   ```bash
   ssh-keygen -t rsa -b 4096 -C "jenkins@your-domain.com"
   ```

2. Copy public key to EC2 instance:

   ```bash
   ssh-copy-id -i ~/.ssh/id_rsa.pub ec2-user@your-ec2-ip
   ```

3. Add private key to Jenkins credentials:
   - Navigate to **Manage Jenkins** → **Manage Credentials**
   - Click **(global)** domain
   - Click **Add Credentials**
   - Kind: SSH Username with private key
   - ID: `ec2-ssh-key`
   - Username: `ec2-user`
   - Private Key: Paste the private key content

### 5. GitHub Webhook Configuration

#### 5.1 Configure Webhook in GitHub

1. Navigate to your GitHub repository
2. Click **Settings** → **Webhooks**
3. Click **Add webhook**
4. Payload URL: `http://your-jenkins-server:8080/github-webhook/`
5. Content type: `application/json`
6. Events: Select "Just the push event"
7. ✓ Active
8. Click **Add webhook**

### 6. Testing the Pipeline

#### 6.1 Manual Pipeline Execution

1. Navigate to your Jenkins job
2. Click **Build Now**
3. Monitor the build progress in **Console Output**

#### 6.2 Automated Pipeline Trigger

1. Make a code change in your local repository
2. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Test automated pipeline trigger"
   git push origin main
   ```
3. Verify that Jenkins automatically triggers the build

### 7. Pipeline Stages Explained

#### Stage 1: Checkout

- Pulls latest source code from GitHub repository
- Ensures clean workspace for build

#### Stage 2: Build

- Compiles Java source code using Maven
- Downloads dependencies
- Validates code syntax

#### Stage 3: Test

- Executes unit tests
- Generates test reports
- Publishes test results to Jenkins

#### Stage 4: Package

- Creates JAR artifact
- Archives artifact for deployment

#### Stage 5: Code Quality Analysis

- Runs checkstyle for code quality
- Can be extended with SonarQube integration

#### Stage 6: Deploy to Staging

- Deploys application to staging environment
- Stops existing application instance
- Starts new application version

#### Stage 7: Health Check

- Verifies application health in staging
- Validates endpoints are responding

#### Stage 8: Deploy to Production (Main branch only)

- Deploys to production environment
- Only executes for main branch commits

#### Stage 9: Production Health Check

- Final verification of production deployment
- Ensures production environment is healthy

### 8. Monitoring and Troubleshooting

#### 8.1 Application Logs

```bash
# View application logs on EC2
ssh ec2-user@your-ec2-ip
tail -f /opt/production/app.log
```

#### 8.2 Health Check Endpoints

- Application Health: `http://your-ec2-ip:8080/health`
- Actuator Health: `http://your-ec2-ip:8080/actuator/health`
- Application Info: `http://your-ec2-ip:8080/info`

#### 8.3 Common Issues and Solutions

**Issue: Build Fails with Java Version Error**

```bash
# Solution: Verify Java version in Jenkins
java -version
echo $JAVA_HOME
```

**Issue: SSH Connection to EC2 Fails**

```bash
# Solution: Check security group rules and SSH key permissions
chmod 600 ~/.ssh/id_rsa
```

**Issue: Application Port Already in Use**

```bash
# Solution: Kill existing process
pkill -f "demo.*jar"
```

**Issue: Health Check Fails**

```bash
# Solution: Check application logs and verify port configuration
curl -v http://localhost:8080/actuator/health
```

### 9. Best Practices

#### 9.1 Security

- Use SSH keys for EC2 access
- Implement proper security groups
- Store sensitive data in Jenkins credentials
- Use HTTPS for production deployments

#### 9.2 Pipeline Optimization

- Use parallel stages where possible
- Cache Maven dependencies
- Implement proper error handling
- Use meaningful commit messages

#### 9.3 Monitoring

- Implement application logging
- Set up alerts for pipeline failures
- Monitor application performance
- Regular health checks

### 10. Maintenance

#### 10.1 Regular Updates

- Keep Jenkins plugins updated
- Update Java and Maven versions
- Security patches for EC2 instances
- Backup Jenkins configuration

#### 10.2 Scaling Considerations

- Implement load balancing for production
- Use Auto Scaling Groups for EC2
- Consider containerization with Docker/Kubernetes
- Implement database for application state

## Conclusion

This CI/CD pipeline provides a solid foundation for automated application deployment. The pipeline can be extended with additional stages such as:

- Integration testing
- Security scanning
- Performance testing
- Blue-green deployments
- Rollback mechanisms

For any issues or questions, refer to the troubleshooting section or check the application logs for detailed error information.
