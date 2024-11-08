
FROM eclipse-temurin:21 as builder
COPY . /app
RUN cd /app && ./mvnw -Dmaven.test.skip package


FROM eclipse-temurin:21-jre-ubi9-minimal as optimizer
COPY --from=builder /app/target/spring-petclinic-3.3.0-SNAPSHOT.jar /app/
WORKDIR /app/
#jar extract for efficiency -> #https://docs.spring.io/spring-boot/reference/packaging/efficient.html
RUN java -Djarmode=tools -jar /app/spring-petclinic-3.3.0-SNAPSHOT.jar extract --layers --launcher


FROM eclipse-temurin:21-jre-ubi9-minimal as runner
EXPOSE 8080
ENV MYSQL_URL=jdbc:mysql://mysql-pets/petclinic
ENTRYPOINT ["java",  "org.springframework.boot.loader.launch.JarLauncher"]
COPY --from=optimizer /app/spring-petclinic-3.3.0-SNAPSHOT/dependencies/ ./
COPY --from=optimizer /app/spring-petclinic-3.3.0-SNAPSHOT/spring-boot-loader/ ./
COPY --from=optimizer /app/spring-petclinic-3.3.0-SNAPSHOT/snapshot-dependencies/ ./
COPY --from=optimizer /app/spring-petclinic-3.3.0-SNAPSHOT/application/ ./
