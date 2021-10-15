#!/bin/sh

#set -x

USER=${1-user00}

IFS=$'\n'
LINES=($(top -bc -w 512 -n 1 -u ${USER}))

TOP=$(echo ${LINES[0]} | awk -F" " '{gsub(",","",$7); print "{\"time\":\""$3"\",\"up\":\""$5,$6,$7"\",\"users\":"$8",\"load\":["$12$13$14"]}"}')
TASKS=$(echo ${LINES[1]} | awk -F" " '{print "{\"total\":"$2",\"running\":"$4",\"sleeping\":"$6",\"stopped\":"$8",\"zombie\":"$10"}"}')
CPUs=$(echo ${LINES[2]} | awk -F" " '{print "{\"us\":"$2",\"sy\":"$4",\"ni\":"$6",\"id\":"$8",\"wa\":"$10",\"hi\":"$12",\"si\":"$14",\"st\":"$16"}"}')
Mem=$(echo ${LINES[3]} | awk -F" " '{print "{\"total\":"$4",\"free\":"$6",\"used\":"$8",\"buff/cache\":"$10"}"}')
Swap=$(echo ${LINES[4]} | awk -F" " '{print "{\"total\":"$3",\"free\":"$5",\"used\":"$7",\"avail\":"$9"}"}')

PROCESS=()
for ((i=6;i<${#LINES[*]};i++)); do
    PROCESS[${#PROCESS[*]}]=$(echo ${LINES[$i]} | awk -F" " '{ORS="";print "\""$1"\":{\"pid\":"$1",\"user\":\""$2"\",\"pr\":"$3",\"ni\":"$4",\"virt\":"$5",\"res\":\""$6"\",\"shr\":"$7",\"s\":\""$8"\",\"cpu\":"$9",\"mem\":"$10",\"time\":\""$11"\",\"command\":\""; for(i=1;i<12;i++) $i=""; sub(/^[ ]*/,""); print $0"\"},"}')
done

cat <<AAA | awk '{ORS=""; print}'
{
"top":${TOP},
"tasks":${TASKS},
"cpu":${CPUs},
"mem":${Mem},
"swap":${Swap},
${PROCESS[*]}
}
AAA

echo