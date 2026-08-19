# E1-1 필수 과제용 Dockerfile
# FROM: 기존 이미지(base image)를 선택합니다.
FROM nginx:alpine

# COPY: 내 웹 페이지를 NGINX의 기본 문서 폴더로 복사합니다.
COPY site/ /usr/share/nginx/html/

# EXPOSE: 컨테이너 안의 웹 서버 포트가 80임을 문서화합니다.
EXPOSE 80
