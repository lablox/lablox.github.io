FROM ghcr.io/imorty/webimg:latest
COPY build.sh /build.sh
RUN chmod +x build.sh
ENTRYPOINT ["/build.sh"]
