#!/bin/bash
# 脚本功能：自动执行CSDN爬虫脚本 + Git提交推送
# 适用于cron定时任务执行

# ==================== 关键配置（根据ECS服务器环境固定） ====================
# Miniconda安装路径（硬编码，避免cron环境中找不到conda命令）
CONDA_BASE="/root/miniconda3"
# 项目根目录
PROJECT_DIR="/root/Project/Lvyizhuo.github.io"
# 日志文件路径
LOG_FILE="${PROJECT_DIR}/auto_update_blog.log"
# Python脚本路径
PYTHON_SCRIPT="${PROJECT_DIR}/scripts/fetch_csdn_articles.py"
# Python解释器路径
PYTHON_PATH="${CONDA_BASE}/bin/python"
# Git路径（cron环境可能找不到git）
GIT_PATH="/usr/bin/git"
# 锁文件路径（防止重复执行）
LOCK_FILE="/tmp/auto_update_blog.lock"
# 日志最大行数（超过则截断旧日志）
MAX_LOG_LINES=2000

# ==================== 环境变量设置（解决cron环境问题） ====================
# 设置PATH，确保能找到必要的命令
export PATH="${CONDA_BASE}/bin:/usr/local/bin:/usr/bin:/bin:${PATH}"
# 设置HOME变量（某些git操作需要）
export HOME="/root"
# 设置语言环境，避免中文乱码
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ==================== 函数定义 ====================
# 日志格式化输出函数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
}

# 错误处理函数
handle_error() {
    log "ERROR: $1"
    # 清理锁文件
    rm -f "${LOCK_FILE}"
    # 如果已激活conda环境，尝试退出
    conda deactivate 2>/dev/null
    exit 1
}

# 清理函数（脚本退出时执行）
cleanup() {
    rm -f "${LOCK_FILE}"
    conda deactivate 2>/dev/null
}

# 日志轮转函数（保留最近的日志）
rotate_log() {
    if [ -f "${LOG_FILE}" ]; then
        local line_count=$(wc -l < "${LOG_FILE}")
        if [ "${line_count}" -gt "${MAX_LOG_LINES}" ]; then
            # 保留最后 MAX_LOG_LINES 行
            tail -n "${MAX_LOG_LINES}" "${LOG_FILE}" > "${LOG_FILE}.tmp"
            mv "${LOG_FILE}.tmp" "${LOG_FILE}"
        fi
    fi
}

# Git操作重试函数
git_with_retry() {
    local cmd="$1"
    local max_retries=3
    local retry_delay=5
    
    for ((i=1; i<=max_retries; i++)); do
        if eval "${cmd}" >> "${LOG_FILE}" 2>&1; then
            return 0
        fi
        if [ $i -lt $max_retries ]; then
            log "Git操作失败，${retry_delay}秒后重试 ($i/$max_retries)..."
            sleep ${retry_delay}
        fi
    done
    return 1
}

# ==================== 脚本主流程 ====================

# 设置退出时清理
trap cleanup EXIT

# 第零步：检查锁文件，防止重复执行
if [ -f "${LOCK_FILE}" ]; then
    # 检查锁文件是否过期（超过1小时认为是残留锁）
    if [ $(($(date +%s) - $(stat -c %Y "${LOCK_FILE}"))) -gt 3600 ]; then
        rm -f "${LOCK_FILE}"
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 脚本正在执行中，跳过本次运行" >> "${LOG_FILE}"
        exit 0
    fi
fi
# 创建锁文件
touch "${LOCK_FILE}"

# 第一步：日志轮转
rotate_log

# 第二步：初始化日志
log "=======================================================================开始执行自动更新博客流程========================================================================================="
log "开始执行自动更新博客流程"
log "当前用户: $(whoami)"
log "当前PATH: ${PATH}"

# 第二步：验证关键路径是否存在
log "验证关键路径..."
if [ ! -d "${CONDA_BASE}" ]; then
    handle_error "Miniconda目录不存在：${CONDA_BASE}"
fi
if [ ! -d "${PROJECT_DIR}" ]; then
    handle_error "项目目录不存在：${PROJECT_DIR}"
fi
if [ ! -f "${PYTHON_SCRIPT}" ]; then
    handle_error "Python脚本不存在：${PYTHON_SCRIPT}"
fi
if [ ! -f "${PYTHON_PATH}" ]; then
    handle_error "Python解释器不存在：${PYTHON_PATH}"
fi
if [ ! -f "${GIT_PATH}" ]; then
    # 尝试其他常见git路径
    if [ -f "/usr/local/bin/git" ]; then
        GIT_PATH="/usr/local/bin/git"
    else
        handle_error "Git命令不存在，请确认已安装git"
    fi
fi
log "路径验证通过"

# 第三步：激活conda base环境
log "开始激活conda base环境..."
# 加载conda配置（cron环境必须手动source）
if [ -f "${CONDA_BASE}/etc/profile.d/conda.sh" ]; then
    source "${CONDA_BASE}/etc/profile.d/conda.sh" || handle_error "加载conda配置文件失败"
else
    handle_error "conda配置文件不存在：${CONDA_BASE}/etc/profile.d/conda.sh"
fi
# 激活base环境
conda activate base || handle_error "激活conda base环境失败"
log "conda base环境激活成功"
log "当前Python路径：${PYTHON_PATH}"
log "Python版本：$(${PYTHON_PATH} --version 2>&1)"

# 第四步：切换到项目根目录
log "切换到项目目录：${PROJECT_DIR}"
cd "${PROJECT_DIR}" || handle_error "切换到项目目录失败"

# 第五步：拉取远程最新代码（避免推送冲突）
log "执行git pull origin main"
if ! git_with_retry "${GIT_PATH} pull origin main"; then
    handle_error "Git拉取失败，请检查网络或仓库状态"
fi
log "Git拉取成功"

# 第六步：执行Python爬虫脚本
log "开始执行爬虫脚本：${PYTHON_SCRIPT}"
${PYTHON_PATH} "${PYTHON_SCRIPT}" >> "${LOG_FILE}" 2>&1
if [ $? -eq 0 ]; then
    log "爬虫脚本执行成功"
else
    handle_error "爬虫脚本执行失败，请检查Python依赖是否完整"
fi

# 第七步：Git添加所有更改到缓存区
log "执行git add ."
${GIT_PATH} add . >> "${LOG_FILE}" 2>&1
if [ $? -eq 0 ]; then
    log "Git添加缓存区成功"
else
    handle_error "Git添加缓存区失败"
fi

# 第八步：Git提交（带日期的提交信息）
COMMIT_MSG="自动更新博客 $(date +'%Y-%m-%d %H:%M:%S')"
log "检查是否有文件更改..."
# 检查是否有实际更改，避免空提交
${GIT_PATH} diff --quiet && ${GIT_PATH} diff --staged --quiet
if [ $? -eq 1 ]; then
    # 有更改才提交和推送
    log "执行git commit -m '${COMMIT_MSG}'"
    ${GIT_PATH} commit -m "${COMMIT_MSG}" >> "${LOG_FILE}" 2>&1
    if [ $? -eq 0 ]; then
        log "Git提交成功，提交信息：${COMMIT_MSG}"
    else
        handle_error "Git提交失败"
    fi
    
    # 第九步：推送到远程仓库（仅在有提交时执行）
    log "执行git push origin main"
    if git_with_retry "${GIT_PATH} push origin main"; then
        log "Git推送到远程仓库成功"
    else
        handle_error "Git推送失败！请检查SSH免密配置或网络"
    fi
else
    log "无文件更改，跳过Git提交和推送步骤"
fi

# 收尾：退出conda环境（cleanup函数会处理）
log "自动更新博客流程执行完毕"
log "==============================================自动更新博客流程执行完毕=========================================================================================================================================================="
echo "" >> "${LOG_FILE}"

exit 0