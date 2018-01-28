#!/bin/bash
FORCE=1
set -x
set -e

#check if root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
fi

#Add non-free to sources.lists
DEBIAN_RELEASE=`cat /etc/*-release 2> /dev/null | grep PRETTY_NAME | awk -F "=" {'print $2'} | awk -F "(" {'print $2'} | awk -F ")" {'print $1'}`

echo "Writes /etc/apt/sources.list in order to add $DEBIAN_RELEASE non-free repository"

echo "# deb http://http.debian.net/debian $DEBIAN_RELEASE main" > /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://http.debian.net/debian $DEBIAN_RELEASE main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://http.debian.net/debian $DEBIAN_RELEASE main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ $DEBIAN_RELEASE/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ $DEBIAN_RELEASE/updates main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "# $DEBIAN_RELEASE-updates, previously known as "volatile"" >> /etc/apt/sources.list
echo "deb http://http.debian.net/debian $DEBIAN_RELEASE-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://http.debian.net/debian $DEBIAN_RELEASE-updates main contrib non-free" >> /etc/apt/sources.list




apt-get update
apt-get install -y sudo git git-flow wget curl  \
firefox-esr \
vim \
meld \
software-properties-common \
firmware-b43-installer \
firmware-iwlwifi

#For FIRST FTC
JAVAMAJOR="8"
JAVAMINOR="161"
JAVAVERSION="${JAVAMAJOR}u${JAVAMINOR}"
JAVAFOLDER="jdk1.${JAVAMAJOR}.0_${JAVAMINOR}"
JAVABUILD="12"
JAVAFILE="jdk-${JAVAVERSION}-linux-x64.tar.gz"
JAVAHASH="2f38c3b165be4555a1fa6e98c45e0808"
if [ ! -f ${JAVAFILE} ]; then
  wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVAVERSION}-b${JAVABUILD}/${JAVAHASH}/${JAVAFILE}
fi 
if [ ! -f ${JAVAFILE} ]; then
  echo "File Not Download"
  exit 1
fi
tar -xf ${JAVAFILE}
if [ -d $JAVAFOLDER ] ; then 
  chown -R root:root ${JAVAFOLDER}
  if [ "$FORCE" == "1" ]; then
    rm -rf /usr/lib/jvm/${JAVAFOLDER}
  fi
  mv -i $JAVAFOLDER/ /usr/lib/jvm/
  update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/${JAVAFOLDER}/bin/java" 1
  update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/${JAVAFOLDER}/bin/javac" 1
  update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/${JAVAFOLDER}/bin/javaws" 1
  update-alternatives --set "java" "/usr/lib/jvm/${JAVAFOLDER}/bin/java" 
  update-alternatives --set "javac" "/usr/lib/jvm/${JAVAFOLDER}/bin/javac" 
  update-alternatives --set "javaws" "/usr/lib/jvm/${JAVAFOLDER}/bin/javaws" 
else
  echo "Java Folder Wrong"
  exit 1
fi  
echo "Checking Java Versions"
if [ "`java -version 2>&1 | grep 1.${JAVAMAJOR}.0_${JAVAMINOR}-b${JAVABUILD} > /dev/null ; echo $?`" != "0" ] ; then 
  echo "Java Version Error"
  exit 1
fi
if [ ! -d /opt/android-studio/ ] ; then
  wget https://dl.google.com/dl/android/studio/ide-zips/3.0.1.0/android-studio-ide-171.4443003-linux.zip
  unzip android-studio-ide-*
  rm android-studio-ide*
  mv android-studio/ /opt/
fi
cat << EOF > /etc/profile.d/android 
#ANDROID
export PATH=${PATH}:/opt/android-studio/bin
EOF
grep -q -F '#ANDROID' /etc/bash.bashrc || cat << EOF >> /etc/bash.bashrc
#ANDROID
export PATH=${PATH}:/opt/android-studio/bin
EOF

grep -q -F '#FIRST Helpers Bin' /etc/bash.bashrc || cat << EOF >> /etc/bash.bashrc
#FIRST Helpers Bin
export PATH=${PATH}:/opt/first-helpers/bin
EOF
grep -q -F '#FIRST Helpers Source' /etc/bash.bashrc || cat << EOF >> /etc/bash.bashrc
#FIRST Helpers Source
source /opt/first-helpers/bin/first-profile.sh
EOF
mkdir -p /opt/first-helpers/bin
cp first-profile.sh /opt/first-helpers/bin/


cat << EOF > /usr/share/applications/android.desktop
[Desktop Entry]
Comment=Android Studio
Terminal=false
Name=Android Studio
Exec=/opt/android-studio/bin/studio.sh
Type=Application
Icon=/opt/android-studio/bin/studio.png
EOF
