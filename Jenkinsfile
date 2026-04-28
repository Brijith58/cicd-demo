pipeline {
    agent any

    environment {
        IMAGE_NAME     = 'cicd-demo'
        IMAGE_TAG      = "v${BUILD_NUMBER}"
        DOCKER_USER    = 'brijith07'
        CONTAINER_NAME = 'cicd-demo-app'
        APP_PORT       = '3000'
        HOST_PORT      = '4000'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 20, unit: 'MINUTES')
        timestamps()
    }

    stages {

        // ───────────── CHECKOUT ─────────────
        stage('📥 Checkout') {
            steps {
                echo '📥 Cloning from GitHub...'
                checkout scm
                echo "✅ Build #${BUILD_NUMBER}"
            }
        }

        // ───────────── INSTALL ─────────────
        stage('📦 Install') {
            steps {
                bat '''
                node -v
                npm -v
                npm install
                '''
            }
        }

        // ───────────── TEST ─────────────
        stage('🧪 Test') {
            steps {
                bat 'npm test'
            }
        }

        // ───────────── BUILD DOCKER ─────────────
        stage('🐳 Build Image') {
            steps {
                bat """
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                """
            }
        }

        // ───────────── PUSH TO DOCKER HUB ─────────────
        stage('📤 Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-cred',
                    usernameVariable: 'DOCKER_USER_VAR',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    bat """
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER_VAR% --password-stdin

                    docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG%
                    docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKER_USER%/%IMAGE_NAME%:latest

                    docker push %DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG%
                    docker push %DOCKER_USER%/%IMAGE_NAME%:latest
                    """
                }
            }
        }

        // ───────────── DEPLOY ─────────────
        stage('🚀 Deploy') {
            steps {
                bat """
                docker stop %CONTAINER_NAME% 2>nul
                docker rm %CONTAINER_NAME% 2>nul

                docker run -d ^
                --name %CONTAINER_NAME% ^
                --restart unless-stopped ^
                -p %HOST_PORT%:%APP_PORT% ^
                %DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG%

                echo Waiting for container startup...
                ping -n 6 127.0.0.1 > nul

                docker ps | findstr %CONTAINER_NAME%
                """
            }
        }

        // ───────────── VERIFY ─────────────
        stage('✅ Verify') {
            steps {
                script {
                    def retries = 5
                    def success = false

                    for (int i = 0; i < retries; i++) {
                        try {
                            bat "curl -f http://localhost:${HOST_PORT}/health"
                            echo "✅ Health check passed"
                            success = true
                            break
                        } catch (Exception e) {
                            echo "⚠️ Retry ${i+1} failed... waiting"
                            bat "ping -n 4 127.0.0.1 > nul"
                        }
                    }

                    if (!success) {
                        error("❌ App failed health check")
                    }
                }
            }
        }

        // ───────────── OPTIONAL: PUSH BACK TO GITHUB ─────────────
        stage('📤 Push to GitHub (Optional)') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-cred',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {

                    bat """
                    git config user.name "jenkins"
                    git config user.email "jenkins@local"

                    git add .
                    git commit -m "CI update build %BUILD_NUMBER%" || echo No changes

                    git push https://%GIT_USER%:%GIT_PASS%@github.com/Brijith58/cicd-demo.git HEAD:main
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ SUCCESS: Build #${BUILD_NUMBER}"
            echo "🌐 App URL: http://localhost:${HOST_PORT}"
        }

        failure {
            echo "❌ FAILED: Build #${BUILD_NUMBER}"

            bat """
            docker stop %CONTAINER_NAME% 2>nul
            docker rm %CONTAINER_NAME% 2>nul
            """
        }
    }
}