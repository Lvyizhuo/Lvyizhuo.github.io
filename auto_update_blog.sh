#!/bin/bash
# 脚本功能：自动执行CSDN爬虫脚本 + Git提交推送
# 日志文件路径（记录执行过程，方便排查问题）
LOG_FILE="/root/Project/Lvyizhuo.github.io/auto_update_blog.log"
# 项目根目录（务必替换为你的实际路径）
PROJECT_DIR="/root/Project/Lvyizhuo.github.io"
# Python脚本路径
PYTHON_SCRIPT="${PROJECT_DIR}/scripts/fetch_csdn_articles.py"

# 日志格式化输出函数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> ${LOG_FILE}
}

# 第一步：初始化日志
log "========================================"
log "开始执行自动更新博客流程"

# 第二步：激活conda base环境（核心修正：整合到脚本内+错误处理）
log "开始激活conda base环境..."
# 动态获取conda根路径（替代硬编码，更通用）
CONDA_BASE=$(conda info --base) || {
    log "ERROR: 获取conda根路径失败！请确认conda已正确安装"
    exit 1
}
# 加载conda配置
source "${CONDA_BASE}/etc/profile.d/conda.sh" || {
    log "ERROR: 加载conda配置文件失败！路径：${CONDA_BASE}/etc/profile.d/conda.sh"
    exit 1
}
# 激活base环境
conda activate base || {
    log "ERROR: 激活conda base环境失败！"
    exit 1
}
log "conda base环境激活成功"

# 第三步：指定base环境的Python路径（稳定替代which python3）
PYTHON_PATH="${CONDA_BASE}/bin/python"
log "当前使用的Python路径：${PYTHON_PATH}"
# 验证Python路径是否存在
if [ ! -f "${PYTHON_PATH}" ]; then
    log "ERROR: Python路径不存在！${PYTHON_PATH}"
    exit 1
fi

# 第四步：切换到项目根目录（关键，避免Git路径错误）
log "切换到项目目录：${PROJECT_DIR}"
cd ${PROJECT_DIR} || {
    log "ERROR: 切换到项目目录失败！"
    exit 1
}

# 第五步：执行Python爬虫脚本
log "开始执行爬虫脚本：${PYTHON_SCRIPT}"
${PYTHON_PATH} ${PYTHON_SCRIPT} >> ${LOG_FILE} 2>&1
# 检查脚本执行是否成功
if [ $? -eq 0 ]; then
    log "爬虫脚本执行成功"
else
    log "ERROR: 爬虫脚本执行失败！"
    exit 1
fi

# 第六步：Git添加所有更改到缓存区
log "执行git add ."
git add . >> ${LOG_FILE} 2>&1
if [ $? -eq 0 ]; then
    log "Git添加缓存区成功"
else
    log "ERROR: Git添加缓存区失败！"
    exit 1
fi

# 第七步：Git提交（带日期的提交信息）
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

# 第八步：推送到远程仓库（确保已配置SSH免密）
log "执行git push origin main"
git push origin main >> ${LOG_FILE} 2>&1
if [ $? -eq 0 ]; then
    log "Git推送到远程仓库成功"
else
    log "ERROR: Git推送失败！请检查SSH免密配置或网络"
    exit 1
fi

# 收尾：退出conda环境（规范操作）
conda deactivate
log "已退出conda base环境"

# 完成
log "自动更新博客流程执行完毕"
log "========================================\n"

exit 0