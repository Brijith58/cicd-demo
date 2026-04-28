// ─────────────────────────────────────────────────────────────
// Jenkinsfile — Full CI/CD Pipeline (Windows + Docker + Push)
// Project : cicd-demo (Node.js)
// ─────────────────────────────────────────────────────────────

pipeline {
    agent any

    environment {
        IMAGE_NAME     = 'cicd-demo'
        IMAGE_TAG      = "v${BUILD_NUMBER}"
        DOCKERHUB_USER = 'brijith07'
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
                echo '📥 Cloning code from GitHub...'
                checkout scm
                echo "✅ Build #${BUILD_NUMBER}"
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

        // ───────────── BUILD ─────────────
        stage('🐳 Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'

                bat """
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                """

                echo "✅ Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        // ───────────── PUSH (OPTIONAL) ─────────────
        stage('📤 Push to Docker Hub') {
            steps {
                echo '📤 Pushing image to Docker Hub...'

                bat """
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKERHUB_USER%/%IMAGE_NAME%:%IMAGE_TAG%
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKERHUB_USER%/%IMAGE_NAME%:latest

                docker push %DOCKERHUB_USER%/%IMAGE_NAME%:%IMAGE_TAG%
                docker push %DOCKERHUB_USER%/%IMAGE_NAME%:latest
                """

                echo '✅ Image pushed to Docker Hub'
            }
        }

        // ───────────── DEPLOY ─────────────
        stage('🚀 Deploy Container') {
            steps {
                echo '🚀 Deploying container...'

                bat """
                docker stop %CONTAINER_NAME% 2>nul
                docker rm %CONTAINER_NAME% 2>nul

                docker run -d ^
                --name %CONTAINER_NAME% ^
                -p %HOST_PORT%:%APP_PORT% ^
                --restart unless-stopped ^
                %IMAGE_NAME%:%IMAGE_TAG%

                echo Waiting for container...
                ping 127.0.0.1 -n 6 > nul

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
                ping 127.0.0.1 -n 4 > nul
                curl -f http://localhost:%HOST_PORT%/health
                """

                echo '✅ Health check passed!'
            }
        }
    }

    // ───────────── POST ─────────────
    post {

        success {
            echo '════════════════════════════════════'
            echo "✅ BUILD #${BUILD_NUMBER} SUCCESS"
            echo "🌐 http://localhost:${HOST_PORT}"
            echo "🐳 ${IMAGE_NAME}:${IMAGE_TAG}"
            echo '════════════════════════════════════'
        }

        failure {
            echo '════════════════════════════════════'
            echo "❌ BUILD FAILED"
            echo '════════════════════════════════════'

            bat """
            docker stop %CONTAINER_NAME% 2>nul
            docker rm %CONTAINER_NAME% 2>nul
            """
        }

        always {
            echo "📋 Status: ${currentBuild.currentResult}"
        }
    }
}