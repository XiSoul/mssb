#!/bin/bash

# 需要监听的目录
CONFIG_DIR="/mssb/mosdns"

# 使用 inotifywait 监听特定文件类型的变动
while true; do
  inotifywait -e modify,create,delete -r $CONFIG_DIR --include '.*\.(txt|yaml|json|srs|yml)$'
  echo "MosDNS 配置文件发生变化，重启 MosDNS 服务..."

  # 通过 supervisorctl 重启 MosDNS 服务
  supervisorctl restart mosdns
done
