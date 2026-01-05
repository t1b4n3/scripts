#!/bin/bash

$VMLINUX="./linux/vmlinux"

gdb "$VMLINUX" -ex "target remote :1234"