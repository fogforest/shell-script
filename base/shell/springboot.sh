#!/usr/bin/env bash
print_conf(){
printf "app_ame: %s\n" ${app_name}
printf "jar_path: %s\n" ${jar_path}
printf "profile: %s\n" ${profile}
printf "Xms: %s\n" ${Xms}
printf "Xmx: %s\n" ${Xmx}
printf "Xmn: %s\n" ${Xmn}
}
start_boot_app(){
if [[ ${Xms} == "" ]]
then
   Xms="2g"
fi
if [[ ${Xmx} == "" ]]
then
   Xms="2g"
fi
if [[ ${Xmn} == "" ]]
then
   Xms="1g"
fi
JAVA_OPTS="
-Dapp.name=${app_name}
-Xms${Xms}
-Xmx${Xmx}
-Xmn${Xmn}
-Xss256k
-verbose:gc
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/home/work/logs/jvm/${app_name}`date +%Y%m%d.%H%M%S`.dump
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-XX:+PrintGCDateStamps
-Xloggc:/home/work/logs/jvm/${app_name}-gc.log`date +%Y%m%d.%H%M%S`
"
APP_OPTS="${JAVA_OPTS} -Dspring.profiles.active=${profile}"
echo "====================================================="
echo "         start ${app_name}"
echo "====================================================="
echo ${APP_OPTS}
if [[ ! -d "/home/work/logs/start_log" ]]; then
  mkdir /home/work/logs/start_log
fi
nohup java ${APP_OPTS} -jar ${jar_path} > /home/work/logs/start_log/${app_name}_start.log &
}

stop_boot_app(){
#jar_name=`awk -v jar_path=${jar_path} 'BEGIN {split(jar_path,arr,"/"); print arr[length(arr)]}'`
#两种方式都可以
jar_name=`awk 'BEGIN {split("'${jar_path}'",arr,"/"); print arr[length(arr)]}'`
ID=`ps -aux | grep ${jar_name} |  grep -v grep | awk '{print $2}'`
if [[ ${ID} == "" ]]
then
echo "${app_name} has no process needs to stop. "
else
echo "${app_name}'s pid is ${ID}"
for id in $ID
do
kill -9 ${id}
echo "killed ${id}"
done
echo "====================================================="
echo "         stop ${app_name}"
echo "====================================================="
fi
}

restart_boot_app(){
    stop_boot_app
    start_boot_app
}

if [[ $1 == "" ]]
then
echo "cmd is Required! Example: \"./springboot.sh start xxx_conf.sh \""
exit -1
fi
cmd=$1
if [[ $2 == "" ]]
then
echo "conf is Required! Example: \"./springboot.sh start xxx_conf.sh\""
exit -1
fi
source $2  #应用配置文件
if [[ ${app_name} == "" || ${jar_path} == "" || ${profile} == "" ]]
then
    echo "\"app_name\",\"jar_path\",\"profile\" are Required! "
    exit -1
fi

print_conf

case ${cmd} in
    "start")
        start_boot_app
    ;;
    "stop")
        stop_boot_app
    ;;
    "restart")
        restart_boot_app
    ;;
    *)
    echo "Unsupported cmd ! Supported: start,stop,restart."
esac
