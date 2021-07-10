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
$(tput setaf 2)You can find the latest version here: https://github.com/Parkeymon/EXILED-SCP-SL-egg
$(tput setaf 0)
"

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
    ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update "${SRCDS_APPID}" "${BETA_TAG}" validate +quit
fi
# Install SL with SteamCMD

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

cd /mnt/server || echo

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
    echo "$(tput setaf 4)Using LocalAdmin.$(tput setaf 0)"
fi

echo "$(tput setaf 4)Configuring start.sh$(tput setaf 0)"
rm start.sh
touch "start.sh"
chmod +x ./start.sh

if [ "${INSTALL_BOT}" == "true" ] && [ "${INSTALL_MULTIADMIN}" == "false" ] 
then
    echo "#!/bin/bash
    node discordIntegration.js > /dev/null &
    ./LocalAdmin \${SERVER_PORT}" >> start.sh
    echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin and Discord Integration.$(tput setaf 0)"

elif [ "${INSTALL_BOT}" == "false" ] && [ "${INSTALL_MULTIADMIN}" == "false" ]
then
echo "#!/bin/bash
    ./LocalAdmin \${SERVER_PORT}" >> start.sh
    echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin.$(tput setaf 0)"

elif [ "${INSTALL_BOT}" == "true" ] 

then
    echo "#!/bin/bash
    node discordIntegration.js > /dev/null &
    mono MultiAdmin.exe --port \${SERVER_PORT}" >> start.sh
    echo "$(tput setaf 4)Finished configuring start.sh for MultiAdmin and Discord Integration.$(tput setaf 0)"

else
    echo "#!/bin/bash
    mono MultiAdmin.exe --port \$1" >> start.sh
    echo "$(tput setaf 4)Finished configuring start.sh for MultiAdmin.$(tput setaf 0)"
fi

if [ "${INSTALL_BOT}" == "true" ]; then
    if [ "${BOT_VERSION}" == "latest" ]; then
       if [ "${CONFIG_SAVER}" == "true" ]; then
            # Latest Bot WITH config saver

            echo "$(tput setaf 4)Removing old bot version if it still exists.$(tput setaf 0)"
            rm -r Bot

            #Config SAVER
            echo "$(tput setaf 4)Config Saver is $(tput setaf 2)ENABLED"
            echo "Making temporary directory"
            mkdir BotConfigTemp
            echo "Moving config."
            mv config.yml ./BotConfigTemp

            echo "$(tput setaf 4)Installing latest Discord Integration bot version.$(tput setaf 0)"
            wget https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/DiscordIntegration.Bot.tar.gz
            tar xzvf DiscordIntegration.Bot.tar.gz
            rm DiscordIntegration.Bot.tar.gz
            echo "Deleting config"
            rm config.yml
            echo "Replacing Config"
            mv ./BotConfigTemp/config.yml ./
            echo "Removing temporary directory"
            rm -r BotConfigTemp
            echo "$(tput setaf 4)Your configs have been saved!"
        
            echo "$(tput setaf 4)Updating Packages$(tput setaf 0)"

            yarn install

        else
            # Latest Bot WITHOUT config saver

            echo "$(tput setaf 4)Removing old bot version if it still exists.$(tput setaf 0)"
            rm -r Bot

            echo "$(tput setaf 4)Installing latest Discord Integration bot version.$(tput setaf 0)"
            wget https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/DiscordIntegration.Bot.tar.gz
            tar xzvf DiscordIntegration.Bot.tar.gz
            rm DiscordIntegration.Bot.tar.gz
        
            echo "$(tput setaf 4)Updating Packages$(tput setaf 0)"

            yarn install
        fi
    else
        if [ "${CONFIG_SAVER}" == "true" ]; then
            # Specific Version WITH config saver

            echo "$(tput setaf 4)Removing old bot version if it still exists.$(tput setaf 0)"
            rm -r Bot

            #Config SAVER
            echo "$(tput setaf 4)Config Saver is $(tput setaf 2)ENABLED"
            echo "Making temporary directory"
            mkdir BotConfigTemp
            echo "Moving config."
            mv config.yml ./BotConfigTemp

            echo "$(tput setaf 4)Installing Discord Integration bot version: ${BOT_VERSION}..."
            wget https://github.com/Exiled-Team/DiscordIntegration/releases/download/"${BOT_VERSION}"/Bot.tar.gz
            tar xzvf DiscordIntegration.Bot.tar.gz
            rm DiscordIntegration.Bot.tar.gz
            echo "Deleting config"
            rm config.yml
            echo "Replacing Config"
            mv ./BotConfigTemp/config.yml ./
            echo "Removing temporary directory"
            rm -r BotConfigTemp
            echo "$(tput setaf 4)Your configs have been saved!"

            echo "$(tput setaf 4)Updating Packages$(tput setaf 0)"
            yarn install

        else
            # Specific Version WITHOUT config saver

            echo "$(tput setaf 4)Removing old bot version if it still exists.$(tput setaf 0)"
            rm -r Bot

            echo "$(tput setaf 4)Installing Discord Integration bot version: ${BOT_VERSION}..."
            wget https://github.com/Exiled-Team/DiscordIntegration/releases/download/"${BOT_VERSION}"/Bot.tar.gz
            tar xzvf DiscordIntegration.Bot.tar.gz
            rm DiscordIntegration.Bot.tar.gz
        
            echo "$(tput setaf 4)Updating Packages$(tput setaf 0)"
            yarn install
        fi
    fi
else
    echo "$(tput setaf 4)Skipping bot install...$(tput setaf 0)"

fi

if [ "${INSTALL_EXILED}" == "true" ]; then
    if [ "${EXILED_PRE}" == "true" ]; then
        echo "$(tput setaf 4)Downloading $(tput setaf 1)EXILED$(tput setaf 0).."
        mkdir .config/
        echo "$(tput setaf 4)Downloading latest $(tput setaf 1)EXILED$(tput setaf 4) Installer$(tput setaf 0)"
        rm Exiled.Installer-Linux
        wget https://github.com/galaxy119/EXILED/releases/latest/download/Exiled.Installer-Linux
        echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED (pre-release)$(tput setaf 0).."
        chmod +x ./Exiled.Installer-Linux
        ./Exiled.Installer-Linux --pre-releases

    elif [ "${EXILED_PRE}" == "false" ]; then
        echo "$(tput setaf 4)Downloading $(tput setaf 1)EXILED$(tput setaf 0).."
        mkdir .config/
        echo "$(tput setaf 4)Downloading latest $(tput setaf 1)EXILED$(tput setaf 4) Installer$(tput setaf 0)"
        rm Exiled.Installer-Linux
        wget https://github.com/galaxy119/EXILED/releases/latest/download/Exiled.Installer-Linux
        echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED$(tput setaf 0).."
        chmod +x ./Exiled.Installer-Linux
        ./Exiled.Installer-Linux
    else
        #Installing with specific version.
        echo "$(tput setaf 4)Downloading $(tput setaf 1)EXILED$(tput setaf 0).."
        mkdir .config/
        echo "$(tput setaf 4)Downloading latest $(tput setaf 1)EXILED$(tput setaf 4) Installer$(tput setaf 0)"
        rm Exiled.Installer-Linux
        wget https://github.com/galaxy119/EXILED/releases/latest/download/Exiled.Installer-Linux
        echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED$(tput setaf 0).."
        chmod +x ./Exiled.Installer-Linux
        ./Exiled.Installer-Linux --target-version "${EXILED_PRE}"
    fi
else
    echo "Skipping Exiled installation."
fi

if [ "${REMOVE_UPDATER}" == "true" ]; then
    echo "Removing Exiled updater."
    rm .config/EXILED/Plugins/Exiled.Updater.dll
else
    echo "Skipping EXILED updater removal."
fi

if [ "${INSTALL_INTEGRATION}" == "true" ]; then
    if [ "${BOT_VERSION}" == "latest" ]; then
        echo Installing Discord Latest Integration Plugin...
        #Moves to plugin folder for plugin installation. 
        cd .config/EXILED/Plugins || {
          echo "Bot Install Failed"
          return
          }

        echo "Removing old Discord Integration (if it exists)"
        rm DiscordIntegration_Plugin.dll
        rm DiscordIntegration.dll

        echo "Grabbing plugin and dependencies."
        wget https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/Plugin.tar.gz

        echo "Extracting..."
        tar xzvf Plugin.tar.gz
        rm Plugin.tar.gz

    else
        echo "Installing Discord Integration Plugin Version: ${BOT_VERSION}"
    fi
fi

if  [ "${INSTALL_ADMINTOOLS}" == "true" ]; then
    echo "Removing existing Admin Tools version."
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
else
    echo "Skipping Common Utilities Install"
fi

if [ "${INSTALL_SCPSTATS}" == "true" ]; then
    echo "Removing existing SCPStats version."
    rm SCPStats.dll
    echo "Installing SCPStats"
    wget https://github.com/SCPStats/Plugin/releases/latest/download/SCPStats.dll
else
    echo "Skipping SCPStats Install."
fi    

if [ "${INSTALL_BOT}" == "true" ]
then
    echo "Dont forget to configure the discord bot in /home/container/config.yml"
    echo "$(tput setaf 2)Installation Complete!$(tput sgr 0)"
else
    echo "$(tput setaf 2)Installation Complete!$(tput sgr 0)"
fi