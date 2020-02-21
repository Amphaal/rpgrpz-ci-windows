FROM archlinux/base:latest
LABEL maintainer="guillaume.vara@gmail.com"

# Create devel user...
RUN useradd -m -d /home/devel -u 1000 -U -G users,tty -s /bin/bash devel
RUN echo 'devel ALL=(ALL) NOPASSWD: /usr/sbin/pacman, /usr/sbin/makepkg' >> /etc/sudoers;

#create working dir
RUN mkdir -p /workdir && chown devel.users /workdir

#Workaround for the "setrlimit(RLIMIT_CORE): Operation not permitted" error
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

#update base pacman
RUN pacman -Syyu --noconfirm --noprogressbar 

#install base build tools (1/2)
RUN pacman -S --noconfirm --noprogressbar --needed pacman-contrib nano wget base-devel make

#install base build tools (2/2)
RUN pacman -S --noconfirm --noprogressbar --needed git cmake ninja clang lld pkg-config 

#define nano as default editor for debuging purposes
ENV EDITOR=nano

# Install yay
USER devel
ARG BUILDDIR=/tmp/tmp-build
RUN  mkdir "${BUILDDIR}" && cd "${BUILDDIR}" && \
     git clone https://aur.archlinux.org/yay.git 
RUN  cd "${BUILDDIR}/yay" && makepkg -si --noconfirm --rmdeps && \
     rm -rf "${BUILDDIR}"

USER root

#add multilib mirrorlist (for wine)
RUN echo "[multilib]" >> /etc/pacman.conf \
    && echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
    && echo "" >> /etc/pacman.conf

#add mingw64 mirrorlist
RUN echo "[mingw64]"  >> /etc/pacman.conf \
    && echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf \
    && echo "Server = http://repo.msys2.org/mingw/x86_64/" >> /etc/pacman.conf \
    && echo "Server = https://sourceforge.net/projects/msys2/files/REPOS/MINGW/x86_64/" >> /etc/pacman.conf \
    && echo "Server = http://www2.futureware.at/~nickoe/msys2-mirror/mingw/x86_64/" >> /etc/pacman.conf \
    && echo "Server = https://mirror.yandex.ru/mirrors/msys2/mingw/x86_64/" >> /etc/pacman.conf

#update pacman mirrors
RUN pacman -Sy 

#install wine
RUN pacman -S --noconfirm --noprogressbar wine
RUN winecfg

#define mingw64 root
ENV MINGW64_ROOT /mingw64

#additional search path for pkg-config
ENV PKG_CONFIG_PATH /mingw64/lib/pkgconfig

#install requirements (some packages require to run some .exe)
RUN pacman -S --noconfirm --noprogressbar \
    mingw64/mingw-w64-x86_64-gstreamer \
    mingw64/mingw-w64-x86_64-gst-plugins-base \
    mingw64/mingw-w64-x86_64-gst-plugins-good \
    mingw64/mingw-w64-x86_64-qt-installer-framework \
    mingw64/mingw-w64-x86_64-qt5 \ 
    mingw64/mingw-w64-x86_64-miniupnpc \
    mingw64/mingw-w64-x86_64-breakpad-git \
    mingw64/mingw-w64-x86_64-gtest

#install AUR packages
RUN yay -S --noconfirm --noprogressbar --needed \
        mingw-w64-clang-git

# Cleanup
USER root
RUN pacman -Scc --noconfirm
RUN rm -rf /usr/share/man/*; \
    rm -rf /tmp/*; \
    rm -rf /var/tmp/*;
USER devel
RUN yay -Scc

#setup env
ENV HOME=/home/devel
WORKDIR /workdir
ONBUILD USER root
ONBUILD WORKDIR /