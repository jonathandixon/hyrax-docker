FROM tomcat:7-jre8

# Set Environment Variables.
ENV FCREPO_VERSION=4.7.2 \
    FCREPO_HOME=/opt/fcrepo/data \
    FCREPO_PORT=8984

# Setup Fedora Data Volume.
RUN mkdir -p ${FCREPO_HOME}
VOLUME ${FCREPO_HOME}

# Download the Fedora WAR.
RUN curl -L http://repo1.maven.org/maven2/org/fcrepo/fcrepo-webapp/${FCREPO_VERSION}/fcrepo-webapp-${FCREPO_VERSION}.war > ${CATALINA_HOME}/webapps/fcrepo.war

# Copy the Server config.
COPY conf/server.xml ${CATALINA_HOME}/conf/server.xml

# Set Java options for Tomcat and Fedora.
ENV JAVA_OPTS='-Dfcrepo.home=${FCREPO_HOME} -Djava.awt.headless=true -Dfile.encoding=UTF-8 -server -Xms512m -Xmx1024m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=256m -XX:+DisableExplicitGC -Dfcrepo.modeshape.configuration=classpath:/config/jdbc-postgresql/repository.json -Dfcrepo.postgresql.host=fcrepo_db -Dfcrepo.postgresql.port=5432 -Dfcrepo.postgresql.username=root -Dfcrepo.postgresql.password=root'

EXPOSE 8984
