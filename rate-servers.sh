#!/bin/sh
srvlist=./work/servers
stats=./work/stats
unsorted=./work/unsorted
sorted=./work/sorted
tmp=./work/tmp
stats=./work/stats
pingBlockSize=10
#for now
region=US

if [ ! -d "./work/" ];
then
	echo 'mkdir work folder'
	mkdir ./work
	sudo mount -t tmpfs -o size=256m tmpfs ./work/
else
	if [ $(mount | awk -v cd=$(pwd)'/work' '{if ($3 == cd) {exit 0}} ENDFILE{exit -1}') ];
	then
		echo 'work folder mounted, cleaning...'
		rm -f ./work/*
	else
		echo "work folder exists, mounting tmpfs?"
		sudo mount -t tmpfs -o size=256m tmpfs ./work/
	fi
fi


echo 'creating server list'
# US servers here, will add region selection later
for file in $(ls ./profiles/ | grep $region) #./profiles/*.ovpn
do
	grep -o -E "\w+-\w+\.ipvanish.com" -m 1 ./profiles/$file >> $srvlist
done
# echo $srvlist
total=$(wc -l $srvlist | grep -oP '\d+') #number of lines in srvlist file
echo 'pinging servers...'
for (( block = 10; block <= $total; block=$block+$pingBlockSize )) 
do
	echo 'block ' $block ' of ' $total
	tmpsrvlist=$(head -n $block $srvlist| tail| tr '\n' ' ')
	echo 'pinging ' $tmpsrvlist
	nping --delay 200ms -c 3 -H $tmpsrvlist >> $stats
done
echo 'done. cleaning up the file.'
grep -v "RCVD" $stats > $tmp && mv $tmp $stats
echo 'compiling unsorted rated list'
for e in $(cat $srvlist)
do
	echo $(awk -v srv=$e 'c&&!--c; $0~srv{c=2}' < $stats | grep -o -P 'Avg rtt: \d+\.\d{3}ms$' | grep -o -P '\d+\.\d+') $e >> $unsorted 
done
echo 'sorting...'
cat $unsorted | sort -n > $sorted
echo 'done'
echo '3 fastest servers' $(head -n 3 $sorted)

sudo umount -f ./work
rm -rf ./work