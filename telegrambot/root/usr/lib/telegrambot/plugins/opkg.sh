#!/bin/sh

ACTION=$1
PKG="$2 $3 $4 $5 $6"

update_(){
	opkg update > /dev/null 2>&1
	MSG="List updated."
}

list_(){
	PKGS="$(opkg list-upgradable)"
	MSG="\`\`\`\n$PKGS\`\`\`"
	if [ "$PKGS" ]; then
		MSG="Packages to upgrade are:\n${MSG}"
	else
		MSG="Noting to upgrade"
	fi
}

listpkg_(){
	PKGS="$(opkg ${ACTION} ${PKG})"
	if [ "$PKGS" ]; then
		MSG="\`\`\`\n$PKGS\`\`\`"
	else
		MSG="Package $2 not found."
	fi
}

upgrade_(){
	PKGS="$(opkg list-upgradable | awk '{print $1}')"
	opkg upgrade $(echo ${PKGS}) > /dev/null 2>&1
	MSG="Upgraded package(s):\n\`\`\`\n${PKGS}\`\`\`"
}

install_(){
	opkg ${ACTION} ${PKG} > /dev/null 2>&1
	MSG="Package(s): $PKG installed."
}

remove_(){
	opkg ${ACTION} ${PKG} > /dev/null 2>&1
	MSG="Package(s): $PKG removed."
}

installed_(){
	PKGS="$(opkg list-installed | awk '{print $1}')"
	#PKGS="Test TEst2 TEst3"
	MSG="Installed package(s):\n\`\`\`\n$(echo ${PKGS})\`\`\`"
}

help_(){
	MSG="Usage: */opkg command [argument]*\n\
	Aviable opkg commands:\n\
	\t\tupdate - update packages list\n\
	\t\tlist pkgmane - show package\n\
	\t\tinstall pkgname - install packages (max 5 package names)\n\
	\t\tremove pkgname - remove packages (max 5 package names)\n\
	\t\tlist-installed [pkgname] - list installed packages [package]\n\
	\t\tlist-upgrade - list upgradabe packages\n\
	\t\trun-upgrade - run upgrade upgradable packages\n\
	\t\thelp - this help."
}

case ${ACTION} in
	update)
		update_
		echo -en "$MSG"
	;;
	list)
		listpkg_
		echo -en "$MSG"
	;;
	list-upgrade)
		list_
		echo -en "$MSG"
	;;
	run-upgrade)
		upgrade_
		echo -en "$MSG"
	;;
	install)
		install_
		echo -en "$MSG"
	;;
	remove)
		remove_
		echo -en "$MSG"
	;;
	list-installed)
		installed_
		echo -en "$MSG"
	;;
	*)
		help_
		echo -en "$MSG"
	;;
esac
