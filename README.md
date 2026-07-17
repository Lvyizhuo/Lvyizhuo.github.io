# Lvyizhuo.github.io — 吕一卓的个人学术主页

[![pages-build-deployment](https://github.com/Lvyizhuo/Lvyizhuo.github.io/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/Lvyizhuo/Lvyizhuo.github.io/actions/workflows/pages/pages-build-deployment)
[![GitHub license](https://img.shields.io/github/license/Lvyizhuo/Lvyizhuo.github.io?color=blue)](LICENSE)

这是 **Yizhuo Lv (吕一卓)** 的个人学术主页，基于 [Academic Pages](https://academicpages.github.io/) 模板构建，采用 Jekyll 静态站点框架。

**网站地址：** [https://Lvyizhuo.github.io](https://Lvyizhuo.github.io)

---

## 站点特性

- **单页首页设计** — 所有内容（About、News、Publications、Projects、Honors、Education、Internships）整合在一个页面上，通过导航栏锚点跳转
- **明/暗双主题** — 支持一键切换 light / dark 主题
- **CSDN 博客自动同步** — Python 爬虫定时抓取 CSDN 文章并生成本站博客列表
- **Projects 卡片组件** — 自定义 `.paper-box` 卡片样式，左图右文，悬停上浮效果
- **学术字体排版** — 基于 Times New Roman 的 serif 阅读栈，自适应宽屏两端对齐

---

## 🚀 快速开始 — 本地开发

### 前置依赖

```bash
# macOS
brew install ruby
brew install node
gem install bundler

# Linux (Ubuntu/Debian)
sudo apt install ruby-dev ruby-bundler nodejs build-essential gcc make
```

### 安装与运行

```bash
# 1. 克隆仓库
git clone https://github.com/Lvyizhuo/Lvyizhuo.github.io.git
cd Lvyizhuo.github.io

# 2. 安装 Ruby 依赖
bundle config set --local path 'vendor/bundle'
bundle install

# 3. 启动本地服务器
bundle exec jekyll serve -l -H localhost
```

访问 `http://localhost:4000` 即可预览。修改文件后页面会自动刷新。

### 使用 Docker

```bash
chmod -R 777 .
docker compose up -d
```

### 使用 VS Code DevContainer

在 VS Code 中打开项目，按 `F1` → **Dev Containers: Reopen in Container**，自动构建并启动开发环境。

---

## 📁 项目结构

```
Lvyizhuo.github.io/
├── _config.yml             # Jekyll 主配置
├── _config.dev.yml         # 本地 Docker 开发覆盖配置
├── _data/                  # 站点结构化数据
│   ├── authors.yml         # 作者信息
│   ├── csdn_posts.yml      # CSDN 博客数据（脚本自动生成）
│   ├── navigation.yml      # 导航栏菜单
│   └── ui-text.yml         # UI 多语言文本
├── _includes/              # Jekyll 模板片段
├── _layouts/               # Jekyll 页面布局
├── _pages/                 # 实际页面
│   ├── 404.md              # 404 页面
│   ├── about.md            # 首页 (permalink: /)
│   └── year-archive.html   # 博客列表
├── _sass/                  # SCSS 样式源
│   ├── _syntax.scss
│   ├── _themes.scss
│   ├── include/
│   ├── layout/
│   ├── theme/
│   └── vendor/             # 第三方 SCSS（breakpoint, FontAwesome, susy 等）
├── assets/                 # 编译后资源
│   ├── css/                # main.scss + custom.css + academicons
│   ├── js/                 # main.min.js + _main.js
│   ├── fonts/              # academicons 字体
│   └── webfonts/           # FontAwesome 字体
├── images/                 # 图片资源（头像、favicon、项目封面、主题截图）
│   ├── projects/           # 项目截图
│   └── themes/             # 主题截图
├── scripts/                # 自动化脚本
│   ├── auto_update_blog.sh   # ECS cron 定时抓取博客并推送
│   ├── fetch_csdn_articles.py # CSDN 文章爬虫
│   ├── sync_blog.sh        # 博客同步脚本
│   └── test_sync.sh        # 同步测试脚本
├── Dockerfile
├── docker-compose.yaml
├── Gemfile / Gemfile.lock
├── package.json
├── .github/workflows/      # GitHub Actions 部署
└── .devcontainer/          # VS Code DevContainer 配置
```

> 详细结构梳理与清理过程见 [PROJECT_STRUCTURE_REVIEW.md](PROJECT_STRUCTURE_REVIEW.md)。

---

## 📝 博客自动同步

站点博客数据从 [CSDN 博客](https://blog.csdn.net/Lvyizhuo666) 自动同步，流程如下：

1. **Python 爬虫** (`scripts/fetch_csdn_articles.py`) 抓取 CSDN 文章列表
2. 生成 `_data/csdn_posts.yml` 结构化数据
3. GitHub Actions 或 ECS cron 定时触发同步
4. Jekyll 构建时读取数据生成博客列表页面

手动触发同步：
```bash
python3 scripts/fetch_csdn_articles.py
```

---

## 🔧 维护与贡献

- 本项目为个人主页，欢迎通过 [Issues](https://github.com/Lvyizhuo/Lvyizhuo.github.io/issues) 提出建议
- 详细贡献指南见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📄 许可

本项目基于 MIT 许可证开源，详见 [LICENSE](LICENSE)。

原模板 [Academic Pages](https://github.com/academicpages/academicpages.github.io) 基于 [Minimal Mistakes Jekyll Theme](https://mmistakes.github.io/minimal-mistakes/)，© 2016 Michael Rose，MIT License。
