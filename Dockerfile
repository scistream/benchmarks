FROM ubuntu:24.04

WORKDIR /app

COPY scripts/install.sh /app/
COPY scripts/version.sh /app/
RUN chmod +x /app/install.sh 
RUN /app/install.sh

CMD ["/app/install.sh"]
