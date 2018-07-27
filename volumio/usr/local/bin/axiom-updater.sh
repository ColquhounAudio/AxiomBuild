#!/bin/bash
echo "Calculating current hash"
md5=`md5sum /imgpart/volumio_current.sqsh | awk '{ print $1 }'`
if [[ `wget -S --spider https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/updates/$md5.sha256  2>&1 | grep 'HTTP/1.1 200 OK'` ]] ; then 
	echo "Found update. Downloading"; 
	wget -O /imgpart/$md5.sha256 https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/updates/$md5.sha256
	wget -O /imgpart/$md5.tar.gz https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/updates/$md5.tar.gz
	echo "Verifying signature"
	openssl base64 -d -in /imgpart/$md5.sha256 -out /tmp/$md5.sha256
	if openssl dgst -sha256 -verify /etc/axiom-image-signature-public.pem -signature /tmp/$md5.sha256 /imgpart/$md5.tar.gz; then
		echo "Signature verified"
		tar -zxf /imgpart/$md5.tar.gz -C /imgpart/
	else
		echo "Signature check failed"
	fi
	rm /imgpart/$md5.sha256
	rm /imgpart/$md5.tar.gz
	rm -f /tmp/$md5.sha256

fi
