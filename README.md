# thumbnails-docker
Recursion create .thumb/file.webp in each (image/video) directory

For https://github.com/eritpchy/rcx

### Usage
docker-compose build --no-rm

UID_GID="$(id -u Jason):$(id -g Jason)" docker-compose run --rm -v /test:/test thumbnails /test