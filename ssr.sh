#!/bin/bash
# shadowsocksR/SSR CentOS 7/8一键安装教程
# Author: hijk<https://hijk.art>


RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

V6_PROXY=""
IP=`curl -sL -4 ip.sb`
if [[ "$?" != "0" ]]; then
    IP=`curl -sL -6 ip.sb`
    V6_PROXY="https://gh.hijk.art/"
fi

FILENAME="ShadowsocksR-v3.2.2"
URL="${V6_PROXY}https://github.com/shadowsocksrr/shadowsocksr/archive/3.2.2.tar.gz"
BASE=`pwd`

OS=`hostnamectl | grep -i system | cut -d: -f2`

CONFIG_FILE="/etc/shadowsocksR.json"
SERVICE_FILE="/etc/systemd/system/shadowsocksR.service"
NAME="shadowsocksR"

colorEcho() {
    echo -e "${1}${@:2}${PLAIN}"
}


checkSystem() {
    result=$(id | awk '{print $1}')
    if [[ $result != "uid=0(root)" ]]; then
        colorEcho $RED " Please execute the script as root"
        exit 1
    fi

    res=`which yum 2>/dev/null`
    if [[ "$?" != "0" ]]; then
        res=`which apt 2>/dev/null`
        if [[ "$?" != "0" ]]; then
            colorEcho $RED " Unsupported Linux system"
            exit 1
        fi
        PMT="apt"
        CMD_INSTALL="apt install -y "
        CMD_REMOVE="apt remove -y "
        CMD_UPGRADE="apt update && apt upgrade -y; apt autoremove -y"
    else
        PMT="yum"
        CMD_INSTALL="yum install -y "
        CMD_REMOVE="yum remove -y "
        CMD_UPGRADE="yum update -y"
    fi
    res=`which systemctl 2>/dev/null`
    if [[ "$?" != "0" ]]; then
        colorEcho $RED " The system version is too low, please upgrade to the latest version"
        exit 1
    fi
}

getData() {
    echo ""
    read -p " Please set the SSR password (if you don’t enter it, it will be randomly generated) :" PASSWORD
    [[ -z "$PASSWORD" ]] && PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
    echo ""
    colorEcho $BLUE " Password： $PASSWORD"

    echo ""
    while true
    do
        read -p " Please set the port number of SSR [1-65535]: " PORT
        [[ -z "$PORT" ]] && PORT=`shuf -i1025-65000 -n1`
        if [[ "${PORT:0:1}" = "0" ]]; then
            echo -e " ${RED}Port cannot start with 0${PLAIN}"
            exit 1
        fi
        expr $PORT + 0 &>/dev/null
        if [[ $? -eq 0 ]]; then
            if [ $PORT -ge 1 ] && [ $PORT -le 65535 ]; then
                echo ""
                colorEcho $BLUE " The port number: $PORT"
                break
            else
                colorEcho $RED " Input error, port number is 1-65535"
            fi
        else
            colorEcho $RED " Input error, port number is 1-65535"
        fi
    done

    echo ""
    colorEcho $BLUE " Please select the encryption method of SSR:" 
    echo "  1)aes-256-cfb"
    echo "  2)aes-192-cfb"
    echo "  3)aes-128-cfb"
    echo "  4)aes-256-ctr"
    echo "  5)aes-192-ctr"
    echo "  6)aes-128-ctr"
    echo "  7)aes-256-cfb8"
    echo "  8)aes-192-cfb8"
    echo "  9)aes-128-cfb8"
    echo "  10)camellia-128-cfb"
    echo "  11)camellia-192-cfb"
    echo "  12)camellia-256-cfb"
    echo "  13)chacha20-ietf"
    read -p " Please select the encryption method (default aes-256-cfb) " answer
    if [[ -z "$answer" ]]; then
        METHOD="aes-256-cfb"
    else
        case $answer in
        1)
            METHOD="aes-256-cfb"
            ;;
        2)
            METHOD="aes-192-cfb"
            ;;
        3)
            METHOD="aes-128-cfb"
            ;;
        4)
            METHOD="aes-256-ctr"
            ;;
        5)
            METHOD="aes-192-ctr"
            ;;
        6)
            METHOD="aes-128-ctr"
            ;;
        7)
            METHOD="aes-256-cfb8"
            ;;
        8)
            METHOD="aes-192-cfb8"
            ;;
        9)
            METHOD="aes-128-cfb8"
            ;;
        10)
            METHOD="camellia-128-cfb"
            ;;
        11)
            METHOD="camellia-192-cfb"
            ;;
        12)
            METHOD="camellia-256-cfb"
            ;;
        13)
            METHOD="chacha20-ietf"
            ;;
        *)
            colorEcho $RED " 无效的选择，使用默认加密方式"
            METHOD="aes-256-cfb"
        esac
    fi
    echo ""
    colorEcho $BLUE " Encryption: $METHOD"

    echo ""
    colorEcho $BLUE " Please select SSR protocol: "
    echo "   1)origin"
    echo "   2)verify_deflate"
    echo "   3)auth_sha1_v4"
    echo "   4)auth_aes128_md5"
    echo "   5)auth_aes128_sha1"
    echo "   6)auth_chain_a"
    echo "   7)auth_chain_b"
    echo "   8)auth_chain_c"
    echo "   9)auth_chain_d"
    echo "   10)auth_chain_e"
    echo "   11)auth_chain_f"
    read -p " Please select SSR protocol (default origin) " answer
    if [[ -z "$answer" ]]; then
        PROTOCOL="origin"
    else
        case $answer in
        1)
            PROTOCOL="origin"
            ;;
        2)
            PROTOCOL="verify_deflate"
            ;;
        3)
            PROTOCOL="auth_sha1_v4"
            ;;
        4)
            PROTOCOL="auth_aes128_md5"
            ;;
        5)
            PROTOCOL="auth_aes128_sha1"
            ;;
        6)
            PROTOCOL="auth_chain_a"
            ;;
        7)
            PROTOCOL="auth_chain_b"
            ;;
        8)
            PROTOCOL="auth_chain_c"
            ;;
        9)
            PROTOCOL="auth_chain_d"
            ;;
        10)
            PROTOCOL="auth_chain_e"
            ;;
        11)
            PROTOCOL="auth_chain_f"
            ;;
        *)
            colorEcho $RED " 无效的选择，使用默认协议"
            PROTOCOL="origin"
        esac
    fi
    echo ""
    colorEcho $BLUE " SSR protocol： $PROTOCOL"

    echo ""
    colorEcho $BLUE " Please select SSR obfuscation mode: "
    echo "   1)plain"
    echo "   2)http_simple"
    echo "   3)http_post"
    echo "   4)tls1.2_ticket_auth"
    echo "   5)tls1.2_ticket_fastauth"
    read -p " Please select obfuscation mode (default plain)" answer
    if [[ -z "$answer" ]]; then
        OBFS="plain"
    else
        case $answer in
        1)
            OBFS="plain"
            ;;
        2)
            OBFS="http_simple"
            ;;
        3)
            OBFS="http_post"
            ;;
        4)
            OBFS="tls1.2_ticket_auth"
            ;;
        5)
            OBFS="tls1.2_ticket_fastauth"
            ;;
        *)
            colorEcho $RED " 无效的选择，使用默认混淆模式"
            OBFS="plain"
        esac
    fi
    echo ""
    colorEcho $BLUE " Confusion mode: $OBFS"
}

status() {
    res=`which python 2>/dev/null`
    if [[ "$?" != "0" ]]; then
        echo 0
        return
    fi
    if [[ ! -f $CONFIG_FILE ]]; then
        echo 1
        return
    fi
    port=`grep server_port $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    res=`netstat -nltp | grep ${port} | grep python`
    if [[ -z "$res" ]]; then
        echo 2
    else
        echo 3
    fi
}

statusText() {
    res=`status`
    case $res in
        2)
            echo -e ${GREEN}It has been installed${PLAIN} ${RED}Not running${PLAIN}
            ;;
        3)
            echo -e ${GREEN}It has been installed${PLAIN} ${GREEN}Running${PLAIN}
            ;;
        *)
            echo -e ${RED}Not Installed${PLAIN}
            ;;
    esac
}

preinstall() {
    $PMT clean all
    [[ "$PMT" = "apt" ]] && $PMT update
    #echo $CMD_UPGRADE | bash
    echo ""
    colorEcho $BLUE " 安装必要软件"
    if [[ "$PMT" = "yum" ]]; then
        $CMD_INSTALL epel-release
    fi
    $CMD_INSTALL curl wget vim net-tools libsodium* openssl unzip tar qrencode
    res=`which wget 2>/dev/null`
    [[ "$?" != "0" ]] && $CMD_INSTALL wget
    res=`which netstat 2>/dev/null`
    [[ "$?" != "0" ]] && $CMD_INSTALL net-tools
    res=`which python 2>/dev/null`
    if [[ "$?" != "0" ]]; then
        ln -s /usr/bin/python3 /usr/bin/python
    fi

    if [[ -s /etc/selinux/config ]] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
        setenforce 0
    fi
}

installSSR() {
    if [[ ! -d /usr/local/shadowsocks ]]; then
        colorEcho $BLUE " Download the installation file"
        if ! wget --no-check-certificate -O ${FILENAME}.tar.gz ${URL}; then
            echo -e " [${RED}Error${PLAIN}] Failed to download file!"
            exit 1
        fi

        tar -zxf ${FILENAME}.tar.gz
        mv shadowsocksr-3.2.2/shadowsocks /usr/local
        if [[ ! -f /usr/local/shadowsocks/server.py ]]; then
            colorEcho $RED " $OS Installation failed, please go to https://hijk.art website to feedback"
            cd ${BASE} && rm -rf shadowsocksr-3.2.2 ${FILENAME}.tar.gz
            exit 1
        fi
        cd ${BASE} && rm -rf shadowsocksr-3.2.2 ${FILENAME}.tar.gz
    fi

cat > $SERVICE_FILE <<-EOF
[Unit]
Description=shadowsocksR
Documentation=https://hijk.art/
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
LimitNOFILE=32768
ExecStart=/usr/local/shadowsocks/server.py -c $CONFIG_FILE -d start
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable shadowsocksR
}

configSSR() {
    cat > $CONFIG_FILE<<-EOF
{
    "server":"0.0.0.0",
    "server_ipv6":"::",
    "server_port":${PORT},
    "local_port":1080,
    "password":"${PASSWORD}",
    "timeout":600,
    "method":"${METHOD}",
    "protocol":"${PROTOCOL}",
    "protocol_param":"",
    "obfs":"${OBFS}",
    "obfs_param":"",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":false,
    "workers":1
}
EOF
}

setFirewall() {
    res=`which firewall-cmd 2>/dev/null`
    if [[ $? -eq 0 ]]; then
        systemctl status firewalld > /dev/null 2>&1
        if [[ $? -eq 0 ]];then
            firewall-cmd --permanent --add-port=${PORT}/tcp
            firewall-cmd --permanent --add-port=${PORT}/udp
            firewall-cmd --reload
        else
            nl=`iptables -nL | nl | grep FORWARD | awk '{print $1}'`
            if [[ "$nl" != "3" ]]; then
                iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
                iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT
            fi
        fi
    else
        res=`which iptables 2>/dev/null`
        if [[ $? -eq 0 ]]; then
            nl=`iptables -nL | nl | grep FORWARD | awk '{print $1}'`
            if [[ "$nl" != "3" ]]; then
                iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
                iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT
            fi
        else
            res=`which ufw 2>/dev/null`
            if [[ $? -eq 0 ]]; then
                res=`ufw status | grep -i inactive`
                if [[ "$res" = "" ]]; then
                    ufw allow ${PORT}/tcp
                    ufw allow ${PORT}/udp
                fi
            fi
        fi
    fi
}

installBBR() {
    result=$(lsmod | grep bbr)
    if [[ "$result" != "" ]]; then
        colorEcho $GREEN " BBR module is installed"
        INSTALL_BBR=false
        return
    fi
    res=`hostnamectl | grep -i openvz`
    if [ "$res" != "" ]; then
        colorEcho $YELLOW " openvz machine, skip installation"
        INSTALL_BBR=false
        return
    fi
    
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    result=$(lsmod | grep bbr)
    if [[ "$result" != "" ]]; then
        colorEcho $GREEN " BBR module is enabled"
        INSTALL_BBR=false
        return
    fi

    colorEcho $BLUE " Install the BBR module..."
    if [[ "$PMT" = "yum" ]]; then
        if [[ "$V6_PROXY" = "" ]]; then
            rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
            rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
            $CMD_INSTALL --enablerepo=elrepo-kernel kernel-ml
            $CMD_REMOVE kernel-3.*
            grub2-set-default 0
            echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
            INSTALL_BBR=true
        fi
    else
        $CMD_INSTALL --install-recommends linux-generic-hwe-16.04
        grub-set-default 0
        echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
        INSTALL_BBR=true
    fi
}

showInfo() {
    port=`grep server_port $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    res=`netstat -nltp | grep ${port} | grep python`
    [[ -z "$res" ]] && status="${RED}stopped${PLAIN}" || status="${GREEN}running${PLAIN}"
    password=`grep password $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    method=`grep method $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    protocol=`grep protocol $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    obfs=`grep obfs $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    
    p1=`echo -n ${password} | base64 -w 0`
    p1=`echo -n ${p1} | tr -d =`
    res=`echo -n "${IP}:${port}:${protocol}:${method}:${obfs}:${p1}/?remarks=&protoparam=&obfsparam=" | base64 -w 0`
    res=`echo -n ${res} | tr -d =`
    link="ssr://${res}"

    echo ""
    echo ============================================
    echo -e " ${BLUE}ssr operating status: ${PLAIN}${status}"
    echo -e " ${BLUE}ssr configuration file: ${PLAIN}${RED}$CONFIG_FILE${PLAIN}"
    echo ""
    echo -e " ${RED}ssr configuration information:${PLAIN}"
    echo -e "   ${BLUE}Ip address:${PLAIN}  ${RED}${IP}${PLAIN}"
    echo -e "   ${BLUE}port：${PLAIN}${RED}${port}${PLAIN}"
    echo -e "   ${BLUE}password：${PLAIN}${RED}${password}${PLAIN}"
    echo -e "   ${BLUE}method：${PLAIN} ${RED}${method}${PLAIN}"
    echo -e "   ${BLUE}protocol：${PLAIN} ${RED}${protocol}${PLAIN}"
    echo -e "   ${BLUE}obfuscation：${PLAIN} ${RED}${obfs}${PLAIN}"
    echo
    echo -e " ${BLUE}ssr link:${PLAIN} $link"
    #qrencode -o - -t utf8 $link
}

showQR() {
    port=`grep server_port $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    res=`netstat -nltp | grep ${port} | grep python`
    [[ -z "$res" ]] && status="${RED}stopped${PLAIN}" || status="${GREEN}running${PLAIN}"
    password=`grep password $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    method=`grep method $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    protocol=`grep protocol $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    obfs=`grep obfs $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    
    p1=`echo -n ${password} | base64 -w 0`
    p1=`echo -n ${p1} | tr -d =`
    res=`echo -n "${IP}:${port}:${protocol}:${method}:${obfs}:${p1}/?remarks=&protoparam=&obfsparam=" | base64 -w 0`
    res=`echo -n ${res} | tr -d =`
    link="ssr://${res}"
    qrencode -o - -t utf8 $link
}

bbrReboot() {
    if [[ "${INSTALL_BBR}" == "true" ]]; then
        echo  
        colorEcho $BLUE  " In order for the BBR module to take effect, the system will restart in 30 seconds"
        echo  
        echo -e " You can press ctrl + c to cancel the restart and enter it later ${RED}reboot${PLAIN} Reboot the system"
        sleep 30
        reboot
    fi
}


install() {
    getData
    preinstall
    installBBR
    installSSR
    configSSR
    setFirewall

    start
    showInfo
    
    bbrReboot
}

reconfig() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}SSR is not installed, please install it first!${PLAIN}"
        return
    fi
    getData
    configSSR
    setFirewall
    restart

    showInfo
}

uninstall() {
    echo ""
    read -p " Are you sure to uninstall SSR? (y/n)" answer
    [[ -z ${answer} ]] && answer="n"

    if [[ "${answer}" == "y" ]] || [[ "${answer}" == "Y" ]]; then
        rm -f $CONFIG_FILE
        rm -f /var/log/shadowsocksr.log
        rm -rf /usr/local/shadowsocks
        systemctl disable shadowsocksR && systemctl stop shadowsocksR && rm -rf $SERVICE_FILE
    fi
    echo -e " ${RED}Successfully uninstalled${PLAIN}"
}

start() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}SS is not installed, please install it first!${PLAIN}"
        return
    fi
    systemctl restart ${NAME}
    sleep 2
    port=`grep server_port $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    res=`netstat -nltp | grep ${port} | grep python`
    if [[ "$res" = "" ]]; then
        colorEcho $RED " SSR failed to start, please check if the port is occupied!"
    else
        colorEcho $BLUE " SSR started successfully!"
    fi
}

restart() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}SSR is not installed, please install it first!${PLAIN}"
        return
    fi

    stop
    start
}

stop() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}SSR is not installed, please install it first!${PLAIN}"
        return
    fi
    systemctl stop ${NAME}
    colorEcho $BLUE " SSR stopped successfully"
}

showLog() {
    tail /var/log/shadowsocksr.log
}

menu() {
    clear
    echo "#############################################################"
    echo -e "#             ${RED}ShadowsocksR/SSR One-click installation script${PLAIN}               #"
    echo -e "# ${GREEN}Author${PLAIN}: Network skipping(hijk)                                      #"
    echo -e "# ${GREEN}URL${PLAIN}: https://hijk.art                                    #"
    echo -e "# ${GREEN}forum${PLAIN}: https://hijk.club                                   #"
    echo -e "# ${GREEN}TG group${PLAIN}: https://t.me/hijkclub                               #"
    echo -e "# ${GREEN}Youtube channel${PLAIN}: https://youtube.com/channel/UCYTB--VsObzepVJtc9yvUxQ #"
    echo "#############################################################"
    echo ""

    echo -e "  ${GREEN}1.${PLAIN}  Install SSR"
    echo -e "  ${GREEN}2.  ${RED}Uninstall SSR${PLAIN}"
    echo " -------------"
    echo -e "  ${GREEN}4.${PLAIN}  Start SSR"
    echo -e "  ${GREEN}5.${PLAIN}  Restart SSR"
    echo -e "  ${GREEN}6.${PLAIN}  Stop SSR"
    echo " -------------"
    echo -e "  ${GREEN}7.${PLAIN}  View SSR configuration"
    echo -e "  ${GREEN}8.${PLAIN}  View configuration QR code"
    echo -e "  ${GREEN}9.  ${RED}Modify SSR configuration${PLAIN}"
    echo -e "  ${GREEN}10.${PLAIN} View SSR log"
    echo " -------------"
    echo -e "  ${GREEN}0.${PLAIN} drop out"
    echo 
    echo -n " Current status:"
    statusText
    echo 

    read -p " Please choose an operation[0-10]：" answer
    case $answer in
        0)
            exit 0
            ;;
        1)
            install
            ;;
        2)
            uninstall
            ;;
        4)
            start
            ;;
        5)
            restart
            ;;
        6)
            stop
            ;;
        7)
            showInfo
            ;;
        8)
            showQR
            ;;
        9)
            reconfig
            ;;
        10)
            showLog
            ;;
        *)
            echo -e "$RED Please choose the correct operation!${PLAIN}"
            exit 1
            ;;
    esac
}

checkSystem

menu
