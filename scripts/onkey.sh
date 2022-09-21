#!/bin/bash
[[ $(id -u) != 0 ]] && echo -e "使用su命令切换到root用户再运行" && exit 1

cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
    if [[ $(command -v yum) ]]; then
        cmd="yum"
    fi
else
    echo "不支持此系统" && exit 1
fi

install() {
    if [ -f "/root/vinerProxy/vinerProxy" ]; then
        echo -e "您已下载了vinerProxy，重新运行此脚本，并选2.卸载->1.安装" && exit 1
    fi
    if screen -list | grep -q "vinerProxy"; then
        echo -e "vinerProxy已在运行中，请选6.停止->2.卸载->1.安装" && exit 1
    fi

    $cmd update -y
    $cmd install curl wget screen -y
    mkdir /root/vinerProxy
	chmod 777 /root/vinerProxy

    wget https://raw.githubusercontent.com/vinerproxy/VinerProxy/master/release/vtProxy -O /root/vinerProxy/vinerProxy
	
	
    chmod 777 /root/vinerProxy/vinerProxy

    start
}

install100() {
    if [ -f "/root/vinerProxy/vinerProxy" ]; then
        echo -e "您已下载了vinerProxy，重新运行此脚本，并选2.卸载->1.安装" && exit 1
    fi
    if screen -list | grep -q "vinerProxy"; then
        echo -e "vinerProxy已在运行中，请选6.停止->2.卸载->1.安装" && exit 1
    fi

    $cmd update -y
    $cmd install curl wget screen -y
    mkdir /root/vinerProxy
	chmod 777 /root/vinerProxy

    wget https://raw.githubusercontent.com/vinerproxy/VinerProxy/master/release/vtProxy100 -O /root/vinerProxy/vinerProxy
	
	
    chmod 777 /root/vinerProxy/vinerProxy

    if screen -list | grep -q "vinerProxy"; then
        echo -e "vinerProxy已启动" && exit 1
    fi
    echo "正在启动..."
    screen -dmS vinerProxy
    sleep 0.2s
    screen -r vinerProxy -p 0 -X stuff "cd /root/vinerProxy"
    screen -r vinerProxy -p 0 -X stuff $'\n'
    screen -r vinerProxy -p 0 -X stuff "./vinerProxy"
    screen -r vinerProxy -p 0 -X stuff $'\n'
    sleep 5s
    cat /root/vinerProxy/configV6.yml
    echo "已启动web后台 您可: screen -r vinerProxy 查看程序输出;CTRL+A+D退出screen"
}

uninstall() {
    read -p "是否确认删除vinerProxy[yes/no]：" flag
    if [ -z $flag ]; then
        echo "输入错误" && exit 1
    else
        if [ "$flag" = "yes" -o "$flag" = "ye" -o "$flag" = "y" ]; then
            screen -X -S vinerProxy quit
		rm /root/vinerProxy/vinerProxy
            echo "卸载vinerProxy成功"
        fi
    fi
}

update() {
    stop
	uninstall
	install
	start
}

start() {
    if screen -list | grep -q "vinerProxy"; then
        echo -e "vinerProxy已启动" && exit 1
    fi
    echo "正在启动..."
    screen -dmS vinerProxy
    sleep 0.2s
    screen -r vinerProxy -p 0 -X stuff "cd /root/vinerProxy"
    screen -r vinerProxy -p 0 -X stuff $'\n'
    screen -r vinerProxy -p 0 -X stuff "./vinerProxy"
    screen -r vinerProxy -p 0 -X stuff $'\n'
    sleep 5s
    cat /root/vinerProxy/config.json
    echo "已启动web后台 您可: screen -r vinerProxy 查看程序输出;CTRL+A+D退出screen"
}

restart() {
    stop
    start
}

stop() {
    if screen -list | grep -q "vinerProxy"; then
        screen -X -S vinerProxy quit
    fi
    echo "vinerProxy 已停止"
}

change_limit(){
    echo -n "当前连接数限制："
    num="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 102400" >>/etc/security/limits.conf
        num="y"
    fi

    if [[ "$num" = "y" ]]; then
        echo "连接数限制已修改为102400,重启服务器后生效"
    else
        echo -n "当前连接数限制："
        ulimit -n
    fi
}


echo "======================================================="
echo "vinerProxy 一键工具"
echo "  1、安装(默认安装到/root/vinerProxy)"
echo "  2、卸载"
echo "  3、更新"
echo "  4、启动"
echo "  5、重启"
echo "  6、停止"
echo "  7、解除连接数限制"
echo "  8、安装并启动100版本"
echo "======================================================="
read -p "$(echo -e "请选择[1-8]：")" choose
case $choose in
1)
    install
    ;;
2)
    uninstall
    ;;
3)
    update
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
    change_limit
    ;;
8)
    install100
    ;;
*)
    echo "输入错误请重新输入！"
    ;;
esac
