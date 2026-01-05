#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 kernel_module.c"
    exit 1
fi

SRC="$1"

if [[ "$SRC" != *.c ]]; then
    echo "[!] not a .c file"
    exit 1
fi

MOD_NAME="$(basename "$SRC" .c)"

cat > Makefile <<EOF
obj-m := ${MOD_NAME}.o

KDIR ?= ../linux
PWD  := \$(shell pwd)

all:
	make -C \$(KDIR) M=\$(PWD) modules

clean:
	make -C \$(KDIR) M=\$(PWD) clean
EOF


echo "[*] building ${MOD_NAME}.ko"

make clean
make

if [ ! -f "${MOD_NAME}.ko" ]; then
    echo "[!] build failed"
    exit 1
fi

echo "[+] built ${MOD_NAME}.ko"

cp "${MOD_NAME}.ko" ..

make clean

rm Makefile