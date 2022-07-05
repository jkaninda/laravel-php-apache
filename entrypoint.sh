#!/bin/sh
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green

echo ""
echo "***********************************************************"
echo " Starting LARAVEL PHP-APACHE Docker Container                 "
echo "***********************************************************"

set -e

## Create APACHE worker process
TASK=/etc/supervisor/conf.d/apache2.conf
touch $TASK
cat > "$TASK" <<EOF
[program:apache2]
command=apache2-foreground
numprocs=1
autostart=true
autorestart=true
stdout_logfile=/var/log/apache2.out.log
user=root
priority=100
EOF

## Check if the artisan file exists
if [ -f $WORKDIR/artisan ]; then
    echo "${Green} artisan file found, creating laravel supervisor config"
    ##Create Laravel Scheduler process
    TASK=/etc/supervisor/conf.d/laravel-worker.conf
    touch $TASK
    cat > "$TASK" <<EOF
    [program:Laravel-scheduler]
    process_name=%(program_name)s_%(process_num)02d
    command=/bin/sh -c "while [ true ]; do (php $WORKDIR/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
    autostart=true
    autorestart=true
    numprocs=1
    user=root
    stdout_logfile=/var/log/laravel_scheduler.out.log
    redirect_stderr=true
    
    [program:Laravel-worker]
    process_name=%(program_name)s_%(process_num)02d
    command=php $WORKDIR/artisan queue:work --sleep=3 --tries=3
    autostart=true
    autorestart=true
    numprocs=$LARAVEL_PROCS_NUMBER
    user=root
    redirect_stderr=true
    stdout_logfile=/var/log/laravel_worker.log
EOF
echo  "${Green} Laravel supervisor config created"
else
    echo  "${Red} artisan file not found"
fi
#check if storage directory exists
echo "Checking if storage directory exists"
    if [ -d "$STORAGE_DIR" ]; then
        echo "Directory $STORAGE_DIR  exist. Fixing permissions..."
        chown -R www-data:www-data $STORAGE_DIR
        chmod -R 775 $STORAGE_DIR
        echo  "${Green}Permissions fixed"

    else
        echo "${Red} Directory $STORAGE_DIR does not exist"
    fi

   ## Check if the supervisor config file exists
  if [ -f /var/www/html/conf/worker/supervisor.conf ]; then
    echo "Custom supervisor config found"
    cp /var/www/html/conf/worker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf
    else
    echo "${Red} Supervisor.conf not found"
    echo "${Green} If you want to add more supervisor configs, create config file in /var/www/html/conf/worker/supervisor.conf"
    echo "${Green} Start supervisor with default config..."
    fi
echo ""
echo "**********************************"
echo "     Starting Supervisord...     "
echo "***********************************"
supervisord -c /etc/supervisor/supervisord.conf

