# Spring Boot CI/CD Demo Application

A simple Spring Boot web application demonstrating Continuous Integration and Continuous Deployment (CI/CD) pipeline using Jenkins, GitHub, and AWS EC2.

## 🚀 Project Overview

This project serves as a demonstration of a complete CI/CD pipeline for a full-stack Java web application. It includes automated building, testing, and deployment processes designed for enterprise-level development workflows.

### Technical Stack

- **Backend**: Spring Boot 3.4.7
- **Frontend**: Thymeleaf, HTML5, CSS3
- **Build Tool**: Maven
- **Java Version**: 21
- **CI/CD**: Jenkins Pipeline
- **Version Control**: GitHub
- **Deployment**: AWS EC2

## 📁 Project Structure

```
demo/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/demo/
│   │   │       ├── DemoApplication.java          # Main Spring Boot application
│   │   │       └── controller/
│   │   │           └── HomeController.java       # Web controllers
│   │   └── resources/
│   │       ├── static/
│   │       │   └── css/
│   │       │       └── style.css                 # Application styles
│   │       ├── templates/
│   │       │   ├── index.html                    # Home page template
│   │       │   └── health.html                   # Health check page
│   │       └── application.properties            # Application configuration
│   └── test/
│       └── java/
│           └── com/example/demo/
│               └── DemoApplicationTests.java     # Unit tests
├── target/                                       # Build output (ignored in Git)
├── .gitignore                                    # Git ignore rules
├── Dockerfile                                    # Docker container configuration
├── Jenkinsfile                                   # Jenkins CI/CD pipeline
├── pom.xml                                       # Maven build configuration
└── README.md                                     # Project documentation
```

## 🛠️ Features

### Application Features

- **Home Page**: Responsive web interface with modern CSS styling
- **Health Check**: System status monitoring endpoint
- **Version Display**: Shows current application version and build information
- **Responsive Design**: Mobile-friendly interface

### CI/CD Pipeline Features

- **Automated Building**: Maven-based compilation and packaging
- **Unit Testing**: Automated test execution with reporting
- **Code Quality**: Checkstyle integration for code standards
- **Health Monitoring**: Automated health checks post-deployment
- **Multi-stage Deployment**: Staging and production environments
- **Artifact Management**: Build artifact archiving and management

## 🚀 Getting Started

### Prerequisites

- Java 21 or higher
- Maven 3.9.0 or higher
- Git
- Jenkins (for CI/CD)
- AWS EC2 instance (for deployment)

### Local Development

1. **Clone the repository**:

   ```bash
   git clone <your-github-repo-url>
   cd demo
   ```

2. **Run the application locally**:

   ```bash
   mvn spring-boot:run
   ```

3. **Access the application**:
   - Home page: http://localhost:8080
   - Health check: http://localhost:8080/health

### Building the Application

```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package the application
mvn package

# Run the packaged JAR
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

## 🐳 Docker Support

### Build Docker Image

```bash
docker build -t spring-boot-cicd-demo .
```

### Run Container

```bash
docker run -p 8080:8080 spring-boot-cicd-demo
```

## 🔧 CI/CD Pipeline Setup

### Jenkins Configuration

1. **Install Required Plugins**:

   - Git Plugin
   - Maven Integration Plugin
   - Pipeline Plugin
   - Publish Over SSH (for deployment)

2. **Configure Global Tools**:

   - JDK 21 (name: `JDK-21`)
   - Maven 3.9.0 (name: `Maven-3.9.0`)

3. **Create Pipeline Job**:
   - New Item → Pipeline
   - Pipeline script from SCM
   - Repository URL: Your GitHub repository
   - Script Path: `Jenkinsfile`

### AWS EC2 Setup

1. **Launch EC2 Instance**:

   - AMI: Amazon Linux 2 or Ubuntu 20.04+
   - Instance Type: t2.micro (or larger based on needs)
   - Security Group: Allow HTTP (80), HTTPS (443), SSH (22), and Custom (8080)

2. **Install Prerequisites on EC2**:

   ```bash
   # Update system
   sudo yum update -y  # Amazon Linux
   # or
   sudo apt update && sudo apt upgrade -y  # Ubuntu

   # Install Java 21
   sudo yum install -y java-21-amazon-corretto  # Amazon Linux
   # or
   sudo apt install -y openjdk-21-jdk  # Ubuntu

   # Create deployment directories
   sudo mkdir -p /opt/staging /opt/production
   sudo chown ec2-user:ec2-user /opt/staging /opt/production  # Amazon Linux
   # or
   sudo chown ubuntu:ubuntu /opt/staging /opt/production  # Ubuntu
   ```

3. **Configure SSH Access**:
   - Add Jenkins server's public key to EC2's `~/.ssh/authorized_keys`
   - Test SSH connection from Jenkins server

## 📊 Pipeline Stages

The Jenkins pipeline includes the following stages:

1. **Checkout**: Retrieves source code from GitHub
2. **Build**: Compiles the Java application using Maven
3. **Test**: Runs unit tests and generates reports
4. **Package**: Creates JAR artifact
5. **Code Quality Analysis**: Runs checkstyle and other quality checks
6. **Deploy to Staging**: Deploys to staging environment for testing
7. **Health Check**: Verifies application health in staging
8. **Deploy to Production**: Deploys to production (main branch only)
9. **Production Health Check**: Verifies production deployment

## 📝 Tracked Files in Git

### Files Included in Version Control:

- Source code (`src/`)
- Build configuration (`pom.xml`)
- CI/CD pipeline (`Jenkinsfile`)
- Docker configuration (`Dockerfile`)
- Documentation (`README.md`, `HELP.md`)
- Git configuration (`.gitignore`)

### Files Ignored by Git:

- Build artifacts (`target/`)
- IDE-specific files (`.idea/`, `.vscode/`, `.eclipse/`)
- Log files (`*.log`)
- Temporary files (`*.tmp`, `*.temp`)
- OS-specific files (`.DS_Store`, `Thumbs.db`)
- Environment-specific configurations
- Compiled class files (`*.class`)

## 🔍 Monitoring and Health Checks

The application includes built-in health monitoring:

- **Health Endpoint**: `/health` - Returns application status
- **Automated Checks**: Pipeline includes automated health verification
- **Status Indicators**: Visual status indicators in the web interface

## 🔧 Configuration

### Application Properties

Key configuration options in `application.properties`:

```properties
# Server configuration
server.port=8080

# Application information
spring.application.name=demo
management.endpoints.web.exposure.include=health,info

# Logging
logging.level.com.example.demo=INFO
```

## 🚀 Deployment Instructions

### Manual Deployment to EC2

1. **Build the application**:

   ```bash
   mvn clean package
   ```

2. **Copy JAR to EC2**:

   ```bash
   scp target/demo-0.0.1-SNAPSHOT.jar ec2-user@your-ec2-ip:/opt/production/
   ```

3. **Start the application on EC2**:
   ```bash
   ssh ec2-user@your-ec2-ip
   cd /opt/production
   nohup java -jar demo-0.0.1-SNAPSHOT.jar > app.log 2>&1 &
   ```

### Automated Deployment via Jenkins

The Jenkins pipeline automatically handles deployment when code is pushed to the repository:

- **Feature branches**: Deploy to staging environment
- **Main branch**: Deploy to both staging and production

## 🧪 Testing

### Run Tests Locally

```bash
# Run all tests
mvn test

# Run tests with coverage
mvn test jacoco:report

# Run specific test class
mvn test -Dtest=DemoApplicationTests
```

### Test Categories

- **Unit Tests**: Test individual components
- **Integration Tests**: Test component interactions
- **Health Check Tests**: Verify application endpoints

## 📈 Performance Considerations

- **JVM Configuration**: Optimized for containerized environments
- **Resource Limits**: Configured for efficient memory usage
- **Health Checks**: Regular monitoring for early issue detection
- **Graceful Shutdown**: Proper application lifecycle management

## 🔧 Troubleshooting

### Common Issues

1. **Port Already in Use**:

   ```bash
   # Kill process using port 8080
   pkill -f "demo.*jar"
   ```

2. **Java Version Issues**:

   ```bash
   # Verify Java version
   java -version
   echo $JAVA_HOME
   ```

3. **Permission Issues on EC2**:
   ```bash
   # Fix directory permissions
   sudo chown -R ec2-user:ec2-user /opt/staging /opt/production
   ```

## 📞 Support

For issues and questions:

1. Check the application logs: `/opt/production/app.log`
2. Verify health endpoint: `http://your-domain/health`
3. Review Jenkins build logs
4. Check EC2 instance status and security groups

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is created for educational and demonstration purposes.

---

**© 2025 Spring Boot CI/CD Demo Project**
