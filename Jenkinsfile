pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker')
        WEATHER_API_KEY = credentials('weather_api_key')
    }
    triggers {
        githubPush()
    }
    stages {
        stage('Checkout'){
            steps {
                git url: 'https://github.com/samiularif/Pipeline-automation.git', branch: 'main'
            }
        }
        stage('Set Version'){
            when {
                tag 'v*'
            }
            steps {
                script {
                    env.APP_VERSION = env.TAG_NAME
                }
            }
        }
        stage('Build Docker Image') {
            when {
                tag 'v*'
            }
            steps {
                script {
                    def version = env.APP_VERSION ?: 'latest'
                    docker.build("tanjim26/test-devops:${version}", "--build-arg APP_VERSION=${version} --build-arg WEATHER_API_KEY=${WEATHER_API_KEY} .")
                }
            }
        }
        stage('Push Docker Image') {
            when{
                tag 'v*'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'DOCKERHUB_CREDENTIALS') {
                        def version = env.APP_VERSION ?: 'latest'
                        def image = docker.image("tanjim26/test-devops:${version}")
                        image.push()
                        if (version != 'latest'){
                            image.push('latest')
                        }
                }
            }
        }
        }
    }    
}