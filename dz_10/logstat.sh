#!/bin/bash

# Переменные - логи, файл с меткой текущего времени
ACCESS_LOG_FILE=/etc/httpd/logs/access_log
ERROR_LOG_FILE=/etc/httpd/logs/error_log
TIME_FILE=/tmp/run_date.time
CURRENT_DATE=`date +%e/%b/%C%y:%H:%M:%S`
RUN_DATE=[`cat $TIME_FILE`

# Уникальные адреса и их количество
OUTPUT="$(awk '{if ($4 > "'$RUN_DATE'") print $1}' apache_log | sort -nr | uniq -c | sort -nr | head -n 30)"
echo -e "$OUTPUT" | mail -s "Уникальные адреса и их количество с $RUN_DATE по $CURRENT_DATE" mistiko@mail.ru
# Топ запрошенных УРЛ и их количество
OUTPUT="$(awk '{if ($4 > "'$RUN_DATE'") print $11}' apache_log | sort -nr | uniq -c | sort -nr | head -n 30)"
echo -e "$OUTPUT" | mail -s "Топ запрошенных УРЛ и их количество с $RUN_DATE по $CURRENT_DATE" mistiko@mail.ru
# Серверные ошибки
OUTPUT="$(grep "error"  ./error_log | awk '{if ($1 > "'$RUN_DATE'") print}')"
echo -e "$OUTPUT" | mail -s "Серверные ошибки с $RUN_DATE по $CURRENT_DATE" mistiko@mail.ru
# Количество и коды ответов HTTP 
OUTPUT="$(awk '{if ($4 > "'$RUN_DATE'") print $9}' apache_log | sort -nr | uniq -c | sort -nr)"
echo -e "$OUTPUT" | mail -s "Количество и коды ответов HTTP с $RUN_DATE по $CURRENT_DATE" mistiko@mail.ru
# echo 'Attachment' | mail -s 'Анализ логов' -a /tmp/file mail@mail.com
# echo $CURRENT_DATE > $TIME_FILE