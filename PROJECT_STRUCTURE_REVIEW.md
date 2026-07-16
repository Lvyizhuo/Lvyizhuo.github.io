# 项目结构梳理与清理规划

> 对象：`Lvyizhuo.github.io`（Jekyll + Academic Pages / Minimal-Mistakes 学术主页）
> 生成时间：2026-07-16
> 说明：本站是 **Jekyll 静态站点**，`_config.yml`、`_data`、`_includes`、`_layouts`、`_pages`、`_sass`、`assets` 等目录名由 Jekyll 约定**强制固定，不能改名或随意移动**，否则构建即失败。因此"重新规划目录"只能在 Jekyll 规则内优化，本报告已据此给出方案。

---

## 一、根目录逐项用途说明

| 路径 | 类型 | 用途 | 状态 |
|---|---|---|---|
| `_config.yml` | 配置 | Jekyll 主配置（站点标题、作者、插件、SEO、集合） | ✅ 核心 |
| `_config.dev.yml` | 配置 | 本地 Docker 开发覆盖配置（`url: localhost`），由 compose `--config` 加载 | ✅ 使用中 |
| `_data/` | 数据 | 站点结构化数据（导航、作者、博客、i18n、CV） | ✅ 部分冗余 |
| `_includes/` | 模板 | 页面可复用片段（头部、侧栏、SEO、评论等，主题内置） | ✅ 部分冗余 |
| `_layouts/` | 模板 | 页面骨架布局（single/archive/default 等） | ✅ 部分冗余 |
| `_pages/` | 内容 | 实际页面：`about.md`(首页)、`year-archive.html`(博客)、`404.md` | ✅ 全部在用 |
| `_plugins/dev_url.rb` | 插件 | 早期把 `0.0.0.0` 替换为 `localhost` 的补丁 | ⚠️ 已冗余 |
| `_sass/` | 样式 | SCSS 源（主题变量、布局、语法高亮），编译进 `main.css` | ✅ 核心 |
| `assets/` | 资源 | 编译后 CSS、JS、字体 | ✅ 部分冗余 |
| `images/` | 图片 | 头像、favicon、项目封面、主题截图 + **大量主题示例图** | ⚠️ 大量冗余 |
| `files/` | 附件 | 主题自带的示例 PDF/bib（paper/slides） | ❌ 全部冗余 |
| `scripts/` | 脚本 | CSDN 抓取、博客同步、CV 生成脚本 | ✅ 部分冗余 |
| `auto_update_blog.sh` | 脚本 | ECS 上 cron 定时抓取+推送（根目录散落） | ✅ 建议归位 |
| `Dockerfile` / `docker-compose.yaml` / `.dockerignore` | 构建 | 本地 Docker 预览环境 | ✅ 使用中 |
| `Gemfile` / `Gemfile.lock` | 依赖 | Ruby gem 依赖锁定（GitHub Pages 需提交） | ✅ 核心 |
| `package.json` | 依赖 | 主题 JS 压缩构建脚本（生成 `main.min.js`） | ✅ 工具链，保留 |
| `README.md` / `CONTRIBUTING.md` / `LICENSE` | 文档 | 仍是原 Academic Pages 模板内容 | ⚠️ 待更新 |
| `QUICKSTART.md` | 文档 | 自建的本地预览快速指南 | ✅ 使用中 |
| `.github/` | CI | `workflows/pages.yml` 部署；`ISSUE_TEMPLATE/` 为模板残留 | ✅/⚠️ |
| `.devcontainer/` | 环境 | GitHub Codespaces 开发容器配置 | ✅ 保留 |
| `.claude/` | 编辑器 | 本地工具配置（未纳入 git） | ✅ 保留 |
| `.workbuddy/` | 记忆 | 项目工作记忆（**请勿删除**） | ✅ 保留 |
| `_site/` | 产物 | Jekyll 构建输出（已 gitignore） | 🗑️ 缓存 |
| `.sass-cache/` | 缓存 | SCSS 编译缓存（已 gitignore） | 🗑️ 缓存 |
| `.jekyll-metadata` | 缓存 | 增量构建缓存 | 🗑️ 缓存**但被误提交进 git** |
| `.DS_Store` | 垃圾 | macOS 目录元数据 | 🗑️ 垃圾 |
| `logs/` | 空目录 | 空，无脚本写入 | 🗑️ 可删 |
| `site-preview.png` | 图片 | 站点预览截图，站内无任何引用 | 🗑️ 冗余 |

---

## 二、冗余 / 未使用文件清单（可安全删除）

以下均已通过全库引用检索确认**无任何页面/模板/配置引用**（排除 `_site`/`.git`）。

### A. 构建缓存与系统垃圾
| 文件 | 处理 |
|---|---|
| `.jekyll-metadata` | `git rm --cached` 后删除，并加入 `.gitignore`（当前被误跟踪） |
| `.DS_Store` | 删除（已 gitignore，仅物理残留） |
| `.sass-cache/` | 删除物理目录（可重建） |
| `_site/` | 删除物理目录（每次构建自动重建） |
| `logs/` | 删除空目录 |

### B. 孤立的 CV 子系统（整链未接入任何页面）
调用链 `cv.json → cv-template.html → cv-layout.html`，但**没有任何页面使用 `layout: cv-layout`**，导航也无 CV 入口，整条链为死代码：
- `_data/cv.json`
- `_includes/cv-template.html`
- `_layouts/cv-layout.html`
- `_includes/archive-single-cv.html`
- `_includes/archive-single-talk-cv.html`
- `assets/css/cv-layout.css`
- `assets/css/cv-style.css`
- `scripts/cv_markdown_to_json.py`
- `scripts/update_cv_json.sh`

### C. 孤立的 Talks 子系统（无 talk 集合/页面）
- `_layouts/talk.html`
- `_includes/archive-single-talk.html`

### D. 孤立的折叠组件（无引用）
- `assets/css/collapse.css`
- `assets/js/collapse.js`

### E. 主题示例附件（模板自带 demo）
- `files/` 全部：`paper1.pdf`、`paper2.pdf`、`paper3.pdf`、`slides1.pdf`、`slides2.pdf`、`slides3.pdf`、`bibtex1.bib`（仅被未使用的 `cv.json`/README 引用）

### F. 主题示例图片（demo 残留）
- `images/500x300.png`
- `images/image-alignment-1200x4002.jpg`、`image-alignment-150x150.jpg`、`image-alignment-300x200.jpg`、`image-alignment-580x300.jpg`
- `images/foo-bar-identity.jpg`、`foo-bar-identity-th.jpg`
- `images/3953273590_704e3899d5_m.jpg`
- `images/editing-talk.png`
- `images/paragraph-indent.png`、`paragraph-no-indent.png`
- `images/homepage.png`（仅 README 引用）
- `images/bio-photo.jpg`、`bio-photo-2.jpg`（`authors.yml` 引用，但站内无多作者文章，实际未渲染）
- `site-preview.png`（根目录，无引用）

### G. 已冗余的开发补丁（可选删除）
- `_plugins/dev_url.rb`：其功能已被 `_includes/base_path`（输出相对路径）+ `_config.dev.yml`（`url: localhost`）双重覆盖，`0.0.0.0` 已不再出现，插件不再触发。删除前建议本地 `docker compose up -d` 验证一次。

> **保留提醒**：`images/profile.png`(头像)、`site-logo.png`、`favicon*`、`manifest.json`、`images/projects/`、`images/themes/`、`_data/{navigation,csdn_posts,ui-text}.yml`、`assets/css/custom.css`、`assets/webfonts/`(FontAwesome)、`assets/fonts/`(academicons) 均在用，**不要删**。

---

## 三、相关文件合并 / 归位建议

Jekyll 目录名不可动，可优化的是**散落文件归位**与**文档合并**：

1. **脚本统一到 `scripts/`**
   - 将根目录 `auto_update_blog.sh` 移入 `scripts/`，使所有自动化脚本集中。
   - ⚠️ 该脚本内含硬编码路径 `PYTHON_SCRIPT=.../scripts/fetch_csdn_articles.py`，移动后需同步更新 ECS 上 crontab 里的脚本路径。

2. **文档收敛**
   - `README.md` 目前仍是原 Academic Pages 模板文案（引用 `homepage.png`），建议改写为本站真实介绍；`QUICKSTART.md` 的本地预览步骤可并入 README 的"本地开发"章节，减少文档碎片。
   - `.github/ISSUE_TEMPLATE/`（bug_report/feature_request）为模板残留，个人主页仓库通常无需，可删。

3. **字体目录说明（不建议合并）**
   - `assets/fonts/`(academicons) 与 `assets/webfonts/`(FontAwesome) 由各自 CSS 用相对路径引用，虽可合并但风险高、收益低，**保持现状**。

---

## 四、目标目录结构（Jekyll 规范内，清理后）

```
Lvyizhuo.github.io/
├── _config.yml                 # 主配置
├── _config.dev.yml             # 本地 Docker 开发覆盖
├── _data/                      # 站点数据
│   ├── authors.yml
│   ├── csdn_posts.yml          # 博客数据（脚本自动生成）
│   ├── navigation.yml
│   └── ui-text.yml             # （删除 cv.json）
├── _includes/                  # 模板片段（删除 cv/talk 孤立片段）
├── _layouts/                   # 布局（删除 cv-layout/talk）
├── _pages/
│   ├── 404.md
│   ├── about.md                # 首页 (permalink: /)
│   └── year-archive.html       # 博客列表
├── _sass/                      # SCSS 源
├── assets/
│   ├── css/                    # custom.css + academicons（删除 cv/collapse）
│   ├── js/                     # main.min.js + _main.js
│   ├── fonts/                  # academicons
│   └── webfonts/               # FontAwesome
├── images/                     # 仅保留真实用图（头像/favicon/项目/主题）
├── scripts/                    # 全部自动化脚本集中
│   ├── fetch_csdn_articles.py
│   ├── sync_blog.sh
│   ├── test_sync.sh
│   └── auto_update_blog.sh     # ← 从根目录移入
├── Dockerfile
├── docker-compose.yaml
├── .dockerignore
├── Gemfile / Gemfile.lock
├── package.json
├── README.md                   # 合并 QUICKSTART 内容后
├── LICENSE / CONTRIBUTING.md
├── .github/workflows/pages.yml
├── .devcontainer/
└── .workbuddy/                 # 工作记忆（勿动）
```

---

## 五、命名规范建议

当前命名整体较统一，仅少量待规整：

| 项 | 现状 | 建议 |
|---|---|---|
| 数据文件 | `csdn_posts.yml` 等 snake_case | ✅ 保持 snake_case |
| 脚本 | `.py`/`.sh` snake_case | ✅ 保持 |
| Compose 文件 | `docker-compose.yaml` | 可选统一为 `.yml`（社区更常见，非必须） |
| 页面 | `year-archive.html`、`404.md` | ✅ kebab-case，保持 |
| 文档 | 全大写 `README/QUICKSTART/CONTRIBUTING` | ✅ 约定俗成，保持 |

结论：**命名不需要大动**，重点是删冗余、脚本归位、修复 `.jekyll-metadata` 误提交。

---

## 六、执行影响与风险

- B/C/D/E/F 类删除均为**无引用死文件**，删除不影响构建与页面。
- A 类为缓存/垃圾，删除后自动重建。
- G 类（`dev_url.rb`）删除前建议本地预览验证一次。
- 归位 `auto_update_blog.sh` 需**同步修改 ECS crontab 路径**。
- 所有改动都在 git 版本控制下，可随时回退。
