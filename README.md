#Intro

This project was built and used on Linux Mint

##plex-and-others
plex, seer, radarr, sonarr, qbittorrent and others to manage and stream movies and tv shows.

##immich
Run your own "google pictures" server with face recognition, etc.

##homeassistant

This repo does not contain my automations, but this project structure makes is esy for code assistants to do the automation for you on the config file inside config folder:

I use it for, the below:
    Alert me when dryer is done (attached vibration sensor from yolink)
    Alert me on water leeks (yolink sensor)
    Setup vacation mode to:
        Switch thermostat to vacation mode
        Switch smart light switches to vacation mode

##cloudflare

Just runs the cloudflare docker container to create a tunel to access all services externally. Does not include cloud flare configuration. I use free tier zero trust with google OAuth, AI is your friend for setup.

##backup

Right now I only bother backing up Immich, might include homeassistant, plex and others in future.