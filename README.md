# 🚀 CI/CD Pipeline with Jenkins, Docker & Azure VM

## 📌 Project Overview
This project demonstrates a complete CI/CD (Continuous Integration & Continuous Deployment) pipeline that automates application build, test, and deployment.

The system integrates:
- GitHub for source code management
- Jenkins for CI/CD automation
- Docker for containerization
- Docker Hub for image registry
- Azure Virtual Machine for deployment

---

## 🏗️ Architecture

Developer → GitHub → Webhook → Jenkins → Docker Build → Docker Hub → Azure VM → Application

---

## ⚙️ Technology Stack

| Layer            | Technology Used         |
|------------------|------------------------|
| Application      | Node.js                |
| CI/CD Tool       | Jenkins                |
| Containerization | Docker                 |
| Registry         | Docker Hub             |
| Cloud Platform   | Azure VM               |
| Version Control  | GitHub                 |

---

## 🔄 CI/CD Workflow

1. Developer pushes code to GitHub
2. GitHub webhook triggers Jenkins pipeline
3. Jenkins performs:
   - Build
   - Test
   - Docker image creation
4. Docker image is pushed to Docker Hub
5. Jenkins deploys container on Azure VM
6. Application becomes live

---

## 🐳 Docker Usage

### Build Image
docker build -t <your-dockerhub-username>/cicd-demo .

### Run Container
docker run -d -p 4000:3000 <your-dockerhub-username>/cicd-demo

---

## 🔧 Jenkins Setup

- Jenkins runs inside a Docker container
- Ports:
  - 8080 → Jenkins UI
  - 50000 → Agent communication
- Docker socket mounted for deployment control

---

## ☁️ Azure Deployment

- Ubuntu-based Azure Virtual Machine
- Public IP used for access
- Docker installed for container execution

---

## 🌐 Access Application

http://<Azure-Public-IP>:4000

---

## 🔐 Security Features

- Jenkins credentials management
- Docker container isolation
- Controlled GitHub access

---

## 📊 Monitoring

- Azure VM CPU & memory usage
- Docker container logs
- Application health endpoint

### Health Check
curl http://localhost:4000/health

---

## 🚀 Future Enhancements

- Terraform for Infrastructure as Code
- Kubernetes for orchestration
- Azure Monitor integration
- Security scanning (SonarCloud, OWASP ZAP)
- AI-based monitoring using Azure OpenAI

---

## 🎯 Learning Outcomes

- End-to-end CI/CD pipeline implementation
- Automated deployment using Jenkins
- Docker containerization
- Cloud deployment on Azure

---

## 👨‍💻 Author

Brijith

---

## 📜 License

This project is for educational purposes.