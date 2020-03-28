FROM amphaal/rpgrpz-docker-ci:latest
LABEL maintainer="guillaume.vara@gmail.com"

USER root
    #add multilib mirrorlist (for wine)
    RUN echo "[multilib]" >> /etc/pacman.conf \
        && echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
        && echo "" >> /etc/pacman.conf \
        && pacman -Sy

    #install build prerequisites
    RUN pacman -S --noconfirm --noprogressbar --needed wine
    
    # setup wine
    ENV WINEDEBUG=fixme-all
    ENV WINEARCH=win64
    RUN winecfg
    
    #add msys2 mirrorlist
    RUN echo "[mingw64]"  >> /etc/pacman.conf \
        && echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf \
        && echo "Server = http://repo.msys2.org/mingw/x86_64/" >> /etc/pacman.conf \
        && echo "Server = https://sourceforge.net/projects/msys2/files/REPOS/MINGW/x86_64/" >> /etc/pacman.conf \
        && echo "Server = http://www2.futureware.at/~nickoe/msys2-mirror/mingw/x86_64/" >> /etc/pacman.conf \
        && echo "Server = https://mirror.yandex.ru/mirrors/msys2/mingw/x86_64/" >> /etc/pacman.conf \
        && pacman -Syu --needed --noconfirm

    #install requirements (some packages require to run some .exe)
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-qt5
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-gstreamer
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-gst-plugins-base
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-gst-plugins-good
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-clang
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-lld
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-qt-installer-framework
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-miniupnpc
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-uasm

    #rename header files
    RUN cd /mingw64/x86_64-w64-mingw32/include \ 
        && cp ntsecapi.h NTSecAPI.h
    
    CMD [ "/usr/bin/bash" ]
