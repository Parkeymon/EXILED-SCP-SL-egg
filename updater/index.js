const fs = require("fs");
const fetch = require("node-fetch");
const Nodeactyl = require("nodeactyl");
const config = require("./config.json");

// Convert minutes to ms
const checkInterval = config.checkInterval * 60000
const steamURL = "https://api.steamcmd.net/v1/info/996560";
const ptero = new Nodeactyl.NodeactylClient("https://ptero.nutinc.net/", config.pteroKey);

// Make sure these are filled so it doesn't pointlessly run or cause errors
if (config.pteroKey === "unfilled") {
    console.warn("AUTO UPDATER ERROR! YOU DID NOT SET A PTERODACTYL API KEY!");
    return;
}
if (config.pteroDomain === "unfilled") {
    console.warn("AUTO UPDATER ERROR! YOU DID NOT SET A PTERODACTYL DOMAIN!");
    return;
}
if (config.serverID === "unfilled") {
    console.warn("AUTO UPDATER ERROR! YOU DID NOT SET A SERVER ID!");
    return;
}

async function checkForUpdoots() {
    console.log("Running checkForUpdoots");
    const response = await fetch(steamURL);
    const data = response.json();
    return data;
}

const interval = setInterval(() => {
    checkForUpdoots().then(data => {
        let latestBuild;
        if (config.betaTag === "none") { latestBuild = data.data[996560].depots.branches.public.buildid; }
        else { latestBuild = data.data[996560].depots.branches[config.betaTag].buildid; }
        console.log("LATEST BUILD:", latestBuild);
        console.log(data.data[996560].depots.branches.public);

        fs.readFile('versionCache.txt', {encoding: "utf8"}, (err, data) => {
            if (err) console.error(err);
            console.log("CACHED VERSION:", data);

            if (data !== latestBuild) {
                console.warn("CACHED SERVER VERSION IS NOT THE LATEST BUILD!");

                //Send warning of server restart
                ptero.sendServerCommand(config.serverID, "bc 30 SERVER RESTARTING IN 30 SECONDS FOR AUTOMATIC GAME UPDATES").then((success) => {
                    if (!success) { console.error("There was a problem!"); return; }

                    // Reinstall the server after a delay so players are warned
                    setTimeout(function () {
                        ptero.reInstallServer(config.serverID).then((success) => {
                            if (!success) { console.error("There was a problem!"); return; }

                            fs.writeFile('versionCache.txt',
                                latestBuild, function(err) {
                                    if (err) console.error(err);
                                    console.info("Updated build version");
                                });
                        }).catch((err) => {
                            console.error("THERE WAS AN ERROR WHILE RE-INSTALLING!", err);
                        });
                    }, 5000);
                }).catch((err) => {
                    console.error("THERE WAS AN ERROR WHILE SENDING A COMMAND! CODE:", err);
                });
            } else {
                console.log("Server is up to date, continuing...");
            }
        })
    });
    // TODO - For the delay there needs to be a variable in the EGG that updates the config.json with the user variable.
}, checkInterval);
