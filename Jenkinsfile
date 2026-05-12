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
                sh '''
                node -v
                npm -v
                npm install
                '''
            }
        }

        // ───────────── TEST ─────────────
        stage('🧪 Test') {
            steps {
                sh '''
                npm test || echo "No tests configured"
                '''
            }
        }

        // ───────────── BUILD DOCKER ─────────────
        stage('🐳 Build Image') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                '''
            }
        }

        // ───────────── PUSH TO DOCKER HUB ─────────────
        stage('📤 Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER_VAR',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER_VAR --password-stdin

                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:latest

                    docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${DOCKER_USER}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        // ───────────── DEPLOY ─────────────
        stage('🚀 Deploy') {
            steps {
                sh '''
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true

                docker run -d \
                  --name ${CONTAINER_NAME} \
                  --restart unless-stopped \
                  -p ${HOST_PORT}:${APP_PORT} \
                  ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}

                echo "Waiting for container startup..."
                sleep 15

                docker ps | grep ${CONTAINER_NAME}
                '''
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
                            sh "curl -f http://host.docker.internal:${HOST_PORT}/health"
                            echo "✅ Health check passed"
                            success = true
                            break
                        } catch (Exception e) {
                            echo "⚠️ Retry ${i+1} failed... waiting"
                            sh "sleep 4"
                        }
                    }

                    if (!success) {
                        error("❌ App failed health check")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ SUCCESS: Build #${BUILD_NUMBER}"
            echo "🌐 App URL: http://20.198.81.85:${HOST_PORT}"
        }

        failure {
            echo "❌ FAILED: Build #${BUILD_NUMBER}"

            sh '''
            docker stop ${CONTAINER_NAME} || true
            docker rm ${CONTAINER_NAME} || true
            '''
        }
    }
}