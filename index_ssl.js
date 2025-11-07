const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Binary and config definitions
const apps = [
  
  {
    name: "navidrome",
    binaryPath: "HOME/bin/navidrome/navidrome",
    args: ["--configfile", "HOME/bin/navidrome/navidrome.toml"],
    mode: "inherit"
  },
  
  {
    name: "acme",
    binaryPath: "bash",
    args: ["HOME/bin/acme/ssl.sh"],
    mode: "inherit"
  },
  
  {
    name: "nginx",
    binaryPath: "bash",
    args: [ "HOME/bin/nginx/sbin/nginx.sh"],
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
