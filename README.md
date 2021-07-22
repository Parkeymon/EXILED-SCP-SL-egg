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

###⚠️**WARNING**⚠️
If you need to make more thank 60 GitHub requests in an hour you NEED to use authentication or else the installation could possibly fail leaving you with a failed install state!
Each install/reinstall makes at least one request to check the egg version and one request per plugin that you add in so if you add 19 plugins and reinstall a few times within a short time frame it _will_ rate-limit you.

![Failed Install State](https://media.discordapp.net/attachments/867104159907840031/867106088767062027/unknown.png)

## How to use authentication

You should authenticate because it allows you to make up to _5000_ GitHub requests per hour as well as letting you download from private repos.

In order to use authentication all you need to do is fill out your GitHub username and Access Token in the startup configuration.
You can find a tutorial on how to get a token [here](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token).

It is important to follow the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege) and only grant the permissions it needs. 
In this case you don't need to add any scopes because we are just validating we are a user.

This should also allow you to download from private repos (Although I haven't tested it you may need additional scopes).

## Custom Docker Images

Server Image: https://github.com/Parkeymon/docker-scpsl

Script Container: https://github.com/Parkeymon/scpsl-install-docker
