// =====================================================================
//  Jenkins Declarative Pipeline - CI/CD for the Flask demo app
//  Stages: Checkout -> Build -> Test -> Docker Build -> Deploy -> Verify
// =====================================================================
pipeline {
    agent any

    // Automated source-code integration: Jenkins polls GitHub every
    // ~2 minutes and starts a build automatically when a new commit appears.
    triggers {
        pollSCM('H/2 * * * *')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    environment {
        APP_NAME   = 'cicd-demo-app'
        IMAGE_NAME = 'cicd-demo-app'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        APP_PORT   = '5000'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Fetching source code from GitHub...'
                checkout scm
                sh 'git log -1 --pretty=format:"Commit: %h | Author: %an | Message: %s"'
            }
        }

        stage('Build') {
            steps {
                echo 'Creating virtual environment and installing dependencies...'
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --quiet --upgrade pip
                    pip install --quiet -r requirements.txt
                    python -m py_compile app.py
                    echo "Build successful"
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests with pytest...'
                sh '''
                    . .venv/bin/activate
                    mkdir -p reports
                    pytest -v --junitxml=reports/test-results.xml
                '''
            }
            post {
                always {
                    junit 'reports/test-results.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest .'
                sh 'docker images $IMAGE_NAME'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying new container (replacing the old one)...'
                sh '''
                    docker rm -f $APP_NAME 2>/dev/null || true
                    docker run -d --name $APP_NAME \
                        -p $APP_PORT:5000 \
                        -e BUILD_NUMBER=$IMAGE_TAG \
                        -e APP_ENV=production \
                        --restart unless-stopped \
                        $IMAGE_NAME:$IMAGE_TAG
                    docker ps --filter name=$APP_NAME
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Smoke-testing the live application...'
                sh '''
                    for i in $(seq 1 15); do
                        if curl -fs http://localhost:$APP_PORT/health; then
                            echo ""
                            echo "Application is UP on port $APP_PORT"
                            exit 0
                        fi
                        echo "Waiting for app... ($i)"
                        sleep 2
                    done
                    echo "Application did not start" && exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "PIPELINE SUCCESS - Build #${env.BUILD_NUMBER} deployed at http://<EC2-PUBLIC-IP>:${APP_PORT}"
            archiveArtifacts artifacts: 'reports/*.xml', allowEmptyArchive: true
        }
        failure {
            echo "PIPELINE FAILED - check the stage logs above."
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}
