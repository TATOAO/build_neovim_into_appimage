# cp your config folder in the current wokring dir
mkdir -p ./config
mkdir -p ./output
cp -r ~/.config/nvim ./config

# stage 1
docker build --target build-deps -t my-neovim-build-deps -f centos.Dockerfile .

# stage 2
docker build --target build_neovim -t my-neovim-build-deps -f centos.Dockerfile .


# Run the Docker container but not build the AppImage
# docker run -it --privileged -v /dev/fuse:/dev/fuse --name neovim-appimage-build my-neovim-build-deps /bin/bash
#

docker run -it --privileged -v /dev/fuse:/dev/fuse --name neovim-appimage-build my-neovim-build-deps /bin/bash 

# # Run the Docker container to build the AppImage
# docker run -it --privileged -v /dev/fuse:/dev/fuse --name neovim-appimage-build my-neovim-build-deps /bin/bash -c "ARCH=x86_64 /tmp/appimagetool-x86_64.AppImage /AppDir /nvim.AppImage"
#
# # Copy the AppImage from the container to your local machine
# docker cp neovim-appimage-build:/nvim.AppImage ./output/nvim.AppImage
#
# # Test the image 
# sh ./test_neovim_image.sh
#
# # Clean up: remove the container after copying the AppImage
# # docker rm neovim-appimage-build
