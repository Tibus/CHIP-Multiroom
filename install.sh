red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

function echoGreen {
    echo "${green}"
    echo "********************"
    echo $1
    echo "********************"
    echo "${reset}"
}

echo "${green}Type the speaker's name:${reset}"
read hostname

if which shairport-sync >/dev/null; then
  echoGreen "shairport already installed"
else
  echoGreen "Update CHIP"
  sudo apt-get update -y

  echoGreen "Install shairport-sync"
  sudo apt-get install shairport-sync -y
fi

echoGreen "Get current hostname"
currentHostname=$(</etc/hostname)

echoGreen "update hostname"
echo "$hostname">'/etc/hostname'
sed -i.bak "s|${currentHostname}|${hostname}|g" /etc/hosts
echoGreen "current Speaker name changed from '$currentHostname' to '$hostname'"

echoGreen "restart avahi-daemon"
sudo /etc/init.d/avahi-daemon restart

echoGreen "set volume to 100%"
amixer sset 'Power Amplifier' 100%

echoGreen "sync"
sudo sync

echoGreen "Finished"

#sudo axp209 --no-limit
#sudo systemctl enable no-limit
#iw dev wlan0 set power_save off
