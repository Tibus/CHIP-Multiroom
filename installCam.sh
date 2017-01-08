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

read -e -p "${green}resolution de votre caméra (width): ${reset}" -i "640" width

read -e -p "${green}resolution de votre caméra (height): ${reset}" -i "480" height

read -e -p "${green}Nombre d'image par secondes de votre caméra (1 à 100): ${reset}" -i "25" fps

read -e -p "${green}Voulez-vous sécurisez votre caméra? (y/n): ${reset}" -i "y" answer

auth=0

if echo "$answer" | grep -iq "^y" ;then
  echo "${green}Entrez le nom d'utilisateur : ${reset}"
  read user

  echo "${green}Entrez le password : ${reset}"
  read password

  auth=1
fi

pkill -9 mjpg_streamer

if which svn >/dev/null; then
  echoGreen "mjpg_streamer already installed"
else
  echoGreen "Update CHIP"
  sudo apt-get update -y

  echoGreen "Install mjpg_streamer"
  sudo apt-get -y --force-yes install uvcdynctrl
  sudo apt-get -y --force-yes install build-essential subversion libjpeg62-turbo-dev
  sudo apt-get -y --force-yes install imagemagick libv4l-0 libv4l-dev
  mkdir mjpg-streamer
  cd mjpg-streamer
  svn co https://svn.code.sf.net/p/mjpg-streamer/code mjpg-streamer
  cd mjpg-streamer/mjpg-streamer
  wget https://dl.dropboxusercontent.com/u/48891705/chip/input_uvc_patch
  patch -p0 < input_uvc_patch
  make USE_LIBV4L2=true clean all
  sudo make install
fi

cd ~

if [ "$auth" -eq "1" ]; then
  echo "auth"
  echo -e "#!/bin/bash\npkill -9 mjpg_streamer\n/usr/local/bin/mjpg_streamer -i \"/usr/local/lib/input_uvc.so -n -f ${fps} -r ${width}x${height}\" -o \"/usr/local/lib/output_http.so -p 80 -w /usr/local/www  -c ${user}:${password}\" &">'streamer'
else
  echo "no auth"
  echo -e "#!/bin/bash\npkill -9 mjpg_streamer\n/usr/local/bin/mjpg_streamer -i \"/usr/local/lib/input_uvc.so -n -f ${fps} -r ${width}x${height}\" -o \"/usr/local/lib/output_http.so -p 80 -w /usr/local/www\" &">'streamer'
fi

chmod +x 'streamer'

echo -e "#!/bin/bash
sudo ~/streamer
exit 0">'/etc/rc.local'

sudo axp209 --no-limit
sudo systemctl enable no-limit

./streamer
sudo sync

echoGreen "Finished"

#sudo axp209 --no-limit
#sudo systemctl enable no-limit
#iw dev wlan0 set power_save off
