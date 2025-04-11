pipeline {
    agent any
//    parameters {
//        string(name: 'RELEASE_VERSION', defaultValue: '', description: 'Tag name from GitHub releases')
//        string(name: 'RELEASE_ACTION', defaultValue: '', description: 'Action from GitHub release event')
//    }
     triggers {
        GenericTrigger(
            genericVariables: [
                // Extract "action" (e.g., "published")
                [key: 'RELEASE_ACTION', value: '$.action'],
                // Use JSONPath for nested fields (e.g., "release.tag_name")
                [key: 'RELEASE_VERSION', value: '$.release.tag_name'],
                [key: 'RELEASE_NAME', value: '$.release.name']
            ],
            token: 'release-trigger', // Must match your webhook URL token
            causeString: 'Triggered by GitHub Release: $RELEASE_VERSION',
            // Trigger only for "published" releases (not drafts)
            regexpFilterText: '$RELEASE_ACTION',
            regexpFilterExpression: '^published$',
            printContributedVariables: true, // Debug variables
            printPostContent: true // Print raw payload in logs
        )
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
                    //echo "RELEASE_VERSION: ${params.RELEASE_VERSION}"
                    //echo "RELEASE_ACTION: ${params.RELEASE_ACTION}"
                    echo "Release Tag: ${env.RELEASE_VERSION}"
                    echo "Release Name: ${env.RELEASE_NAME}"
                }
            }
        }
//        stage('Validate Release Version') {
//            steps {
//                script {
//                    if(!params.RELEASE_ACTION?.trim() || params.RELEASE_ACTION != 'published') {
//                        echo "Skipping pipeline: Action is '${params.RELEASE_ACTION}', expected 'published'"
//                        currentBuild.result = 'SUCCESS'
//                        return
//                    }
//                    if (!params.RELEASE_VERSION?.trim()) {
//                        error("RELEASE_VERSION is required. Make sure GitHub webhook sends the tag name.")
//                    }
//                    echo "Triggered by GitHub release (published): ${params.RELEASE_VERSION}"
//                }
//            }
//        }
        stage('Checkout'){
            steps {
                git url: 'https://github.com/samiularif/Pipeline-automation.git', branch: 'main'
            }
        }
        stage('Build Docker Image') {
        steps {
            script {
                sh """
                    docker build -t tanjim26/test-devops:${params.RELEASE_VERSION} \\
                    --build-arg APP_VERSION=${params.RELEASE_VERSION} \\
                    --build-arg WEATHER_API_KEY=${env.WEATHER_API_KEY} .
                """
            }
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