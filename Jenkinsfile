pipeline {
    agent any

    environment {
        UPMONTH_TESTS_REPO = 'git@bitbucket.org:upmonthteam/upmonth-tests.git'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Verify docker-compose.yml') {
            steps {
                sh '''
                    echo "📁 Verifying workspace contents..."
                    ls -la
                    test -f docker-compose.yml || (echo "❌ docker-compose.yml missing!" && exit 1)
                '''
            }
        }

        stage('Clone Test Repo') {
            steps {
                dir('upm-tests') {
                    git branch: 'new-environment-setup',
                        url: "${UPMONTH_TESTS_REPO}",
                        credentialsId: 'bitbucket-ssh-key-new'
                }
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-creds']]) {
                    sh '''
                        echo "🔐 Logging into ECR..."
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 175663446849.dkr.ecr.us-east-1.amazonaws.com
                    '''
                }
            }
        }

        stage('Start All Services') {
            steps {
                sh '''
                    echo "🧹 Cleaning up previous containers..."
                    docker compose down --remove-orphans || true

                    echo "📦 Pulling all service images..."
                    docker compose pull

                    echo "🚀 Starting all services..."
                    docker compose up -d

                    echo "✅ Services started:"
                    docker ps
                '''
            }
        }

        stage('Container Status and Logs') {
            steps {
                sh '''
                    echo "📋 Listing all running containers..."
                    docker ps

                    echo "📝 Tail logs from key services..."
                    docker logs --tail=20 webapp || echo "webapp not found"
                    docker logs --tail=20 pytest-service || echo "pytest-service not found"
                    docker logs --tail=20 mongodb || echo "mongodb not found"
                '''
            }
        }

        stage('Keep Alive') {
            steps {
                script {
                    echo "🟢 All services are running. You can now SSH to the agent and run docker exec commands."
                    echo "⏳ Sleeping for debug session..."
                    sh 'sleep 600' // Keep alive 10 min (change if needed)
                }
            }
        }
    }

    post {
        always {
            echo "🧼 Pipeline done. Use logs above to debug."
        }
    }
}
