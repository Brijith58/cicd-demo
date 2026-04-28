// ─────────────────────────────────────────────────────────────
// Jenkinsfile — Declarative CI/CD Pipeline
// Project : cicd-demo (Node.js + Docker)
// Trigger : GitHub Webhook on push to main branch
// Stages  : Checkout → Install → Test → Build → Deploy
// ─────────────────────────────────────────────────────────────

pipeline {
    // Run on any available Jenkins agent
    agent any

    // ── Environment variables ──────────────────────────────────
    environment {
        IMAGE_NAME   = 'cicd-demo'          // Docker image name
        IMAGE_TAG    = "v${BUILD_NUMBER}"   // Tag = Jenkins build number
        CONTAINER_NAME = 'cicd-demo-app'    // Running container name
        APP_PORT     = '3000'               // Port inside container
        HOST_PORT    = '4000'               // Port exposed on host machine
    }

    // ── Pipeline options ───────────────────────────────────────
    options {
        // Keep only last 5 builds to save disk space
        buildDiscarder(logRotator(numToKeepStr: '5'))
        // Fail if pipeline takes longer than 15 minutes
        timeout(time: 15, unit: 'MINUTES')
        // Add timestamps to console output
        timestamps()
    }

    // ── Pipeline Stages ────────────────────────────────────────
    stages {

        // STAGE 1: Clone the repository from GitHub
        stage('📥 Checkout') {
            steps {
                echo '─────────────────────────────────────'
                echo '📥 Cloning source code from GitHub...'
                echo '─────────────────────────────────────'
                // Jenkins SCM checkout (uses repo configured in job settings)
                checkout scm
                echo "✅ Code checked out. Build #${BUILD_NUMBER}"
            }
        }

        // STAGE 2: Install Node.js dependencies
        stage('📦 Install Dependencies') {
            steps {
                echo '──────────────────────────────────────────'
                echo '📦 Installing Node.js dependencies (npm)...'
                echo '──────────────────────────────────────────'
                sh 'node --version'
                sh 'npm --version'
                sh 'npm install'
                echo '✅ Dependencies installed successfully'
            }
        }

        // STAGE 3: Run basic application test
        stage('🧪 Test') {
            steps {
                echo '──────────────────────────────'
                echo '🧪 Running application tests...'
                echo '──────────────────────────────'
                sh 'npm test'
                echo '✅ Tests passed'
            }
        }

        // STAGE 4: Build Docker image
        stage('🐳 Build Docker Image') {
            steps {
                echo '──────────────────────────────────────────'
                echo "🐳 Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                echo '──────────────────────────────────────────'
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                """
                echo "✅ Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        // STAGE 5: Stop and remove any existing container, then deploy new one
        stage('🚀 Deploy Container') {
            steps {
                echo '────────────────────────────────────────────────────'
                echo "🚀 Deploying container: ${CONTAINER_NAME} on port ${HOST_PORT}"
                echo '────────────────────────────────────────────────────'
                sh """
                    # Stop old container if it exists (ignore errors if not running)
                    docker stop ${CONTAINER_NAME} || true
                    docker rm   ${CONTAINER_NAME} || true

                    # Run new container
                    docker run -d \\
                        --name ${CONTAINER_NAME} \\
                        -p ${HOST_PORT}:${APP_PORT} \\
                        --restart unless-stopped \\
                        ${IMAGE_NAME}:${IMAGE_TAG}

                    echo '⏳ Waiting for container to start...'
                    sleep 5

                    # Verify the container is running
                    docker ps | grep ${CONTAINER_NAME}
                """
                echo "✅ Container deployed! App running at http://localhost:${HOST_PORT}"
            }
        }

        // STAGE 6: Verify deployment with a quick health check
        stage('✅ Verify') {
            steps {
                echo '────────────────────────────────────'
                echo '✅ Verifying deployment health check...'
                echo '────────────────────────────────────'
                sh """
                    sleep 3
                    curl -f http://localhost:${HOST_PORT}/health || exit 1
                    echo ""
                    echo "✅ Health check passed! Application is live."
                """
            }
        }
    }

    // ── Post-build actions ─────────────────────────────────────
    post {
        success {
            echo '════════════════════════════════════════'
            echo "✅ BUILD #${BUILD_NUMBER} SUCCEEDED!"
            echo "🌐 App live at: http://localhost:${HOST_PORT}"
            echo "🐳 Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo '════════════════════════════════════════'
        }
        failure {
            echo '════════════════════════════════════════'
            echo "❌ BUILD #${BUILD_NUMBER} FAILED!"
            echo '📋 Check the console output above for errors.'
            echo '════════════════════════════════════════'
            // Clean up failed container if partially started
            sh "docker stop ${CONTAINER_NAME} || true"
            sh "docker rm   ${CONTAINER_NAME} || true"
        }
        always {
            echo "📋 Pipeline finished. Status: ${currentBuild.currentResult}"
        }
    }
}
