#!/bin/bash

VMLINUX=$(pwd)/linux
INITRAMFS=$(pwd)/initramfs
OUTMOD="$INITRAMFS/home"

is_ko() {
	file "$1" | grep -q "relocatable"
}

if [ $1 ]; then 
	if is_ko "$1"; then
		MODULE_PATH="$1"
		cp $MODULE_PATH "$OUTMOD"
	else
		MOD=$(find "$(dirname "$1")" -maxdepth 3 -name "*.ko")
		if [ ! -f "$MOD" ]; then
        		echo "[-] .ko not found"
        		exit 1
		fi
		cp "$MOD" "$OUTMOD"
	fi
fi

if [ $2 ]; then 
	cp "$2" "$OUTMOD"
fi

echo  "building initramfs"
#cd "$INITRAMFS"
cd "./initramfs"
find . -not -name *.cpio | cpio -o -H newc > ../initramfs.cpio
cpio -i -F ../initramfs.cpio
cd ..

qemu-system-x86_64 -s \
    -kernel bzImage \
    -initrd initramfs.cpio \
    -append "console=ttyS0 quit loglevel=3 panic=10 oops=panic nokaslr" \
    -monitor /dev/null \
    -nographic \
    -no-reboot

#-append "console=ttyS0 quit loglevel=3 panic=10 oops=panic" \

rm ./initramfs/home/*
rm ./initramfs.cpio
