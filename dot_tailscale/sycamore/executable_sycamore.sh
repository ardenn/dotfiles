#!/bin/sh

## Exit on failure
set -e

podman pod stop sycamore -i

podman pod rm sycamore -i

podman pod create --name sycamore -p 8080:80

podman run -d --pod=sycamore --security-opt label=disable --name=portainer --restart=unless-stopped -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z -v portainer_data:/data docker.io/portainer/portainer-ce:latest

podman run -d --name=sonarr --pod=sycamore -e PUID=1000 -e PGID=1000 -e UMASK=002 -v /home/rodgers/config/sonarr:/config:Z -v /run/media/rodgers/Cinemax:/data:z --restart unless-stopped lscr.io/linuxserver/sonarr:latest

podman run -d --name=radarr --pod=sycamore -e PUID=1000 -e PGID=1000 -e UMASK=002 -v /home/rodgers/config/radarr:/config:Z -v /run/media/rodgers/Cinemax:/data:z --restart unless-stopped lscr.io/linuxserver/radarr:latest

podman run -d --name=flaresolverr --pod=sycamore -e LOG_LEVEL=info --restart unless-stopped ghcr.io/flaresolverr/flaresolverr:latest

podman run -d --name=prowlarr --pod=sycamore -e PUID=1000 -e PGID=1000 -e UMASK=002 -v /home/rodgers/config/prowlarr:/config:Z --restart unless-stopped lscr.io/linuxserver/prowlarr:develop

podman run -d --name=qbittorrent --pod=sycamore -e PUID=1000 -e PGID=1000 -e UMASK=002 -e WEBUI_PORT=8282 -v /home/rodgers/config/qbittorent:/config:Z -v /run/media/rodgers/Cinemax/downloads:/data/downloads:z --restart unless-stopped lscr.io/linuxserver/qbittorrent:latest

podman run -d --pod=sycamore --security-opt label=disable --name=jellyfin --user 1000:1000 -v /home/rodgers/config/jellyfin/cache:/cache:Z -v /home/rodgers/config/jellyfin/config:/config:Z -v /run/media/rodgers/Cinemax:/media:z docker.io/jellyfin/jellyfin:latest

podman run -d --pod=sycamore --name=syncthing -e PUID=1000 -e PGID=1000 -v /home/rodgers/config/syncthing:/config:Z -v /run/media/rodgers/Cinemax/Photos:/data/photos:z --restart unless-stopped lscr.io/linuxserver/syncthing:latest

podman run -d --name=caddy --pod=sycamore -v /home/rodgers/config/caddy/Caddyfile:/etc/caddy/Caddyfile:z -v /home/rodgers/config/caddy/site:/srv:z -v /home/rodgers/config/caddy/data:/data:Z -v /home/rodgers/config/caddy/config:/config:Z --restart unless-stopped docker.io/library/caddy:2.6.2
