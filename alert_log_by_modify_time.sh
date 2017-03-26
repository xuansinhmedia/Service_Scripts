#!bin/bash
# Description about this script: 
# 1. Check time modify of log file.
# 2. Compare between time modify and current time
# 3. If time modify not change after 3 minutes, system will send alert.
export ORACLE_HOME=/usr/lib/oracle/11.2/client64/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib64
PATH=$PATH:$HOME/bin:/sbin:$ORACLE_HOME/bin
export PATH=/usr/lib/oracle/11.2/client64/bin:$PATH

# Check time modify of log file.
file_log=/u01/vas_pay4me/sccpgw/nohup.out
time_log=`stat $file_log | grep Modify | awk '{print $2 "-" $3}' | awk -F "-" '{print $1 "/" $2 "/" $3 " " $4}' | cut -d'.' -f1`

# Convert time from log file to unix timestamp
log_second=`date -d "$time_log" +%s`

# extract time of sysdate to unix timestamp
time_sys=`date +%s`

diff=$((time_sys - log_second))

# Check subtract of system time and the last time of log file
# if it is greater than 5 minitues, run auto restart command.

if [ $diff -ge 180 ] 
then
sqlplus 'vas_pay4me/ADweredsd2ds@(DESCRIPTION=(LOAD_BALANCE=yes)(ADDRESS=(PROTOCOL=TCP)(HOST=10.229.42.173)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.229.42.174)(PORT=1521))(CONNECT_DATA=(FAILOVER_MODE=(TYPE=select)(METHOD=basic)(RETRIES=180)(DELAY=5))(SERVER=shared)(SERVICE_NAME=marketdbXDB)))' <<sql
INSERT INTO "MSG_ALERTER" (DOMAIN, THRESHOLD, ISSUE, ALERTMSG,INSDATE,ALERT_LEVEL, CONTACT, GROUPNAME) VALUES ('MVT_P4M01', 'Alert', 'Alert', 'No log gctload in $((diff/60)) minitues',sysdate, 'serious', 'vnteleco', 'admin');
quit
sql
fi

# Check log TCPEV_DLG_REQ_DISCARD to send alert
# 1. Grep log and count filter by: TCPEV_DLG_REQ_DISCARD
# 2. if > 5 in 20 rows --> send mail alert
discard_log=`tail -n 20 $file_log | grep "TCPEV_DLG_REQ_DISCARD" | wc -l`
if [ $discard_log -ge 5 ]
then
echo $discard_log "seen in gctload"
sqlplus 'vas_pay4me/ADweredsd2ds@(DESCRIPTION=(LOAD_BALANCE=yes)(ADDRESS=(PROTOCOL=TCP)(HOST=10.229.42.173)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.229.42.174)(PORT=1521))(CONNECT_DATA=(FAILOVER_MODE=(TYPE=select)(METHOD=basic)(RETRIES=180)(DELAY=5))(SERVER=shared)(SERVICE_NAME=marketdb)))' <<sql
INSERT INTO "MSG_ALERTER" (DOMAIN, THRESHOLD, ISSUE, ALERTMSG,INSDATE,ALERT_LEVEL, CONTACT, GROUPNAME) VALUES ('MVT_P4M01', 'Alert', 'Alert', 'Log TCPEV_DLG_REQ_DISCARD seen $discard_log',sysdate, 'serious', 'vnteleco', 'admin');
quit
sql
fi
