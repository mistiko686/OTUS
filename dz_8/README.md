1.  В ходе выполнения попал тремя способами в однопользовательский режим Centos. 
    На этапе загрузки, в меню выбора ОС, нажимаем "е" переходим в редактор загрузчика
    пробуем способы из методички: init=/bin/sh    rd.break  так же редактируем  "ro" на "rw /init=sysroot/bin/sh"
    Все cпособы позволяют сменить пароль пользователя root - "passwd root" и загрузиться,используя свои учетные данные

2. Переименование Volume Group LVM:
   vgrename VolGroup00 OtusRoot
   Задаем новое название в трех файлах:
     /etc/fstab 
     /etc/default/grub 
     /boot/grub2/grub.cfg
   Далее требуется пересоздать образ initrd - mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
  
[vagrant@tosrer ~]$ sudo vgs

  VG       #PV #LV #SN Attr   VSize   VFree
  
  OtusRoot   1   2   0 wz--n- <38.97g    0 

   
3. Создал модуль и добавил его в initrd:
   
   [root@tosrer ~]# mkdir /usr/lib/dracut/modules.d/pingwin
   
   [root@tosrer ~]# cd /usr/lib/dracut/modules.d/pingwin
   
   [root@tosrer pingwin]# nano module-setup.sh
   
   [root@tosrer pingwin]# nano pingwin.sh
   
   [root@tosrer pingwin]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
         
   [root@tosrer pingwin]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep pingwin

   [root@tosrer ~]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep ping

   pingwin

При перезагрузке, видно пингвина в текстовом формате.