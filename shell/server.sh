#!/bin/bash
# 一键查看服务器利用率
# CPU 60% 超过变慢 处理后续请求时间长
# MEM 利用率 响应慢 拒绝请求
# DISK 利用率
# TCP 连接状态

function cpu() {
    util=$(vmstat | awk '{if(NR==3)print $13+$14}')
    iowait=$(vmstat | awk '{if(NR==3)print $16}')
    echo "CPU - 使用率：${util}%，等待磁盘IO使用响应率：${iowait}%"
}

function memory() {
    total=$(free -m | awk '{if(NR==2)printf "%.1f",$2/1024}')
    used=$(free -m | awk '{if(NR==2)printf "%.1f",($2-$NF)/1024}')
    available=$(free -m | awk '{if(NR==2)printf "%.1f",$NF/1024}')
    echo "内存 - 总大小：${total}G，已使用：${used}G，剩余：${available}G"
}

disk() {
    fs=$(df -h | awk '/^\/dev/{print $1}')
    for p in $fs; do
        mounted=$(df -h | awk -v p=$p '$1==p{print $NF}')
        size=$(df -h | awk -v p=$p '$1==p{print $2}')
        used=$(df -h | awk -v p=$p '$1==p{print $3}')
        used_percent=$(df -h | awk -v p=$p '$1==p{print $5}')
        echo "硬盘 - 挂载点：$mounted，总大小：$size，已使用：$used，使用率：$used_percent"
    done
}

tcp_status() {
    tcp=$(netstat -antp | awk '{a[$6]++}END{for (i in a)printf i":"a[i]" "}')
    echo "TCP连接状态 - $tcp"
}

cpu
memory
disk
tcp_status