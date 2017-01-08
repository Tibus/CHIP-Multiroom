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

function setInConf {
  echo "$1 => $2"
  sed -i.bak "/$1 / s/ .*/ $2/" /etc/motion/motion.conf
}

echo "${green}resolution de votre caméra (width):${reset}"
read width

echo "${green}resolution de votre caméra (height):${reset}"
read height

echo "${green}Nombre d'image par secondes de votre caméra (1 à 100):${reset}"
read fps

if which motion >/dev/null; then
  echoGreen "motion already installed"
else
  echoGreen "Update CHIP"
  sudo apt-get update -y

  echoGreen "Install motion"
  sudo apt-get install motion -y
fi

sudo /etc/init.d/motion start
sudo chmod 777 /var/lib/motion/

setInConf "width" $width
setInConf "height" $height
setInConf "daemon" "on"
setInConf "framerate" $fps
setInConf "stream_maxrate" $fps
setInConf "auto_brightness" "off"
setInConf "output_pictures" "off"
setInConf "ffmpeg_output_movies" "off"
#setInConf "target_dir" "/var/lib/motion"
setInConf "stream_port" "8081"
setInConf "stream_localhost" "off"
setInConf "webcontrol_port" "8080"
setInConf "webcontrol_localhost" "off"

echo "start_motion_daemon=yes">'/etc/default/motion'

sudo /etc/init.d/motion restart

sudo sync

echoGreen "Finished"

#sudo axp209 --no-limit
#sudo systemctl enable no-limit
#iw dev wlan0 set power_save off
