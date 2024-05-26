#!/bin/sh
LOG_FILE=/var/log/homebridge.log

function check_node_environment(){
echo "Begin Checking Node environment-----------------------">>$LOG_FILE
if node -v > /dev/null 2>&1
then                                                
	echo "node already installed" >> $LOG_FILE	
else                                        
	echo "try install node" >> $LOG_FILE
	if opkg install node >> $LOG_FILE 2>&1
	then
		echo "node environment install success" >> $LOG_FILE
	else
		echo "node install failed" >> $LOG_FILE                                                                                                                               
		return 1
	fi
fi

if npm --version > /dev/null 2>&1
then
	echo "node-npm environment install success" >> $LOG_FILE
else
	echo "try install node-npm" >> $LOG_FILE
	if opkg install node-npm >> $LOG_FILE 2>&1
	then
		echo "node-npm environment install success"
	else
		echo "node-npm install failed" >> $LOG_FILE
		return 1
	fi
fi

if node-gyp --version > /dev/null 2>&1
then             
echo "node-gyp already installed" >> $LOG_FILE               
return 0                                                     
else               
	echo "try install node-gyp" >> $LOG_FILE                                                  
	if npm install -g node-gyp >> $LOG_FILE 2>&1                                   
    then                                                          
        echo "install node-gyp success" >> $LOG_FILE         
        return 0                                             
    else                                                         
        echo "install node-gyp failed" >> $LOG_FILE          
        return 1                                             
    fi                                                      
fi
}

function check_miio(){
echo "Begin Checking Miio-----------------------">>$LOG_FILE
if [ -d "/usr/lib/node_modules/miio" ]; then
	echo "miio already installed" >> $LOG_FILE
	return 0
else
	echo "try install miio" >> $LOG_FILE
	if npm install -g miio@0.14.1 2 >> $LOG_FILE 2>&1
	then
		echo "miio install complete" >> $LOG_FILE
		return 0
	else
		echo "miio install failed" >> $LOG_FILE
		return 1
	fi
fi
return 1
} 

function check_homebridge(){
echo "Homebridge check ----------------------------">>$LOG_FILE
if [ -d "/usr/lib/node_modules/homebridge" ]; then
	echo "homebridge already installed" >> $LOG_FILE
	return 0
else
	echo "try install homebridge" >> $LOG_FILE
	if npm install -g homebridge >> $LOG_FILE 2>&1
	then
		echo "homebridge install success">>$LOG_FILE
		return 0
	else
		echo "homebridge install failed">>$LOG_FILE
		return 1
	fi
fi
return 1
}

function update_opkg(){
echo "OPKG update -------------------------" >> $LOG_FILE
if opkg update >> $LOG_FILE 2>&1
then
	echo "OPKG update success" >> $LOG_FILE
else
	echo "OPKG update failed" >> $LOG_FILE
fi
echo "OPKG update finished ----------------" >> $LOG_FILE
}

function main(){
echo "Begin Checking Environment--------------" > $LOG_FILE
update_opkg
if check_node_environment
then
	if check_miio
	then
		if check_homebridge
		then
			echo "End Checking Environment ---------------------------">>$LOG_FILE
		fi
	fi
fi
}

main
