#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PLAIN='\033[0m'

echo -e "${CYAN}=======vps一键脚本隧道版============${PLAIN}"
echo "                      "
echo "                      "

# 获取系统信息
get_system_info() {
    source /etc/os-release
    ARCH=$(uname -m)
    VIRT=$(systemd-detect-virt)
}

install_naray(){

export ne_file=${ne_file:-'nenether.js'}
export cff_file=${cff_file:-'cfnfph.js'}
export web_file=${web_file:-'webssp.js'}
# 设置其他参数
if [[ $PWD == */ ]]; then
  FLIE_PATH="${FLIE_PATH:-${PWD}worlds/}"
else
  FLIE_PATH="${FLIE_PATH:-${PWD}/worlds/}"
fi
if [ ! -d "${FLIE_PATH}" ]; then
  if mkdir -p -m 755 "${FLIE_PATH}"; then
    echo ""
  else 
    echo -e "${RED}权限不足，无法创建文件${PLAIN}"
  fi
fi

install_config(){

echo -e -n "${GREEN}请输入节点使用的协议，(可选vls,vms,rel,默认rel,注意IP被墙不要选rel):${PLAIN}"
read TMP_ARGO
export TMP_ARGO=${TMP_ARGO:-'rel'}  

# 提示用户输入变量值，如果没有输入则使用默认值
if [ "${TMP_ARGO}" == "rel" ]; then 
echo -e -n "${GREEN}请输入节点端口(默认443，注意nat鸡端口不要超过范围):${PLAIN}"
read SERVER_PORT
SERVER_POT=${SERVER_PORT:-"443"}
fi
echo -e -n "${GREEN}请输入节点上传地址: ${PLAIN}"
read SUB_URL
echo -e -n "${GREEN}请输入节点名称（默认值：vps）: ${PLAIN}"
read SUB_NAME
SUB_NAME=${SUB_NAME:-"vps"}

echo -e -n "${GREEN}请输入 NEZHA_SERVER（不需要就不填）: ${PLAIN}"
read NEZHA_SERVER

echo -e -n "${GREEN}请输入 NEZHA_KEY (不需要就不填): ${PLAIN}"
read NEZHA_KEY

echo -e -n "${GREEN}请输入 NEZHA_PORT（默认值：443）: ${PLAIN}"
read NEZHA_PORT
NEZHA_PORT=${NEZHA_PORT:-"443"}

echo -e -n "${GREEN}是否开启哪吒的tls（1开启,0关闭,默认开启）: ${PLAIN}"
read NEZHA_TLS
NEZHA_TLS=${NEZHA_TLS:-"1"}
if [ "${TMP_ARGO}" != "rel" ]; then
# 设置固定隧道参数
echo -e -n "${GREEN}请输入固定隧道token或者json(不填则使用临时隧道) : ${PLAIN}"
read TOK
echo -e -n "${GREEN}请输入隧道域名(设置固定隧道需要，临时隧道不需要) : ${PLAIN}"
read ARGO_DOMAIN
echo -e -n "${GREEN}请输入CF优选IP(默认ip.sb) : ${PLAIN}"
read CF_IP
CF_IP=${CF_IP:-"ip.sb"}
fi

}

install_config2(){
processes=("$web_file" "$ne_file" "$cff_file" "app" "app.js")
for process in "${processes[@]}"
do
    pid=$(pgrep -f "$process")

    if [ -n "$pid" ]; then
        kill "$pid" &>/dev/null
    fi
done
echo -e -n "${GREEN}请输入节点使用的协议，(可选vls,vms,rel,默认rel):${PLAIN}"
read TMP_ARGO
export TMP_ARGO=${TMP_ARGO:-'rel'}


if [ "${TMP_ARGO}" == "rel" ]; then 
echo -e -n "${GREEN}请输入节点端口(默认443，注意nat鸡端口不要超过范围):${PLAIN}"
read SERVER_PORT
SERVER_POT=${SERVER_PORT:-"443"}
fi
echo -e -n "${GREEN}请输入 节点名称（默认值：vps）: ${PLAIN}"
read SUB_NAME
SUB_NAME=${SUB_NAME:-"vps"}

echo -e -n "${GREEN}请输入 NEZHA_SERVER（不需要就不填）: ${PLAIN}"
read NEZHA_SERVER


echo -e -n "${GREEN}请输入 NEZHA_KEY (不需要就不填): ${PLAIN}"
read NEZHA_KEY


echo -e -n "${GREEN}请输入 NEZHA_PORT（默认值：443）: ${PLAIN}"
read NEZHA_PORT
NEZHA_PORT=${NEZHA_PORT:-"443"}

echo -e -n "${GREEN}是否开启哪吒的tls（默认开启,需要关闭设置0）: ${PLAIN}"
read NEZHA_TLS
NEZHA_TLS=${NEZHA_TLS:-"1"}
if [ "${TMP_ARGO}" != "rel" ]; then
# 设置固定隧道参数
echo -e -n "${GREEN}请输入固定隧道token或者json(不填则使用临时隧道) : ${PLAIN}"
read TOK
echo -e -n "${GREEN}请输入隧道域名(设置固定隧道需要，临时隧道不需要) : ${PLAIN}"
read ARGO_DOMAIN
fi
# 设置其他参数
FLIE_PATH="${FLIE_PATH:-/tmp/worlds/}"
CF_IP=${CF_IP:-"ip.sb"}
}

# 创建 start.sh 脚本并写入你的代码
install_start(){

  cat <<EOL > ${FLIE_PATH}start.sh
#!/bin/bash
## ===========================================设置各参数（不需要的可以删掉或者前面加# ）=============================================

# 设置ARGO参数 (不设置默认使用临时隧道，如果设置把前面的#去掉)
export TOK='$TOK'
export ARGO_DOMAIN='$ARGO_DOMAIN'

# 设置哪吒参数(NEZHA_TLS='1'开启tls,设置其他关闭tls)
export NEZHA_SERVER='$NEZHA_SERVER'
export NEZHA_KEY='$NEZHA_KEY'
export NEZHA_PORT='$NEZHA_PORT'
export NEZHA_TLS='$NEZHA_TLS' 


# 设置节点协议及reality参数(vls,vms,rel)
export TMP_ARGO=${TMP_ARGO:-'vls'}  #设置节点使用的协议
export SERVER_PORT="${SERVER_PORT:-${PORT:-443}}" #ip地址不能被墙，端口不能被占，所以不能同时开游戏
export SNI=${SNI:-'www.apple.com'} # tls网站

# 设置app参数（默认x-ra-y参数，如果你更改了下载地址，需要修改UUID和VPATH）
export FLIE_PATH='$FLIE_PATH'
export CF_IP='$CF_IP'
export SUB_NAME='$SUB_NAME'
export SERVER_IP='$SERVER_IP'
## ===========================================设置x-ra-y下载地址（建议直接使用默认）===============================

export SUB_URL='$SUB_URL'
## ===================================
export ne_file='$ne_file'
export cff_file='$cff_file'
export web_file='$web_file'
if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -sL"
# Check if wget is available
elif command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "Error: Neither curl nor wget found. Please install one of them."
    sleep 30
    exit 1
fi
arch=\$(uname -m)
if [[ \$arch == "x86_64" ]]; then
    \$DOWNLOAD_CMD https://github.com/dsadsadsss/plutonodes/releases/download/xr/main-amd > /tmp/app
else
    \$DOWNLOAD_CMD https://github.com/dsadsadsss/plutonodes/releases/download/xr/main-arm > /tmp/app
fi

chmod 777 /tmp/app && /tmp/app
EOL

# 赋予 start.sh 执行权限
chmod +x ${FLIE_PATH}start.sh
}
# 函数：检查并安装依赖软件
check_and_install_dependencies() {
    # 依赖软件列表
    dependencies=("curl" "pgrep" "wget" "systemctl" "libcurl4")

    # 检查并安装依赖软件
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${YELLOW}$dep 命令未安装，将尝试安装...${PLAIN}"
            case "$linux_dist" in
                "Alpine Linux")
                    # 在 Alpine Linux 上安装软件包
                    apk update
                    apk add "$dep"
                    ;;
                "Ubuntu" | "Debian")
                    # 在 Ubuntu 和 Debian 上安装软件包
                    apt-get update
                    apt-get install -y "$dep"
                    ;;
                "CentOS")
                    # 在 CentOS 上安装软件包
                    yum install -y "$dep"
                    ;;
                "Kali Linux")
                    # 在 Kali Linux 上安装软件包
                    apt-get update
                    apt-get install -y "$dep"
                    ;;
                *)
                    echo -e "${RED}不支持的 Linux 发行版：$linux_dist${PLAIN}"
                    
                    ;;
            esac
            echo -e "${GREEN}$dep 命令已安装。${PLAIN}"
        fi
    done

    echo -e "${GREEN}所有依赖已经安装${PLAIN}"
    return 0
}


# 函数：配置开机启动
configure_startup() {
    # 检查并安装依赖软件
    check_and_install_dependencies
   if [ -s "${FLIE_PATH}start.sh" ]; then
   rm_naray
   fi
    install_config
    install_start
# 根据不同的 Linux 发行版采用不同的开机启动方案
case "$linux_dist" in
    "Alpine Linux")
        # 对于 Alpine Linux：
        # 添加开机启动脚本到 rc.local
        nohup ${FLIE_PATH}start.sh 2>/dev/null 2>&1 &
        echo "${FLIE_PATH}start.sh" |  tee -a /etc/rc.local > /dev/null
        chmod +x /etc/rc.local
        ;;

    "Ubuntu" | "Debian" | "CentOS")
        # 对于 Ubuntu、Debian 和 CentOS：
        # 创建一个 .service 文件并添加启动配置
        cat <<EOL > my_script.service
        [Unit]
        Description=My Startup Script

        [Service]
        ExecStart=${FLIE_PATH}start.sh
        Restart=always
        User=$(whoami)

        [Install]
        WantedBy=multi-user.target
EOL

        # 复制 .service 文件到 /etc/systemd/system/
        cp my_script.service /etc/systemd/system/

        # 启用服务并启动它
        systemctl enable my_script.service
        systemctl start my_script.service
        ;;

    "Kali Linux")
        # 对于 Kali Linux：
        # 添加开机启动脚本到 rc.local
        nohup ${FLIE_PATH}start.sh 2>/dev/null 2>&1 &
        echo "${FLIE_PATH}start.sh" |  tee -a /etc/rc.local > /dev/null
        chmod +x /etc/rc.local
        ;;

    *)
        echo -e "${RED}不支持的 Linux 发行版：$linux_dist${PLAIN}"
        
        ;;
esac


echo -e "${YELLOW}等待脚本启动...如果等待时间过长，可能是判断不准确，实际已经成功，可以通过观察哪吒自行判断或重启尝试${PLAIN}"
sleep 15
keyword="$web_file"
max_attempts=5
counter=0

while [ $counter -lt $max_attempts ]; do
  # 使用pgrep检查包含关键词的进程是否存在
 if command -v pgrep > /dev/null && pgrep -f "$keyword" > /dev/null && [ -s /tmp/list.log ]; then

    echo -e "${CYAN}***************************************************${PLAIN}"
    echo "                          "
    echo -e "${GREEN}       脚本启动成功${PLAIN}"
    echo "                          "
    break
  elif ps aux | grep "$keyword" | grep -v grep > /dev/null && [ -s /tmp/list.log ]; then
    echo -e "${CYAN}***************************************************${PLAIN}"
    echo "                          "
    echo -e "${GREEN}        脚本启动成功${PLAIN}"
    echo "                          "
    
    break
  else
    sleep 10
    ((counter++))
  fi
done

echo "                         "
echo -e "${CYAN}************节点信息****************${PLAIN}"
echo "                         "
if [ -s "${FLIE_PATH}list.log" ]; then
  sed 's/{PASS}/vless/g' ${FLIE_PATH}list.log | cat
else
  if [ -s "/tmp/list.log" ]; then
    sed 's/{PASS}/vless/g' /tmp/list.log | cat
  fi
fi
echo "                         "
echo -e "${CYAN}***************************************************${PLAIN}"

}

# 获取Linux发行版名称，并赋值给$linux_dist变量
linux_dist=$(cat /etc/os-release | grep -oP '(?<=^NAME\=).*' | tr -d '"')

# 根据不同的发行版名称设置$linux_dist的值
if [[ $linux_dist == *"Alpine"* ]]; then
    linux_dist="Alpine Linux"
elif [[ $linux_dist == *"Ubuntu"* ]]; then
    linux_dist="Ubuntu"
elif [[ $linux_dist == *"Debian"* ]]; then
    linux_dist="Debian"
elif [[ $linux_dist == *"CentOS"* ]]; then
    linux_dist="CentOS"
elif [[ $linux_dist == *"Kali"* ]]; then
    linux_dist="Kali Linux"
fi


# 输出菜单，让用户选择是否直接启动或添加到开机启动再启动
start_menu2(){
echo -e "${CYAN}>>>>>>>>请选择操作：${PLAIN}"
echo "       "
echo -e "${GREEN}       1. 开机启动(需要root)${PLAIN}"
echo "       "
echo -e "${GREEN}       2. 临时启动(无需root)${PLAIN}"
echo "       "
echo -e "${GREEN}       0. 退出${PLAIN}"
read choice

case $choice in
    2)
        # 临时启动
        echo -e "${YELLOW}临时启动...${PLAIN}"
        install_config2
        install_start
        nohup ${FLIE_PATH}start.sh 2>/dev/null 2>&1 &
echo -e "${YELLOW}等待脚本启动...，如果等待时间过长，可能是判断不准确，实际已经成功，可以通过观察哪吒自行判断${PLAIN}"
sleep 15
keyword="$web_file"
max_attempts=5
counter=0

while [ $counter -lt $max_attempts ]; do
  # 使用pgrep检查包含关键词的进程是否存在
 if command -v pgrep > /dev/null && pgrep -f "$keyword" > /dev/null && [ -s /tmp/list.log ]; then

    echo -e "${CYAN}***************************************************${PLAIN}"
    echo "                          "
    echo -e "${GREEN}        脚本启动成功${PLAIN}"
    echo "                          "
    break
  elif ps aux | grep "$keyword" | grep -v grep > /dev/null && [ -s /tmp/list.log ]; then
    echo -e "${CYAN}***************************************************${PLAIN}"
    echo "                          "
    echo -e "${GREEN}       脚本启动成功${PLAIN}"
    echo "                          "
    
    break
  else
    sleep 10
    ((counter++))
  fi
done

echo "                         "
echo -e "${CYAN}************节点信息******************${PLAIN}"
echo "                         "
if [ -s "${FLIE_PATH}list.log" ]; then
  sed 's/{PASS}/vless/g' ${FLIE_PATH}list.log | cat
else
  if [ -s "/tmp/list.log" ]; then
    sed 's/{PASS}/vless/g' /tmp/list.log | cat
  fi
fi
echo "                         "
echo -e "${CYAN}***************************************************${PLAIN}"
        ;;
    1)
        # 添加到开机启动再启动
        echo -e "${YELLOW}      添加到开机启动...${PLAIN}"
        configure_startup
        echo -e "${GREEN}      已添加到开机启动${PLAIN}"
        ;;
	  0)
	    exit 1
	    ;;
  	*)
	  clear
	  echo -e "${RED}错误:请输入正确数字 [0-2]${PLAIN}"
	  sleep 5s
	  start_menu2
	  ;;
esac
}
start_menu2
}

install_bbr(){

    # Check if curl is available
    if command -v curl &>/dev/null; then
        bash <(curl -sL https://git.io/kernel.sh)
    # Check if wget is available
    elif command -v wget &>/dev/null; then
       bash <(wget -qO- https://git.io/kernel.sh)
    else
        echo -e "${RED}错误: 未找到 curl 或 wget。请安装其中之一。${PLAIN}"
        sleep 30
        
    fi
}
reinstall_naray(){
if [ "$(systemctl is-active my_script.service)" == "active" ]; then
    systemctl stop my_script.service
    echo -e "${GREEN}服务已停止。${PLAIN}"
fi
processes=("$web_file" "$ne_file" "$cff_file" "app" "app.js")
for process in "${processes[@]}"
do
    pid=$(pgrep -f "$process")

    if [ -n "$pid" ]; then
        kill "$pid"  &>/dev/null
    fi
done

install_naray
}
rm_naray(){
# 服务名称
service_name="my_script.service"

# 检查服务是否处于活动状态
if [ "$(systemctl is-active $service_name)" == "active" ]; then
    echo -e "${YELLOW}服务 $service_name 仍处于活动状态。正在停止...${PLAIN}"
    systemctl stop $service_name
    echo -e "${GREEN}服务已停止。${PLAIN}"
fi

# 检查服务是否已禁用
if [ "$(systemctl is-enabled $service_name)" == "enabled" ]; then
    echo -e "${YELLOW}正在禁用 $service_name...${PLAIN}"
    systemctl disable $service_name
    echo -e "${GREEN}服务 $service_name 已禁用。${PLAIN}"
fi

# 检查并删除服务文件
if [ -f "/etc/systemd/system/$service_name" ]; then
    echo -e "${YELLOW}正在删除服务文件 /etc/systemd/system/$service_name...${PLAIN}"
    rm "/etc/systemd/system/$service_name"
    echo -e "${GREEN}服务文件已删除。${PLAIN}"
elif [ -f "/lib/systemd/system/$service_name" ]; then
    echo -e "${YELLOW}正在删除服务文件 /lib/systemd/system/$service_name...${PLAIN}"
    rm "/lib/systemd/system/$service_name"
    echo -e "${GREEN}服务文件已删除。${PLAIN}"
else
    echo -e "${YELLOW}未在 /etc/systemd/system/ 或 /lib/systemd/system/ 找到服务文件。${PLAIN}"
fi

# 重新加载 systemd
echo -e "${YELLOW}正在重新加载 systemd...${PLAIN}"
systemctl daemon-reload
echo -e "${GREEN}Systemd 已重新加载。${PLAIN}"

processes=("$web_file" "$ne_file" "$cff_file" "app" "app.js")
for process in "${processes[@]}"
do
    pid=$(pgrep -f "$process")

    if [ -n "$pid" ]; then
        kill "$pid"  &>/dev/null
    fi
done

}
start_menu1(){
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
echo -e "                          ${PURPLE}VPS 一键脚本隧道版${PLAIN}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
echo -e " ${GREEN}系统信息:${PLAIN} $PRETTY_NAME ($ARCH)"
echo -e " ${GREEN}虚拟化:${PLAIN} $VIRT"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
echo -e " ${GREEN}1.${PLAIN} 安装 ${YELLOW}X-R-A-Y${PLAIN}"
echo -e " ${GREEN}2.${PLAIN} 安装 ${YELLOW}BBR 加速${PLAIN}"
echo -e " ${GREEN}3.${PLAIN} 卸载 ${YELLOW}X-R-A-Y${PLAIN}"
echo -e " ${GREEN}0.${PLAIN} 退出脚本"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
read -p " 请输入选择 [0-3]: " choice
case "$choice" in
	1)
	install_naray
	;;
	2)
	install_bbr
	;;
	3)
	rm_naray
	;;
	0)
	exit 1
	;;
	*)
	clear
	echo -e "${RED}请输入正确数字 [0-3]${PLAIN}"
	sleep 5s
	start_menu1
	;;
esac
}

# 在脚本开始时获取系统信息
get_system_info

# 启动主菜单
start_menu1