
# CI/CD Pipeline Setup with Jenkins, Git, Docker, SonarQube, Trivy, Dependency Check, Terraform for AKS, and ArgoCD

## 1. Introduction

### 1.1 Purpose
This guide outlines the setup of a comprehensive CI/CD pipeline using Jenkins, Git, Docker, SonarQube, Trivy, Dependency Check, Terraform for AKS cluster provisioning, and ArgoCD for application deployment. It focuses on automating software project building, testing, AKS cluster creation, and application deployment, ensuring continuous integration and delivery.

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
- [Terraform](https://www.terraform.io/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [ArgoCD](https://argoproj.github.io/argo-cd/)

### 2.2 Familiarity with Concepts
Basic understanding of version control (Git), containerization (Docker), and continuous integration principles.

## 3. Jenkins Installation

### 3.1 Download Jenkins
Visit the [Jenkins download page](https://www.jenkins.io/download/) and download the latest version for your platform.

### 3.2 Installation Steps
1. **Run** the Jenkins installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.

  ![Jenkins Installation](images/jenkinsinsallation.png)

### 3.3 Access Jenkins
Open a web browser and navigate to `http://localhost:8080` to access the Jenkins dashboard. Follow the on-screen instructions to unlock Jenkins.

  ![Configure Credentials](images/configure%20credentials.png)

## 4. Git Installation

### 4.1 Download Git
Visit the [Git download page](https://git-scm.com/downloads) and download the latest version for your platform.

### 4.2 Installation Steps
1. **Run** the Git installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.

  ![Git Plugins](images/plugginss.png)

## 5. Docker Installation

### 5.1 Download Docker
Visit the [Docker download page](https://www.docker.com/get-started) and download the latest version for your platform.

 ![Docker Plugins](images/dockerpluggins.png)

### 5.2 Installation Steps
1. **Run** the Docker installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.

 ![Docker Jenkins Integration](images/docckerjenkins.png)

## 6. SonarQube Installation

### 6.1 Download SonarQube
Visit the [SonarQube download page](https://www.sonarqube.org/downloads/) and download the latest version.

### 6.2 Installation Steps
1. **Run** the SonarQube installer.
2. **Follow** the installation wizard instructions.
3. **Complete** the installation.

![SonarQube Scanner](images/sonarscanner.png)

### 6.3 Start SonarQube
Run SonarQube using Docker:

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube
```

 ![SonarQube Dashboard](images/sonar.png)

Access SonarQube at `http://localhost:9000` and use default credentials (admin/admin).

![SonarQube Dashboard](images/sonarQube%20(2).png)

## 7. Dependency Check Installation

### 7.1 Download Dependency Check
Visit the [Dependency-Check GitHub releases page](https://github.com/jeremylong/DependencyCheck/releases) and download the latest version.

  ![Dependency Check](images/dependencycheck.png)

### 7.2 Installation Steps
1. **Extract** the Dependency Check archive.
2. **Configure** the tool according to project needs.

## 8. CI/CD Pipeline Configuration

### 8.1 Jenkins Configuration
- **Install** necessary plugins (Git, Docker, SonarQube, etc.) from the Jenkins dashboard.
- **Configure** Jenkins credentials for Git, Docker, and SonarQube.

```bash
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/olaoyefaith/netflixcloneDevSecOps-Project.git'
            }
        }
        stage("Sonarqube Analysis ") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }    
        }
        stage("quality gate") {
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
        stage("Docker Build & Push") {
            steps {
                script {
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {   
                       sh "docker build --build-arg TMDB_V3_API_KEY=<your TMDB API key> -t netflix ."
                       sh "docker tag netflix olaoyefaith/netflix: "
                       sh "docker push  olaoyefaith/netflix:latest "
                    }
                }
            }


        }
        stage("TRIVY") {
            steps {
                sh "trivy image olaoyefaith/netflix:

latest > trivyimage.txt" 
            }
        }
        stage('Deploy to container') {
            steps {
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

  ![Jenkins Success](images/jenkinssucces.png)

### 8.3 Run the Pipeline
- **Trigger** the pipeline manually or configure webhooks for automatic triggering on code commits.

  ![Build and Success](images/buildandsuccess.png)

  ![DockerHub](images/dockerhub.png)
  
  ![Netflix Success](images/netflixsuccess.png)

## 9. Prometheus and Grafana Integration

### 9.1 Prometheus Installation and Setup

#### 9.1.1 Download Prometheus
Visit the [Prometheus download page](https://prometheus.io/download/) and download the latest version for your platform.

#### 9.1.2 Installation Steps
1. **Extract** the Prometheus archive to a directory of your choice.
2. **Configure** the `prometheus.yml` file according to your monitoring requirements.

#### 9.1.2 systemd

#### 9.1.2.1 Configure Prometheus

Edit the `prometheus.yml` configuration file:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'myapp'
    static_configs:
      - targets: ['localhost:8081']  
```

#### 9.1.2.2 Create a systemd Service Unit

Create a systemd service unit file for Prometheus:

```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=Promethues
ExecStart=/path/to/prometheus/prometheus 
--config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle
Restart=always

[Install]
WantedBy=default.target
```

#### 9.1.2.3 Reload systemd and Start Prometheus

Reload the systemd manager configuration:

```bash
sudo systemctl daemon-reload
```

Start Prometheus:

```bash
sudo systemctl start prometheus
```

Enable Prometheus to start on boot:

```bash
sudo systemctl enable prometheus
```

Now, Prometheus is running as a daemon process managed by systemd. You can check its status using:

```bash
sudo systemctl status prometheus
```

#### 9.1.3 Access Prometheus
Open a web browser and navigate to `http://localhost:9090` to access the Prometheus dashboard.

  ![Prometheus Dashboard](images/promethues.png)
  
  
  ![Prometheus Targets](images/promethuestarget.png)

### 9.2 Grafana Installation and Setup

#### 9.2.1 Download Grafana
Visit the [Grafana download page](https://grafana.com/get) and download the latest version for your platform.

#### 9.2.2 Installation Steps
1. **Extract** the Grafana archive to a directory of your choice.
2. **Run** Grafana using the following command:
   ```bash
   ./bin/grafana-server
   ```

 ![Grafana Dashboard](images/grafana.png)

#### 9.2.3 Access Grafana
Open a web browser and navigate to `http://localhost:3000` to access the Grafana dashboard.

#### 9.2.4 Configure Prometheus as a Data Source in Grafana
1. Log in to Grafana (default credentials: admin/admin).
2. Add Prometheus as a data source.
3. Configure the Prometheus HTTP URL (`http://localhost:9090` by default).

## 8. Terraform for AKS Deployment

### 8.1 Install Terraform
Follow the [official Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.

### 8.2 AKS Cluster Provisioning
1. **Create a Terraform configuration file (e.g., `aks.tf`) to define AKS infrastructure.**
   ```bash
   resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  }

  resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "systempool"
    node_count = var.node_count
    vm_size    = "Standard_D2s_v4"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }
  }
  ```
2. **Run Terraform commands to initialize and apply the configuration.**
   ```bash
   terraform init
   terraform apply
   ```
  ![Terraform Init](images/terraforminit.png)

  ![Terraform AKS Create](images/terraformakscreate.png)

  ![Terraform Output](images/terraformoutput.png)

## 9. Azure CLI Authentication for Terraform

### 9.1 Install Azure CLI
Follow the [Azure CLI installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

### 9.2 Authenticate to Azure
1. **Open a terminal and run the following command to log in to your Azure account.**
   ```bash
   az login
   ```
2. **Follow the on-screen instructions to complete the authentication process.

## 10. ArgoCD Installation and Setup

### 10.1 Install ArgoCD
1. **Follow the [ArgoCD installation guide](https://argoproj.github.io/argo-cd/getting_started/#1-install-argo-cd) to install ArgoCD on your cluster.**
2. **Expose the ArgoCD API server externally if needed.**
   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
   ```

  ![ArgoCD Installation](images/argoinstallation.png)

3. **Retrieve the ArgoCD server external IP and access the ArgoCD UI.**
   ```bash
   kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

  ![ArgoCD Cluster](images/argocluster.png)

  ![ArgoCD Namespace](images/argonamespace.png)

### 10.2 Retrieve ArgoCD Admin Password
1. **Identify the ArgoCD server pod.**
   ```bash
   kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
   ```
2. **Retrieve the ArgoCD admin password using the identified pod.**
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```
3. **Use the obtained password to log in to the ArgoCD UI.**

### 10.3 Deploy Application with ArgoCD
1. **Access the ArgoCD UI using the external IP obtained earlier.**
2. **Log in with the default credentials (admin/<argocd-server-pod-name>).**
3. **Add your Git repository as a new application source in the ArgoCD UI.**
4. **Configure the application with the appropriate settings for your project.**
5. **Deploy your application using ArgoCD.**
 
  ![Alt text](images/argonetflix.png)

  # Conclusion

This guide outlines the creation of a comprehensive CI/CD pipeline with Jenkins, Git, Docker, SonarQube, Trivy, Dependency Check, Terraform for AKS, and ArgoCD. Automated processes cover building, testing, security scanning, AKS cluster provisioning, and application deployment.

Prometheus and Grafana integration enhances monitoring, offering insights for efficient and confident software delivery. Terraform and ArgoCD support infrastructure as code practices, emphasizing security with tools like SonarQube, Dependency Check, and Trivy.

Follow these steps to establish a DevSecOps pipeline, promoting continuous integration, continuous delivery, and robust security practices for a dependable software development lifecycle.