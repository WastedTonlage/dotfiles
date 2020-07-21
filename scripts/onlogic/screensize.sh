#! /bin/sh

echo ran > /tmp/ran
xrandr -q | grep -F " connected" || xrandr --fb 1920x1080
