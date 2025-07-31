pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.0'  // Configure this name in Jenkins Global Tool Configuration
        jdk 'JDK-21'         // Configure this name in Jenkins Global Tool Configuration
    }
    
    environment {
        MAVEN_OPTS = '-Xmx1024m'
        JAVA_HOME = tool('JDK-21')
        PATH = "${JAVA_HOME}/bin:${PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    publishCoverage adapters: [jacocoAdapter('target/site/jacoco/jacoco.xml')], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: false
                }
            }
        }
        
        stage('Code Quality Analysis') {
            steps {
                echo 'Running code quality checks...'
                // Uncomment and configure SonarQube if available
                // withSonarQubeEnv('SonarQube') {
                //     sh 'mvn sonar:sonar'
                // }
                sh 'mvn checkstyle:check'
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo 'Deploying to staging environment...'
                sh '''
                    # Stop existing application if running
                    pkill -f "demo-.*\\.jar" || true
                    
                    # Copy jar to deployment directory
                    cp target/*.jar /opt/staging/demo-app.jar
                    
                    # Start the application in background
                    nohup java -jar /opt/staging/demo-app.jar --server.port=8080 > /opt/staging/app.log 2>&1 &
                    
                    # Wait for application to start
                    sleep 30
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    def response = sh(
                        script: 'curl -f http://localhost:8080/health || exit 1',
                        returnStatus: true
                    )
                    if (response != 0) {
                        error 'Health check failed!'
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying to production environment...'
                sh '''
                    # Stop existing production application
                    pkill -f "demo-production.*\\.jar" || true
                    
                    # Copy jar to production directory
                    cp target/*.jar /opt/production/demo-production.jar
                    
                    # Start production application
                    nohup java -jar /opt/production/demo-production.jar --server.port=80 > /opt/production/app.log 2>&1 &
                    
                    # Wait for application to start
                    sleep 30
                '''
            }
        }
        
        stage('Production Health Check') {
            when {
                branch 'main'
            }
            steps {
                echo 'Performing production health check...'
                script {
                    def response = sh(
                        script: 'curl -f http://localhost:80/health || exit 1',
                        returnStatus: true
                    )
                    if (response != 0) {
                        error 'Production health check failed!'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed.'
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
            // Send success notification
            // emailext subject: "✅ Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //          body: "Build completed successfully. Check console output at ${env.BUILD_URL}",
            //          to: "team@example.com"
        }
        failure {
            echo 'Pipeline execution failed!'
            // Send failure notification
            // emailext subject: "❌ Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //          body: "Build failed. Check console output at ${env.BUILD_URL}",
            //          to: "team@example.com"
        }
    }
}
