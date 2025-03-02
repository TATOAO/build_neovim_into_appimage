# Stage 1: build devs && Python3.12
# Use an debian base image
FROM debian:bullseye AS build-deps

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    cmake \
    xz-utils \
    libtool-bin \
    fuse \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libffi-dev \
    liblzma-dev \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    libgdbm-compat-dev \
    software-properties-common \
    && apt-get clean

RUN apt install --reinstall coreutils

RUN mkdir -p /AppDir/usr/bin /AppDir/usr/share /AppDir/usr/lib /AppDir/usr/share/nvim/runtime /AppDir/usr/local/nodejs /tmp

# Install Node.js in /AppDir/usr/local
RUN cd /tmp && wget https://nodejs.org/dist/v18.17.1/node-v18.17.1-linux-x64.tar.xz \
    && tar -xJf node-v18.17.1-linux-x64.tar.xz \
    && mv node-v18.17.1-linux-x64 /AppDir/usr/local/nodejs


# Add Node.js to PATH
ENV PATH="/AppDir/usr/local/nodejs/node-v18.17.1-linux-x64/bin:$PATH"

# Verify Node.js and npm versions
RUN node -v && npm -v

RUN cd /tmp \
	&& wget https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz \
    && tar -xf Python-3.12.4.tgz \
    && cd Python-3.12.4 \
    && ./configure --prefix=/AppDir/usr/local \
    && make -j$(nproc) \
    && make install

RUN apt-get install -y ninja-build gettext

FROM build-deps AS build_neovim

RUN /AppDir/usr/local/bin/python3.12 -m pip install --no-cache-dir --prefix=/AppDir/usr/local pynvim

ENV PATH=/AppDir/usr/local/bin:$PATH

RUN git clone --depth 1 --branch stable https://github.com/neovim/neovim.git \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release \
    && make install DESTDIR=/AppDir


# # Set up Neovim configuration
RUN echo "build configuration updated 2"
COPY ./config/nvim /AppDir/usr/share/config/nvim
ENV PATH=/AppDir/usr/bin:$PATH

ENV XDG_CONFIG_HOME="/AppDir/usr/share/config"
ENV XDG_DATA_HOME="/AppDir/usr/share/local/share"
ENV XDG_STATE_HOME="/AppDir/usr/share/local/state"

RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c ":TSUpdateSync" +qa
RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c ":TSUpdateSync" +qa
RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c ":TSUpdateSync" +qa
RUN nvim --headless -c 'MasonInstall jq pyright black isort yapf sql-formatter lua-language-server' +qa

RUN ln -s /AppDir/usr/local/bin/nvim /AppDir/usr/bin/nvim
# Install Pyright via npm into /AppDir/usr/local
RUN npm install -g --prefix /AppDir/usr/local pyright

# Install Ripgrep
RUN cd /tmp && wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
    && cp ripgrep-13.0.0-x86_64-unknown-linux-musl/rg /AppDir/usr/local/bin/


# # Copy AppRun script (used by AppImage)
COPY ./AppRun /AppDir/AppRun
COPY ./nvim.desktop /AppDir/nvim.desktop
COPY ./nvim.png /AppDir/nvim.png
RUN chmod +x /AppDir/AppRun
#
# # Copy the AppImageTool to create the AppImage
RUN cd /tmp && wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
RUN chmod +x /tmp/appimagetool-x86_64.AppImage

