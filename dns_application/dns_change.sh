#!/bin/bash

### Global Definition ###
serverActivedFile="/opt/dns_application/active"
fileToSaveAddress="/etc/resolvconf/resolv.conf.d/head"
localization="/opt/dns_application/server"

#### Function area ###
exitApp(){
	exit
}

# Print new empty line
newLineEmpty(){
	numLine=$1
	count="1"
	while [ $count -le $numLine ]; do
		echo
		count=$((count+1))
	done
}

# Active server with resolvconf
updateResolvConf(){
	setUpdatesResolvConf="sudo resolvconf --enable-updates"
	runNewChange="sudo resolvconf -u"

	# Set changes
	$setUpdatesResolvConf
	# Start new changes
	$runNewChange
}

# Get Server address
getServerAddress(){
	# Get file of server
	serverSelected=$1

	# Get Address
	if [ ! -f $localization/$serverSelected ]; then
		echo "Server file not found"
	else
		index="0"
		while IFS='' read -r line || [ -n "$line" ]; do
			# Save address
	    	allServer[$index]="$line"

	    	# Increment index, index++
	  		index=$((index+1))

		done < $localization/$serverSelected
	fi
}

# Activate DNS Server
activeServer(){
	serverToActivate=$1
	getServerAddress $serverToActivate

	if [ -f $fileToSaveAddress ]; then
		# Read array of address
		for address in ${allServer[@]}
		do
			# Write address on resolvconf
			sudo sh -c "echo nameserver $address >> $fileToSaveAddress"
		done

		if [ -f $serverActivedFile ]; then
			# Escrevo no ficheiro o DNS activo
			sudo sh -c "echo $serverToActivate >> $serverActivedFile"
		else
			# Crio e Escrevo no ficheiro o DNS activo
			sudo sh -c "echo $serverToActivate > $serverActivedFile"
		fi

		# Update resolvconf
		updateResolvConf
	else
		echo "resolv.conf file not find"
	fi
}

# Disable DNS Server
disableServer(){
	if [ -f $fileToSaveAddress ]; then
		# Read array of address
		for address in ${allServer[@]}
		do
			# Remove address on resolvconf
			sudo sed -i "/$address/d" $fileToSaveAddress
		done

		# Update resolvconf
		updateResolvConf "0"
	else
		echo "resolv.conf file not find"
	fi
}

# Set Default Settings Networks
reset(){
	if [ -f $serverActivedFile ]; then
		restartNetwork="sudo service network-manager restart"

		# get active server
		read activeServer < $serverActivedFile

		if [ $activeServer ]; then
			# get all address of the active server
			getServerAddress $activeServer

			# disable server
			disableServer

			# name of active server
			sudo sed -i "/$activeServer/d" $serverActivedFile

			# Restart Network
			$restartNetwork
		fi
	fi
}

# Get List of Server and print them
getListServer(){
	commandLsFilderServer=$(ls $localization)
	index="0"

	newLineEmpty "2"
	echo "List of DNS Server available:"

	for serverFile in $commandLsFilderServer; do
		listOfServer[$index]=$serverFile
		echo "$index - $serverFile"

		index=$((index+1))
	done

	# Insert Reset
	listOfServer[$index]="Reset"
	echo "$index - ${listOfServer[$index]}"

	# Insert Exit
	index=$((index+1))
	listOfServer[$index]="Exit"
	echo "$index - ${listOfServer[$index]}"

	# Insert Unistall
	newLineEmpty "1"
	echo "##########"
	index=$((index+1))
	listOfServer[$index]="Uninstall"
	echo "$index - ${listOfServer[$index]}"
	echo "##########"

	newLineEmpty "1"
	while [ 1 ]; do
		read -p "Select an option: " key

		if [ ${listOfServer[$key]} ]; then
			break
		else
			newLineEmpty "2"
			echo "Option selected is incorect"
		fi
	done
}

# Action Action to do by user option
verifyActiveOrNot(){
	serverSelectByUser=$1

	if [ -f $serverActivedFile ]; then
		read activeServer < $serverActivedFile

		# If user select server diferent of actived server
		if [[ $activeServer != $serverSelectByUser ]]; then
			reset
			activeServer $serverSelectByUser
		else
			activeServer $serverSelectByUser
		fi
	else
		activeServer $serverSelectByUser
	fi
}

# Uninstall
uninstall(){
	# lobal Definition
	HOME_FOLDER=$( echo $HOME )
	optFolder="/opt"
	appFolder="dns_application"
	localizationShortcut=".local/share/applications"
	shortcutFile="dnsChange.desktop"

	reset
	sudo rm -r $optFolder/$appFolder
	sudo rm $HOME_FOLDER/$localizationShortcut/$shortcutFile

	newLineEmpty "1"
	echo "######"
	echo "Press any key to exit"
	read -rsn1
	exitApp
}

### Main ###
if [ $1 ]; then
	# Chamda do metodo introduzido como parâmetro
	$1
else
	showMessage="0"
	while [ 1 ]; do
		clear

		if [ $showMessage -gt "0" ]; then
			if [ ${listOfServer[$key]} == "Reset" ]; then
				echo "### Default Settings is set... ###"
			else
				echo "### ${listOfServer[$key]} DNS Server is set... ###"
			fi
		fi

		# Vou buscar a lista de servidores disponíveis
		getListServer

		if [ ${listOfServer[$key]} == "Exit" ]; then
			exitApp
		elif [ ${listOfServer[$key]} == "Reset" ]; then
			reset
		elif [ ${listOfServer[$key]} == "Uninstall" ]; then
			uninstall
		else
			verifyActiveOrNot ${listOfServer[$key]}
		fi
		showMessage=$((showMessage+1))

	done
fi