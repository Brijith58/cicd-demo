// ─────────────────────────────────────────────────────────────
// Jenkinsfile — Declarative CI/CD Pipeline (Windows Compatible)
// Project : cicd-demo (Node.js + Docker)
// ─────────────────────────────────────────────────────────────

pipeline {
    agent any

    environment {
        IMAGE_NAME     = 'cicd-demo'
        IMAGE_TAG      = "v${BUILD_NUMBER}"
        CONTAINER_NAME = 'cicd-demo-app'
        APP_PORT       = '3000'
        HOST_PORT      = '4000'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
    }

    stages {

        // ───────────── CHECKOUT ─────────────
        stage('📥 Checkout') {
            steps {
                echo '─────────────────────────────────────'
                echo '📥 Cloning source code from GitHub...'
                echo '─────────────────────────────────────'
                checkout scm
                echo "✅ Code checked out. Build #${BUILD_NUMBER}"
            }
        }

        // ───────────── INSTALL ─────────────
        stage('📦 Install Dependencies') {
            steps {
                echo '📦 Installing dependencies...'

                bat '''
                node -v
                npm -v
                npm install
                '''

                echo '✅ Dependencies installed'
            }
        }

        // ───────────── TEST ─────────────
        stage('🧪 Test') {
            steps {
                echo '🧪 Running tests...'

                bat '''
                npm test
                '''

                echo '✅ Tests passed'
            }
        }

        // ───────────── BUILD DOCKER ─────────────
        stage('🐳 Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."

                bat """
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                """

                echo "✅ Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        // ───────────── DEPLOY ─────────────
        stage('🚀 Deploy Container') {
            steps {
                echo "🚀 Deploying container..."

                bat """
                docker stop %CONTAINER_NAME% 2>nul
                docker rm %CONTAINER_NAME% 2>nul

                docker run -d ^
                --name %CONTAINER_NAME% ^
                -p %HOST_PORT%:%APP_PORT% ^
                --restart unless-stopped ^
                %IMAGE_NAME%:%IMAGE_TAG%

                echo Waiting for container...
                timeout /t 5

                docker ps | findstr %CONTAINER_NAME%
                """

                echo "✅ App running at http://localhost:${HOST_PORT}"
            }
        }

        // ───────────── VERIFY ─────────────
        stage('✅ Verify') {
            steps {
                echo '🔍 Verifying deployment...'

                bat """
                timeout /t 3
                curl -f http://localhost:%HOST_PORT%/health
                """

                echo "✅ Health check passed!"
            }
        }
    }

    // ───────────── POST ACTIONS ─────────────
    post {

        success {
            echo '════════════════════════════════════════'
            echo "✅ BUILD #${BUILD_NUMBER} SUCCEEDED!"
            echo "🌐 App: http://localhost:${HOST_PORT}"
            echo "🐳 Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo '════════════════════════════════════════'
        }

        failure {
            echo '════════════════════════════════════════'
            echo "❌ BUILD #${BUILD_NUMBER} FAILED!"
            echo '════════════════════════════════════════'

            bat """
            docker stop %CONTAINER_NAME% 2>nul
            docker rm %CONTAINER_NAME% 2>nul
            """
        }

        always {
            echo "📋 Pipeline Status: ${currentBuild.currentResult}"
        }
    }
}