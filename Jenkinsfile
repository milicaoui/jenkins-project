pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '175663446849.dkr.ecr.$AWS_REGION.amazonaws.com'
        TEXT_EXTRACTION_IMAGE = "$ECR_REGISTRY/text-extraction:latest"
        QUERY_DSL_IMAGE = "$ECR_REGISTRY/upmonth-query-dsl:latest"
        ANALYTICS_IMAGE = "$ECR_REGISTRY/upmonth-analytics:latest"
        MYSQL_ROOT_PASSWORD = 'upmonth'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-creds']]) {
                    sh '''
                        echo "Logging into ECR..."
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Pull Service Images') {
            steps {
                sh '''
                    echo "Pulling latest images from ECR..."
                    docker compose pull
                '''
            }
        }

        stage('Cleanup Old Containers') {
            steps {
                sh '''
                    echo "Cleaning up old Docker containers..."
                    docker compose down --remove-orphans || true
                    docker rm -f pytest-tests || true
                    docker rm -f testupmonthdb || true
                '''
            }
        }

        stage('Verify Required Files') {
            steps {
                script {
                    sh """
                        echo "--- Workspace Directory ---"
                        ls -la
                        [ -f "docker-compose.yml" ] || (echo "❌ Missing docker-compose.yml" && exit 1)
                    """
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh '''
                    echo "Running integration tests with Docker Compose..."
                    docker compose up --abort-on-container-exit --exit-code-from pytest-tests pytest-tests
                '''
            }
        }
    }

    post {
        always {
            sh '''
                echo "Cleaning up Docker environment..."
                docker compose down --remove-orphans || true
            '''
        }
        success {
            echo "🎉 All integration tests passed!"
        }
        failure {
            echo "❌ Tests failed. Check logs above for details."
        }
    }
}