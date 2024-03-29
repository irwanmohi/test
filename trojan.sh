#!/bin/bash
# trojan一键安装脚本
# Author: hijk<https://hijk.art>

RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

OS=`hostnamectl | grep -i system | cut -d: -f2`

V6_PROXY=""
IP=`curl -sL -4 ip.sb`
if [[ "$?" != "0" ]]; then
    IP=`curl -sL -6 ip.sb`
    V6_PROXY="https://gh.hijk.art/"
fi

BT="false"
NGINX_CONF_PATH="/etc/nginx/conf.d/"
res=`which bt 2>/dev/null`
if [[ "$res" != "" ]]; then
    BT="true"
    NGINX_CONF_PATH="/www/server/panel/vhost/nginx/"
fi

# The following website is a non-advertising novel website randomly found from Google. If you don’t like it, please change it to another URL, starting with http or https
# The fake domain name cannot be opened after it is set up. It may be that the anti-generation novel website is down. Please leave a message on the website or post an issue on Github to replace the new website.
SITES=(
http://www.zhuizishu.com/
http://xs.56dyc.com/
http://www.xiaoshuosk.com/
https://www.quledu.net/
http://www.ddxsku.com/
http://www.biqu6.com/
https://www.wenshulou.cc/
http://www.auutea.com/
http://www.55shuba.com/
http://www.39shubao.com/
https://www.23xsw.cc/
)

CONFIG_FILE=/usr/local/etc/trojan/config.json

colorEcho() {
    echo -e "${1}${@:2}${PLAIN}"
}

checkSystem() {
    result=$(id | awk '{print $1}')
    if [ $result != "uid=0(root)" ]; then
        colorEcho $RED " 请以root身份执行该脚本"
        exit 1
    fi

    res=`which yum 2>/dev/null`
    if [ "$?" != "0" ]; then
        res=`which apt 2>/dev/null`
        if [ "$?" != "0" ]; then
            colorEcho $RED " 不受支持的Linux系统"
            exit 1
        fi
        PMT=apt
        CMD_INSTALL="apt install -y "
        CMD_REMOVE="apt remove -y "
        CMD_UPGRADE="apt update; apt upgrade -y; apt autoremove -y"
    else
        PMT=yum
        CMD_INSTALL="yum install -y "
        CMD_REMOVE="yum remove -y "
        CMD_UPGRADE="yum update -y"
    fi
    res=`which systemctl 2>/dev/null`
    if [ "$?" != "0" ]; then
        colorEcho $RED " 系统版本过低，请升级到最新版本"
        exit 1
    fi
}

status() {
    trojan_cmd="$(command -v trojan)"
    if [[ "$trojan_cmd" = "" ]]; then
        echo 0
        return
    fi
    if [[ ! -f $CONFIG_FILE ]]; then
        echo 1
        return
    fi
    port=`grep local_port $CONFIG_FILE | cut -d : -f 2 | tr -d \",' '`
    res=`ss -ntlp| grep ${port} | grep trojan`
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
            echo -e ${GREEN}已安装${PLAIN} ${RED}未运行${PLAIN}
            ;;
        3)
            echo -e ${GREEN}已安装${PLAIN} ${GREEN}正在运行${PLAIN}
            ;;
        *)
            echo -e ${RED}未安装${PLAIN}
            ;;
    esac
}

getData() {
    echo " "
    echo " 本脚本为trojan一键脚本，运行之前请确认如下条件已经具备："
    echo -e "  ${RED}1. 一个伪装域名${PLAIN}"
    echo -e "  ${RED}2. 伪装域名DNS解析指向当前服务器ip（${IP}）${PLAIN}"
    echo -e "  3. 如果/root目录下有 ${GREEN}trojan.pem${PLAIN} 和 ${GREEN}trojan.key${PLAIN} 证书密钥文件，无需理会条件2"
    echo " "
    read -p " 确认满足按y，按其他退出脚本：" answer
    if [ "${answer}" != "y" ] && [ "${answer}" != "Y" ]; then
        exit 0
    fi

    echo ""
    while true
    do
        read -p " 请输入伪装域名：" DOMAIN
        if [ -z "${DOMAIN}" ]; then
            echo " 域名输入错误，请重新输入！"
        else
            break
        fi
    done
    DOMAIN=${DOMAIN,,}
    colorEcho $BLUE " 伪装域名(host)： $DOMAIN"

    echo ""
    if [[ -f ~/trojan.pem && -f ~/trojan.key ]]; then
        echo -e "${GREEN} 检测到自有证书，将使用其部署${PLAIN}"
        echo 
        CERT_FILE="/usr/local/etc/trojan/${DOMAIN}.pem"
        KEY_FILE="/usr/local/etc/trojan/${DOMAIN}.key"
    else
        resolve=`curl -sL https://hijk.art/hostip.php?d=${DOMAIN}`
        res=`echo -n ${resolve} | grep ${IP}`
        if [[ -z "${res}" ]]; then
            echo " ${DOMAIN} 解析结果：${resolve}"
            echo -e " ${RED}域名未解析到当前服务器IP(${IP})!${PLAIN}"
            exit 1
        fi
    fi

    echo ""
    read -p " 请设置trojan密码（不输入则随机生成）:" PASSWORD
    [ -z "$PASSWORD" ] && PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
    colorEcho $BLUE " 密码： " $PASSWORD

    echo ""
    read -p " 请输入trojan端口[100-65535的一个数字，默认443]：" PORT
    [ -z "${PORT}" ] && PORT=443
    if [ "${PORT:0:1}" = "0" ]; then
        echo -e " ${RED}端口不能以0开头${PLAIN}"
        exit 1
    fi
    colorEcho $BLUE " trojan端口： " $PORT

    echo ""
    colorEcho $BLUE " 请选择伪装站类型:"
    echo "   1) 静态网站(位于/usr/share/nginx/html)"
    echo "   2) 小说站(随机选择)"
    echo "   3) 美女站(https://imeizi.me)"
    echo "   4) VPS优惠博客(https://vpsgongyi.com)"
    echo "   5) 自定义反代站点(需以http或者https开头)"
    read -p "  请选择伪装网站类型[默认:美女站]" answer
    if [[ -z "$answer" ]]; then
        PROXY_URL="https://imeizi.me"
    else
        case $answer in
        1)
            PROXY_URL=""
            ;;
        2)
            len=${#SITES[@]}
            ((len--))
            index=`shuf -i0-${len} -n1`
            PROXY_URL=${SITES[$index]}
            ;;
        3)
            PROXY_URL="https://imeizi.me"
            ;;
        4)
            PROXY_URL="https://vpsgongyi.com"
            ;;
        5)
            read -p " 请输入反代站点(以http或者https开头)：" PROXY_URL
            if [[ -z "$PROXY_URL" ]]; then
                colorEcho $RED " 请输入反代网站！"
                exit 1
            elif [[ "${PROXY_URL:0:4}" != "http" ]]; then
                colorEcho $RED " 反代网站必须以http或https开头！"
                exit 1
            fi
            ;;
        *)
            colorEcho $RED " 请输入正确的选项！"
            exit 1
        esac
    fi
    REMOTE_HOST=`echo ${PROXY_URL} | cut -d/ -f3`
    echo ""
    colorEcho $BLUE " 伪装域名：$PROXY_URL"

    echo ""
    colorEcho $BLUE "  是否允许搜索引擎爬取网站？[默认：不允许]"
    echo "    y)允许，会有更多ip请求网站，但会消耗一些流量，vps流量充足情况下推荐使用"
    echo "    n)不允许，爬虫不会访问网站，访问ip比较单一，但能节省vps流量"
    read -p "  请选择：[y/n]" answer
    if [[ -z "$answer" ]]; then
        ALLOW_SPIDER="n"
    elif [[ "${answer,,}" = "y" ]]; then
        ALLOW_SPIDER="y"
    else
        ALLOW_SPIDER="n"
    fi
    echo ""
    colorEcho $BLUE " 允许搜索引擎：$ALLOW_SPIDER"

    echo ""
    read -p "  是否安装BBR(默认安装)?[y/n]:" NEED_BBR
    [ -z "$NEED_BBR" ] && NEED_BBR=y
    [ "$NEED_BBR" = "Y" ] && NEED_BBR=y
    colorEcho $BLUE " 安装BBR：$NEED_BBR"
}

preinstall() {
    $PMT clean all
    [[ "$PMT" = "apt" ]] && $PMT update
    #colorEcho $BLUE " 更新系统..."
    #echo $CMD_UPGRADE | bash

    colorEcho $BLUE " 安装必要软件"
    if [[ "$PMT" = "yum" ]]; then
        $CMD_INSTALL epel-release
    fi
    $CMD_INSTALL wget vim unzip tar gcc openssl
    $CMD_INSTALL net-tools
    if [[ "$PMT" = "apt" ]]; then
        $CMD_INSTALL libssl-dev g++
    fi

    if [[ -s /etc/selinux/config ]] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
        setenforce 0
    fi
}

installTrojan() {
    colorEcho $BLUE " 安装最新版trojan..."
    rm -rf $CONFIG_FILE
    rm -rf /etc/systemd/system/trojan.service

    NAME=trojan
    VERSION=`curl -fsSL ${V6_PROXY}https://api.github.com/repos/trojan-gfw/trojan/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/'`
    TARBALL="$NAME-$VERSION-linux-amd64.tar.xz"
    DOWNLOADURL="${V6_PROXY}https://github.com/trojan-gfw/$NAME/releases/download/v$VERSION/$TARBALL"
    TMPDIR="$(mktemp -d)"
    INSTALLPREFIX=/usr/local
    SYSTEMDPREFIX=/etc/systemd/system

    BINARYPATH="$INSTALLPREFIX/bin/$NAME"
    CONFIGPATH="$INSTALLPREFIX/etc/$NAME/config.json"
    SYSTEMDPATH="$SYSTEMDPREFIX/$NAME.service"

    echo Entering temp directory $TMPDIR...
    cd "$TMPDIR"

    echo Downloading $NAME $VERSION...
    curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

    echo Unpacking $NAME $VERSION...
    tar xf "$TARBALL"
    cd "$NAME"

    echo Installing $NAME $VERSION to $BINARYPATH...
    cp "$NAME" "$BINARYPATH"
    chmod 755 "$BINARYPATH"

    mkdir -p $INSTALLPREFIX/etc/$NAME

    echo Installing $NAME systemd service to $SYSTEMDPATH...
    cat > "$SYSTEMDPATH" << EOF
[Unit]
Description=$NAME
Documentation=https://trojan-gfw.github.io/$NAME/config https://trojan-gfw.github.io/$NAME/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
ExecStart="$BINARYPATH" "$CONFIGPATH"
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF

    echo Reloading systemd daemon...
    systemctl daemon-reload

    echo Deleting temp directory $TMPDIR...
    rm -rf "$TMPDIR"

    echo Done!

    if [[ ! -f "$BINARYPATH" ]]; then
        colorEcho $RED " $OS 安装trojan失败，请到 https://hijk.art 反馈"
        exit 1
    fi

    systemctl enable trojan
    colorEcho $GREEN " trojan安装成功！"
}

configTrojan() {
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    cat >$CONFIG_FILE<<-EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": ${PORT},
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$PASSWORD"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "$CERT_FILE",
        "key": "$KEY_FILE",
        "key_password": "",
	    "sni": "$DOMAIN",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1", "h2"
        ],
        "alpn_port_override": {
            "h2": 81
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
}

getCert() {
    mkdir -p /usr/local/etc/trojan
    if [[ -z ${CERT_FILE+x} ]]; then
        systemctl stop nginx
        res=`netstat -ntlp| grep -E ':80 |:443 '`
        if [[ "${res}" != "" ]]; then
            colorEcho $RED " Port 80 or 443 is occupied by other processes, please close it before running the one-click script"
            echo " Port occupancy information is as follows:"
            echo ${res}
            exit 1
        fi

        $CMD_INSTALL socat openssl
        if [[ "$PMT" = "yum" ]]; then
            $CMD_INSTALL cronie
            systemctl start crond
            systemctl enable crond
        else
            $CMD_INSTALL cron
            systemctl start cron
            systemctl enable cron
        fi
        curl -sL https://get.acme.sh | sh
        source ~/.bashrc
        ~/.acme.sh/acme.sh  --upgrade  --auto-upgrade
        ~/.acme.sh/acme.sh   --issue -d $DOMAIN --pre-hook "systemctl stop nginx" --post-hook "systemctl restart nginx"  --standalone
        if [[ "$?" != "0" ]]; then
            colorEcho $RED " Failed to obtain the certificate, please copy the red text above to https://hijk.art Feedback"
            exit 1
        fi
        CERT_FILE="/usr/local/etc/trojan/${DOMAIN}.pem"
        KEY_FILE="/usr/local/etc/trojan/${DOMAIN}.key"
        ~/.acme.sh/acme.sh  --install-cert -d $DOMAIN \
            --key-file       $KEY_FILE  \
            --fullchain-file $CERT_FILE \
            --reloadcmd     "service nginx force-reload"
        [[ -f $CERT_FILE && -f $KEY_FILE ]] || {
            colorEcho $RED " Failed to obtain the certificate, please go to https://hijk.art to feedback"
            exit 1
        }
    else
        cp ~/trojan.pem /usr/local/etc/trojan/${DOMAIN}.pem
        cp ~/trojan.key /usr/local/etc/trojan/${DOMAIN}.key
    fi
}

installNginx() {
    colorEcho $BLUE " Install nginx..."
    if [[ "$BT" = "false" ]]; then
        if [[ "$PMT" = "yum" ]]; then
            $CMD_INSTALL epel-release 
        fi
        $CMD_INSTALL nginx
        systemctl enable nginx
    else
        res=`which nginx 2>/dev/null`
        if [[ "$?" != "0" ]]; then
            colorEcho $RED " You have installed the pagoda, please install nginx in the background of the pagoda before running this script"
            exit 1
        fi
    fi
}

configNginx() {
    mkdir -p /usr/share/nginx/html
    if [[ "$ALLOW_SPIDER" = "n" ]]; then
        echo 'User-Agent: *' > /usr/share/nginx/html/robots.txt
        echo 'Disallow: /' >> /usr/share/nginx/html/robots.txt
        ROBOT_CONFIG="    location = /robots.txt {}"
    else
        ROBOT_CONFIG=""
    fi

    if [[ "$BT" = "false" ]]; then
        if [ ! -f /etc/nginx/nginx.conf.bak ]; then
            mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        fi
        res=`id nginx 2>/dev/null`
        if [[ "$?" != "0" ]]; then
            user="www-data"
        else
            user="nginx"
        fi
        cat > /etc/nginx/nginx.conf<<-EOF
user $user;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    gzip                on;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
}
EOF
    fi

    mkdir -p $NGINX_CONF_PATH
    if [[ "$PROXY_URL" = "" ]]; then
        cat > $NGINX_CONF_PATH${DOMAIN}.conf<<-EOF
server {
    listen 80;
    listen [::]:80;
    listen 81 http2;
    server_name ${DOMAIN};
    root /usr/share/nginx/html;

    $ROBOT_CONFIG
}
EOF
    else
        cat > $NGINX_CONF_PATH${DOMAIN}.conf<<-EOF
server {
    listen 80;
    listen [::]:80;
    listen 81 http2;
    server_name ${DOMAIN};
    root /usr/share/nginx/html;
    location / {
        proxy_ssl_server_name on;
        proxy_pass $PROXY_URL;
        proxy_set_header Accept-Encoding '';
        sub_filter "$REMOTE_HOST" "$DOMAIN";
        sub_filter_once off;
    }
    
    $ROBOT_CONFIG
}
EOF
    fi
}

startNginx() {
    if [[ "$BT" = "false" ]]; then
        systemctl start nginx
    else
        nginx -c /www/server/nginx/conf/nginx.conf
    fi
}

stopNginx() {
    if [[ "$BT" = "false" ]]; then
        systemctl stop nginx
    else
        res=`ps aux | grep -i nginx`
        if [[ "$res" != "" ]]; then
            nginx -s stop
        fi
    fi
}

setFirewall() {
    res=`which firewall-cmd 2>/dev/null`
    if [[ $? -eq 0 ]]; then
        systemctl status firewalld > /dev/null 2>&1
        if [[ $? -eq 0 ]];then
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            if [[ "$PORT" != "443" ]]; then
                firewall-cmd --permanent --add-port=${PORT}/tcp
            fi
            firewall-cmd --reload
        else
            nl=`iptables -nL | nl | grep FORWARD | awk '{print $1}'`
            if [[ "$nl" != "3" ]]; then
                iptables -I INPUT -p tcp --dport 80 -j ACCEPT
                iptables -I INPUT -p tcp --dport 443 -j ACCEPT
                if [[ "$PORT" != "443" ]]; then
                    iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
                fi
            fi
        fi
    else
        res=`which iptables 2>/dev/null`
        if [[ $? -eq 0 ]]; then
            nl=`iptables -nL | nl | grep FORWARD | awk '{print $1}'`
            if [[ "$nl" != "3" ]]; then
                iptables -I INPUT -p tcp --dport 80 -j ACCEPT
                iptables -I INPUT -p tcp --dport 443 -j ACCEPT
                if [[ "$PORT" != "443" ]]; then
                    iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
                fi
            fi
        else
            res=`which ufw 2>/dev/null`
            if [[ $? -eq 0 ]]; then
                res=`ufw status | grep -i inactive`
                if [[ "$res" = "" ]]; then
                    ufw allow http/tcp
                    ufw allow https/tcp
                    if [[ "$PORT" != "443" ]]; then
                        ufw allow ${PORT}/tcp
                    fi
                fi
            fi
        fi
    fi
}

installBBR() {
    if [ "$NEED_BBR" != "y" ]; then
        INSTALL_BBR=false
        return
    fi

    result=$(lsmod | grep bbr)
    if [ "$result" != "" ]; then
        colorEcho $YELLOW " BBR module is installed"
        INSTALL_BBR=false
        return;
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
    res=`netstat -nltp | grep trojan`
    [[ -z "$res" ]] && status="${RED}stopped${PLAIN}" || status="${GREEN}running${PLAIN}"
    
    domain=`grep sni $CONFIG_FILE | cut -d: -f2 | tr -d \",' '`
    if [[ "$domain" = "" ]]; then
        domain=`grep -m1 cert $CONFIG_FILE | cut -d/ -f5`
    fi
    port=`grep local_port $CONFIG_FILE | cut -d: -f2 | tr -d \",' '`
    line1=`grep -n 'password' $CONFIG_FILE  | head -n1 | cut -d: -f1`
    line11=`expr $line1 + 1`
    password=`sed -n "${line11}p" $CONFIG_FILE | tr -d \",' '`
    
    res=`netstat -nltp | grep ${port} | grep nginx`
    [[ -z "$res" ]] && ngstatus="${RED}stopped${PLAIN}" || ngstatus="${GREEN}running${PLAIN}"
    
    echo ============================================
    echo -e " ${BLUE}trojan running status:${PLAIN}${status}"
    echo ""
    echo -e " ${BLUE}trojan configuration file:${PLAIN}${RED}$CONFIG_FILE${PLAIN}"
    echo -e " ${BLUE}trojan configuration information:${PLAIN}               "
    echo -e "   ${BLUE}IP/domain name:${PLAIN}  ${RED}${domain}${PLAIN}"
    echo -e "   ${BLUE}Port：${PLAIN}${RED}${port}${PLAIN}"
    echo -e "   ${BLUE}Password：${PLAIN}${RED}$password${PLAIN}"
    echo  
    echo ============================================
}

bbrReboot() {
    if [ "${INSTALL_BBR}" == "true" ]; then
        echo ""
        colorEcho $BLUE " In order for the BBR module to take effect, the system will restart in 30 seconds"
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
    setFirewall
    installNginx
    getCert
    configNginx
    installTrojan
    configTrojan

    start
    showInfo
    bbrReboot
}

reconfig() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}Trojan is not installed, please install it first!${PLAIN}"
        return
    fi

    getData
    setFirewall
    getCert
    configNginx
    configTrojan
    restart
    showInfo
}

update() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}Trojan is not installed, please install it first!${PLAIN}"
        return
    fi

    installTrojan

    stop
    start
    colorEcho $BLUE " Successfully updated to the latest version of trojan"
}

start() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e "${RED}Trojan is not installed, please install it first!${PLAIN}"
        return
    fi
    stopNginx
    startNginx
    systemctl restart trojan
    sleep 2
    port=`grep local_port $CONFIG_FILE|cut -d: -f2| tr -d \",' '`
    res=`ss -ntlp| grep ${port} | grep trojan`
    if [[ "$res" = "" ]]; then
         colorEcho $RED " Trojan failed to start, please check if the port is occupied!"
    else
        colorEcho $BLUE " trojan started successfully"
    fi
}

stop() {
    stopNginx
    systemctl stop trojan
    colorEcho $BLUE " trojan停止成功"
}


restart() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e " ${RED}Trojan is not installed, please install it first!${PLAIN}"
        return
    fi

    stop
    start
}

showLog() {
    res=`status`
    if [[ $res -lt 2 ]]; then
        echo -e "${RED}Trojan is not installed, please install it first!${PLAIN}"
        return
    fi

    journalctl -xen -u trojan --no-pager
}

uninstall() {
    echo ""
    read -p " Are you sure to uninstall trojan? (y/n)" answer
    [[ -z ${answer} ]] && answer="n"

    if [[ "${answer}" == "y" ]] || [[ "${answer}" == "Y" ]]; then
        domain=`grep sni $CONFIG_FILE | cut -d: -f2 | tr -d \",' '`
        if [[ "$domain" = "" ]]; then
            domain=`grep -m1 cert $CONFIG_FILE | cut -d/ -f5`
        fi

        systemctl stop trojan
        systemctl disable trojan
        rm -rf /usr/local/bin/trojan
        rm -rf /usr/local/etc/trojan
        rm -rf /etc/systemd/system/trojan.service

        if [[ "$BT" = "false" ]]; then
            $CMD_REMOVE nginx
            if [[ "$PMT" = "apt" ]]; then
                $CMD_REMOVE nginx-common
            fi
            if [[ -d /usr/share/nginx/html.bak ]]; then
                rm -rf /usr/share/nginx/html
                mv /usr/share/nginx/html.bak /usr/share/nginx/html
            fi
        fi
        rm -rf $NGINX_CONF_PATH${domain}.conf
        ~/.acme.sh/acme.sh --uninstall
        colorEcho $GREEN " trojan uninstalled successfully"
    fi
}

menu() {
    clear
    echo "#############################################################"
    echo -e "#                    ${RED}trojan一键安装脚本${PLAIN}                    #"
    echo -e "# ${GREEN}Author${PLAIN}: 网络跳越(hijk)                                      #"
    echo -e "# ${GREEN}URL${PLAIN}: https://hijk.art                                    #"
    echo -e "# ${GREEN}forum${PLAIN}: https://hijk.club                                   #"
    echo -e "# ${GREEN}TG group${PLAIN}: https://t.me/hijkclub                               #"
    echo -e "# ${GREEN}Youtube channel${PLAIN}: https://youtube.com/channel/UCYTB--VsObzepVJtc9yvUxQ #"
    echo "#############################################################"
    echo ""

    echo -e "  ${GREEN}1.${PLAIN}  Install trojan"
    echo -e "  ${GREEN}2.${PLAIN}  Update trojan"
    echo -e "  ${GREEN}3.  ${RED}Uninstall trojan${PLAIN}"
    echo " -------------"
    echo -e "  ${GREEN}4.${PLAIN}  Start trojan"
    echo -e "  ${GREEN}5.${PLAIN}  Restart trojan"
    echo -e "  ${GREEN}6.${PLAIN}  Stop trojan"
    echo " -------------"
    echo -e "  ${GREEN}7.${PLAIN}  View trojan configuration"
    echo -e "  ${GREEN}8.  ${RED}Modify trojan configuration${PLAIN}"
    echo -e "  ${GREEN}9.${PLAIN}  View trojan logs"
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
            update
            ;;
        3)
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
            reconfig
            ;;
        9)
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
