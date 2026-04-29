# Use official Tomcat 10.1 with JDK 21 (latest LTS)
FROM tomcat:10.1-jdk21-temurin

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Create app directory structure
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Copy web content (JSP, HTML, CSS, images, JARs, etc.)
COPY web/ /usr/local/tomcat/webapps/ROOT/

# Copy Java source files and compile them
COPY src/java/ /tmp/src/
RUN javac -cp "/usr/local/tomcat/lib/*:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*" \
    -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    /tmp/src/Servlets/MongoDBConnection.java \
    /tmp/src/Servlets/PasswordUtils.java \
    /tmp/src/Servlets/HtmlUtils.java \
    /tmp/src/Servlets/ImageServlet.java \
    /tmp/src/Servlets/UploadProductServlet.java && \
    rm -rf /tmp/src

# Render passes a PORT env variable — configure Tomcat to use it
# Falls back to 8080 if PORT is not set (local development)
EXPOSE 8080

CMD ["sh", "-c", "if [ -n \"$PORT\" ]; then sed -i \"s/8080/$PORT/g\" /usr/local/tomcat/conf/server.xml; fi && catalina.sh run"]
