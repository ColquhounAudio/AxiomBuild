#!/bin/sh
rm -rf update

if [ $# -lt 3 ]; 
then
	echo 1>&2 "Usage: $0 <previous sqsh file> <new sqsh file> <axiom signature passphrase>"
	exit 2
fi

PREVIOUS=`readlink -e $1`
NEXT=`readlink -e $2`
PASS=$3


if [ ! -f "$PREVIOUS" ];
then
	echo 1>&2 "Error : Missing previous sqsh file"
	exit 2
fi

if [ ! -f "$NEXT" ];
then
	echo 1>&2 "Error : Missing new sqsh file"
	exit 2
fi

echo "Creating delta file..."
mkdir update
xdelta3 -e -9 -s $PREVIOUS $NEXT update/delta.patch

echo "Calculating hashes..."
cd update
ln -s $PREVIOUS ../volumio_current.sqsh
md5sum ../volumio_current.sqsh > verify.hash
md5sum ./delta.patch >> verify.hash
PHASH=`head -n 1 verify.hash |awk '{print $1}'`
rm ../volumio_current.sqsh
ln -s $NEXT ../volumio_current.sqsh
md5sum ../volumio_current.sqsh > final.hash
rm ../volumio_current.sqsh
cd ..

echo "Creating update package..."
cp scripts/update.sh update/update.sh
tar -cf $PHASH.tar update
gzip $PHASH.tar

echo "Signing update package..."
openssl dgst -sha256 -sign axiom-image-signature-private.pem -passin pass:$PASS -out /tmp/update.sha256 $PHASH.tar.gz
openssl base64 -in /tmp/update.sha256 -out $PHASH.sha256
rm /tmp/update.sha256


