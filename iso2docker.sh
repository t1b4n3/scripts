#!/bin/bash

# Step 1: Ask for user input
echo "Please enter the path to the ISO file (e.g., /path/to/iso):"
read iso_file

# Check if the ISO file exists
if [ ! -f "$iso_file" ]; then
    echo "Error: The specified ISO file does not exist."
    exit 1
fi

echo "Please enter the Docker image name and tag (e.g., myimage:latest):"
read image_name_tag

# Step 2: Create the necessary directories
mkdir rootfs unsquashfs

# Step 3: Mount the ISO file to a folder
echo "Mounting ISO..."
sudo mount -o loop "$iso_file" rootfs

# Step 4: Change directory to rootfs (where the filesystem will be extracted)
cd rootfs

# Step 5: Find the filesystem.squashfs file in the mounted ISO
echo "Searching for the squashfs file..."
squashfs_file=$(find . -type f | grep filesystem.squashfs)

# Check if the file was found
if [ -z "$squashfs_file" ]; then
    echo "filesystem.squashfs not found in the mounted ISO."
    exit 1
fi

echo "Found filesystem.squashfs: $squashfs_file"

# Step 6: Change directory back to the original location


# Step 7: Unsquash the SquashFS image
echo "Unsquashing the filesystem..."
sudo unsquashfs -f -d ../unsquashfs/ "$squashfs_file"

# Step 8: Create a Docker image from the unsquashed filesystem
echo "Importing to Docker..."
sudo tar -C ../unsquashfs -c . | docker import - "$image_name_tag"

echo "Docker image $image_name_tag created successfully!"
