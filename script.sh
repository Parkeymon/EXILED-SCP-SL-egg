#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'debian:buster-slim'
apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates
apt-get update
apt-get -y install libicu63
apt-get update
apt-get -y install wget
apt-get update
apt-get -y install libsdl2-2.0-0:i386


## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

if [ "${BETA_TAG}" == "none" ]; then
    ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update ${SRCDS_APPID} validate +quit
else
    ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update ${SRCDS_APPID} ${BETA_TAG} validate +quit
fi
## install game using steamcmd

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

cd /mnt/server

if [ "${INSTALL_MULTIADMIN}" == "true" ]; then 
    echo "Installing MultiAdmin.."
    rm MultiAdmin.exe
    wget https://github.com/ServerMod/MultiAdmin/releases/download/3.4.0.0-alpha/MultiAdmin.exe
    chmod +x MultiAdmin.exe
    
    echo "Configuring scp_multiadmin.cfg"
    rm scp_multiadmin.cfg
    touch "scp_multiadmin.cfg"
    echo "use_new_input_system: false" > scp_multiadmin.cfg
    echo "Configure scp_multiadmin.cfg done."
else
    echo "Using LocalAdmin."
fi

echo "Configuring start.sh"
rm start.sh
touch "start.sh"
chmod +x ./start.sh

if [ "${INSTALL_BOT}" == "true" ] && [ "${INSTALL_MULTIADMIN}" == "false" ] 
then
    echo "#!/bin/bash
    mono Bot/DiscordIntegration_Bot.exe > /dev/null &
    ./LocalAdmin \${SERVER_PORT}" >> start.sh
    echo "Finished configuring start.sh for LocalAdmin and Discord Integration."

elif [ "${INSTALL_BOT}" == "false" ] && [ "${INSTALL_MULTIADMIN}" == "false" ]
then
echo "#!/bin/bash
    ./LocalAdmin \${SERVER_PORT}" >> start.sh
    echo "Finished configuring start.sh for LocalAdmin."

elif [ "${INSTALL_BOT}" == "true" ] 

then
    echo "#!/bin/bash
    mono Bot/DiscordIntegration_Bot.exe > /dev/null &
    mono MultiAdmin.exe --port \${SERVER_PORT}" >> start.sh
    echo "Finished configuring start.sh for MultiAdmin and Discord Integration."

else
    echo "#!/bin/bash
    mono MultiAdmin.exe --port \$1" >> start.sh
    echo "Finished configuring start.sh for MultiAdmin."
fi

if [ "${INSTALL_BOT}" == "true" ]; then
    if [ "${BOT_VERSION}" == "latest" ]; then
        echo "Installing latest Discord Integration bot version."
        wget https://github.com/galaxy119/DiscordIntegration/releases/latest/download/Bot.tar.gz
        rm -r Bot
        tar xzvf Bot.tar.gz
        rm Bot.tar.gz
        chmod +x Bot/DiscordIntegration_Bot.exe
    else
        echo "Installing Discord Integration Version: ${BOT_VERSION}.."
        wget https://github.com/galaxy119/DiscordIntegration/releases/download/${BOT_VERSION}/Bot.tar.gz
        rm -r Bot
        tar xzvf Bot.tar.gz
        rm Bot.tar.gz
        chmod +x Bot/DiscordIntegration_Bot.exe
    fi
else
    echo "Skipping bot install..."

fi

if [ "${INSTALL_EXILED}" == "true" ]; then
    echo "Downloading EXILED.."
    mkdir .config/
    echo "Downloading latest EXILED Installer"
    rm Exiled.Installer-Linux
    wget https://github.com/galaxy119/EXILED/releases/latest/download/Exiled.Installer-Linux
    echo "Installing EXILED.."
    chmod +x ./Exiled.Installer-Linux
    ./Exiled.Installer-Linux --pre-releases
else
    echo "Skipping Exiled installation."

fi

if [ "${REMOVE_UPDATER}" == "true" ]; then
    echo "Removing Exiled updater."
    rm .config/EXILED/Plugins/Exiled.Updater.dll
else
    echo "Not removing Exiled updater."
fi

if [ "${INSTALL_INTEGRATION}" == "true" ]; then
    if [ "${BOT_VERSION}" == "latest" ]; then
        echo Installing Discord Latest Integration Plugin...
        #Moves to plugin folder for plugin installation. 
        cd .config/EXILED/Plugins

        rm DiscordIntegration_Plugin.dll
        echo Grabbing plugin.
        wget https://github.com/galaxy119/DiscordIntegration/releases/latest/download/DiscordIntegration_Plugin.dll

        rm dependencies.tar.gz
        echo Grabbing dependencies.
        wget https://github.com/galaxy119/DiscordIntegration/releases/latest/download/dependencies.tar.gz

        echo Installing dependencies.
        tar -xvf dependencies.tar.gz
        rm dependencies.tar.gz

    else
        echo "Installing Discord Integration Plugin Version: ${BOT_VERSION}"
    fi
fi

if  [ "${INSTALL_ADMINTOOLS}" == "true" ]; then
    echo "Removing current Admin Tools"
    rm AdminTools.dll
    echo "Installing latest Admin Tools"
    wget https://github.com/Exiled-Team/AdminTools/releases/latest/download/AdminTools.dll
else
    echo "Skipping Admin Tools install."
fi

if [ "${INSTALL_UTILITIES}" == "true" ]; then
    echo "Removing existing Common Utilities version."
    rm Common_Utilities.dll
    echo "Installing Common Utilities."
    wget https://github.com/Exiled-Team/Common-Utils/releases/latest/download/Common_Utilities.dll
fi

if [ "${INSTALL_BOT}" == "true" ]
then
    echo "Dont forget to configure the discord bot in IntegrationBotConfig.json"
    echo "$(tput setaf 2)Installation Complete!$(tput sgr 0)"
else
    echo "$(tput setaf 2)Installation Complete!$(tput sgr 0)"
fi