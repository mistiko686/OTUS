Задание по Systemd

1. создание сервиса и таймера для него:
   
   /var/log/watchlog.log добвлен текст плюс ALERT.
   
   сдание файлов в соответствии с указаниями:
   
   nano /etc/sysconfig/watchlog              
   nano /opt/watchlog.sh                        
   chmod +x /opt/watchlog.sh                    
   nano /etc/systemd/system/watchlog.service    
   nano /etc/systemd/system/watchlog.timer      
   systemctl start watchlog.service   
   systemctl start watchlog.timer
  
2. Запуск Апача

   yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
   
   /etc/sysconfig/spawn-fcgi
      
   nano /etc/systemd/system/spawn-fcgi.service
   
   systemctl start spawn-fcgi
   
   systemctl edit httpd
   
   systemctl start httpd@first
   
   systemctl start httpd@second
    
   ss -tnulp | grep httpd
   
   tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("httpd",pid=6269,fd=3),("httpd",pid=6268,fd=3),("httpd",pid=6267,fd=3),("httpd",pid=6265,fd=3))
   
   tcp   LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("httpd",pid=5671,fd=3),("httpd",pid=5670,fd=3),("httpd",pid=5669,fd=3),("httpd",pid=5667,fd=3))