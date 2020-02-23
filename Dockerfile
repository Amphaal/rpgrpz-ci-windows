FROM archlinux:latest
LABEL maintainer="guillaume.vara@gmail.com"

#update base pacman
RUN pacman -Syyu --noconfirm --noprogressbar 

#install base build tools to install yay
RUN pacman -S --noconfirm --noprogressbar --needed base-devel git nano

#define nano as default editor
ENV EDITOR=nano

# Install yay
USER devel
ARG BUILDDIR=/tmp/tmp-build
RUN  mkdir "${BUILDDIR}" && cd "${BUILDDIR}" && \
     git clone https://aur.archlinux.org/yay.git && \
     cd yay && makepkg -si --noconfirm --rmdeps && \
     rm -rf "${BUILDDIR}"