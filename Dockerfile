# Tomcat 9 + java 17
FROM tomcat:9.0-jdk17

# 기존 Tomcat 기본 앱 제거
RUN rm -rf /usr/local/tomcat/webapps/*

# 빌드된 war 파일 복사
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

# 8080 포트 오픈
EXPOSE 8080

# Tomcat 실행
CMD ["catalina.sh", "run"]