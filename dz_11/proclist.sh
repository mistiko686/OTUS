#!/bin/bash
#for file in `/proc/[0-9]* | sort -n`
echo     "PID"      "Status"    "TTY"   "proc time"    "Command"
for file in `ls -l /proc | awk '{print $9}' | grep -Eo '[0-9]*' | sort -n`
do
if [ -d "/proc/$file" ]
then
pid_v=$file
state_v=`grep "State" /proc/$file/status`
term=`ls -l /proc/$file/fd | head -n2 | tail -n1 | awk '{print$11}'`
if [[ "$term" == *"null"* ]] || [[ $term == *"socket"* ]] || [[ $term == *"pipe"* ]]
   then
              #echo "TTY: ?"
              tty_v="?"
       
    else 
        #echo "TTY: ${term:5}"
        tty_v=${term:5}
fi
utime_v=`cat /proc/$file/stat | awk '{print $14}'`
stime_v=`cat /proc/$file/stat | awk '{print $15}'`
clk_v=100
fulltime_v=$((utime_v+stime_v))
fulltime_v=$((fulltime_v/clk_v))
cpu_v=`date -u -d @$fulltime_v +"%T"`
if [[ -z "/proc/$file/cmdline" ]]
   then
       cmd_v=`cat /proc/$file/cmdline`
   else
        cat /proc/$file/cmdline
        echo -e "\n"
        cmd_v=`grep "Name:" /proc/$file/status`
        cmd_v=${cmd_v:5}
fi
echo     $pid_v      $state_v    $tty_v   $fulltime_v "sec"    $cmd_v
fi
done