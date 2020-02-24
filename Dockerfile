FROM archlinux:latest
LABEL maintainer="guillaume.vara@gmail.com"

#update base pacman
RUN pacman -Syyu --noconfirm --noprogressbar 

#install base build tools to install yay
RUN pacman -S --noconfirm --noprogressbar --needed base-devel git nano

#define nano as default editor
ENV EDITOR=nano

# Create devel user...
RUN useradd -m -d /home/devel -u 1000 -U -G users,tty -s /bin/bash devel
RUN echo 'devel ALL=(ALL) NOPASSWD: /usr/sbin/pacman, /usr/sbin/makepkg' >> /etc/sudoers;

#Workaround for the "setrlimit(RLIMIT_CORE): Operation not permitted" error when compiling yay
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

#define temporary yay build dir
ARG BUILDDIR=/tmp/tmp-build

USER devel
    # Install yay
    RUN  mkdir "${BUILDDIR}" && cd "${BUILDDIR}" && \
        git clone https://aur.archlinux.org/yay.git && \
        cd yay && makepkg -si --noconfirm --rmdeps && \
        rm -rf "${BUILDDIR}"

USER root
    #add multilib mirrorlist (for wine)
    RUN echo "[multilib]" >> /etc/pacman.conf \
        && echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
        && echo "" >> /etc/pacman.conf

    #install build prerequisites (1 / 2)
    RUN pacman -S --noconfirm --noprogressbar --needed ninja lld wine cmake clang llvm

USER devel
    #install build prerequisites (2 / 2)
    RUN yay -S --noconfirm --noprogressbar --needed \
            mingw-w64-wine \
            mingw-w64-cmake \
            mingw-w64-clang-git \
            mingw-w64-llvm