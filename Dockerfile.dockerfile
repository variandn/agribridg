# Use official Tomcat image with JDK 17 (best for modern JSP apps)
FROM tomcat:10.1-jdk23-temurin

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your built WAR file (this is the most important part)
COPY build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

# Optional: Copy context.xml for MySQL connection (we'll create this later)
COPY context.xml /usr/local/tomcat/conf/context.xml

EXPOSE 8080

CMD ["catalina.sh", "run"]