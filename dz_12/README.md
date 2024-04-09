Запуск nginx на нестандартном порту тремя разными способами

По умолчанию, SELinux не позволяет такой запуск - служба не стартует при запуске, о чем свидетельствуют сообщения при запуске ВМ:
selinux: Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

Сначала потребовалось установить необходимые для выполнения задания утилиты audit2why audit2allow:

yum install setroubleshoot

Их не было в образе ВМ вагранта.

Утилита audit2why позволяет узнать причину неработоспособности службы:

Сначала мне нужно было узнать, какое событие анализировать с помощью этой утилиты, т.к. временной штамп в методичке, конечно же другой.

Для этого я выполнил команду: grep nginx /var/log/audit/audit.log

и проанализировав вывод, обнаружил нужный лог и обработал его: grep 1706686187.869:801 /var/log/audit/audit.log | audit2why

Вывод команды, собственно, и дает подсказку для первого способа запуска nginx:

Was caused by: The boolean nis_enabled was set incorrectly.

Description: Allow nis to enabled

Allow access by executing:

# setsebool -P nis_enabled 1

После выполнения setsebool -P nis_enabled 1

nginx благополучно запустился на порту 4881:

[root@selinux ~]# systemctl restart nginx

[root@selinux ~]# systemctl status nginx

● nginx.service - The nginx HTTP and reverse proxy server

Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)

Active: active (running) since Wed 2024-01-31 08:15:14 UTC; 10s ago

Process: 3346 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)

Process: 3344 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)

Process: 3343 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)

Main PID: 3348 (nginx)

CGroup: /system.slice/nginx.service

3348 nginx: master process /usr/sbin/nginx

3350 nginx: worker process

Jan 31 08:15:14 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...

Jan 31 08:15:14 selinux nginx[3344]: nginx: the configuration file

/etc/nginx/nginx.conf syntax is ok

Jan 31 08:15:14 selinux nginx[3344]: nginx: configuration file

/etc/nginx/nginx.conf test is successful

Jan 31 08:15:14 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.

Второй способ запуска на нестандвртном порту - включение этого порта в конфигурацию SELinux с помощью команды semanage:

[root@selinux ~]# semanage port -l | grep http

http_cache_port_t tcp 8080, 8118, 8123, 10001-10010

http_cache_port_t udp 3130

http_port_t tcp 80, 81, 443, 488, 8008, 8009, 8443, 9000

pegasus_http_port_t tcp 5988

pegasus_https_port_t tcp 5989

Здесь мы видим, что в парамете http_port_t нет нужного нам 4881

Добавим нужны порт:

[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881

запуск успешен

[root@selinux ~]# systemctl restart nginx

[root@selinux ~]# systemctl status nginx

● nginx.service - The nginx HTTP and reverse proxy server

Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)

Active: active (running) since Wed 2024-01-31 08:21:36 UTC; 3s ago

Process: 3405 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)

Process: 3403 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)

Process: 3402 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)

Main PID: 3407 (nginx)

CGroup: /system.slice/nginx.service

3407 nginx: master process /usr/sbin/nginx

3409 nginx: worker process

Jan 31 08:21:36 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...

Jan 31 08:21:36 selinux nginx[3403]: nginx: the configuration file

/etc/nginx/nginx.conf syntax is ok

Jan 31 08:21:36 selinux nginx[Ж3403]: nginx: configuration file

/etc/nginx/nginx.conf test is successful

Jan 31 08:21:36 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.

Видим, что порт появился в списке:

[root@selinux ~]# semanage port -l | grep http

http_cache_port_t tcp 8080, 8118, 8123, 10001-10010

http_cache_port_t udp 3130

http_port_t tcp 4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000

pegasus_http_port_t tcp 5988

pegasus_https_port_t tcp 5989

Удаляем его для проверки следующего способа:

[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881

Третий способ - добавление модуля для nginx в SELinux.

После удаления порта nginx не запускается опять:

Jan 31 08:22:59 selinux systemd[1]: Failed to start The nginx HTTP and reverse

proxy server.

Теперь используем другую утилиту audit2allow, чтобы понять, как еще можно

заставить работать nginx на 4881 порту. Для этого дадим вывод лога утилите:

[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx

To make this policy package active, execute:

semodule -i nginx.pp

вводим команду:

semodule -i nginx.pp

запускаем сервер:

[root@selinux ~]# systemctl start nginx

[root@selinux ~]# systemctl status nginx

● nginx.service - The nginx HTTP and reverse proxy server

Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)

Active: active (running) since Wed 2024-01-31 08:27:06 UTC; 3s ago

Process: 3473 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)

Process: 3471 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)

Process: 3470 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)

Main PID: 3475 (nginx)

CGroup: /system.slice/nginx.service

3475 nginx: master process /usr/sbin/nginx

3477 nginx: worker process

Команда

[root@selinux ~]# semodule -l | grep nginx

nginx 1.0

2.Обеспечение работоспособности приложения при включенном SELinux

Разворачиваем стенд для работы.

Выполним клонирование репозитория:

git clone https://github.com/mbfx/otus-linux-adm.git

и запускаем машины:

vagrant up

Подключаюсь к клиенту:

vagrant ssh client

Ввод команд по добавлению в зону DNS еще одной записи не дает результата по

причине неправильного контекста безопасности для развернутой службы named:

команда для диагностики ошибок SELinux на клиенте

cat /var/log/audit/audit.log | audit2why

возвращает пустой вывод, что сообщает нам, что на стороне клиента ошибок нет.

Диагностируем сервер:

[root@ns01 ~]# getenforce

Enforcing

[root@ns01 ~]# cat /var/log/audit/audit.log | audit2allow

#!!!! WARNING: 'etc_t' is a base type.

allow named_t etc_t:file create;

Сразу видно, что контекст безопасности SELinux неверный - вместо named_t у нас etc_t

Еще подтверждение этому следующая команда:

[root@ns01 ~]# ls -laZ /etc/named

drw-rwx---. root named system_u:object_r:etc_t:s0 .

drwxr-xr-x. root root system_u:object_r:etc_t:s0 ..

drw-rwx---. root named unconfined_u:object_r:etc_t:s0 dynamic

-rw-rw----. root named system_u:object_r:etc_t:s0 named.50.168.192.rev

-rw-rw----. root named system_u:object_r:etc_t:s0 named.dns.lab

-rw-rw----. root named system_u:object_r:etc_t:s0 named.dns.lab.view1

-rw-rw----. root named system_u:object_r:etc_t:s0 named.newdns.lab

Видно, что установленный контекст - etc_t, а это неправильно, изменения конфигурации невозможны

Чтобы понять, какой нам нужен правильный тип контекста для работы, выполним его поиск с помоющью команды

[root@ns01 ~]# semanage fcontext -l | grep named

Правильный контекст - named_zone_t

Теперь нужно установить его на данный каталог - тогда изменения конфигурации

будут возможны - это самый простой способ заставить работать сервис DNS. Нам не придется

выполнять переустановку или менятькаталоги приложения.

Меняем контекст на верный:

[root@ns01 ~]# sudo chcon -R -t named_zone_t /etc/named

и проверяем:

[root@ns01 ~]# ls -laZ /etc/named

drw-rwx---. root named system_u:object_r:named_zone_t:s0 .

drwxr-xr-x. root root system_u:object_r:etc_t:s0 ..

drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic

-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev

-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab

-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1

-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab

после всех действий изменения зоны с клиента проходит без ошибок, все.