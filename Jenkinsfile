pipeline {
    agent any
    parameters {
        string(name: 'RELEASE_VERSION', defaultValue: '', description: 'Tag name from GitHub releases')
    }
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker')
        WEATHER_API_KEY = credentials('weather_api_key')
    }
    options {
        skipDefaultCheckout()
        timestamps()
    }
    
    stages {
        stage('Debug Webhook Payload') {
            steps {
                script {
                    echo "RELEASE_VERSION: ${params.RELEASE_VERSION}"
                }
            }
        }
        stage('Validate Release Version') {
            steps {
                script {
                    if (!params.RELEASE_VERSION?.trim()) {
                        error("RELEASE_VERSION is required. Make sure GitHub webhook sends the tag name.")
                    }
                    echo "Triggered by GitHub release: ${params.RELEASE_VERSION}"
                }
            }
        }
        stage('Checkout'){
            steps {
                git url: 'https://github.com/samiularif/Pipeline-automation.git', branch: 'main'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                    export DOCKER_BUILDKIT=1
                    docker build -t yourimage:${params.RELEASE_VERSION} \
                    --build-arg APP_VERSION=${params.RELEASE_VERSION} \
                    --build-arg WEATHER_API_KEY=${env.WEATHER_API_KEY} .
                '''
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKERHUB_CREDENTIALS) {
                        def version = params.RELEASE_VERSION
                        def image = docker.image("tanjim26/test-devops:${version}")
                        image.push()
                        
                }
            }
        }
        }
    }    
}