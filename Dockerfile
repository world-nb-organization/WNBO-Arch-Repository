FROM archlinux:latest
RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist &&\ 
pacman -Syyuu --noconfirm &&\
pacman -S base-devel linux-headers git vim sudo --noconfirm &&\
mkdir /aur
RUN echo 'archlive:$6$xGBSPctIakBmXtcF$AK45.AHbiNMaWOJKjmaBSCpkkiLIoizgd4iSqLOqSf6OOouznQABwJVFBg9kyQCK04Eye0njyvVW/7kTc.JCw/:19130:0:99999:7:::' >> /etc/shadow &&\
echo -e "wheel:x:10:archlive\narchlive:x:1000:" >> /etc/group &&\
echo 'archlive:x:2000:2000::/home/archlive:/usr/bin/bash' >> /etc/passwd &&\
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
USER archlive
COPY build-pacakages.sh /aur/build-pacakages.sh
ENTRYPOINT ["/aur/build-pacakages.sh"]
