# Stage 1: Build Dependencies on CentOS 7
FROM centos:7 AS build-deps


# Fix the yum repositories to use vault.centos.org
RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-* \
    && sed -i 's|^#baseurl=|baseurl=|g' /etc/yum.repos.d/CentOS-* \
    && sed -i 's|mirror.centos.org|vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum clean all && yum makecache fast

# Install Development Tools and Dependencies
RUN yum groupinstall -y "Development Tools"
RUN yum install -y epel-release
RUN yum install -y \
    curl \
    wget \
    git \
    cmake3 \
    xz \
    libtool \
    fuse-devel \
    openssl-devel \
    zlib-devel \
    bzip2-devel \
    readline-devel \
    sqlite-devel \
    ncurses-devel \
    gdbm-devel \
    nss-devel \
    libffi-devel \
    tk-devel \
    libxml2-devel \
    libxmlsec1-devel \
    gettext \
    ninja-build \
    perl-FindBin \
    perl-lib \
    which

# Create Directories
RUN mkdir -p /AppDir/usr/bin /AppDir/usr/share /AppDir/usr/lib /AppDir/usr/share/nvim/runtime /AppDir/usr/local/nodejs /tmp

# Set Node.js version
ENV NODE_VERSION=16.20.2

# Build Node.js from source
RUN cd /tmp && wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz \
    && tar -xzf node-v$NODE_VERSION.tar.gz \
    && cd node-v$NODE_VERSION \
    && ./configure --prefix=/AppDir/usr/local \
    && make -j$(nproc) \
    && make install

# Add Node.js to PATH
ENV PATH="/AppDir/usr/local/nodejs/bin:$PATH"

# # Verify Node.js and npm versions
# RUN node -v && npm -v
#
# # Install Python 3.12
# RUN mkdir -p /AppDir/usr/local
# RUN cd /tmp && wget https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz \
#     && tar -xf Python-3.12.4.tgz \
#     && cd Python-3.12.4 \
#     && ./configure --prefix=/AppDir/usr/local \
#     && make -j$(nproc) \
#     && make install
#
# # Install pynvim
# RUN /AppDir/usr/local/bin/python3.12 -m ensurepip
# RUN /AppDir/usr/local/bin/python3.12 -m pip install --no-cache-dir --prefix=/AppDir/usr/local pynvim
#
# # Update PATH
# ENV PATH="/AppDir/usr/local/bin:$PATH"
#
# # Build Neovim
# RUN git clone --depth 1 --branch stable https://github.com/neovim/neovim.git \
#     && cd neovim \
#     && make CMAKE_BUILD_TYPE=Release \
#     && make install DESTDIR=/AppDir
#
# # Copy Neovim Configuration
# COPY ./config/nvim /AppDir/usr/share/config/nvim
#
# # Set Environment Variables for Neovim
# ENV XDG_CONFIG_HOME="/AppDir/usr/share/config"
# ENV XDG_DATA_HOME="/AppDir/usr/share/local/share"
# ENV XDG_STATE_HOME="/AppDir/usr/share/local/state"
#
# # Install Neovim Plugins
# RUN nvim --headless "+Lazy! sync" +qa
# RUN nvim --headless -c ":TSUpdateSync" +qa
# RUN nvim --headless -c 'MasonInstall jq pyright black isort yapf sql-formatter lua-language-server' +qa
#
# # Install Ripgrep
# RUN cd /tmp && wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
#     && tar -xzf ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
#     && cp ripgrep-13.0.0-x86_64-unknown-linux-musl/rg /AppDir/usr/local/bin/
#
# # Copy AppRun script and other files
# COPY ./AppRun /AppDir/AppRun
# COPY ./nvim.desktop /AppDir/nvim.desktop
# COPY ./nvim.png /AppDir/nvim.png
# RUN chmod +x /AppDir/AppRun
#
# # Download appimagetool
# RUN cd /tmp && wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
# RUN chmod +x /tmp/appimagetool-x86_64.AppImage
#
# # Build the AppImage
# RUN /tmp/appimagetool-x86_64.AppImage --appimage-extract \
#     && /squashfs-root/AppRun --no-appstream --verbose /AppDir /Neovim.AppImage
#
# # The final AppImage is located at /Neovim.AppImage
#
