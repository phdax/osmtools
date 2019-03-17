osmtools
====================

[![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/phdax/osmtools/)

This image contains osmfilter, osmosis, and osmconvert.

## Usage

### RUN
```
docker run --rm --name -v [WORKSPACE]:/mnt phdax/osmtools osmfilter ...
docker run --rm --name -v [WORKSPACE]:/mnt phdax/osmtools osmosis ...
docker run --rm --name -v [WORKSPACE]:/mnt phdax/osmtools osmconvert ...
```

### RUN & EXEC
```
docker run -d --name osmtools -v [WORKSPACE]:/mnt phdax/osmtools
docker exec -it osmtools osmfilter ...
docker exec -it osmtools osmosis ...
docker exec -it osmtools osmconvert ...
```

