const fs = require("fs");
const fetch = require("node-fetch");
const config = require("config.json");

// User sets a value in minutes for the check interval, convert to usable.
const checkInterval = config.checkInterval * 60000
const steamURL = "https://api.steamcmd.net/v1/info/996560";
// Pterodactyl POST URL for
const pterodactylURL = "https://ptero.io/{variable}/";

async function checkForUpdoots() {
    console.log("Running checkForUpdoots");
    const response = await fetch(steamURL);
    const data = await response.json();
    return data;
}

const interval = setInterval(() => {
    checkForUpdoots().then(data => {
        const latestBuild = data.data[996560].depots.branches.publicbeta.buildid;
        console.log("LATEST BUILD:", latestBuild);

        fs.readFile('versionCache.txt', {encoding: "utf8"}, (err, data) => {
            if (err) console.error(err);
            console.log("CACHED VERSION:", data);

            if (data > latestBuild) {
                console.warn("SERVER IS OUT OF DATE!");
                // TODO - Put in pterodactyl stuff here to update/reinstall the server

                // Update cached version since the server is up to date.
                // TODO - Probably add a check to make sure the POST went through before writing
                fs.writeFile('versionCache.txt',
                    data.data[996560].depots.branches.publicbeta.buildid, function(err) {
                        if (err) console.error(err);
                        console.info("Updated build version");
                    });
            } else {
                console.log("Server is up to date, continuing...");
            }
        })
    });
    // TODO - For the delay there needs to be a variable in the EGG that updates the config.json with the user variable.
}, checkInterval);