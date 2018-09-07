#!/usr/bin/env bash

# This script writes a standard SSH config file to ~/.ssh/config. 
# If a config file previously existed, it extracts the User attribute and sets that attribute in the new config file. 
# Since this script makes a lot of assumptions, and overwrites the existing config file if it exists, we back the old config file up.

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'\ `
sshConfigFolderPath="/Users/${loggedInUser}/.ssh"
ctrlMstrPath="${sshConfigFolderPath}/CtrlMstr"
sshConfigFilePath="${sshConfigFolderPath}/config"
sshConfigFileBackup="${sshConfigFolderPath}/config.bak.${RANDOM}"

if [ ! -d "$ctrlMstrPath" ]; then
    mkdir -p "$ctrlMstrPath"
    chown -R "${loggedInUser}:staff" $ctrlMstrPath
    echo "No CtrlMstr directory found, making it."
fi

if [ -f "$sshConfigFilePath" ]; then
    loggedInUser=$(grep -io "User.*" ${sshConfigFilePath} | awk '{print $2}')
    echo "Config file found. Setting the username to ${loggedInUser}"
    mv "$sshConfigFilePath" "$sshConfigFileBackup"
    echo "Made backup of the SSH config file at ${sshConfigFileBackup}"
fi 

configFile=$(cat <<'EOF'
host fdwc1.part
    hostname bastion
    StrictHostkeyChecking no
host bastion
    HostName bastion.dmz.banksimple.com
    User %USERNAME% 
    LocalForward 3392 fdwc1.part.banksimple.com:3389
host *
    Compression yes
    ControlMaster auto
    ControlPersist 30 
    ControlPath ~/.ssh/CtrlMstr/%r-%n-%p
    ForwardAgent yes
    ForwardX11 no
    Protocol 2
    HashKnownHosts yes
    ServerAliveInterval 5
    IdentityFile ~/.ssh/id_rsa
    UseKeychain yes
    AddKeysToAgent yes
EOF
)
echo "$configFile" | sed "s;%USERNAME%;$loggedInUser;g" 1> "$sshConfigFilePath"
chown "${loggedInUser}:staff" $sshConfigFilePath
echo "Config file created at ${sshConfigFilePath}" 
