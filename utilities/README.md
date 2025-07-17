# QNAP Dedup extraction tool

## Build

```bash
 docker build -t qnap-dedup -f qnap-dedup.Dockerfile .
```

## Run

- X11

  ```bash
  docker run --rm  -it -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /run/media/ricardo/NASBackup/:/home/ricardo/NASBackup -v.:/home/ricardo/share -e DISPLAY qnap-dedup
  ```

- Wayland

  ```bash
  docker run --rm  -it -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY -v /run/media/ricardo/NASBackup/:/home/ricardo/NASBackup -v.:/home/ricardo/share -e WAYLAND_DISPLAY -e XDG_RUNTIME_DIR=/tmp -e XDG_SESSION_TYPE=wayland -e QT_QPA_PLATFORM=wayland qnap-dedup
  ```
