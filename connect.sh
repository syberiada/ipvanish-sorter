#!/bin/sh
# passfile contains your IPVanish credentials
sudo openvpn --config ~/vpn/profiles/ipvanish-US-San-Jose-sjc-a01.ovpn --auth-user-pass ~/vpn/passfile --ca ~/vpn/profiles/ca.ipvanish.com.crt
