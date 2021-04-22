loop-blocks & 
loop-comp &
/home/tonlage/src/bucklespring/buckle -p /home/tonlage/.config/buckles & 
unclutter -idle 1 & 

hsetroot -full Pictures/backgroundlight.png
setxkbmap -option caps:escape

while true
do
	dwm >> /tmp/dwm.log
	sleep 3
done
