#!/bin/bash

# 定义可修改的参数变量
DOWNLOADS_PATH="file:///opt/petalinux-cache/downloads-2020.2.2-k26"
SSTATE_FEEDS_PATH="/opt/petalinux-cache/sstate_arm_2020.2/arm"

# 配置文件路径
CONFIG_FILE="$1/project-spec/configs/config"
BSP_CONF_FILE="$1/project-spec/meta-user/conf/petalinuxbsp.conf"

# 新的配置值
NEW_PRE_MIRROR_URL="CONFIG_PRE_MIRROR_URL=\"$DOWNLOADS_PATH\""
NEW_SSTATE_FEEDS_URL="CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL=\"$SSTATE_FEEDS_PATH\""

# PREMIRRORS prepend 内容
PREMIRRORS_CONTENT="PREMIRRORS_prepend = \" \\
git://.*/.* $DOWNLOADS_PATH \\n \\ 
gitsm://.*/.* $DOWNLOADS_PATH \\n \\ 
ftp://.*/.* $DOWNLOADS_PATH \\n \\ 
http://.*/.* $DOWNLOADS_PATH \\n \\ 
https://.*/.* $DOWNLOADS_PATH \\n\""


# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件 $CONFIG_FILE 不存在."
    exit 1
fi

# 替换或添加 CONFIG_PRE_MIRROR_URL
if grep -q '^CONFIG_PRE_MIRROR_URL=' "$CONFIG_FILE"; then
    # 如果存在, 使用 sed 替换配置值
    sed -i 's|^CONFIG_PRE_MIRROR_URL=.*|'"$NEW_PRE_MIRROR_URL"'|'  "$CONFIG_FILE"
else
    # 如果不存在, 添加新的配置项
    echo "$NEW_PRE_MIRROR_URL" >> "$CONFIG_FILE"
fi

# 替换或添加 CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL
if grep -q '^CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL=' "$CONFIG_FILE"; then
    # 如果存在, 使用 sed 替换配置值
    sed -i 's|^CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL=.*|'"$NEW_SSTATE_FEEDS_URL"'|' "$CONFIG_FILE"
else
    # 如果不存在, 添加新的配置项
    echo "$NEW_SSTATE_FEEDS_URL" >> "$CONFIG_FILE"
fi

# 确认替换或添加是否成功
if grep -q "$NEW_PRE_MIRROR_URL" "$CONFIG_FILE" && grep -q "$NEW_SSTATE_FEEDS_URL" "$CONFIG_FILE"; then
    echo "配置文件已成功更新."
else
    echo "配置文件更新失败."
    exit 1
fi

# 检查 BSP 配置文件是否存在
if [ ! -f "$BSP_CONF_FILE" ]; then
    echo "BSP配置文件 $BSP_CONF_FILE 不存在."
    exit 1
fi

# 添加 PREMIRRORS_prepend 内容到 BSP 配置文件
if ! grep -q '^PREMIRRORS_prepend' "$BSP_CONF_FILE"; then
    cat << EOF >> "$BSP_CONF_FILE"
$PREMIRRORS_CONTENT
EOF
    echo "已将 PREMIRRORS_prepend 内容添加到 BSP 配置文件."
else
    echo "BSP 配置文件中已存在 PREMIRRORS_prepend 内容."
fi

# 确认添加是否成功
if grep -q "^PREMIRRORS_prepend" "$BSP_CONF_FILE"; then
    echo "BSP 配置文件已成功更新."
else
    echo "BSP 配置文件更新失败."
    exit 1
fi
