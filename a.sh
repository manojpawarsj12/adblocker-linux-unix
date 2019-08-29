#o!/bin/bash
# Block ad serving and tracking system-wide even before a request is issued to them.

SOURCE='https://raw.githubusercontent.com/EnergizedProtection/block/master/unified/formats/hosts'
BACKUP='https://raw.githubusercontent.com/manojpawarsj12/adblocker-linux-unix/master/hosts.default'
TARGET='/etc/hosts'
DOWNLOADED='/etc/hosts.blocklist'
ORIGINAL='/etc/hosts.without-adblock'



clear_dns_cache() {
	if command -v sw_vers >/dev/null 2>&1
	then
		if sw_vers -productVersion | grep -q '10\.6'
		then sudo dscacheutil -flushcache
		elif sw_vers -productVersion | grep -q '10\.10(\.[123])?$'
		then sudo killall -HUP discoveryd
		else sudo killall -HUP mDNSResponder
		fi

		echo 'DNS cache flushed'
	fi
}


block() {
	local tmpfile="$DOWNLOADED.part"

	sudo curl $SOURCE --show-error -\# --output "$tmpfile" && # -# is "show progress as a bar instead of full metrics"
	sudo rm -f "$DOWNLOADED" &&	# -f allows to be silent if the file does not exist
	sudo mv "$tmpfile" "$DOWNLOADED" &&
	sudo cat "$ORIGINAL" | sudo tee "$TARGET" > /dev/null &&
	sudo cat "$DOWNLOADED" | sudo tee -a "$TARGET" > /dev/null &&	# append to file rather than overwrite it
	echo 'Hosts file updated'
}

unblock() {
	

	sudo rm "$TARGET" &&
	sudo cp "$ORIGINAL" "$TARGET" &&
	echo 'Hosts file restored' &&
	sudo rm "$ORIGINAL"
}

stats() {
	local count=$(grep '^0.0.0.0' "$TARGET" | wc -l | tr -d ' ')

	echo "$count domains currently blocked"
}

echo " adblocker by luffysan press 1 to block and 2 to unblock "
read kek
if kek==1
then 
	clear_dns_cache
	stats
	block
elif kek==2
then
	unblock
	exit
else
	echo "wrong nput try running script again"
fi 

