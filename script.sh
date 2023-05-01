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
$(tput setaf 1)|___|___|__/______| |__| (______|____|____/\___  |__|
$(tput setaf 0)
"

echo "
$(tput setaf 2)This installer was created by $(tput setaf 1)Parkeymon#0001$(tput setaf 0) and maintained by EsserGaming.
"

# Egg version checking, do not touch!
currentVersion="2.4.0"
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
  ./steamcmd.sh +force_install_dir /mnt/server +login anonymous +app_update "${SRCDS_APPID}" validate +quit
else
  ./steamcmd.sh +force_install_dir /mnt/server +login anonymous +app_update "${SRCDS_APPID}" -beta ${BETA_TAG} validate +quit
fi

# Install SL with SteamCMD
cd /mnt/server || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /mnt/server"
  exit
}

#Start egg configuration
mkdir .egg

echo "$(tput setaf 4)Configuring start.sh$(tput setaf 0)"
rm ./.egg/start.sh
touch "./.egg/start.sh"
chmod +x ./.egg/start.sh

if [ "${INSTALL_DIBOT}" == "true" ]; then
  echo "#!/bin/bash
    ./.egg/DIBot/DiscordIntegration.Bot > /dev/null &
    ./LocalAdmin \${SERVER_PORT}" >>./.egg/start.sh
  echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin and Discord Integration.$(tput setaf 0)"

elif [ "${INSTALL_SCPBOT}" == "true" ]; then
  echo "#!/bin/bash
    ./.egg/SCPDBot/SCPDiscordBot_Linux &
    ./LocalAdmin \${SERVER_PORT}" >>./.egg/start.sh
  echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin and SCP Discord.$(tput setaf 0)"

else
  echo "#!/bin/bash
    ./LocalAdmin \${SERVER_PORT}" >>./.egg/start.sh
  echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin.$(tput setaf 0)"

fi
# Install Discord Integration Bot
if [ "${INSTALL_DIBOT}" == "true" ]; then
  mkdir /mnt/server/.egg/DIBot
  echo "Removing old Discord Integration"
  rm /mnt/server/.egg/DIBot/DiscordIntegration.Bot
  echo "$(tput setaf 4)Installing latest Discord Integration bot version."
  wget -q https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/DiscordIntegration.Bot -P /mnt/server/.egg/DIBot

  chmod +x /mnt/server/.egg/DIBot/DiscordIntegration.Bot

# Install Discord Integration Plugin
  echo "Installing Latest Discord Integration Plugin.."

  echo "Removing old Discord Integration"
  rm /mnt/server/.config/EXILED/Plugins/DiscordIntegration.dll

  echo "$(tput setaf 5)Grabbing plugin and dependencies."
  wget -q https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/Plugin.tar.gz -P /mnt/server/.config/EXILED/Plugins

  echo "Extracting..."
  tar xzvf /mnt/server/.config/EXILED/Plugins/Plugin.tar.gz -C /mnt/server/.config/EXILED/Plugins
  rm /mnt/server/.config/EXILED/Plugins/Plugin.tar.gz

else
  echo "Skipping Discord Integration install."
fi
#Install SCPDiscord Bot
if [ "${INSTALL_SCPBOT}" == "true" ]; then
  mkdir /mnt/server/.egg/SCPDBot

  echo "Removing old SCPDiscord Bot"
  rm /mnt/server/.egg/SCPDBot/SCPDiscordBot_Linux

  echo "$(tput setaf 4)Installing latest SCP Discord Bot."
  wget -q https://github.com/KarlOfDuty/SCPDiscord/releases/latest/download/SCPDiscordBot_Linux -P /mnt/server/.egg/SCPDBot

  chmod +x /mnt/server/.egg/SCPDBot/SCPDiscordBot_Linux

 #Install SCPDiscord Plugin
  echo "Installing Latest SCP Discord Plugin.."

  echo "Removing old SCPDiscord Plugin"
  rm '/mnt/server/.config/SCP Secret Laboratory/PluginAPI/plugins/global/SCPDiscord.dll'

  echo "$(tput setaf 5)Grabbing plugin and dependencies."
  wget -q https://github.com/KarlOfDuty/SCPDiscord/releases/latest/download/dependencies.zip -P '/mnt/server/.config/SCP Secret Laboratory/PluginAPI/plugins/global'
  wget -q https://github.com/KarlOfDuty/SCPDiscord/releases/latest/download/SCPDiscord.dll -P '/mnt/server/.config/SCP Secret Laboratory/PluginAPI/plugins/global'


  echo "Extracting dependencies..."
  unzip -oq '/mnt/server/.config/SCP Secret Laboratory/PluginAPI/plugins/global/dependencies.zip' -d '/mnt/server/.config/SCP Secret Laboratory/PluginAPI/plugins/global/'
  rm '/mnt/server/.config/SCP Secret Laboratory/PluginAPI/plugins/global/dependencies.zip'
else
  echo "Skipping SCPDiscord install."
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


function installPlugin() {
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

  jq -r .assets[0].browser_download_url plugin.json

  if [ "${GITHUB_TOKEN}" == "none" ]; then
    wget -q "$(jq -r .assets[0].browser_download_url plugin.json)" -P /mnt/server/.config/EXILED/Plugins
  else
    url=$(jq -r .assets[0].url plugin.json | sed "s|https://|https://${GITHUB_TOKEN}:@|")
    wget -q --auth-no-challenge --header='Accept:application/octet-stream' "$url" -O /mnt/server/.config/EXILED/Plugins/"$(jq -r .assets[0].name plugin.json)"
  fi

  rm plugin.json
}

if [ "${INSTALL_CUSTOM}" == "true" ]; then
  touch /mnt/server/.egg/customplugins.txt

  grep -v '^ *#' </mnt/server/.egg/customplugins.txt | while IFS= read -r I; do
    installPlugin "${I}"
  done

fi

echo "$(tput setaf 2)Installation Complete!$(tput sgr 0)"