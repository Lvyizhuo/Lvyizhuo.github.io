# 项目结构梳理与清理规划

> 对象：`Lvyizhuo.github.io`（Jekyll + Academic Pages / Minimal-Mistakes 学术主页）
> 初版：2026-07-16 | 更新：2026-07-17
> 说明：本站是 **Jekyll 静态站点**，`_config.yml`、`_data`、`_includes`、`_layouts`、`_pages`、`_sass`、`assets` 等目录名由 Jekyll 约定**强制固定，不能改名或随意移动**，否则构建即失败。因此"重新规划目录"只能在 Jekyll 规则内优化，本报告已据此给出方案并跟踪执行。

---

## 一、根目录逐项用途说明

| 路径 | 类型 | 用途 | 状态 |
|---|---|---|---|
| `_config.yml` | 配置 | Jekyll 主配置（站点标题、作者、插件、SEO、集合） | ✅ 核心 |
| `_config.dev.yml` | 配置 | 本地 Docker 开发覆盖配置（`url: localhost`），由 compose `--config` 加载 | ✅ 使用中 |
| `_data/` | 数据 | 站点结构化数据（导航、作者、博客、i18n） | ✅ 已清理 (删除了 `cv.json`) |
| `_includes/` | 模板 | 页面可复用片段（头部、侧栏、SEO、评论等，主题内置） | ✅ 已清理 (删除了 cv/talk 孤立片段) |
| `_layouts/` | 模板 | 页面骨架布局（single/archive/default 等） | ✅ 已清理 (删除了 cv-layout/talk) |
| `_pages/` | 内容 | 实际页面：`about.md`(首页)、`year-archive.html`(博客)、`404.md` | ✅ 全部在用 |
| `_sass/` | 样式 | SCSS 源（主题变量、布局、语法高亮），编译进 `main.css` | ✅ 核心 |
| `assets/` | 资源 | 编译后 CSS、JS、字体 | ✅ 已清理 (删除了 cv/collapse CSS 和 JS) |
| `images/` | 图片 | 头像、favicon、项目封面、主题截图 | ✅ 已清理 (删除了大量主题示例图) |
| `scripts/` | 脚本 | CSDN 抓取、博客同步脚本集中管理 | ✅ 已归位 (`auto_update_blog.sh` 移入) |
| `Dockerfile` / `docker-compose.yaml` / `.dockerignore` | 构建 | 本地 Docker 预览环境 | ✅ 使用中 |
| `Gemfile` / `Gemfile.lock` | 依赖 | Ruby gem 依赖锁定（GitHub Pages 需提交） | ✅ 核心 |
| `package.json` | 依赖 | 主题 JS 压缩构建脚本（生成 `main.min.js`） | ✅ 工具链，保留 |
| `README.md` | 文档 | 已重写为本站真实介绍 | ✅ 已更新 |
| `CONTRIBUTING.md` | 文档 | 已更新为个人主页指南 | ✅ 已更新 |
| `QUICKSTART.md` | 文档 | CSDN 博客同步快速指南 | ⚠️ 待合并到 README |
| `LICENSE` | 文档 | MIT 许可证 | ✅ 保留 |
| `PROJECT_STRUCTURE_REVIEW.md` | 文档 | 本文件 | ✅ 当前文档 |
| `.github/` | CI | `workflows/pages.yml` 部署 | ✅ 保留 |
| `.devcontainer/` | 环境 | GitHub Codespaces 开发容器配置 | ✅ 保留 |
| `.claude/` | 编辑器 | 本地工具配置（未纳入 git） | ✅ 保留 |
| `.workbuddy/` | 记忆 | 项目工作记忆（**请勿删除**） | ✅ 保留 |
| `_site/` | 产物 | Jekyll 构建输出（已 gitignore） | 🗑️ 缓存 |
| `.sass-cache/` | 缓存 | SCSS 编译缓存（已 gitignore） | 🗑️ 缓存 |
| `.jekyll-metadata` | 缓存 | 增量构建缓存 | ✅ 已修复（从 git 跟踪中移除并加入 .gitignore） |
| `site-preview.png` / `site-preview-1440.png` / `site-preview-1920.png` | 图片 | 站点预览截图，站内无引用 | ⚠️ 冗余，待清理 |

---

## 二、清理执行状态

### ✅ 已完成（已删除或已修复）

| 项 | 说明 |
|---|---|
| 构建缓存 | `.jekyll-metadata` 从 git 跟踪中移除并加入 `.gitignore` |
| CV 子系统 | `_data/cv.json`、`_includes/cv-template.html`、`_layouts/cv-layout.html`、`_includes/archive-single-cv.html`、`_includes/archive-single-talk-cv.html`、`assets/css/cv-layout.css`、`assets/css/cv-style.css`、`scripts/cv_markdown_to_json.py`、`scripts/update_cv_json.sh` — 整条链删除 |
| Talks 子系统 | `_layouts/talk.html`、`_includes/archive-single-talk.html` 删除 |
| 折叠组件 | `assets/css/collapse.css`、`assets/js/collapse.js` 删除 |
| 主题示例附件 | `files/` 整目录删除（paper1-3.pdf, slides1-3.pdf, bibtex1.bib） |
| 主题示例图片 | 所有 demo 残留图片删除（500x300.png, bio-photo*.jpg, homepage.png, foo-bar-identity*.jpg 等） |
| 开发补丁 | `_plugins/dev_url.rb` 删除（其功能已被 `_includes/base_path` + `_config.dev.yml` 替代） |
| 脚本归位 | `auto_update_blog.sh` 从根目录移入 `scripts/` |
| 文档更新 | `README.md` 重写为本站真实介绍<br>`CONTRIBUTING.md` 更新为个人主页指南 |

### ⚠️ 待清理 / 备选

| 项 | 说明 | 优先级 |
|---|---|---|
| `site-preview.png` | 根目录冗余截图 | 低 |
| `site-preview-1440.png` | 根目录冗余截图 | 低 |
| `site-preview-1920.png` | 根目录冗余截图 | 低 |
| `.github/ISSUE_TEMPLATE/` | 模板残留（bug_report/feature_request），个人主页通常无需 | 低 |
| `QUICKSTART.md` | 内容建议并入 README 后删除 | 低 |

---

## 三、命名规范

| 项 | 现状 | 建议 |
|---|---|---|
| 数据文件 | `csdn_posts.yml` 等 snake_case | ✅ 保持 snake_case |
| 脚本 | `.py`/`.sh` snake_case | ✅ 保持 |
| Compose 文件 | `docker-compose.yaml` | 可选统一为 `.yml`（社区更常见，非必须） |
| 页面 | `year-archive.html`、`404.md` | ✅ kebab-case，保持 |
| 文档 | 全大写 `README/QUICKSTART/CONTRIBUTING` | ✅ 约定俗成，保持 |

结论：**命名不需要大动**，重点是删冗余、脚本归位。

---

## 四、当前目录结构（清理后）

```
Lvyizhuo.github.io/
├── _config.yml                 # Jekyll 主配置
├── _config.dev.yml             # 本地 Docker 开发覆盖
├── _data/                      # 站点数据
│   ├── authors.yml
│   ├── csdn_posts.yml          # 博客数据（脚本自动生成）
│   ├── navigation.yml
│   └── ui-text.yml
├── _includes/                  # 模板片段（已删除 cv/talk 孤立片段）
├── _layouts/                   # 布局（已删除 cv-layout/talk）
├── _pages/
│   ├── 404.md
│   ├── about.md                # 首页 (permalink: /)
│   └── year-archive.html       # 博客列表
├── _sass/                      # SCSS 源
│   ├── _syntax.scss
│   ├── _themes.scss
│   ├── include/
│   ├── layout/
│   ├── theme/
│   └── vendor/                 # 第三方（breakpoint, FontAwesome, susy）
├── assets/
│   ├── css/                    # main.scss + custom.css + academicons
│   ├── js/                     # main.min.js + _main.js + plugins/
│   ├── fonts/                  # academicons
│   └── webfonts/               # FontAwesome
├── images/                     # 头像 + favicon + 项目封面 + 主题截图
│   ├── projects/
│   └── themes/
├── scripts/                    # 全部自动化脚本
│   ├── auto_update_blog.sh
│   ├── fetch_csdn_articles.py
│   ├── sync_blog.sh
│   └── test_sync.sh
├── Dockerfile
├── docker-compose.yaml
├── .dockerignore
├── Gemfile / Gemfile.lock
├── package.json
├── README.md
├── PROJECT_STRUCTURE_REVIEW.md
├── QUICKSTART.md
├── CONTRIBUTING.md
├── LICENSE
├── .github/workflows/pages.yml
├── .devcontainer/
└── .workbuddy/                 # 工作记忆（勿删）
```

---

## 五、技术栈

| 层面 | 技术 |
|---|---|
| **框架** | Jekyll (Ruby) 静态站点 |
| **模板** | Academic Pages (基于 Minimal Mistakes) |
| **样式** | SCSS → 压缩 CSS，支持 light/dark 双主题 |
| **排版** | Times New Roman serif 阅读栈，自定义 `custom.css` |
| **博客同步** | Python 爬虫 + GitHub Actions / ECS cron |
| **部署** | GitHub Pages (`actions/deploy-pages`) |
| **本地开发** | Docker Compose / VS Code DevContainer |
