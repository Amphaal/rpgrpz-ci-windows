FROM archlinux/base:latest
LABEL maintainer="guillaume.vara@gmail.com"

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

#update pacman
RUN pacman -Syyu --noconfirm --noprogressbar 

#install wine
RUN pacman -S --noconfirm --noprogressbar wine
RUN winecfg

#install requirements (some packages require to run some .exe)
RUN pacman -S --noconfirm --noprogressbar \
    mingw-w64-x86_64-gstreamer \
    mingw-w64-x86_64-gst-plugins-base \
    mingw-w64-x86_64-gst-plugins-good \
    mingw-w64-x86_64-qt-installer-framework \
    mingw-w64-x86_64-qt5 \ 
    mingw-w64-x86_64-miniupnpc \
    mingw-w64-x86_64-breakpad-git \
    mingw-w64-x86_64-gtest

#install base build tools
RUN pacman -S --noconfirm --noprogressbar git cmake ninja clang lld

# Cleanup
RUN pacman -Scc --noconfirm
RUN paccache -r -k0; \
    rm -rf /usr/share/man/*; \
    rm -rf /tmp/*; \
    rm -rf /var/tmp/*;