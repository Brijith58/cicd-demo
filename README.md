# 🚀 CI/CD Pipeline Demo — Jenkins + GitHub + Docker

> A production-style CI/CD pipeline built with Node.js, Jenkins, GitHub Webhooks, and Docker. Designed for a college project demo that can be set up in 3–5 hours.

---

## 📌 Problem Statement

Modern software teams push code dozens of times per day. Manually building, testing, and deploying each change is slow, error-prone, and unscalable. There is a need for an **automated pipeline** that takes code from a developer's machine to a running application — consistently and reliably — every single time.

---

## 🎯 Objective

Build a fully automated CI/CD (Continuous Integration / Continuous Deployment) pipeline where:
- A developer pushes code to **GitHub**
- **Jenkins** is automatically notified via a webhook
- Jenkins runs the pipeline: installs dependencies, tests, builds a Docker image, and deploys a container
- The application becomes live on the server — **zero manual steps**

---

## 🛠️ Tools Used

| Tool        | Role                                              |
|-------------|---------------------------------------------------|
| **Node.js** | Application runtime (Express web server)         |
| **GitHub**  | Source code repository + Webhook trigger         |
| **Jenkins** | CI/CD automation server (runs the pipeline)      |
| **Docker**  | Containerization — build image, run container    |
| **npm**     | Package manager for Node.js dependencies         |

---

## 🏗️ Architecture Diagram (Text Format)

```
┌─────────────────────────────────────────────────────────────────┐
│                        DEVELOPER MACHINE                        │
│                                                                 │
│    [ Write Code ]  →  git push origin main                     │
└──────────────────────────────┬──────────────────────────────────┘
                               │  HTTP POST (Webhook)
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                         GITHUB REPO                             │
│                                                                 │
│   ┌─────────────┐    ┌────────────┐    ┌──────────────────┐   │
│   │   app.js    │    │ Dockerfile │    │   Jenkinsfile    │   │
│   │ package.json│    │            │    │   (pipeline def) │   │
│   └─────────────┘    └────────────┘    └──────────────────┘   │
└──────────────────────────────┬──────────────────────────────────┘
                               │  Triggers Jenkins via Webhook
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                       JENKINS SERVER                            │
│                                                                 │
│  Stage 1: 📥 Checkout   →  Clone repo from GitHub              │
│  Stage 2: 📦 Install    →  npm install                         │
│  Stage 3: 🧪 Test       →  npm test                            │
│  Stage 4: 🐳 Build      →  docker build -t cicd-demo .         │
│  Stage 5: 🚀 Deploy     →  docker run -d -p 4000:3000 ...      │
│  Stage 6: ✅ Verify     →  curl http://localhost:4000/health    │
└──────────────────────────────┬──────────────────────────────────┘
                               │  Deploys container
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOCKER CONTAINER                           │
│                                                                 │
│   Image: cicd-demo:v<BUILD_NUMBER>                             │
│   Container: cicd-demo-app                                     │
│   Port: 4000 (host) → 3000 (container)                         │
│                                                                 │
│   GET /         → App info (JSON)                              │
│   GET /health   → Health status                                │
│   GET /info     → Pipeline info                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Folder Structure

```
cicd-demo/
├── app.js           # Express application (3 API routes)
├── package.json     # Node.js project config & dependencies
├── Dockerfile       # Instructions to build Docker image
├── Jenkinsfile      # CI/CD pipeline definition (6 stages)
├── .dockerignore    # Files to exclude from Docker image
├── .gitignore       # Files to exclude from Git
└── README.md        # This file
```

---

## ⚙️ Step-by-Step Setup Instructions

### Prerequisites — Install these first

```bash
# 1. Java (required for Jenkins)
sudo apt update
sudo apt install -y openjdk-17-jdk

# 2. Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update && sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# 3. Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker jenkins   # Allow Jenkins to run Docker
sudo systemctl restart jenkins

# 4. Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

---

### Step 1 — Push Project to GitHub

```bash
# Clone or init your repo
git init cicd-demo
cd cicd-demo

# Copy all project files here, then:
git add .
git commit -m "Initial commit: CI/CD demo app"
git remote add origin https://github.com/YOUR_USERNAME/cicd-demo.git
git push -u origin main
```

---

### Step 2 — Configure Jenkins

1. Open Jenkins: `http://localhost:8080`
2. Get initial password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Install suggested plugins → Create admin user
4. Install additional plugins:
   - **Dashboard → Manage Jenkins → Plugins**
   - Search and install: `Git`, `Pipeline`, `Docker Pipeline`

---

### Step 3 — Create Jenkins Pipeline Job

1. **New Item** → Enter name: `cicd-demo` → Select **Pipeline** → OK
2. Under **General**: ✅ Check **"GitHub project"** → Enter your repo URL
3. Under **Build Triggers**: ✅ Check **"GitHub hook trigger for GITScm polling"**
4. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/YOUR_USERNAME/cicd-demo.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. Click **Save**

---

### Step 4 — Set Up GitHub Webhook

> This makes GitHub automatically notify Jenkins on every push.

1. Go to your GitHub repo → **Settings → Webhooks → Add webhook**
2. Fill in:
   - **Payload URL**: `http://YOUR_JENKINS_IP:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: ✅ Just the push event
3. Click **Add webhook**
4. ✅ A green checkmark should appear confirming delivery

> **Note**: If Jenkins is on your local machine, use [ngrok](https://ngrok.com) to expose it:
> ```bash
> ngrok http 8080
> # Use the https URL from ngrok as the webhook payload URL
> ```

---

### Step 5 — Run & Test

```bash
# Manual trigger (first time or testing)
# Go to Jenkins → cicd-demo → Build Now

# Or push any code change to trigger automatically:
echo "# test" >> README.md
git add . && git commit -m "Trigger pipeline" && git push
```

---

## ▶️ How to Run the Project Locally (Without Jenkins)

```bash
# 1. Install dependencies
npm install

# 2. Run with Node.js
npm start
# App available at http://localhost:3000

# 3. Build & run with Docker manually
docker build -t cicd-demo .
docker run -d --name cicd-demo-app -p 4000:3000 cicd-demo
# App available at http://localhost:4000
```

---

## 📊 Expected Output

### API Responses

**GET http://localhost:4000/**
```json
{
  "message": "🚀 CI/CD Pipeline Demo - App is Running!",
  "version": "1.0.0",
  "status": "healthy",
  "environment": "production",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "deployedBy": "Jenkins + Docker"
}
```

**GET http://localhost:4000/health**
```json
{ "status": "UP", "uptime": 42.3 }
```

### Jenkins Console Output (Success)
```
[Pipeline] stage: 📥 Checkout
✅ Code checked out. Build #3

[Pipeline] stage: 📦 Install Dependencies
npm install → added 57 packages in 2.1s
✅ Dependencies installed successfully

[Pipeline] stage: 🧪 Test
✅ Test Passed: App is healthy

[Pipeline] stage: 🐳 Build Docker Image
Successfully built a3f9c1b2d4e5
✅ Docker image built: cicd-demo:v3

[Pipeline] stage: 🚀 Deploy Container
cicd-demo-app   Up 5 seconds
✅ Container deployed! App running at http://localhost:4000

[Pipeline] stage: ✅ Verify
{"status":"UP","uptime":5.2}
✅ Health check passed! Application is live.

✅ BUILD #3 SUCCEEDED!
```

---

## 🐛 Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `docker: permission denied` | Jenkins can't run Docker | `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins` |
| `port 4000 already in use` | Old container running | `docker stop cicd-demo-app && docker rm cicd-demo-app` |
| Webhook not triggering | Wrong URL or firewall | Use ngrok; check payload URL ends with `/github-webhook/` |
| `npm: command not found` | Node not in Jenkins PATH | Add `/usr/bin` to Jenkins PATH in Manage Jenkins → System |
| `curl: (7) Connection refused` | App crashed in container | Run `docker logs cicd-demo-app` to see errors |
| Jenkins stuck at "waiting" | No agent available | In Manage Jenkins → Nodes, ensure built-in node is online |

---

## 🔗 Useful Docker Commands

```bash
# See running containers
docker ps

# See all containers (including stopped)
docker ps -a

# See container logs
docker logs cicd-demo-app

# Stop container
docker stop cicd-demo-app

# Remove container
docker rm cicd-demo-app

# List all images
docker images

# Remove image
docker rmi cicd-demo:latest
```

---

## 🎓 Viva Questions & Answers

**Q1: What is CI/CD?**
> CI (Continuous Integration) is the practice of automatically building and testing code on every push. CD (Continuous Deployment) is automatically deploying the tested code to production. Together they eliminate manual steps and reduce errors.

**Q2: What does Jenkins do in this project?**
> Jenkins acts as the automation server. It listens for a webhook from GitHub, then executes the Jenkinsfile pipeline — which installs dependencies, runs tests, builds a Docker image, and deploys the container.

**Q3: Why use Docker?**
> Docker packages the application with all its dependencies into a container that runs identically on any machine — no "works on my machine" issues. It also makes deployment fast and rollbacks easy.

**Q4: What is a Webhook?**
> A webhook is an HTTP POST request that GitHub sends to Jenkins whenever code is pushed. This is how Jenkins knows to start the pipeline automatically.

**Q5: What is a Jenkinsfile?**
> A Jenkinsfile is a text file that defines the entire CI/CD pipeline as code. It lives in the repository alongside the application code, making the pipeline versioned and auditable.

**Q6: What is the difference between CI and CD?**
> CI focuses on integrating and verifying code (build + test). CD focuses on delivering that verified code to users (deploy). CI ends at "it works"; CD ends at "users can use it."

**Q7: What happens if the Docker build fails?**
> Jenkins marks the stage as failed, stops the pipeline, and runs the `post { failure }` block — which cleans up any partially started containers and logs the failure.

**Q8: How would you scale this in production?**
> In production you'd add: Docker Hub to push/pull images, Kubernetes for orchestration, environment-specific deployments (staging/prod), secrets management, and notification alerts (Slack/email).

---

*Built for CI/CD Demo — Jenkins + GitHub + Docker*
