Пользователи и группы. Авторизация и аутентификация_РАМ

root@pam:~# sudo useradd otus

root@pam:~# sudo useradd otusadm

root@pam:~# passwd otus

root@pam:~# passwd otusadm

root@pam:~# groupadd -f admin

root@pam:~# usermod otusadm -a -G admin

root@pam:~# usermod vagrant -a -G admin

root@pam:~# usermod root -a -G admin

создан файл /usr/local/bin/login.sh

задаем права на запуск: chmod +x /usr/local/bin/login.sh

добавляем в конфиг sshd - /etc/pam.d/sshd

auth required pam_exec.so debug /usr/local/bin/login.sh

user@pc ~> ssh otus@192.168.57.10

otus@192.168.57.10's password: 

Permission denied, please try again.

user@pc ~> ssh otusadm@192.168.57.10

otusadm@192.168.57.10's password: 

Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-100-generic x86_64)