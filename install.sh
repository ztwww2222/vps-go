#!/bin/bash

# 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 无色

# 全局变量
FLIE_PATH="${PWD}/worlds/"
NE_FILE='nenether.js'
CFF_FILE='cfnfph.js'
WEB_FILE='webssp.js'

# 实用函数
print_centered() {
  printf "%*s\n" $(( (${#1} + COLUMNS) / 2)) "$1"
}

print_line() {
  printf "%*s\n" "${COLUMNS:-$(tput cols)}" '' | tr ' ' '='
}

print_status() {
  echo -e "${BLUE}[*] $1${NC}"
}

print_success() {
  echo -e "${GREEN}[+] $1${NC}"
}

print_error() {
  echo -e "${RED}[-] $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}[!] $1${NC}"
}

# 主要函数
install_naray() {
  print_status "开始安装 X-R-A-Y..."

  if [[ $PWD == */ ]]; then
    FLIE_PATH="${PWD}worlds/"
  else
    FLIE_PATH="${PWD}/worlds/"
  fi

  if [ ! -d "${FLIE_PATH}" ]; then
    if mkdir -p -m 755 "${FLIE_PATH}"; then
      print_success "创建目录: ${FLIE_PATH}"
    else 
      print_warning "无法创建目录，尝试继续..."
    fi
  fi

  install_config
  install_start
}

install_config() {
  print_status "配置 X-R-A-Y..."

  read -p "请输入节点使用的协议 (vls/vms/rel, 默认: rel): " TMP_ARGO
  TMP_ARGO=${TMP_ARGO:-'rel'}

  if [ "${TMP_ARGO}" == "rel" ]; then 
    read -p "请输入节点端口 (默认: 443): " SERVER_PORT
    SERVER_POT=${SERVER_PORT:-"443"}
  fi

  read -p "请输入节点上传地址: " SUB_URL
  read -p "请输入节点名称 (默认: vps): " SUB_NAME
  SUB_NAME=${SUB_NAME:-"vps"}

  read -p "请输入 NEZHA_SERVER (可选): " NEZHA_SERVER
  read -p "请输入 NEZHA_KEY (可选): " NEZHA_KEY
  read -p "请输入 NEZHA_PORT (默认: 443): " NEZHA_PORT
  NEZHA_PORT=${NEZHA_PORT:-"443"}

  read -p "是否开启哪吒的 TLS？(1/0, 默认: 1): " NEZHA_TLS
  NEZHA_TLS=${NEZHA_TLS:-"1"}

  if [ "${TMP_ARGO}" != "rel" ]; then
    read -p "请输入固定隧道 token 或 JSON (可选): " TOK
    read -p "请输入隧道域名 (固定隧道必填): " ARGO_DOMAIN
    read -p "请输入 CF 优选 IP (默认: ip.sb): " CF_IP
    CF_IP=${CF_IP:-"ip.sb"}
  fi
}

install_start() {
  print_status "创建启动脚本..."

  cat <<EOL > "${FLIE_PATH}start.sh"
#!/bin/bash

export TOK='$TOK'
export ARGO_DOMAIN='$ARGO_DOMAIN'
export NEZHA_SERVER='$NEZHA_SERVER'
export NEZHA_KEY='$NEZHA_KEY'
export NEZHA_PORT='$NEZHA_PORT'
export NEZHA_TLS='$NEZHA_TLS'
export TMP_ARGO='${TMP_ARGO:-vls}'
export SERVER_PORT="${SERVER_PORT:-\${PORT:-443}}"
export SNI='www.apple.com'
export FLIE_PATH='$FLIE_PATH'
export CF_IP='$CF_IP'
export SUB_NAME='$SUB_NAME'
export SERVER_IP='$SERVER_IP'
export SUB_URL='$SUB_URL'
export ne_file='$NE_FILE'
export cff_file='$CFF_FILE'
export web_file='$WEB_FILE'

if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -sL"
elif command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "警告: 未找到 curl 或 wget。尝试继续..."
fi

arch=\$(uname -m)
if [[ \$arch == "x86_64" ]]; then
    \$DOWNLOAD_CMD https://github.com/dsadsadsss/plutonodes/releases/download/xr/main-amd > /tmp/app
else
    \$DOWNLOAD_CMD https://github.com/dsadsadsss/plutonodes/releases/download/xr/main-arm > /tmp/app
fi

chmod 777 /tmp/app && /tmp/app
EOL

  chmod +x "${FLIE_PATH}start.sh"
  print_success "启动脚本创建成功"
}

check_and_install_dependencies() {
  print_status "检查并安装依赖..."

  local dependencies=("curl" "pgrep" "wget" "systemctl" "libcurl4")

  for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      print_warning "$dep 未安装。尝试安装..."
      case "$linux_dist" in
        "Alpine Linux")
          apk update && apk add "$dep" || print_warning "无法安装 $dep，尝试继续..."
          ;;
        "Ubuntu" | "Debian" | "Kali Linux")
          apt-get update && apt-get install -y "$dep" || print_warning "无法安装 $dep，尝试继续..."
          ;;
        "CentOS")
          yum install -y "$dep" || print_warning "无法安装 $dep，尝试继续..."
          ;;
        *)
          print_warning "不支持的 Linux 发行版: $linux_dist，尝试继续..."
          ;;
      esac
    fi
  done

  print_success "依赖检查完成"
}

configure_startup() {
  print_status "配置开机启动..."

  check_and_install_dependencies
  if [ -s "${FLIE_PATH}start.sh" ]; then
    rm_naray
  fi
  install_config
  install_start

  case "$linux_dist" in
    "Alpine Linux" | "Kali Linux")
      nohup "${FLIE_PATH}start.sh" >/dev/null 2>&1 &
      echo "${FLIE_PATH}start.sh" | tee -a /etc/rc.local > /dev/null
      chmod +x /etc/rc.local
      ;;
    "Ubuntu" | "Debian" | "CentOS")
      cat <<EOL > my_script.service
[Unit]
Description=X-R-A-Y 启动脚本

[Service]
ExecStart=${FLIE_PATH}start.sh
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOL
      mv my_script.service /etc/systemd/system/
      systemctl enable my_script.service
      systemctl start my_script.service
      ;;
    *)
      print_warning "不支持的 Linux 发行版: $linux_dist，尝试继续..."
      ;;
  esac

  print_status "正在启动 X-R-A-Y..."
  wait_for_startup
}

wait_for_startup() {
  local max_attempts=5
  local counter=0

  while [ $counter -lt $max_attempts ]; do
    if (pgrep -f "$WEB_FILE" > /dev/null || ps aux | grep "$WEB_FILE" | grep -v grep > /dev/null) && [ -s /tmp/list.log ]; then
      print_success "X-R-A-Y 启动成功"
      display_node_info
      return 0
    else
      print_warning "等待 X-R-A-Y 启动，尝试 $((counter+1))/$max_attempts..."
      sleep 10
      ((counter++))
    fi
  done

  print_warning "X-R-A-Y 未能在预期时间内启动，但可能仍在后台运行"
  return 1
}

display_node_info() {
  print_line
  print_centered "节点信息"
  print_line
  echo

  if [ -s "${FLIE_PATH}list.log" ]; then
    sed 's/{PASS}/vless/g' "${FLIE_PATH}list.log"
  elif [ -s "/tmp/list.log" ]; then
    sed 's/{PASS}/vless/g' /tmp/list.log
  else
    print_warning "未找到节点信息，但 X-R-A-Y 可能仍在运行"
  fi

  echo
  print_line
}

install_bbr() {
  print_status "安装 BBR..."

  if command -v curl &>/dev/null; then
    bash <(curl -sL https://git.io/kernel.sh)
  elif command -v wget &>/dev/null; then
    bash <(wget -qO- https://git.io/kernel.sh)
  else
    print_warning "未找到 curl 或 wget。无法安装 BBR。"
    sleep 5
  fi
}

rm_naray() {
  print_status "移除 X-R-A-Y..."

  local service_name="my_script.service"

  if systemctl is-active --quiet $service_name; then
    print_status "停止 $service_name..."
    systemctl stop $service_name
  fi

  if systemctl is-enabled --quiet $service_name; then
    print_status "禁用 $service_name..."
    systemctl disable $service_name
  fi

  if [ -f "/etc/systemd/system/$service_name" ]; then
    print_status "移除服务文件 /etc/systemd/system/$service_name..."
    rm "/etc/systemd/system/$service_name"
  elif [ -f "/lib/systemd/system/$service_name" ]; then
    print_status "移除服务文件 /lib/systemd/system/$service_name..."
    rm "/lib/systemd/system/$service_name"
  fi

  print_status "重新加载 systemd..."
  systemctl daemon-reload

  if [ -d "${FLIE_PATH}" ]; then
    rm -rf "${FLIE_PATH}"
  fi
  if [ -d "/tmp/worlds/" ]; then
    rm -rf "/tmp/worlds/"
  fi

  local processes=("$WEB_FILE" "$NE_FILE" "$CFF_FILE" "app" "app.js")
  for process in "${processes[@]}"; do
    pkill -f "$process" &>/dev/null
  done

  print_success "X-R-A-Y 移除完成"
}

temporary_start() {
  print_status "临时启动 X-R-A-Y..."
  install_config
  install_start
  nohup "${FLIE_PATH}start.sh" >/dev/null 2>&1 &
  wait_for_startup
}

show_menu() {
  clear
  echo -e "${CYAN}"
  print_line
  print_centered "X-R-A-Y 安装菜单"
  print_line
  echo -e "${NC}"
  echo
  echo -e "${YELLOW}1.${NC} 安装 X-R-A-Y（开机启动）"
  echo -e "${YELLOW}2.${NC} 临时启动 X-R-A-Y"
  echo -e "${YELLOW}3.${NC} 安装 BBR 加速"
  echo -e "${YELLOW}4.${NC} 卸载 X-R-A-Y"
  echo -e "${YELLOW}0.${NC} 退出"
  echo
  echo -e "${CYAN}"
  print_line
  echo -e "${NC}"
}

# 确定 Linux 发行版
linux_dist=$(. /etc/os-release && echo "$NAME")

# 主菜单循环
while true; do
  show_menu
  read -p "请输入您的选择 [0-4]: " choice
  case $choice in
    1) configure_startup ;;
    2) temporary_start ;;
    3) install_bbr ;;
    4) rm_naray ;;
    0) exit 0 ;;
    *) print_warning "无效选项。请重试。" ;;
  esac
  read -p "按回车键继续..."
done