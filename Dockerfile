FROM existdb/existdb:release

EXPOSE 8080

WORKDIR /exist

COPY build/*.xar autodeploy/
