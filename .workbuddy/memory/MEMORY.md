# Project Memory — Lvyizhuo.github.io

Jekyll "Minimal-Mistakes" academic personal blog (machine learning / data mining).

## 构建与调试（重要）
- **必须用 Docker 调试/预览**，用户明确要求。本地 Ruby 环境是坏的（bundler 仅 1.17.2、无 jekyll gem、无写权限），不要依赖本地 `bundle`/`jekyll`。
- 预览：`docker compose up -d` → http://localhost:4000
- 仅编译校验：`docker compose run --rm --build jekyll bundle exec jekyll build`（产物在 `_site/`）
- Dockerfile 用 ruby:3.2 + ruby-china 镜像装 gem；compose 已挂 `.:/usr/src/app` 与 `bundle_data` 卷。

## 排版设计系统（参考 ZhChHoooi.github.io）
用户要求字体/排版对齐该参考站；保留浅色配色，仅优化字体与排版。
- 字体：英文 Times New Roman 衬线，中文回退 `Songti SC`/`SimSun`。代码块按用户要求也改为衬线（参考站本身保留等宽，可读性更好）。
- 数值：根字号 **16px**（用户要求"调大1号"，15→16）、正文行高 1.6、容器最大宽度 **1320px**（配合 `width: 84%`）；在 1440px 笔记本屏上约 1210px 宽（左右约 131px 边距），在 1920px 显示器上达 1320px（左右约 316px 边距），既加宽又不贴边。
- 实现位置：
  - `_sass/_themes.scss`：新增 `$times-new-roman` 变量；`$global-font-family`/`$header-font-family` 改为它；`$doc-font-size: 16`。
  - `assets/css/custom.css`（新建）：全局衬线、行高/标题层级/段落间距、宽屏两端对齐、引用块、侧栏与导航微调、代码块衬线、容器 1400px（`@media (min-width:1280px)` 内设置，移动端保持主题响应式）、左图右文悬浮卡片 `.paper-box`（图片占 44%）。
  - 重要居中修复：主题把 `.page` 的 `suffix(2 of 12)` 以 `padding-right` 发出，导致右侧正文距屏幕边距远大于左侧侧栏距屏幕边距。在 `@media (min-width: 1024px)` 内加 `.page{ padding-right: 0 !important; }` 消除，保留左侧 padding 作为侧栏与正文间距，即可让左右外沿空隙相等、整体居中（1440px 视口：左=右=131px；1920px 视口：左=右=316px）。
  - `_includes/head.html`：在 `main.css` 之后引入 `custom.css`。
- 临时预览文件 `typography-preview.html` 已于 2026-07-16 清理删除（不再存在）。
- 可调旋钮：`custom.css` 的 `html{ font-size: 16px; }`（想更大改 17/18）、行高（当前 1.6）、容器 `max-width`（当前 1400px，已加宽用于卡片）、`.paper-box-image` 图片占比（当前 44%）。

## 2026-07-16 修复：Docker 本地预览「页面崩了 / 靠左 / 裸奔」—— 根因与根治
- **根因**：`docker-compose.yaml` 里 `jekyll serve -H 0.0.0.0` 既用于容器内绑定（Docker 端口映射必须绑 0.0.0.0 才能从宿主机访问），又会把生成的资源/链接主机名也写成 `http://0.0.0.0:4000`。浏览器作为客户端连不上 `0.0.0.0`，于是 CSS/JS/图片全部 502 → 页面只剩裸 HTML、呈现"靠左/崩"。
- **之前的临时修法（不可靠）**：`_config.dev.yml` 设 `url: localhost` + `_plugins/dev_url.rb` 钩子把 0.0.0.0 替换成 localhost。但插件未被稳定加载（`JEKYLL_ENV`/增量构建下未必触发），链接反复退回 0.0.0.0。
- **根治（当前生效）**：改 `_includes/base_path`，只输出 `site.baseurl`（本站为空）→ 所有资源/导航链接变成**相对路径** `/assets/...`、`/about/` 等，浏览器按当前访问主机（localhost:4000）自动解析，彻底摆脱主机名问题。该改法对 GitHub Pages 根目录部署同样安全。
- **务必保留** `docker-compose.yaml` 里的 `-H 0.0.0.0`（换成 localhost 会让容器只绑 127.0.0.1，Docker 端口映射失效、站点不可访问）。
- `_plugins/dev_url.rb` 现在已冗余（链接不再含 0.0.0.0），可日后清理。
- 以后本地预览：`docker compose up -d` → http://localhost:4000。改文件后 Jekyll watch 自动重建，浏览器硬刷新（Cmd+Shift+R）即可。

## 结构梳理与冗余清单（2026-07-16 全库引用检索确认）
- 报告：`PROJECT_STRUCTURE_REVIEW.md`（逐文件用途 + 冗余清单 + Jekyll 规范内的目录规划）。
- **孤立死代码链**（无任何页面引用，可安全删）：
  - CV 子系统整链：`_data/cv.json`、`_includes/cv-template.html`、`_includes/archive-single-cv.html`、`_includes/archive-single-talk-cv.html`、`_layouts/cv-layout.html`、`assets/css/cv-layout.css`、`assets/css/cv-style.css`、`scripts/cv_markdown_to_json.py`、`scripts/update_cv_json.sh`（无页面用 `layout: cv-layout`，导航也无 CV 入口）。
  - Talks 子系统：`_layouts/talk.html`、`_includes/archive-single-talk.html`。
  - 折叠组件：`assets/css/collapse.css`、`assets/js/collapse.js`（无引用）。
- **主题 demo 残留**：`files/` 全部 PDF/bib；`images/` 中 500x300、image-alignment-*、foo-bar-*、3953273590*、editing-talk.png、paragraph-*.png、homepage.png、bio-photo*.jpg；根目录 `site-preview.png`。
- **缓存/垃圾**：`.jekyll-metadata`（被误 git 跟踪，应 `git rm --cached`+gitignore）、`.DS_Store`、`.sass-cache/`、`_site/`、空 `logs/`。
- **冗余补丁**：`_plugins/dev_url.rb` 已被 base_path 相对路径 + `_config.dev.yml` 双重覆盖，可删（删前本地预览验证）。
- **归位建议**：根目录 `auto_update_blog.sh` → `scripts/`（注意同步改 ECS crontab 路径，脚本内硬编码 `PYTHON_SCRIPT=.../scripts/fetch_csdn_articles.py`）。
- **在用勿删**：profile.png/site-logo.png/favicon*/manifest.json/images/{projects,themes}、_data/{navigation,csdn_posts,ui-text}.yml、assets/css/custom.css、assets/webfonts(FontAwesome)、assets/fonts(academicons)、_config.dev.yml（compose --config 加载）。
- **Jekyll 约束**：`_config.yml/_data/_includes/_layouts/_pages/_sass/assets` 目录名固定不可改名/迁移，"重规划"只能在此约束内做（脚本归位、文档合并、删冗余）。

## 内容维护映射（对用户的长期说明）
- 首页内容（About / News / Publications / Honors / Education / Internships）→ 编辑 `_pages/about.md`（Markdown + front matter）。之前它 front matter 的 `title` 和正文 `# About Me` 重复，导致两个标题；已改为只在 front matter 留标题。
- 博客文章 → 编辑或新增 `_posts/YYYY-MM-DD-title.md`。
- 侧边栏姓名/头像/邮箱/社交链接 → 编辑 `_config.yml`。
- 站点用 Jekyll 生成静态 HTML，并非手写 HTML。
- **坑：改了 `docker-compose.yaml` 的 `command`/`environment` 后，`docker compose restart` 不生效**（restart 只重启进程、沿用旧容器配置），必须 `docker compose up -d --force-recreate`（或 `down && up -d`）才会应用。
- **坑：改 CSS 后浏览器看不到变化 = 浏览器缓存**。让用户硬刷新（Mac: Cmd+Shift+R）或用无痕窗口；并确认访问的是 `http://localhost:4000`。
