#!/bin/sh
echo starting vpn profile update...
wget https://configs.ipvanish.com/configs/configs.zip -O ./new.zip
if [ -f "./new.zip" ]; then
	echo 'new file downloaded'
	rm -f ./old.zip
	rm -f ./profiles/*
	unzip new.zip -d ./profiles/
	mv new.zip old.zip
	for file in ~/vpn/profiles/*.ovpn
	do
		sed -i '/keysize/d' $file
	done
echo 'done.'
fi
