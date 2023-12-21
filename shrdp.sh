#!/bin/bash

###### shrdp list
###### shrdp [hostname]
###### cfgfile like
#Host lab3-4
#    #192.168.1.1   admin   admin
#    Hostname 192.168.1.1
#    Port 3389
#    User admin
#    Pass admin
#    lpath /home/Downloads

cfgfile=rdpcfg
cmd="rdesktop"

Host="*"
Hostname=""
Port=""
User=""
Pass=""
Lpath=""

hostt="*"

parseLine () {
    line=$*
    if [[ "${line:0:1}" == "#" ]]; then
        return
    fi
    key=$(echo "$line" | grep -Eoi "^\S+\s+")
    if [[ "$key" == "" ]]; then
        return
    fi
    val=${line#$key}
    key=${key^^}
    key=$(echo ${key} | awk '{print$1}') 
    #echo "<$key> <$val>"

    case $key in
        HOST )
            #echo "Host:$Host Got:$val"
            hostt=$val
            ;;
        HOSTNAME )
            if [[ "$hostt" == "$Host" ]]; then
                Hostname=$val
                echo "Got Hostname $Hostname"
            fi
            ;;
        PORT )
            if [[ "$hostt" == "$Host" ]]; then
                Port=$val
            fi
            ;;
        USER )
            if [[ "$hostt" == "$Host" ]]; then
                User=$val
            fi
            ;;
        PASS )
            if [[ "$hostt" == "$Host" ]]; then
                Pass=$val
            fi
            ;;
        LPATH )
            if [[ "$hostt" == "$Host" ]]; then
                Lpath=$val
            fi
            ;;
        * )
            echo "Bad key: $key"
            ;;
    esac

}

getHostParam () {
    fname=$1
    if [[ ! -f $fname ]]; then
        return
    fi

    while read line
    do
        parseLine $line
    done < $fname
}

startRdp () {
#rdesktop -g workarea -D -r clipboard:PRIMARYCLIPBOARD -r disk:h=$lpath -u $user -p $pass  $ip
    params=" -g workarea -D -r clipboard:PRIMARYCLIPBOARD"
    getHostParam $cfgfile
    echo "Hostname: $Hostname"

    if [[ "$Hostname" == "" ]]; then
        echo "remote host:"
        read Hostname
    fi
    if [[ "$Port" != "" ]]; then
        Hostname="$Hostname:$Port"
    fi
    if [[ "$Lpath" != "" ]]; then
        params="$params -r disk:r=$Lpath"
    fi
    if [[ "$User" != "" ]]; then
        params="$params -u $User"
    fi
    if [[ "$Pass" != "" ]]; then
        params="$params -p $Pass"
    fi
    command $cmd $params $Hostname
}

if [[ "$1" == "list" ]]; then
    cat "$cfgfile" | grep -iE "^ *host"
    exit 0
fi

if [[ "$1" != "" ]]; then
    Host=$1 
fi

startRdp
