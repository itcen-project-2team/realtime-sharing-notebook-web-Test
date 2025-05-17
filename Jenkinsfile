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

    stage('Enable buildx & QEMU') {
      steps {
        sh '''
          # QEMU 실행 환경 등록 (ARM에서도 작동하게)
          docker run --privileged --rm tonistiigi/binfmt --install all

          # buildx 빌더 생성 (중복 방지)
          docker buildx inspect multiarch-builder || docker buildx create --name multiarch-builder --use
          docker buildx use multiarch-builder
          docker buildx inspect --bootstrap
        '''
      }
    }

    stage('Docker Build for amd64') {
      steps {
        sh '''
          docker buildx build \
            --platform linux/amd64 \
            -t $IMAGE_NAME . \
            --push
        '''
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
