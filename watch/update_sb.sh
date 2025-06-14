#!/bin/bash

# 定义颜色变量
yellow="\033[33m"
green="\033[32m"
reset="\033[0m"

log() {
    echo -e "[$(date +'%F %T')] $*"
}

# 检测系统 CPU 架构
detect_architecture() {
    case "$(uname -m)" in
        x86_64)     echo "amd64" ;;
        aarch64)    echo "arm64" ;;
        armv7l)     echo "armv7" ;;
        armhf)      echo "armhf" ;;
        s390x)      echo "s390x" ;;
        i386|i686)  echo "386" ;;
        *)
            echo -e "${yellow}不支持的CPU架构: $(uname -m)${reset}"
            exit 1
            ;;
    esac
}

# 主体流程
main() {
    log "开始更新 Sing-box..."

    # 获取当前核心类型
    if [ -f "/mssb/sing-box/core_type" ]; then
        core_type=$(cat "/mssb/sing-box/core_type")
    else
        log "未找到核心类型记录，默认使用 reF1nd佬 R核心"
        core_type="sing-box-reF1nd"
    fi

    arch=$(detect_architecture)
    
    # 根据核心类型选择下载地址
    case "$core_type" in
        "sing-box-reF1nd")
            SING_BOX_URL="https://ghproxylist.com/https://github.com/herozmy/StoreHouse/releases/download/sing-box-reF1nd/sing-box-reF1nd-dev-linux-${arch}.tar.gz"
            log "当前使用 reF1nd佬 R核心，准备更新..."
            ;;
        "sing-box-yelnoo")
            SING_BOX_URL="https://ghproxylist.com/https://github.com/herozmy/StoreHouse/releases/download/sing-box-yelnoo/sing-box-yelnoo-linux-${arch}.tar.gz"
            log "当前使用 S佬Y核心，准备更新..."
            ;;
        *)
            log "未知的核心类型：$core_type，退出更新"
            exit 1
            ;;
    esac

    log "正在从 $SING_BOX_URL 下载 Sing-box..."
    if wget -O /tmp/sing-box.tar.gz "$SING_BOX_URL"; then
        log "Sing-box 下载成功。"
    else
        log "Sing-box 下载失败，请检查网络连接或 URL 是否正确。"
        exit 1
    fi

    log "正在解压 Sing-box..."
    if tar -zxvf /tmp/sing-box.tar.gz -C /usr/local/bin; then
        log "Sing-box 解压成功。"
    else
        log "Sing-box 解压失败，请检查压缩包是否正确。"
        exit 1
    fi

    log "设置 Sing-box 可执行权限..."
    if chmod +x /usr/local/bin/sing-box; then
        log "设置执行权限成功。"
    else
        log "设置执行权限失败，请检查文件路径和权限。"
        exit 1
    fi

    # 更新 UI
    log "准备更新 UI..."
    mkdir -p /mssb/sing-box/ui/
    rm -rf /tmp/ui
    if git clone --depth=1 https://ghproxylist.com/https://github.com/Zephyruso/zashboard.git -b gh-pages /tmp/ui; then
        cp -r /tmp/ui/* /mssb/sing-box/ui/
        log "UI 文件克隆并复制成功。"
    else
        log "UI 文件克隆失败，请检查 GitHub URL 或网络连接。"
        exit 1
    fi

    # 重启服务
    log "正在通过 Supervisor 重启 Sing-box 服务..."
    if supervisorctl restart sing-box && systemctl restart sing-box-router; then
        log "Sing-box 服务重启成功。"
    else
        log "Sing-box 服务重启失败，请检查 Supervisor 配置。"
        exit 1
    fi

    # 清理临时文件
    rm -rf /tmp/*
    log "${green}Sing-box 更新完成，临时文件已清理。${reset}"
}

# 执行主函数
main
