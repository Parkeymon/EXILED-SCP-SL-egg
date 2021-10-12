#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server

echo "
$(tput setaf 4)  ____________________________       ______________     
$(tput setaf 4) /   _____/\_   ___ \______   \ /\  /   _____/|    |    
$(tput setaf 4) \_____  \ /    \  \/|     ___/ \/  \_____  \ |    |    
$(tput setaf 4) /        ||     \___|    |     /\  /        \|    |___ 
$(tput setaf 4)/_________/ \________/____|     \/ /_________/|________|
$(tput setaf 1) ___                 __          __   __                
$(tput setaf 1)|   | ____   _______/  |______  |  | |  |   ___________ 
$(tput setaf 1)|   |/    \ /  ___/\   __\__  \ |  | |  | _/ __ \_  __ |
$(tput setaf 1)|   |   |  |\___ \  |  |  / __ \|  |_|  |_\  ___/|  | \/
$(tput setaf 1)|___|___|__/______> |__| (______|____|____/\___  |__|       
$(tput setaf 0)
"

echo "
$(tput setaf 2)This installer was created by $(tput setaf 1)Parkeymon#0001
"

# Egg version checking, do not touch!
currentVersion="2.1.5"
latestVersion=$(curl --silent "https://api.github.com/repos/Parkeymon/EXILED-SCP-SL-egg/releases/latest" | jq -r .tag_name)

if [ "${currentVersion}" == "${latestVersion}" ]; then
  echo "$(tput setaf 2)Installer is up to date"
else

  echo "
  $(tput setaf 1)THE INSTALLER IS NOT UP TO DATE!

    Current Version: $(tput setaf 1)${currentVersion}
    Latest: $(tput setaf 2)${latestVersion}

  $(tput setaf 3)Please update to the latest version found here: https://github.com/Parkeymon/EXILED-SCP-SL-egg/releases/latest

  "
  sleep 10
fi

# Download SteamCMD and Install
cd /tmp || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /TMP"
  exit
}
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /mnt/server/steamcmd"
  exit
}

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

if [ "${BETA_TAG}" == "none" ]; then
  ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update "${SRCDS_APPID}" validate +quit
else
  ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update "${SRCDS_APPID}" -beta "${BETA_TAG}" validate +quit
fi

# Install SL with SteamCMD
cd /mnt/server || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /mnt/server"
  exit
}

echo "$(tput setaf 4)Configuring start.sh$(tput setaf 0)"
rm start.sh
touch "start.sh"
chmod +x ./start.sh

mkdir .egg

if [ "${INSTALL_BOT}" == "true" ]; then
  echo "#!/bin/bash
    node discordIntegration.js > /dev/null &
    ./LocalAdmin \${SERVER_PORT}" >>start.sh
  echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin and Discord Integration.$(tput setaf 0)"

else
  echo "#!/bin/bash
    ./LocalAdmin \${SERVER_PORT}" >>start.sh
  echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin.$(tput setaf 0)"

fi

if [ "${INSTALL_BOT}" == "true" ]; then

  if [ "${CONFIG_SAVER}" == "true" ]; then
    echo "$(tput setaf 4)Config Saver is $(tput setaf 2)ENABLED"
    echo "Making temporary directory"
    mkdir BotConfigTemp
    echo "Moving config."
    mv config.yml ./BotConfigTemp
  fi

  echo "$(tput setaf 4)Installing latest Discord Integration bot version."
  wget -q https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/DiscordIntegration.Bot.tar.gz
  tar xzvf DiscordIntegration.Bot.tar.gz
  rm DiscordIntegration.Bot.tar.gz

  if [ "${CONFIG_SAVER}" == "true" ]; then
    echo "Deleting config"
    rm config.yml
    echo "Replacing Config"
    mv ./BotConfigTemp/config.yml ./
    echo "Removing temporary directory"
    rm -r BotConfigTemp
    echo "$(tput setaf 4)Your configs have been saved!"
  fi

  echo "$(tput setaf 4)Updating Packages"
  yarn install

else
  echo "$(tput setaf 4)Skipping bot install...$(tput setaf 0)"
fi

if [ "${INSTALL_EXILED}" == "true" ]; then
  echo "$(tput setaf 4)Downloading $(tput setaf 1)EXILED$(tput setaf 0).."
  mkdir .config/
  echo "$(tput setaf 4)Downloading latest $(tput setaf 1)EXILED$(tput setaf 4) Installer"
  rm Exiled.Installer-Linux
  wget -q https://github.com/galaxy119/EXILED/releases/latest/download/Exiled.Installer-Linux
  chmod +x ./Exiled.Installer-Linux

  if [ "${EXILED_PRE}" == "true" ]; then
    echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED (pre-release)..."
    ./Exiled.Installer-Linux --pre-releases

  elif [ "${EXILED_PRE}" == "false" ]; then
    echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED$(tput setaf 0)..."
    ./Exiled.Installer-Linux

  else
    echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED$(tput setaf 0) version: ${EXILED_PRE} .."
    ./Exiled.Installer-Linux --target-version "${EXILED_PRE}"

  fi
else
  echo "Skipping Exiled installation."
fi

if [ "${REMOVE_UPDATER}" == "true" ]; then
  echo "Removing Exiled updater."
  rm /mnt/server/.config/EXILED/Plugins/Exiled.Updater.dll
else
  echo "Skipping EXILED updater removal."
fi

if [ "${INSTALL_INTEGRATION}" == "true" ]; then
  echo "Installing Latest Discord Integration Plugin..."

  echo "Removing old Discord Integration (if it exists)"
  rm /mnt/server/.config/EXILED/Plugins/DiscordIntegration_Plugin.dll
  rm /mnt/server/.config/EXILED/Plugins/DiscordIntegration.dll

  echo "$(tput setaf 5)Grabbing plugin and dependencies."
  wget -q https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/Plugin.tar.gz -P /mnt/server/.config/EXILED/Plugins

  echo "Extracting..."
  tar xzvf /mnt/server/.config/EXILED/Plugins/Plugin.tar.gz
  rm /mnt/server/.config/EXILED/Plugins/Plugin.tar.gz

else
  echo "Skipping Discord integration plugin install"
fi

if [ "${INSTALL_ADMINTOOLS}" == "true" ]; then
  echo "Removing existing Admin Tools version."
  rm .config/EXILED/Plugins/AdminTools.dll
  echo "$(tput setaf 5)Installing latest Admin Tools"
  wget -q https://github.com/Exiled-Team/AdminTools/releases/latest/download/AdminTools.dll -P /mnt/server/.config/EXILED/Plugins

else
  echo "Skipping Admin Tools install."
fi

if [ "${INSTALL_UTILITIES}" == "true" ]; then
  echo "Removing existing Common Utilities version."
  rm .config/EXILED/Plugins/Common_Utilities.dll
  echo "$(tput setaf 5)Installing Common Utilities."
  wget -q https://github.com/Exiled-Team/Common-Utils/releases/latest/download/Common_Utilities.dll -P /mnt/server/.config/EXILED/Plugins
else
  echo "Skipping Common Utilities Install"
fi

if [ "${INSTALL_SCPSTATS}" == "true" ]; then
  echo "Removing existing SCPStats version."
  rm .config/EXILED/Plugins/SCPStats.dll
  echo "$(tput setaf 5)Installing SCPStats"
  wget -q https://github.com/SCPStats/Plugin/releases/latest/download/SCPStats.dll -P /mnt/server/.config/EXILED/Plugins
else
  echo "Skipping SCPStats Install."
fi

function pluginInstall() {
  # Caches the plugin to a json so only one request to Github is needed

  curl --silent -u "${GITHUB_USERNAME}:${GITHUB_TOKEN}" "$1" | jq . > plugin.json

  if [ "$(jq -r .assets[0].browser_download_url plugin.json)" == null ]; then
    echo "
    $(tput setaf 5)ERROR GETTING PLUGIN DOWNLOAD URL!

    Inputted URL: $1

    You likely inputted the incorrect URL or have been rate-limited ( https://takeb1nzyto.space/ )
    "

  fi

  echo "$(tput setaf 5)Installing $(jq -r .assets[0].name plugin.json) $(jq -r .tag_name plugin.json) by $(jq -r .author.login plugin.json)"

  # For the evil people that put the version in their plugin name the old version will need to be manually deleted
  rm /mnt/server/.config/EXILED/Plugins/"$(jq -r .assets[0].name plugin.json)"

  echo "$(jq -r .assets[0].browser_download_url plugin.json)
  "

  wget -q "$(jq -r .assets[0].browser_download_url plugin.json)" -P /mnt/server/.config/EXILED/Plugins

  rm plugin.json
}

if [ "${INSTALL_CUSTOM}" == "true" ]; then
  touch /mnt/server/.egg/customplugins.txt

  grep -v '^ *#' </mnt/server/.egg/customplugins.txt | while IFS= read -r I; do
    pluginInstall "${I}"
  done

fi

if [ "${INSTALL_BOT}" == "true" ]; then
  echo "Dont forget to configure the discord bot in /home/container/config.yml"
fi

echo "$(tput setaf 2)Installation Complete!$(tput sgr 0)"

##TODO - using git to sync configs with github

##TODO - Append plugin version to file name so they dont reinstall when they dont need to be?
