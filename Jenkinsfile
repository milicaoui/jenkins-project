pipeline {
    agent any

    environment {
        UPMONTH_TESTS_REPO = 'git@bitbucket.org:upmonthteam/upmonth-tests.git'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()  // clean first, before checkout
            }
        }
        
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }
        
        stage('Verify docker-compose.yml') {
            steps {
                sh 'ls -la'
                sh 'test -f docker-compose.yml || (echo "docker-compose.yml missing!" && exit 1)'
            }
        }

        stage('Clone Projects') {
            steps {
                script {
                    echo "Cloning Pytest repo..."
                    dir('upm-tests') {
                        git branch: 'new-environment-setup',
                            url: 'git@bitbucket.org:upmonthteam/upmonth-tests.git',
                            credentialsId: 'bitbucket-ssh-key-new'

                        // ⬇️ Add this to confirm contents
                        sh '''
                            echo "--- Listing contents of upm-tests ---"
                            ls -la
                            echo "--- Showing requirements.txt ---"
                            cat requirements.txt || echo "❌ requirements.txt is missing"
                            echo "--- Showing Dockerfile ---"
                            cat Dockerfile || echo "❌ Dockerfile is missing"
                        '''
                    }
                }
            }
        }



        stage('Login to Amazon ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-creds']]) {
                    sh '''
                        echo "Logging into ECR..."
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 175663446849.dkr.ecr.us-east-1.amazonaws.com
                    '''
                }
            }
        }

        stage('Pull Service Images') {
            steps {
                sh '''
                    echo "Cleaning up any existing containers..."
                    docker compose down --remove-orphans || true
                    docker rm -f mongodb memcached-dsl pytest-service testupmonthdb || true

                    echo "Pulling latest images from ECR..."
                    docker compose pull
                    docker compose up -d
                '''
            }
        }

        stage('Start Containers') {
            steps {
                sh 'docker compose up -d'
            }
        }

        stage('Run Tests') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '''
                    docker exec pytest-service pytest -v tests/02_fund_permissions
                    '''
                }
            }
        }


        stage('Cleanup Old Containers') {
            steps {
                sh '''
                    echo "Cleaning up old Docker containers..."
                    docker compose down --remove-orphans || true
                    docker rm -f pytest-service || true
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
                    docker compose up --abort-on-container-exit --exit-code-from pytest-service pytest-service
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