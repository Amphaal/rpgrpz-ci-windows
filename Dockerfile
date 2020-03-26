FROM amphaal/rpgrpz-docker-ci:latest
LABEL maintainer="guillaume.vara@gmail.com"

USER root
    #add multilib mirrorlist (for wine)
    RUN echo "[multilib]" >> /etc/pacman.conf \
        && echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
        && echo "" >> /etc/pacman.conf \
        && pacman -Sy

    #install build prerequisites (1 / 3) (base)
    RUN pacman -S --noconfirm --noprogressbar --needed wine

USER devel
    #install build prerequisites (2 / 3) (prebuilt requisites)
    RUN yay -S --noconfirm --noprogressbar --needed mingw-w64-crt-bin \ 
                                                    mingw-w64-gcc-bin \ 
                                                    mingw-w64-binutils-bin \ 
                                                    mingw-w64-winpthreads-bin \
                                                    mingw-w64-headers-bin
    
    #install build prerequisites (3 / 3) (helpers)
    RUN yay -S --noconfirm --noprogressbar --needed mingw-w64-wine
    RUN yay -S --noconfirm --noprogressbar --needed mingw-w64-clang-git 
    RUN yay -S --noconfirm --noprogressbar --needed mingw-w64-cmake 

USER root
    #add msys2 mirrorlist
    RUN echo "[mingw64]"  >> /etc/pacman.conf \
        && echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf \
        && echo "Server = http://repo.msys2.org/mingw/x86_64/" >> /etc/pacman.conf \
        && echo "Server = https://sourceforge.net/projects/msys2/files/REPOS/MINGW/x86_64/" >> /etc/pacman.conf \
        && echo "Server = http://www2.futureware.at/~nickoe/msys2-mirror/mingw/x86_64/" >> /etc/pacman.conf \
        && echo "Server = https://mirror.yandex.ru/mirrors/msys2/mingw/x86_64/" >> /etc/pacman.conf \
        && pacman -Syu --needed --noconfirm

    #install requirements (some packages require to run some .exe)
    RUN pacman -S --noconfirm --noprogressbar \
        mingw64/mingw-w64-x86_64-gstreamer \
        mingw64/mingw-w64-x86_64-gst-plugins-base \
        mingw64/mingw-w64-x86_64-gst-plugins-good \
        mingw64/mingw-w64-x86_64-qt-installer-framework \
        mingw64/mingw-w64-x86_64-qt5 \ 
        mingw64/mingw-w64-x86_64-miniupnpc
    
    #install uasm
    RUN yay -S --noconfirm --noprogressbar --needed uasm
    
CMD [ "/usr/bin/bash" ]
COPY compile.sh /
