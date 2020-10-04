pipeline {
    agent none
    parameters {
        string(name: 'GIT_HASH', defaultValue: 'fe69934191ca46c4948a71f416c21dcc5a29e63a', description: 'git hash from ipxe repo')
        string(name: 'WIMBOOT_VERSION', defaultValue: '2.6.0', description: 'Wimboot signed version to download')
    }
    stages {
        stage('Build On Windows') {
            agent { label "docker" }
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    // build docker file.
                    sh "cd docker_image && docker build -t opvolger/pxe . --build-arg GIT_HASH=${params.GIT_HASH} --build-arg WIMBOOT_VERSION=${params.WIMBOOT_VERSION}"
                    // login docker hub && push image
                    sh "docker login --username $USERNAME --password $PASSWORD && docker push opvolger/pxe"
                    cleanWs() // clean de stage!
                }
            }
        }
    }
}
