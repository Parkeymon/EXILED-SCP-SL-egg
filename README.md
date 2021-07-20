# EXILED-SCP-SL-egg
[![wakatime](https://wakatime.com/badge/github/Parkeymon/EXILED-SCP-SL-egg.svg)](https://wakatime.com/badge/github/Parkeymon/EXILED-SCP-SL-egg)

A pterodactyl egg for SCP:SL that has [EXILED](https://github.com/Exiled-Team/EXILED) support.

Features:

- Beta tag support
- EXILED
- Select pre-release or release of EXILED
- Specific EXILED version support
- Discord integration bot and plugin
- Localadmin 
- Automiatically checks if the egg is up to date and notifys you when there is an update.
- Auto Admintools install 
- Auto Common Utilities install.
- Auto SCPStats install. 
- Automatically install and update any plugin you put in.
- Exiled updater auto-removal
- FFmpeg (for use with [CommsHack](https://github.com/VirtualBrightPlayz/CommsHack))

If you send a PR that only updates the [install script](https://github.com/Parkeymon/EXILED-SCP-SL-egg/blob/master/script.sh) don't send the exported egg just send the updated script.sh I will add it unless you need to make variable changes in the egg.

## Using the automatic plugin installer

Located in the `.egg/` directory if you enabled "AUTO INSTALL CUSTOM PLUGINS?" there should a file called `customplugins.txt`.
You can put the Github link to any plugin in there, one per line but it must be in the correct format for it to work.

### Format
```
https://api.github.com/repos/<PLUGIN-AUTHOR>/<REPO-NAME>/releases/latest
```

### Example for [BetterScp939](https://github.com/iopietro/BetterScp939)
```
https://api.github.com/repos/iopietro/BetterScp939/releases/latest
```


## Custom Docker Images

Server Image: https://github.com/Parkeymon/docker-scpsl

Script Container: https://github.com/Parkeymon/scpsl-install-docker
