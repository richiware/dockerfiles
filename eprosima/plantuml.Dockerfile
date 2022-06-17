FROM plantuml/plantuml-server:tomcat

COPY gitlab.intranet.eprosima.com.crt /usr/share/ca-certificates

RUN update-ca-certificates && \
    keytool -importcert -noprompt -file /usr/share/ca-certificates/gitlab.intranet.eprosima.com.crt -alias gitlab.intranet.eprosima.com -keystore /usr/local/openjdk-11/lib/security/cacerts  --storepass changeit
