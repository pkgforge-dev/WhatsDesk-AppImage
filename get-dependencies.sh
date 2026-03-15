#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm  \
	dbus-broker			 \
 	nodejs 				 \
 	libappindicator-gtk3 \
	libxcrypt-compat	 \
	libnotify 			 \
	npm 				 \
	pipewire-audio 		 \
	pipewire-jack		 \
	pnpm

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

echo "Building WhatsDesk..."
echo "---------------------------------------------------------------"
REPO="https://gitlab.com/zerkc/whatsdesk.git"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --depth 1 "$REPO" ./whatsdesk
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./whatsdesk
npm install

case "$ARCH" in
	aarch64) EB_ARCH="arm64" ;;
	*)       EB_ARCH="x64" ;;
esac
if [ "$EB_ARCH" != "x64" ]; then
	sed -i "s/builder\.Arch\.x64/builder.Arch.$EB_ARCH/" build.js
fi

BUILD_TARGETS=dir BUILD_SKIP_PUBLIC=true npm run build

if [ "$ARCH" = "aarch64" ]; then
	mv -v dist/linux-arm64-unpacked/* ../AppDir/bin
else
	mv -v dist/linux-unpacked/* ../AppDir/bin
fi
