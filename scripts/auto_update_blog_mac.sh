#!/bin/bash
# 脚本功能：自动执行CSDN爬虫脚本 + Git提交推送（macOS 本地专用版）
# 自动检测 conda 安装路径并激活环境，日志输出到 logs/ 目录
#
# 使用方法：
#   ./scripts/auto_update_blog_mac.sh          # 完整流程
#   ./scripts/auto_update_blog_mac.sh --dry    # 试运行（不实际 git push）
#   ./scripts/auto_update_blog_mac.sh --crawl  # 只抓取，不推送

# ==================== 配置 ====================
# conda 环境名（用户已将依赖安装在 base 环境）
CONDA_ENV="base"
# 项目根目录（从脚本位置自动推导）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# 日志目录（每天一个日志文件）
LOG_DIR="${PROJECT_DIR}/logs"
LOG_FILE="${LOG_DIR}/auto_update_blog_$(date +'%Y-%m-%d').log"
# Python 爬虫脚本
PYTHON_SCRIPT="${PROJECT_DIR}/scripts/fetch_csdn_articles.py"
# 锁文件
LOCK_FILE="/tmp/auto_update_blog_mac.lock"

# ==================== 参数解析 ====================
DRY_RUN=false
CRAWL_ONLY=false
case "$1" in
    --dry) DRY_RUN=true ;;
    --crawl) CRAWL_ONLY=true ;;
esac

# ==================== 函数定义 ====================
log() {
    local msg="$1"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "${timestamp} $msg" | tee -a "${LOG_FILE}"
}

handle_error() {
    log "❌ 错误: $1"
    rm -f "${LOCK_FILE}"
    exit 1
}

cleanup() {
    rm -f "${LOCK_FILE}"
}

commit_and_push() {
    local commit_msg="$1"

    log "📦 执行 git add -A ..."
    git add -A >> "${LOG_FILE}" 2>&1 || handle_error "Git add 失败"

    if [ -z "$(git status --porcelain --untracked-files=all 2>/dev/null)" ]; then
        log "📭 无文件变更，跳过提交和推送"
        return 0
    fi

    log "💾 执行 git commit ..."
    git commit -m "${commit_msg}" >> "${LOG_FILE}" 2>&1 || handle_error "Git commit 失败"
    log "✅ 提交成功: ${commit_msg}"

    if [ "$DRY_RUN" = true ]; then
        log "🔍 试运行模式，跳过 git push"
        return 0
    fi

    log "☁️  执行 git push origin main..."
    if git push origin main >> "${LOG_FILE}" 2>&1; then
        log "✅ Git 推送到远程仓库成功"
    else
        handle_error "Git 推送失败！请检查网络或认证配置"
    fi
}

# 自动查找 conda 安装目录
find_conda_base() {
    # 常见 conda 安装位置（按优先级）
    local candidates=(
        "/opt/miniconda3"
        "/usr/local/miniconda3"
        "${HOME}/miniconda3"
        "${HOME}/miniforge3"
        "${HOME}/anaconda3"
        "/opt/anaconda3"
    )
    for dir in "${candidates[@]}"; do
        if [ -f "${dir}/etc/profile.d/conda.sh" ]; then
            echo "${dir}"
            return 0
        fi
    done
    return 1
}

# ==================== 主流程 ====================
trap cleanup EXIT

# 确保 logs 目录存在
mkdir -p "${LOG_DIR}"

# 检查锁文件
if [ -f "${LOCK_FILE}" ]; then
    log "⏳ 脚本正在执行中，跳过本次运行"
    exit 0
fi
touch "${LOCK_FILE}"

log "═══════════════════════════════════════════════════════"
log "🚀 开始执行自动更新博客 (macOS 本地)"
log "项目目录: ${PROJECT_DIR}"
log "运行模式: $([ "$DRY_RUN" = true ] && echo '试运行 (--dry)' || ([ "$CRAWL_ONLY" = true ] && echo '仅抓取 (--crawl)' || echo '完整流程'))"

# 验证路径
log "📁 验证路径..."
[ -d "${PROJECT_DIR}" ] || handle_error "项目目录不存在：${PROJECT_DIR}"
[ -f "${PYTHON_SCRIPT}" ] || handle_error "Python脚本不存在：${PYTHON_SCRIPT}"

# ---- conda 自动检测与激活 ----
log "🔍 检测 conda 安装位置..."
CONDA_BASE=$(find_conda_base)
if [ -z "${CONDA_BASE}" ]; then
    # 如果常见位置没找到，尝试用 conda info 命令定位
    if command -v conda &>/dev/null; then
        CONDA_BASE="$(conda info --base 2>/dev/null)"
    fi
fi
if [ -z "${CONDA_BASE}" ]; then
    handle_error "未找到 conda 安装目录，请确认 conda 已安装"
fi

log "   conda 根目录: ${CONDA_BASE}"

# 加载 conda.sh 使 conda 命令可用（subshell 中也有效）
source "${CONDA_BASE}/etc/profile.d/conda.sh" || handle_error "加载 conda.sh 失败"

log "🐍 使用 conda 环境: ${CONDA_ENV}"
log "Python 版本: $(conda run -n "${CONDA_ENV}" python --version 2>&1)"

# 切换到项目目录
cd "${PROJECT_DIR}" || handle_error "切换到项目目录失败"

# Git pull（仅在完整流程下执行）
if [ "$CRAWL_ONLY" = false ]; then
    log "⬇️  执行 git pull origin main..."
    if conda run -n "${CONDA_ENV}" git pull origin main >> "${LOG_FILE}" 2>&1; then
        log "✅ Git 拉取成功"
    else
        log "⚠️  Git 拉取失败（可能无远程变更或无网络），继续执行..."
    fi
fi

# 执行爬虫
log "🕷️  执行爬虫脚本..."
conda run -n "${CONDA_ENV}" python "${PYTHON_SCRIPT}" 2>&1 | tee -a "${LOG_FILE}"
CRAWL_EXIT=${PIPESTATUS[0]}
if [ "${CRAWL_EXIT}" -ne 0 ]; then
    handle_error "爬虫脚本执行失败 (exit code: ${CRAWL_EXIT})"
fi
log "✅ 爬虫脚本执行成功"

# 仅抓取模式在此结束
if [ "$CRAWL_ONLY" = true ]; then
    log "📌 仅抓取模式，跳过 Git 操作"
    log "═══════════════════════════════════════════════════════"
    exit 0
fi

# 自动提交并推送（默认流程）
COMMIT_MSG="自动更新博客 $(date +'%Y-%m-%d %H:%M:%S')"
commit_and_push "${COMMIT_MSG}"

log "🎉 自动更新博客流程执行完毕"
log "═══════════════════════════════════════════════════════"

exit 0
