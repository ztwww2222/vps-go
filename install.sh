#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PLAIN='\033[0m'

# 输出带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${PLAIN} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${PLAIN} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${PLAIN} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${PLAIN} $1"
}

# 检查并安装依赖
check_and_install_dependencies() {
    dependencies=("curl" "pgrep" "wget" "systemctl")
    
    print_info "正在检查依赖..."
    
    for dep in "${dependencies[@]}"; do
        if command -v "$dep" &>/dev/null; then
            print_success "$dep 已安装"
        else
            print_warning "$dep 未安装，正在尝试安装..."
            case "$linux_dist" in
                "Alpine Linux")
                    apk update && apk add "$dep"
                    ;;
                "Ubuntu" | "Debian" | "Kali Linux")
                    apt-get update && apt-get install -y "$dep"
                    ;;
                "CentOS")
                    yum install -y "$dep"
                    ;;
                *)
                    print_error "不支持的 Linux 发行版：$linux_dist，程序将尝试启动"
                    
                    ;;
            esac
            
            if command -v "$dep" &>/dev/null; then
                print_success "$dep 安装成功"
            else
                print_error "$dep 安装失败，尝试启动"
                
            fi
        fi
    done
    
    print_success "所有依赖已安装"
    return 0
}

install_config() {
    print_info "正在配置节点..."

    read -p "请输入节点使用的协议 (可选vls,vms,rel,默认rel): " TMP_ARGO
    TMP_ARGO=${TMP_ARGO:-'rel'}
    UUID=${UUID:-"fd80f56e-93f3-4c85-b2a8-c77216c509a7"}
    VPATH='vls-flvlkc'

    if [ "${TMP_ARGO}" == "rel" ]; then 
        read -p "请输入节点端口 (默认443): " SERVER_PORT
        SERVER_PO=${SERVER_PORT:-"443"}
    fi

    read -p "请输入节点名称 (默认值：vps): " SUB_NAME
    SUB_NAME=${SUB_NAME:-"vps"}

    read -p "请输入 NEZHA_SERVER (不需要就不填): " NEZHA_SERVER
    read -p "请输入 NEZHA_KEY (不需要就不填): " NEZHA_KEY
    read -p "请输入 NEZHA_PORT (默认值：443): " NEZHA_PORT
    NEZHA_PORT=${NEZHA_PORT:-"443"}

    read -p "是否开启哪吒的tls (1开启,0关闭,默认开启): " NEZHA_TLS
    NEZHA_TLS=${NEZHA_TLS:-"1"}

    if [ "${TMP_ARGO}" != "rel" ]; then
        read -p "请输入固定隧道token或者json (不填则使用临时隧道): " TOK
        read -p "请输入隧道域名 (设置固定隧道后填写，临时隧道不需要): " ARGO_DOMAIN
        read -p "请输入CF优选IP (默认ip.sb): " CF_IP
        CF_IP=${CF_IP:-"ip.sb"}
    fi

    export ne_file=${ne_file:-'nenether.js'}
    export cff_file=${cff_file:-'cfnfph.js'}
    export web_file=${web_file:-'webssp.js'}

    if [[ $PWD == */ ]]; then
        FLIE_PATH="${FLIE_PATH:-${PWD}worlds/}"
    else
        FLIE_PATH="${FLIE_PATH:-${PWD}/worlds/}"
    fi

    print_success "配置完成"
}

install_start() {
    print_info "正在创建启动脚本..."

    if [ ! -d "${FLIE_PATH}" ]; then
        if mkdir -p -m 755 "${FLIE_PATH}"; then
            print_success "创建目录成功"
        else 
            print_error "权限不足，无法创建文件"
            return 1
        fi
    fi

    cat <<EOL > ${FLIE_PATH}start.sh
#!/bin/bash
export TOK='$TOK'
export ARGO_DOMAIN='$ARGO_DOMAIN'
export NEZHA_SERVER='$NEZHA_SERVER'
export NEZHA_KEY='$NEZHA_KEY'
export NEZHA_PORT='$NEZHA_PORT'
export NEZHA_TLS='$NEZHA_TLS' 
export TMP_ARGO=${TMP_ARGO:-'vls'}
export SERVER_PORT="${SERVER_PORT:-${PORT:-443}}"
export SNI=${SNI:-'www.apple.com'}
export FLIE_PATH='$FLIE_PATH'
export CF_IP='$CF_IP'
export SUB_NAME='$SUB_NAME'
export SERVER_IP='$SERVER_IP'
export UUID='$UUID'
export VPATH='$VPATH'
export SUB_URL='$SUB_URL'
export ne_file='$ne_file'
export cff_file='$cff_file'
export web_file='$web_file'

if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -sL"
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

    chmod +x ${FLIE_PATH}start.sh
    print_success "启动脚本创建完成"
}

configure_startup() {
    print_info "正在配置开机启动..."
    
    check_and_install_dependencies || return 1
    # 检查是否存在旧的启动脚本
    if [ -f "${FLIE_PATH}start.sh" ]; then
        print_warning "检测到已存在的启动脚本，将先卸载旧版本..."
        rm_naray
    fi
    install_config
    install_start
    
    case "$linux_dist" in
        "Alpine Linux" | "Kali Linux")
            nohup ${FLIE_PATH}start.sh 2>/dev/null 2>&1 &
            echo "${FLIE_PATH}start.sh" | tee -a /etc/rc.local > /dev/null
            chmod +x /etc/rc.local
            ;;
        "Ubuntu" | "Debian" | "CentOS")
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
            cp my_script.service /etc/systemd/system/
            systemctl enable my_script.service
            systemctl start my_script.service
            ;;
        *)
            print_error "不支持的 Linux 发行版：$linux_dist"
            return 1
            ;;
    esac
    
    print_success "开机启动配置完成"
    
    print_info "等待脚本启动..."
    sleep 15
    keyword="$web_file"
    max_attempts=5
    counter=0

    while [ $counter -lt $max_attempts ]; do
        if command -v pgrep > /dev/null && pgrep -f "$keyword" > /dev/null && [ -s /tmp/list.log ]; then
            print_success "脚本启动成功"
            break
        elif ps aux | grep "$keyword" | grep -v grep > /dev/null && [ -s /tmp/list.log ]; then
            print_success "脚本启动成功"
            break
        else
            sleep 10
            ((counter++))
        fi
    done

    print_info "节点信息："
    if [ -s "${FLIE_PATH}list.log" ]; then
        sed 's/{PASS}/vless/g' ${FLIE_PATH}list.log | cat
    elif [ -s "/tmp/list.log" ]; then
        sed 's/{PASS}/vless/g' /tmp/list.log | cat
    fi

    
}

install_bbr() {
    print_info "正在安装BBR加速..."

    if command -v curl &>/dev/null; then
        bash <(curl -sL https://git.io/kernel.sh)
    elif command -v wget &>/dev/null; then
        bash <(wget -qO- https://git.io/kernel.sh)
    else
        print_error "Neither curl nor wget found. Please install one of them."
        sleep 30
    fi
}

rm_naray() {
    print_info "正在卸载X-R-A-Y..."

    service_name="my_script.service"

    if [ "$(systemctl is-active $service_name)" == "active" ]; then
        systemctl stop $service_name
        print_success "服务已停止"
    fi

    if [ "$(systemctl is-enabled $service_name)" == "enabled" ]; then
        systemctl disable $service_name
        print_success "服务已禁用"
    fi

    if [ -f "/etc/systemd/system/$service_name" ]; then
        rm "/etc/systemd/system/$service_name"
        print_success "服务文件已删除"
    elif [ -f "/lib/systemd/system/$service_name" ]; then
        rm "/lib/systemd/system/$service_name"
        print_success "服务文件已删除"
    else
        print_warning "未找到服务文件"
    fi

    systemctl daemon-reload
    print_success "Systemd已重新加载"

    if [[ $PWD == */ ]]; then
        FLIE_PATH="${FLIE_PATH:-${PWD}worlds/}"
    else
        FLIE_PATH="${FLIE_PATH:-${PWD}/worlds/}"
    fi
    
    if [ -d "${FLIE_PATH}" ]; then
        rm -rf ${FLIE_PATH}
    fi
    if [ -d "/tmp/worlds/" ]; then
        rm -rf /tmp/worlds/
    fi

    processes=("$web_file" "$ne_file" "$cff_file" "app" "app.js")
    for process in "${processes[@]}"
    do
        pid=$(pgrep -f "$process")
        if [ -n "$pid" ]; then
            kill "$pid"
            print_success "进程 $process 已终止"
        fi
    done

    print_success "X-R-A-Y 卸载完成"
}

start_menu() {
    echo -e "${CYAN}————————————选择菜单————————————${PLAIN}"
    echo -e "${YELLOW}1.${PLAIN} 安装 X-R-A-Y"
    echo -e "${YELLOW}2.${PLAIN} 安装 BBR 加速"
    echo -e "${YELLOW}3.${PLAIN} 卸载 X-R-A-Y"
    echo -e "${YELLOW}0.${PLAIN} 退出脚本"
    
    read -p "请输入数字 [0-3]: " choice
    
    case "$choice" in
        1) configure_startup ;;
        2) install_bbr ;;
        3) rm_naray ;;
        0) exit 0 ;;
        *) 
            print_error "请输入正确数字 [0-3]"
            sleep 2
            start_menu
            ;;
    esac
}

get_linux_dist() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ $ID == "alpine" ]]; then
            linux_dist="Alpine Linux"
        elif [[ $ID == "ubuntu" || $ID_LIKE == *"ubuntu"* ]]; then
            linux_dist="Ubuntu"
        elif [[ $ID == "debian" || $ID_LIKE == *"debian"* ]]; then
            linux_dist="Debian"
        elif [[ $ID == "centos" || $ID == "rhel" || $ID_LIKE == *"rhel"* ]]; then
            linux_dist="CentOS"
        elif [[ $ID == "kali" ]]; then
            linux_dist="Kali Linux"
        else
            linux_dist=$NAME
        fi
    else
        linux_dist=$(uname -s)
    fi
    print_info "检测到的 Linux 发行版: $linux_dist"
}

main() {
    get_linux_dist
    start_menu
}

main
