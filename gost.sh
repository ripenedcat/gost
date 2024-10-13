#! /bin/bash
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
shell_version="91wa_1.0.0"
gost_conf_path="/etc/gost/config.json"
raw_conf_path="/etc/gost/rawconf"
function checknew() {
  checknew=$(gost -V 2>&1 | awk '{print $2}')
  check_new_ver
  echo "你的gost版本为:""$checknew"""
  echo -n 是否更新\(y/n\)\:
  read checknewnum
  if test $checknewnum = "y"; then
    cp -r /etc/gost /tmp/
    Install_ct
    rm -rf /etc/gost
    mv /tmp/gost /etc/
    systemctl restart gost
  else
    exit 0
  fi
}
function check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  fi
  bit=$(uname -m)
  if test "$bit" != "x86_64"; then
    echo "请输入你的芯片架构，/386/armv5/armv6/armv7/armv8"
    read bit
  else
    bit="amd64"
  fi
}
function Installation_dependency() {
  gzip_ver=$(gzip -V)
  if [[ -z ${gzip_ver} ]]; then
    if [[ ${release} == "centos" ]]; then
      yum update
      yum install -y gzip wget
    else
      apt-get update
      apt-get install -y gzip wget
    fi
  fi
}
function check_root() {
  [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
function check_new_ver() {
  ct_new_ver=$(wget --no-check-certificate -qO- -t2 -T3 https://api.github.com/repos/ginuerzh/gost/releases/latest | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g;s/v//g')
  if [[ -z ${ct_new_ver} ]]; then
    ct_new_ver="2.11.2"
    echo -e "${Error} gost 最新版本获取失败，正在下载v${ct_new_ver}版"
  else
    ct_new_ver="2.11.2"
    echo -e "${Info} gost 目前最新版本为 ${ct_new_ver}"
  fi
}
function check_file() {
  if test ! -d "/usr/lib/systemd/system/"; then
    mkdir /usr/lib/systemd/system
    chmod -R 777 /usr/lib/systemd/system
  fi
}
function check_nor_file() {
  rm -rf "$(pwd)"/gost
  rm -rf "$(pwd)"/gost.service
  rm -rf "$(pwd)"/config.json
  rm -rf /etc/gost
  rm -rf /usr/lib/systemd/system/gost.service
  rm -rf /usr/bin/gost
}
function Install_ct() {
  check_root
  check_nor_file
  Installation_dependency
  check_file
  check_sys
  check_new_ver
  rm -rf gost-linux-"$bit"-"$ct_new_ver".gz
  wget --no-check-certificate https://github.com/ginuerzh/gost/releases/download/v"$ct_new_ver"/gost-linux-"$bit"-"$ct_new_ver".gz
  gunzip gost-linux-"$bit"-"$ct_new_ver".gz
  mv gost-linux-"$bit"-"$ct_new_ver" gost
  mv gost /usr/bin/gost
  chmod -R 777 /usr/bin/gost
  wget --no-check-certificate https://91wa.net/gost/gost.service && chmod -R 777 gost.service && mv gost.service /usr/lib/systemd/system
  mkdir /etc/gost && wget --no-check-certificate https://91wa.net/gost//config.json && mv config.json /etc/gost && chmod -R 777 /etc/gost

  systemctl enable gost && systemctl restart gost
  echo "------------------------------"
  if test -a /usr/bin/gost -a /usr/lib/systemctl/gost.service -a /etc/gost/config.json; then
    echo "gost安装成功并已启动---91wa.net"
    rm -rf "$(pwd)"/gost
    rm -rf "$(pwd)"/gost.service
    rm -rf "$(pwd)"/config.json
    systemctl start gost
  else
    echo "gost没有安装成功---91wa.net"
    rm -rf "$(pwd)"/gost
    rm -rf "$(pwd)"/gost.service
    rm -rf "$(pwd)"/config.json
    rm -rf "$(pwd)"/gost.sh
  fi
}
function Uninstall_ct() {
  rm -rf /usr/bin/gost
  rm -rf /usr/lib/systemd/system/gost.service
  rm -rf /etc/gost
  rm -rf "$(pwd)"/gost.sh
  echo "gost已经成功删除---91wa.net"
}
function Start_ct() {
  systemctl start gost
  echo "已启动---91wa.net"
}
function Stop_ct() {
  systemctl stop gost
  echo "已停止---91wa.net"
}
function Restart_ct() {
  systemctl restart gost
  echo "已重启Gost---91wa.net"
}


update_sh() {
  ol_version=$(curl -L -s --connect-timeout 5 https://91wa.net/gost/gost.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
  if [ -n "$ol_version" ]; then
    if [[ "$shell_version" != "$ol_version" ]]; then
      echo -e "存在新版本，是否更新 [Y/N]?"
      read -r update_confirm
      case $update_confirm in
      [yY][eE][sS] | [yY])
        wget -N --no-check-certificate https://91wa.net/gost/gost.sh
        echo -e "更新完成"
        exit 0
        ;;
      *) ;;

      esac
    else
      echo -e "                 ${Green_font_prefix}当前版本为最新版本！${Font_color_suffix}"
    fi
  else
    echo -e "                 ${Red_font_prefix}脚本最新版本获取失败，请检查与github的连接！${Font_color_suffix}"
  fi
}

update_sh
echo && echo -e "-----------gost一键安装配置脚本"${Red_font_prefix}[${shell_version}]${Font_color_suffix}"
  ----------- 91wa.net -----------
  特性: (1)采用systemd及gost配置文件对gost进行管理。
        (2)能够在不借助其他工具(如screen，nohup)的情况下实现关闭Shell窗口程序继续运行。
        (3)机器reboot后转发不失效。
  功能: (1)配置用户认证方式，来解密对接转发矿池流量。
        (2)矿池地址由Windows电脑配置文件控制。
  ----------- 91wa.net -----------
 ${Green_font_prefix}1.${Font_color_suffix} 安装 gost
 ${Green_font_prefix}2.${Font_color_suffix} 更新 gost
 ${Green_font_prefix}3.${Font_color_suffix} 卸载 gost
  ----------- 91wa.net -----------
 ${Green_font_prefix}4.${Font_color_suffix} 启动 gost
 ${Green_font_prefix}5.${Font_color_suffix} 停止 gost
 ${Green_font_prefix}6.${Font_color_suffix} 重启 gost
————————————
 ----------- 91wa.net -----------
————————————" && echo
read -e -p " 请输入数字 [1-6]:" num
case "$num" in
1)
  Install_ct
  ;;
2)
  checknew
  ;;
3)
  Uninstall_ct
  ;;
4)
  Start_ct
  ;;
5)
  Stop_ct
  ;;
6)
  Restart_ct
  ;;
*)
  echo "请输入正确数字 [1-6]"
  ;;
esac
