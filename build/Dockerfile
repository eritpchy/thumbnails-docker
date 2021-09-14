FROM alpine:3.14
RUN apk --no-cache add ffmpeg bash imagemagick file
ADD thumbnails.sh /bin/thumbnails.sh
RUN chmod +x /bin/thumbnails.sh
ENTRYPOINT ["/bin/bash", "/bin/thumbnails.sh"]