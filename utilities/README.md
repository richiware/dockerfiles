# QNAP Dedup extraction tool

## Build

```bash
 docker build -t qnap-dedup -f qnap-dedup.Dockerfile .
```

## Run

```bash
docker run --rm  -it -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /run/media/ricardo/NASBackup/:/home/ricardo/NASBackup -v.:/home/ricardo/share -e DISPLAY qnap-dedup
```
