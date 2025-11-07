
#!/usr/bin/env sh
PORT="${PORT:-5244}"
DYNV6_TOKEN="${DYNV6_TOKEN:-123}"
DYNV6_DNS="${DYNV6_DNS:-a.com}"
LOCAL_PATH="$PWD:-/home/container"



function  BASH()
{

curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json
cd "$LOCAL_PATH"
cat > "./index.js" <<EOF 

const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Binary and config definitions
const apps = [
  
  {
    name: "navidrome",
    binaryPath: "$LOCAL_PATH/bin/navidrome/navidrome",
    args: ["--configfile", "$LOCAL_PATH/bin/navidrome/navidrome.toml"],
    mode: "inherit"
  }
  
];


// Run binary with keep-alive
function runProcess(app) {
  const child = spawn(app.binaryPath, app.args, { stdio: "inherit" });

  child.on("exit", (code) => {
    console.log(`[EXIT] ${app.name} exited with code: ${code}`);
    console.log(`[RESTART] Restarting ${app.name}...`);
    setTimeout(() => runProcess(app), 10000); // restart after 3s
  });
}

// Main execution
function main() {
  try {
    for (const app of apps) {
      runProcess(app);
    }
  } catch (err) {
    console.error("[ERROR] Startup failed:", err);
    process.exit(1);
  }
}

main();


EOF
cat  "./index.js"


mkdir -p "$LOCAL_PATH/file/music"
mkdir -p "$LOCAL_PATH/bin/navidrome"
cd  "$LOCAL_PATH/bin/navidrome"
curl -sSL -o navidrome.tar.gz  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf navidrome.tar.gz
chmod +x navidrome
rm navidrome.tar.gz

curl -sSL -o navidrome.toml  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/navidrome.toml
sed -i "s|\/home|$LOCAL_PATH|g" navidrome.toml
sed -i "s/5244/$PORT/g" navidrome.toml

echo "base is ok"

}


function  SSL()
{

curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json
cd "$LOCAL_PATH"
cat > "./index.js" <<EOF 

const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Binary and co
