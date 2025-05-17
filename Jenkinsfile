pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = 'dockerhub-cred'
    IMAGE_NAME = 'visionn7111/nginx-web-test'
    SERVER_IP = '13.124.177.239'
  }

  stages {
    stage('Clone') {
      steps {
        git url: 'https://github.com/itcen-project-2team/realtime-sharing-notebook-web-Test', branch: 'main'
      }
    }

    stage('Generate .env') {
      steps {
        writeFile file: '.env', text: '''
VITE_BACKEND_URL=http://13.124.177.239:8080
'''
      }
    }

    stage('Enable buildx') {
      steps {
        sh '''
          docker buildx create --name multiarch-builder --use || docker buildx use multiarch-builder
          docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
        '''
      }
    }

    stage('Docker Build for amd64') {
      steps {
        sh 'docker buildx build --platform linux/amd64 -t $IMAGE_NAME . --push'
      }
    }

    stage('Deploy to Web Server') {
      steps {
        sshagent(credentials: ['webserver-ssh-key']) {
          sh """
            ssh -o StrictHostKeyChecking=no ubuntu@$SERVER_IP '
              docker pull ${IMAGE_NAME} &&
              docker stop nginx-web || true &&
              docker rm nginx-web || true &&
              docker run -d --name nginx-web -p 80:80 ${IMAGE_NAME}
            '
          """
        }
      }
    }
  }
}
