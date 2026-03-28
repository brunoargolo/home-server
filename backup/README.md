# Backup

The docker compose spins up backrest, which is an app with graphical interface to schedule restif backups. Think of restif like git for bynary files (but not really).
It can use multiple backends to store backup and some "indexing" data, then it cn tell which files changed and upload them but creating snapshots. So you can have multiple snapshots with same files variation but not duplicating any files that remain the same. Kind of like git commits/tags etc.

Blackblaze b2 is what I use for the back end, s3 would work too but its significantly more expensive. 

Use AI for instructions to setup backrest