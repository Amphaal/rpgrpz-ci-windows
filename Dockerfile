FROM archlinux:latest
LABEL maintainer="guillaume.vara@gmail.com"

#update base pacman
RUN pacman -Syyu --noconfirm --noprogressbar 

#install base build tools (1/2)
RUN pacman -S --noconfirm --noprogressbar --needed nano yay