#!/bin/bash
# ============================================================
# CSDN 博客一键同步脚本
# 功能：抓取 CSDN 文章 + 自动提交推送到 GitHub
# 使用方法：./scripts/sync_blog.sh
# ============================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 切换到项目根目录
cd "$PROJECT_ROOT"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}           CSDN 博客一键同步工具${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# 检查是否有未提交的更改
echo -e "${YELLOW}📋 检查 Git 状态...${NC}"
if ! git diff --quiet HEAD 2>/dev/null; then
    echo -e "${YELLOW}⚠️  检测到未提交的更改，请先处理后再运行同步${NC}"
    git status --short
    echo ""
    read -p "是否继续？这可能会将其他更改一起提交 (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ 已取消${NC}"
        exit 1
    fi
fi

# 拉取最新代码
echo -e "${YELLOW}📥 拉取最新代码...${NC}"
git pull origin main --rebase || {
    echo -e "${RED}❌ 拉取失败，请手动解决冲突${NC}"
    exit 1
}
echo -e "${GREEN}✅ 代码已更新${NC}"
echo ""

# 运行爬虫脚本
echo -e "${YELLOW}🕷️  开始抓取 CSDN 文章...${NC}"
echo ""

# 检测 Python 命令
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}❌ 未找到 Python，请先安装 Python${NC}"
    exit 1
fi

# 执行爬虫
$PYTHON_CMD "$SCRIPT_DIR/fetch_csdn_articles.py"
CRAWLER_EXIT_CODE=$?

echo ""

if [ $CRAWLER_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}❌ 爬虫执行失败${NC}"
    exit 1
fi

# 检查是否有文件变更
echo -e "${YELLOW}🔍 检查文件变更...${NC}"
if git diff --quiet _data/csdn_posts.yml 2>/dev/null; then
    echo -e "${GREEN}✅ 文章数据没有变化，无需更新${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}🎉 同步完成！（无更新）${NC}"
    echo -e "${BLUE}============================================================${NC}"
    exit 0
fi

# 显示变更统计
echo -e "${GREEN}📝 检测到文章数据变更：${NC}"
git diff --stat _data/csdn_posts.yml
echo ""

# 获取当前时间作为提交信息
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# 提交更改
echo -e "${YELLOW}📤 提交更改...${NC}"
git add _data/csdn_posts.yml
git commit -m "📝 更新 CSDN 博客文章 [$TIMESTAMP]"
echo -e "${GREEN}✅ 已提交${NC}"
echo ""

# 推送到 GitHub
echo -e "${YELLOW}🚀 推送到 GitHub...${NC}"
git push origin main || {
    echo -e "${RED}❌ 推送失败，可能需要先拉取更新${NC}"
    echo -e "${YELLOW}尝试重新拉取并推送...${NC}"
    git pull origin main --rebase
    git push origin main || {
        echo -e "${RED}❌ 推送仍然失败，请手动处理${NC}"
        exit 1
    }
}
echo -e "${GREEN}✅ 已推送${NC}"

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}🎉 博客同步完成！${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "📊 提交时间: ${TIMESTAMP}"
echo -e "🔗 GitHub: https://github.com/Lvyizhuo/Lvyizhuo.github.io"
echo -e "🌐 网站将在几分钟后自动更新"
echo ""
