echo "Создаем пулы"
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdh
zpool create otus4 mirror /dev/sdg /dev/sdi

echo "Задаем компрессию на пулах"
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

echo "Скачиваем файл на все пулы"
wget -P / https://gutenberg.org/cache/epub/2600/pg2600.converter.log
for i in {1..4}; do \cp pg2600.converter.log /otus$i; done

echo "Выводим значения компрессии для каждого пула"
zfs get all | grep compressratio | grep -v ref

echo "Скачиваем файл и импортируем пул"
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
tar -xzvf archive.tar.gz
zpool import -d zpoolexport/ otus

echo "Выводим параметры пула"
zfs get all otus | grep 'available\|type\|recordsize\|checksum\|recordsize\|compression'

echo "Скачивание и восстановление снапшота"
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
sleep 30
zfs receive otus/test@today < otus_task2.file

echo "Поиск секретного сообщения"
find /otus/test -name "secret_message"
echo "Секретное сообщение:"
cat /otus/test/task1/file_mess/secret_message