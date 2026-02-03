#!/bin/bash
# 脚本功能：自动执行CSDN爬虫脚本 + Git提交推送
# 日志文件路径（记录执行过程，方便排查问题）
LOG_FILE="/root/Project/Lvyizhuo.github.io/auto_update_blog.log"
# 项目根目录（务必替换为你的实际路径）
PROJECT_DIR="/root/Project/Lvyizhuo.github.io"
# Python脚本路径
PYTHON_SCRIPT="${PROJECT_DIR}/scripts/fetch_csdn_articles.py"
# Python解释器绝对路径（避免crontab环境变量缺失，先执行 which python3 获取）
PYTHON_PATH=$(which python3)

# 日志格式化输出函数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> ${LOG_FILE}
}

# 第一步：初始化日志
log "========================================"
log "开始执行自动更新博客流程"

# 第二步：切换到项目根目录（关键，避免Git路径错误）
log "切换到项目目录：${PROJECT_DIR}"
cd ${PROJECT_DIR} || {
    log "ERROR: 切换到项目目录失败！"
    exit 1
}

# 第三步：执行Python爬虫脚本
log "开始执行爬虫脚本：${PYTHON_SCRIPT}"
${PYTHON_PATH} ${PYTHON_SCRIPT} >> ${LOG_FILE} 2>&1
# 检查脚本执行是否成功
if [ $? -eq 0 ]; then
    log "爬虫脚本执行成功"
else
    log "ERROR: 爬虫脚本执行失败！"
    exit 1
fi

# 第四步：Git添加所有更改到缓存区
log "执行git add ."
git add . >> ${LOG_FILE} 2>&1
if [ $? -eq 0 ]; then
    log "Git添加缓存区成功"
else
    log "ERROR: Git添加缓存区失败！"
    exit 1
fi

# 第五步：Git提交（带日期的提交信息）
COMMIT_MSG="自动更新博客 $(date +'%Y-%m-%d %H:%M:%S')"
log "执行git commit -m '${COMMIT_MSG}'"
# 检查是否有实际更改，避免空提交
git diff --quiet && git diff --staged --quiet
if [ $? -eq 1 ]; then
    # 有更改才提交
    git commit -m "${COMMIT_MSG}" >> ${LOG_FILE} 2>&1
    if [ $? -eq 0 ]; then
        log "Git提交成功，提交信息：${COMMIT_MSG}"
    else
        log "ERROR: Git提交失败！"
        exit 1
    fi
else
    log "无文件更改，跳过Git提交步骤"
fi

# 第六步：推送到远程仓库（确保已配置SSH免密）
log "执行git push origin main"
git push origin main >> ${LOG_FILE} 2>&1
if [ $? -eq 0 ]; then
    log "Git推送到远程仓库成功"
else
    log "ERROR: Git推送失败！请检查SSH免密配置或网络"
    exit 1
fi

# 完成
log "自动更新博客流程执行完毕"
log "========================================\n"

exit 0
