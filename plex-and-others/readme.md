# Media Server Setup

Configure a linux machine to act as a media server. 
If everything works as epected below the following links will work.

- [Plex](http://localhost:32400)
- [Radarr](http://localhost:7878/)
- [Sonarr](http://localhost:8989/)
- [Prowlarr](http://localhost:9696/)
- [Qbittorent](http://localhost:8080/)
- [Seer](http://localhost:5055/)

Ask AI how to configure each app to talk to each other.

# Torguard

You want to setup a proxy or VPN for torrenting. One safe option is Proxy only for torrents [Torguard](https://torguard.net/). Make sure to add configuration into qBittorrent and test it [here](https://torguard.net/checkmytorrentipaddress.php). The IP being reported should be of VPN/Proxy.

# Applications

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

## Prowlarr

[Prowlarr](https://prowlarr.com/) is an index manager for torrents. It integrates with sonarr and radarr nicely. It will automatically add the indexers into them.

- Add sonnar and radarr
- Add indexers of your choice
- Confirm that they are automatically added to sonnar/radarr


## Sonarr / Radarr

[Sonarr](https://sonarr.tv/) is manager for TV shows. It reaches out to torrent indexers and fetches all shows you are interested in. It user qBittorrent internally to do the actual downloading.

[Radarr](https://radarr.video/) is manager for Movies. It reaches out to torrent indexers and fetches all shows you are interested in. It user qBittorrent internally to do the actual downloading.

They are forks of each other and look very similar. They just manage different sort of media

- Add qbittorent as client
- Add notifications via telegram (optional)
    - Generate a bot using telegram @BotFather
    - Integrate bot using Settings -> Connect -> Notification
- Confirm indexers are configured (Prowlarr)
- Add root media library

## QTorrent

[qBittorrent](https://www.qbittorrent.org/) is torrent client. Radarr and Sonarr interact with it via APIs to instruct what to download.

- Enable web interface
- Setup global max upload/download speeds
- TODO figure out how files completed and gets removed. For now I simply set to continue seeding for 3 hours after complete and be remove automatically.

## Seer

[Seerr](https://overseerr.dev/) to discover new media and provide media request functionality. 


## Plex backup


TODO
https://github.com/alekdavis/PlexBackup/blob/master/PlexBackup.ps1
powershell.exe -ExecutionPolicy ByPass -File "C:\Users\kshat\OneDrive\media-pc\PlexBackup\PlexBackup.ps1"

## Radarr \ Sonarr \ Prowlarr

Both have built in capability for backup. I set it to create a backupfile every week and retain for 28 days.
simply copy this folders to cloud

\\wsl$\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes\media_radarr-data\_data\Backups
\\wsl$\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes\media_sonarr-data\_data\Backups
\\wsl$\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes\media_prowlarr-data\_data\Backups

for restore simply point to the backedup zip and apps will restore

## qBittorrent

Backup this folder
\\wsl$\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes\media_qtorrent-data\_data\qBittorrent

for restore simply stop the container and copy from backup to same folder overwritting files

## Seerr

Backup this folder
\\wsl$\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes\media_overseerr-data\_data

for restore simply stop the container and copy from backup to same folder overwritting files

# Phone

Bookmark all the apps on your phone to make it simpler. Ideally use something like [Hermit](https://play.google.com/store/apps/details?id=com.chimbori.hermitcrab&hl=en_CA&pli=1) to make it look like these are native apps on your home screen.