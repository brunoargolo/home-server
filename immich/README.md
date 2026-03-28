# Immich

Immich is a self-hosted, open-source photo and video backup solution designed to be a private alternative to Google Photos or iCloud. It automatically backs up media from mobile devices, organizes them into albums, and offers fast searching with AI-powered features like face recognition, object detection, and map views

# Getting Started
Bring All Up
```docker compose up -d```

Bring All Down
```docker compose down```

Update
```
docker compose down
docker compose pull
docker compose up -d
```
# Backup
see ../backup/README.md

# Securing
To access immich externally, use cloudflare zero trust, simple dns. if you protect it with cloudflare or google auth your app wont be able to use it. You can use the app password feature in immich to create a password for the app, and use that password to access immich externally.

A safer approach would be to create a VPN on your network and access immich through that. Like WireGuard. 
If you have a router with openwrt like flint 2 this is free. Ask AI how to set it up.
