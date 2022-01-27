#!/bin/sh
BUILD="arm"
ARCH="arm64"

echo 'Cloning Volumio Node Backend'
mkdir "build/$BUILD/root/volumio"

git clone --depth 1 -b pi4 --single-branch https://github.com/ColquhounAudio/Volumio2.git build/$BUILD/root/volumio
echo 'Cloning Volumio UI'
git clone --depth 1 -b AxiomAirV2-dist --single-branch https://github.com/ColquhounAudio/Volumio2-UI.git "build/$BUILD/root/volumio/http/www"
echo "Adding os-release infos"
{
	echo "VOLUMIO_FE_VERSION=\"$(git --git-dir "build/$BUILD/root/volumio/http/www/.git" rev-parse HEAD)\""
	echo "VOLUMIO_BE_VERSION=\"$(git --git-dir "build/$BUILD/root/volumio/.git" rev-parse HEAD)\""
	echo "VOLUMIO_ARCH=\"${BUILD}\""
} >> "build/$BUILD/root/etc/os-release"

rm -rf build/$BUILD/root/volumio/http/www/.git

# Download node modules
echo "Installing pre-build node-modules package"
wget -O build/$BUILD/root/volumio/node_modules.tar.gz https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/v1.0/node_modules_pi4.tar.gz
tar -zxf build/$BUILD/root/volumio/node_modules.tar.gz -C build/$BUILD/root/volumio
rm -f build/$BUILD/root/volumio/node_modules.tar.gz



