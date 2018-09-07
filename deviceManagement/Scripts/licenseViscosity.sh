PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

/Applications/Viscosity.app/Contents/MacOS/Viscosity -installHelperTool YES

CONFIG_VISC=$(cat <<'EOF'
#! /bin/bash

CONFIG_VISC_CHECK=$(defaults read -app viscosity License 2> /dev/null)
CONFIG_VISC_HELPER="/Library/PrivilegedHelperTools/com.sparklabs.ViscosityHelper"
if ! [ "$CONFIG_VISC_CHECK" ]; then
    defaults write -app viscosity License "FBSHAMAKKMTW4YLNMUTQU4BRBJRV6X3COVUWY5DJNZPV6CTVNZUWG33EMUFHAMQKFBLFG2LNOBWGKICGNFXGC3TDMUQFIZLDNBXG63DPM54SAQ3POJYAU4BTBJ2HANAKKJYDKCTTKMTWWZLZE4FHANQKKMTVMTJRKZEVSV2RJUZTKNCQI5HE6MRWIJMEKMZUK5JDEV2CKM3UGSSZIUTQU4BXBJZVGJ3FNVQWS3BHBJYDQCSTE5XXA42AONUW24DMMUXGG33NE4FHAOIKOMXA===="
    defaults write -app viscosity MenuBarIcons "Leopard Colored"
    defaults write -app viscosity ResetNetOnDisconnect 0
    defaults write -app viscosity SUEnableAutomaticChecks 1
    defaults write -app viscosity FirstRun NO
fi

EOF
)

CONFIG_VISC_SCRIPT="/usr/local/outset/login-once/config-visc.sh"

if [ "$USER" == 'root' ] || [ -z $USER ]; then
    printf "$CONFIG_VISC" > $CONFIG_VISC_SCRIPT
    chown root:wheel $CONFIG_VISC_SCRIPT
    chmod 755 $CONFIG_VISC_SCRIPT
else
    sudo -u $USER sh -c "$CONFIG_VISC"
fi
