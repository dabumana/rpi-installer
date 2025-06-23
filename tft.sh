#!/bin/bash
#
# Author: @dabumana
# Copyright BSD
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

DRIVER=$1
if [ -z "$1" ]
then
  echo "Help: ./install-dietpi-tft.sh [DRIVER] [SIZE] - You are missing an argument, add DRIVER name for TFT screen."
  exit
fi

SIZE=$2
if [ -z "$2" ]
then
  echo "Help: ./install-dietpi-tft.sh [DRIVER] [SIZE] - You are missing an argument, add screen SIZE."
  exit
fi

cd /tmp
wget https://github.com/goodtft/LCD-show/archive/master.zip

unzip master.zip
rm master.zip
cd LCD-show-master

cp usr/"$DRIVER"-overlay.dtb /boot/overlays/
mv usr/"$DRIVER"-overlay.dtb /boot/overlays/"$DRIVER".dtb

mkdir -p /etc/X11/xorg.conf.d
cp usr/99-calibration.conf-"$SIZE"-90  /etc/X11/xorg.conf.d/99-calibration.conf
mkdir -p  /usr/share/X11/xorg.conf.d
cp usr/99-fbturbo.conf  /usr/share/X11/xorg.conf.d/

sed -i 's/[[:blank:]]logo.nologo//' /boot/cmdline.txt
sed -i 's/[[:blank:]]fbcon=[^[:blank:]]*//g' /boot/cmdline.txt

echo "$(sed -n 1p /boot/cmdline.txt) fbcon=map:10 fbcon=font:ProFont6x11 logo.nologo" > /boot/cmdline_new.txt
mv /boot/cmdline_new.txt /boot/cmdline.txt

G_CONFIG_INJECT 'dtoverlay=$DRIVER' 'dtoverlay=$DRIVER:rotate=90' /boot/config.txt
G_CONFIG_INJECT 'dtparam=i2c_arm=' 'dtparam=i2c_arm=on' /boot/config.txt
G_CONFIG_INJECT 'dtparam=spi=' 'dtparam=spi=on' /boot/config.txt
G_CONFIG_INJECT 'enable_uart=' 'enable_uart=1' /boot/config.txt
G_CONFIG_INJECT 'hdmi_force_hotplug=' 'hdmi_force_hotplug=1' /boot/config.txt

G_AGI xserver-xorg-input-evdev
