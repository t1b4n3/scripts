#!/bin/bash

# Ask for the path to the QCOW2 file and Docker image name
echo "Please enter the path to the QCOW2 file (e.g., /path/to/image.qcow2):"
read qcow2_file

# Check if the QCOW2 file exists
if [ ! -f "$qcow2_file" ]; then
    echo "Error: The specified QCOW2 file does not exist."
    exit 1
fi

echo "Please enter the Docker image name and tag (e.g., myimage:latest):"
read image_name_tag

# Convert QCOW2 to RAW format
echo "Converting QCOW2 to RAW..."
raw_image="${qcow2_file%.qcow2}.img"
qemu-img convert -f qcow2 -O raw "$qcow2_file" "$raw_image"

# Check if conversion was successful
if [ ! -f "$raw_image" ]; then
    echo "Error: Failed to convert QCOW2 to RAW."
    exit 1
fi

echo "RAW image created: $raw_image"

# Create the necessary directories
mkdir -p mount_point unsquashfs

# Mount the raw disk image
echo "Mounting the RAW image..."
sudo mount -o loop "$raw_image" mount_point

# Copy the filesystem to the unsquashfs folder
echo "Copying the filesystem to the unsquashfs folder..."
sudo cp -a mount_point/. unsquashfs/

# Create Docker image from the unsquashfs directory
echo "Creating Docker image..."
sudo tar -C unsquashfs -c . | docker import - "$image_name_tag"

echo "Docker image $image_name_tag created successfully!"
