# 1단계: React 앱 빌드
FROM node:20 AS build

WORKDIR /app

# 먼저 패키지 설치 관련 파일 복사
COPY package*.json ./

# .env 복사 (중요)
COPY .env ./

# 나머지 소스 코드 복사
COPY . .

RUN npm install && npm run build

# 2단계: NGINX 서버
FROM nginx:stable-alpine

# 복사
COPY --from=build /app/dist /usr/share/nginx/html

# NGINX 설정 복사
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
