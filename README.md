# Basic CI/CD Pipeline Setup using Jenkins, Git, Docker, SonarQube,Trivy  and Dependency Check

## 1. Introduction

### 1.1 Purpose
This document provides a comprehensive guide to set up a basic CI/CD pipeline using Jenkins, Git, Docker, SonarQube, and Dependency Check. The pipeline aims to automate the building, testing, and deployment of software projects, ensuring continuous integration and delivery.

### 1.2 Scope
This guide is intended for software developers, DevOps engineers, and individuals involved in software development and deployment processes.

### 1.3 Audience
- Software Developers
- DevOps Engineers
- System Administrators

### 1.4 Document Conventions
- **Bold text:** Indicates actions or commands.
- *Italic text:* Indicates variable names or user-specific input.

## 2. Prerequisites

### 2.1 Software Requirements
- [Jenkins](https://www.jenkins.io/)
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [SonarQube](https://www.sonarqube.org/)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)

### 2.2 Familiarity with Concepts
Basic understanding of version control (Git), containerization (Docker), and continuous integration principles.

## 3. Jenkins Installation

### 3.1 Download Jenkins
Visit the [Jenkins download page](https://www.jenkins.io/download/) and download the latest version for your platform.

### 3.2 Installation Steps
1. **Run** the Jenkins installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.

![Alt text](images/jenkinsinsallation.png)

### 3.3 Access Jenkins
Open a web browser and navigate to `http://localhost:8080` to access the Jenkins dashboard. Follow the on-screen instructions to unlock Jenkins.

![Alt text](images/configure%20credentials.png)

## 4. Git Installation

### 4.1 Download Git
Visit the [Git download page](https://git-scm.com/downloads) and download the latest version for your platform.

### 4.2 Installation Steps
1. **Run** the Git installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.


![Alt text](images/plugginss.png)

## 5. Docker Installation

### 5.1 Download Docker
Visit the [Docker download page](https://www.docker.com/get-started) and download the latest version for your platform.

![Alt text](images/dockerpluggins.png)

### 5.2 Installation Steps
1. **Run** the Docker installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.

![Alt text](images/docckerjenkins.png)

## 6. SonarQube Installation

### 6.1 Download SonarQube
Visit the [SonarQube download page](https://www.sonarqube.org/downloads/) and download the latest version.

### 6.2 Installation Steps
1. **Run** the SonarQube installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.


![Alt text](images/sonarscanner.png)

### 6.3 Start SonarQube
Run SonarQube using Docker:
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube
```


![Alt text](images/sonar.png)

Access SonarQube at `http://localhost:9000` and use default credentials (admin/admin).

![Alt text](images/sonarQube%20(2).png)

## 7. Dependency Check Installation

### 7.1 Download Dependency Check
Visit the [Dependency-Check GitHub releases page](https://github.com/jeremylong/DependencyCheck/releases) and download the latest version.

![Alt text](images/dependencycheck.png)

### 7.2 Installation Steps
1. **Extract** the Dependency Check archive.
2. **Configure** the tool according to project needs.

## 8. CI/CD Pipeline Configuration

### 8.1 Jenkins Configuration
- **Install** necessary plugins (Git, Docker, SonarQube, etc.) from the Jenkins dashboard.
- **Configure** Jenkins credentials for Git, Docker, and SonarQube.

```bash
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/olaoyefaith/netflixcloneDevSecOps-Project.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }    
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            } 
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "docker build --build-arg TMDB_V3_API_KEY=<your TMDB API key> -t netflix ."
                       sh "docker tag netflix olaoyefaith/netflix: "
                       sh "docker push  olaoyefaith/netflix:latest "
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image olaoyefaith/netflix:latest > trivyimage.txt" 
            }
        }
        stage('Deploy to container'){
            steps{
                sh 'docker run -d --name netflix -p 8081:80 olaoyefaith/netflix:latest'
            }
        }
    }
}

```

### 8.2 Create Jenkins Pipeline
1. **Create** a new pipeline job in Jenkins.
2. **Configure** the pipeline to fetch source code from the Git repository.
3. **Define** pipeline stages (Build, Test, SonarQube Analysis, Docker Build, etc.).

![Alt text](images/jenkinssucces.png)

### 8.3 Run the Pipeline
- **Trigger** the pipeline manually or configure webhooks for automatic triggering on code commits.


![Alt text](images/buildsuccess.png)


![Alt text](images/dockerhub.png)

![Alt text](images/netflixsuccess.png)




## 9. Conclusion

### 9.1 Summary
This document has guided users through setting up a basic CI/CD pipeline using Jenkins, Git, Docker, SonarQube, and Dependency Check. The pipeline facilitates continuous integration, automated testing, and deployment, contributing to efficient and reliable software development practices.


---

