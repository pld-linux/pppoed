#!/bin/sh
#
# Many thanks to David Hinds and others (PCMCIA code) for the script
# skeleton
# Ralph Siemsen <ralphs@netwinder.org> for the module.conf portion
# PPP+DNS parsing/prompting configppp Mike Harris <mharris@beer.com>
#
#
PPPOED_DIR=`pwd`
PPPOE_MOD_DIR=$PPPOED_DIR/kernel-patches/module 
FWC=$PPPOED_DIR/contribs/mssclampfw-1.2 
PPPOED=$PPPOED_DIR/pppoed

fail ()
{
    echo ""
    echo "Configuration failed."
    echo ""
    exit 1
}


bye()
{
	echo " "
	echo "=================================="
	echo "pppoed installation complete "
	echo "=================================="
	echo " "
}
#=======================================================================


arg () {
    VALUE="`echo X"$2" | sed -e 's/^X--[a-zA-Z_]*=//'`"
    eval $1=\"$VALUE\"
}


#=======================================================================

KERNEL_DIR=/usr/src/linux
MODVER=include/linux/modversions.h
RC_INIT_DIR=/etc/rc.d/init.d
CC=gcc


prompt () {
    eval $3=\"$2\"
    if [ "$PROMPT" = "y" ] ; then
	/bin/echo -e "$1 [$2]: \c"
	read tmp
	if [ ! -t 1 ] ; then echo $tmp ; fi
	if [ -n "$tmp" ] ; then eval $3=\"$tmp\" ; fi
    else
	/bin/echo "$1 [$2]"
    fi
}

ask_bool () {
    default=`eval echo '$'$2`
    if [ ! "$default" ] ; then default=n ; fi
    answer=""
    while [ "$answer" != "n" -a "$answer" != "y" ] ; do
	prompt "$1 (y/n)" "$default" answer
    done
    eval "$2=$answer"
}

ask_str () {
    default=`eval echo '$'$2`
    prompt "$1" "`echo $default`" answer
    eval $2=\"$answer\"
}

#=======================================================================

###############################################
PROMPT=y
ask_str "Do you want me to setup PPP for you?(answer y/n only)" PROMPT

if [ $PROMPT = "n" ] ; then
	bye
fi
config_restart="y"
while [ "$config_restart" == "y" ] ; do
{
echo ""
ask_str " Please enter your Username for your ISP" userName
#no point hiding, because we need to verify this
ask_str "Please enter your Password for your ISP" passWord

echo""
echo "Please enter your domain name"
echo "This is often trailing the @ in your email address"
echo "If your email was John@Doe.com, then most often, your"
echo "domain name would be: Doe.com"
ask_str "domain name :" domainName
echo " "
echo " "
echo "collected information"
echo ""
echo "User Name : $userName"
echo "passWord: $passWord"
echo "domainName: $domainName"
echo " "
ask_str "is this correct?(answer y/n only)" PROMPT

if [ $PROMPT = "n" ] ; then
	PROMPT=y
	ask_str "would you like to restart?(answer y/n only)" PROMPT
	echo ""
	if [ $PROMPT = "n" ] ; then
		bye
	fi
else
	break
fi

}
done

echo "setting ppp-options ...."
if [ ! -d /etc/ppp ]; then
	mkdir /etc/ppp
fi

if [ -f /etc/ppp/options ] ; then
	cp /etc/ppp/options /etc/ppp/options.`date +%m%d%Y`
fi

echo "lock
local
nocrtscts
noauth
#be careful with mtu/mru if you are masquerading.
# look at Kal Lin's page at http://www.cs.toronto.edu/~kal/hse/resource.html
mru 1490
mtu 1490
#please make sure you have noaccomp for now
noaccomp
#the construct below is needed by sympatico
name \"$userName@$domainName\"
#you might want to change defaultroute if you have more
#than one pppoe session
defaultroute
hide-password
sync
#it might be a good idea to uncoment the debug below
#debug
#kdebug 7
#if you use the -R option to make it persistent
#then uncomment the next two lines below
#lcp-echo-interval 240
#lcp-echo-failure 3
#nodetach
" > /etc/ppp/options

if [ -f /etc/ppp/pap-secrets ] ; then
	cp /etc/ppp/pap-secrets /etc/ppp/pap-secrets.`date +%m%d%Y`
	rm /etc/ppp/pap-secrets
fi

touch /etc/ppp/pap-secrets
echo "# Secrets for authentication using PAP 
# client        server  secret                  IP addresses
$userName@$domainName * $passWord" > /etc/ppp/pap-secrets
echo "Setting /etc/ppp/pap-secrets* perms to 600"
chmod 600 /etc/ppp/pap-secrets.`date +%m%d%Y`
chmod 600 /etc/ppp/pap-secrets  
echo " "
###############################################
PROMPT=n
ask_str "Do you want me to setup DNS for you?(answer y/n only)" PROMPT

if [ $PROMPT = "n" ] ; then
	bye
fi
echo " "
config_restart="y"
nameServer2=""
while [ "$config_restart" == "y" ] ; do
{
echo "Please enter your Primary DNS server"
echo "It should be in the form ###.###.###.###"
echo "Where the \"#\" is either a number or blank space"
ask_str " Primary DNS server: "  nameServer1
echo " "
echo "If you have a Secondary DNS server please enter it"
echo "If none, just press enter"
ask_str " Secondary DNS server: "  nameServer2
echo " "

echo " "
echo " "
echo "collected information"
echo ""
echo "nameServer1 Name : $nameServer1"
if [ $nameServer2 ] ; then
echo "second nameserver:  $nameServer2"
fi
echo " "
ask_str "is this correct?(answer y/n only)" PROMPT
if [ $PROMPT = "n" ] ; then
	PROMPT=y
	ask_str "would you like to restart?(answer y/n only)" PROMPT
	echo ""
	if [ $PROMPT = "n" ] ; then
		bye
	fi
else
	break
fi

}
done

echo "setting DNS .... domainName: $domainName"

if [ -f /etc/resolv.conf ] ; then
	cp /etc/resolv.conf /etc/resolv.conf.`date +%m%d%Y`
	rm /etc/resolv.conf
fi
touch /etc/resolv.conf
echo "search $domainName" > /etc/resolv.conf
echo "nameserver $nameServer1" >> /etc/resolv.conf

if [ $nameServer2 ] ; then
	echo "nameserver $nameServer2" >> /etc/resolv.conf
fi
echo "Setting /etc/resolv.conf perms to 644"
chmod 644 /etc/resolv.conf

depmod -a
mknod /dev/pppox0 c 144 0
bye
