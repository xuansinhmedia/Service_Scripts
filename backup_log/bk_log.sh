# Config homedir where to place this file
homedir=//home/topup/backuplog/
conf="dirlist.conf";
logfile="backup.log";

dt=`date +"%Y-%m-%d" -d yesterday`
olddate=`date +"%Y-%m-%d" --date="-90 day"`

cd $homedir;
if [ -f "$conf" ]
then
    echo "------------------------------------------------" >> $logfile;
    echo "BACKUP LOG START @ `date`" >> $logfile;
    
    for logdir in `cat $conf`    
    do
        if [ -d "$logdir" ]
        then
            # log
            echo "Process $logdir" >> $logfile
        
            # start
            cd $logdir;
            mkdir -p backup;
            
            # conpress yesterday log
            tar -zcvf $dt.tar.gz *$dt*
            mv *.tar.gz backup/
            rm -rf *$dt*
            
            # Remove old log
            cd backup
            rm -rf *$olddate*
            
            # change back to homedir
            cd $homedir;
        else
            echo "$logdir does not exist." >> $logfile
        fi
    done
    
    echo "BACKUP LOG Finish @ `date`" >> $logfile;
    echo "------------------------------------------------" >> $logfile;
else
        echo "File '$conf' doest not exist, please config.";
        exit;
fi

