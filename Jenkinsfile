pipeline {
    agent none
    stages {
        stage('Build On Windows') {
            agent { label "docker" }
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    // build docker file.
                    sh "cd docker_image && docker build -t opvolger/pxe . --build-arg GIT_HASH=${GIT_HASH} --build-arg WIMBOOT_VERSION=${WIMBOOT_VERSION}"
                    // login docker hub && push image
                    sh "docker login --username $USERNAME --password $PASSWORD && docker push opvolger/pxe"
                    cleanWs() // clean de stage!
                }
            }
        }
    }
}
