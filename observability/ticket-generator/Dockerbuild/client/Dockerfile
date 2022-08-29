FROM alpine
RUN apk update
RUN apk add curl
COPY request.sh /
CMD ["/request.sh"]
