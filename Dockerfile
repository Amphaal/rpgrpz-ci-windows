FROM amphaal/base-docker-ci-mingw:latest
LABEL maintainer="guillaume.vara@gmail.com"

USER root
    #install requirements (some packages require to run some .exe)
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-qt5
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-gstreamer
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-gst-plugins-base
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-gst-plugins-good
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-miniupnpc
    RUN pacman -S --noconfirm --noprogressbar mingw64/mingw-w64-x86_64-uasm

    #rename header files
    RUN cd /mingw64/x86_64-w64-mingw32/include \ 
        && cp ntsecapi.h NTSecAPI.h
    
    #install sentry-cli    
    RUN curl -sL https://sentry.io/get-cli/ | bash
    
    CMD [ "/usr/bin/bash" ]
