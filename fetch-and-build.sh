#!/bin/bash
# DailyCuration 远程编译脚本
# 使用方法：在配置了 DevEco Studio 的电脑上运行此脚本

set -e

REMOTE_HOST="你的服务器IP"
REMOTE_USER="root"
REMOTE_PATH="/root/.openclaw/workspace-fs1/harmony/DailyCuration-IDE"
LOCAL_PROJECT_DIR="$HOME/DailyCuration-IDE"

echo "=================================="
echo "DailyCuration 远程编译脚本"
echo "=================================="

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. 从远程服务器拉取项目
echo -e "${YELLOW}[1/4] 从远程拉取项目...${NC}"
if command -v rsync &> /dev/null; then
    rsync -avz --progress "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/" "$LOCAL_PROJECT_DIR/"
else
    scp -r "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/*" "$LOCAL_PROJECT_DIR/"
fi
echo -e "${GREEN}✓ 项目拉取完成${NC}"

# 2. 打开 DevEco Studio
echo -e "${YELLOW}[2/4] 打开 DevEco Studio...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open -a "DevEco Studio" "$LOCAL_PROJECT_DIR"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    "C:\Program Files\Huawei\DevEco Studio\bin\deveco64.exe" "$LOCAL_PROJECT_DIR"
else
    # Linux
    deveco-studio "$LOCAL_PROJECT_DIR" &
fi
echo -e "${GREEN}✓ DevEco Studio 已启动${NC}"

# 3. 等待用户配置签名
echo -e "${YELLOW}[3/4] 请手动配置签名...${NC}"
echo "步骤："
echo "  1. File → Project Structure → Signing Configs"
echo "  2. 勾选 'Automatically generate signature'"
echo "  3. 点击 Apply → OK"
echo ""
read -p "配置完成后按回车继续..."

# 4. 编译
echo -e "${YELLOW}[4/4] 开始编译...${NC}"
cd "$LOCAL_PROJECT_DIR"

if command -v hvigor &> /dev/null; then
    hvigor clean
    hvigor assembleHap --mode release
else
    echo "请使用 DevEco Studio 编译："
    echo "  Build → Build Hap(s)/APP(s) → Build Hap(s)"
fi

echo ""
echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}编译完成!${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""
echo "HAP 文件位置："
echo "  $LOCAL_PROJECT_DIR/entry/build/default/outputs/default/entry-default-signed.hap"
echo ""
echo "安装到手机："
echo "  hdc install entry/build/default/outputs/default/entry-default-signed.hap"