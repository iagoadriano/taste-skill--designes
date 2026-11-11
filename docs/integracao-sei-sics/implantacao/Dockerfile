# SIGA-Doc para a SEMUS: compila o codigo e monta o servidor de aplicacao.
# Etapa 1: compilar com Java 8.
FROM maven:3.8-openjdk-8 AS build
ARG SIGA_REPO=https://github.com/projeto-siga/siga.git
# Commit da versao 11.5 validada na prova de conceito (ramo develop, 04/11/2025).
ARG SIGA_COMMIT=c65f287e84f1a0626c79310da0245bc8abb3175c
# Commit do siga-docker de onde vem a configuracao base e os drivers de banco.
ARG DOCKER_COMMIT=e301c4c142818ba57dfb691f1275ff1f22319d06
WORKDIR /src
RUN git init -q . && git remote add origin ${SIGA_REPO} \
 && git fetch -q --depth 1 origin ${SIGA_COMMIT} && git checkout -q FETCH_HEAD
RUN mvn -B -q clean package -T 1C -DskipTests=true
WORKDIR /extras
RUN curl -fsSL -o modules.tar.gz https://raw.githubusercontent.com/projeto-siga/siga-docker/${DOCKER_COMMIT}/modules.tar.gz \
 && curl -fsSL -o standalone.xml https://raw.githubusercontent.com/projeto-siga/siga-docker/${DOCKER_COMMIT}/standalone.xml \
 && curl -fsSL -O https://github.com/projeto-siga/siga-docker/releases/latest/download/ckeditor.war \
 && curl -fsSL -O https://github.com/assijus/blucservice/releases/latest/download/blucservice.war \
 && curl -fsSL -O https://github.com/projeto-siga/vizservice/releases/latest/download/vizservice.war \
 && mkdir modules-x && tar -xzf modules.tar.gz -C modules-x

# Etapa 2: servidor de aplicacao.
FROM daggerok/jboss-eap-7.2:7.2.5-alpine
USER root
RUN apk add --no-cache graphviz ttf-freefont tzdata
ENV TZ=America/Araguaina LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8
COPY --from=build --chown=jboss /extras/modules-x/ ${JBOSS_HOME}/
COPY --from=build --chown=jboss /extras/*.war ${JBOSS_HOME}/standalone/deployments/
COPY --from=build --chown=jboss /src/target/siga.war /src/target/sigaex.war /src/target/sigawf.war ${JBOSS_HOME}/standalone/deployments/
COPY --from=build --chown=jboss /extras/standalone.xml ${JBOSS_HOME}/standalone/configuration/standalone.xml.modelo
COPY --chown=jboss iniciar.sh /iniciar.sh
RUN chmod +x /iniciar.sh
EXPOSE 8080
ENTRYPOINT ["/iniciar.sh"]
