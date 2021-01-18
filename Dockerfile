FROM amphaal/base-docker-ci-mingw:latest
LABEL maintainer="guillaume.vara@gmail.com"

USER root
    #install requirements
    ADD https://raw.githubusercontent.com/Amphaal/rpgrpz/master/prerequisites/msys2/pkglist_build.txt /
    RUN pacman -S --needed --noconfirm - < ./pkglist_build.txt
    
    #populate wrappers
    RUN echo "/mingw64/bin/lrelease.exe" > ./wine-wrappers/wrappersList.txt
    RUN echo "/mingw64/bin/lupdate.exe" >> ./wine-wrappers/wrappersList.txt
    RUN echo "/mingw64/bin/moc.exe" >> ./wine-wrappers/wrappersList.txt
    RUN echo "/mingw64/bin/rcc.exe" >> ./wine-wrappers/wrappersList.txt
    RUN echo "/mingw64/bin/uasm.exe" >> ./wine-wrappers/wrappersList.txt
    RUN echo "/mingw64/bin/uic.exe" >> ./wine-wrappers/wrappersList.txt
    RUN echo "/mingw64/bin/windeployqt.exe" >> ./wine-wrappers/wrappersList.txt
    
    #build and install wrappers
    RUN cd wine-wrappers && rm -rf _gen && cmake -GNinja -B_gen -H. && ninja -C_gen install && cd ..
    
    #
    CMD [ "/usr/bin/bash" ]
