---
title: "山东省智能政策咨询助手"
excerpt: "基于 RAG 的以旧换新政策智能问答系统。"
collection: portfolio
date: 2026-03-24
week: "2026-W12"
status: "更新"
summary: "基于 RAG 的以旧换新政策智能问答系统"
link: "http://mmgg.dpdns.org/home"
show_in_projects: true
card_highlights:
  - "RAG 向量知识库整合 PDF、Docx、网页与联网搜索结果，支持审核入库、去重与重排序。"
  - "智能体支持多轮对话、ReAct 推理、工具意图分类、会话事实缓存，以及图像、语音、发票等多模态解析。"
  - "全栈采用 React 19、Spring Boot 3.4、Spring AI、pgvector、Redis 与 Docker Compose，覆盖管理后台到部署编排。"
tech_tags:
  - React 19
  - Vite 7
  - Spring Boot 3.4.1
  - Spring AI 1.0.3
  - DashScope
  - PostgreSQL 16
  - pgvector
  - Redis 7
  - MinIO
  - JWT
---

<div class="project-detail-cover">
  <img src="/images/projects/shandong-policy-assistant-cover.png" alt="山东省智能政策咨询助手项目封面">
</div>

在线访问: [http://mmgg.dpdns.org/home](http://mmgg.dpdns.org/home){: target="_blank" rel="noopener noreferrer" }

## 亮点

- **项目概述**：山东省智能政策咨询助手是一个基于 AI 大语言模型驱动的问答系统，面向山东省以旧换新补贴政策咨询，采用 RAG（检索增强生成）实现政策知识检索与回答。
- **技术栈**
  - 前端：React 19 + Vite 7 (JavaScript/JSX)
  - 后端：Spring Boot 3.4.1 + Spring AI 1.0.3 (Java 21)
  - AI 模型：阿里云 DashScope（默认 qwen3.5-plus，支持可配置嵌入模型）
  - 向量数据库：PostgreSQL 16 + pgvector
  - 会话存储：Redis 7
  - 对象存储：MinIO
  - 身份验证：Spring Security + JWT
- **RAG 知识库**：使用 RAG 向量数据库存储政策文件、优惠信息、优惠政策等。
  - 知识库来源
    - 官方红头文件 PDF、Docx
      - 文档加载器 `Document loader` 载入文档
      - 嵌入模型生成嵌入向量
      - 存储至向量数据库 `vector_store`
    - 搜索工具搜集的信息，会自动存入向量数据库
      - Tavily Search API，Redis 缓存 120 分钟
    - 山东省商务厅（及各个地市）的网页与文件
      - 爬虫适配器实现，采用两阶段抓取（省级入口页 -> 各地市入口页）、BFS 深度控制、政策关键词筛选、附件抽取
      - URL 导入任务与待处理条目管理，支持人工审核确认入库
      - 重复文档筛选功能
  - 构建向量数据库 `vector_store`
    - 切分策略：默认切片大小 1600 字符，重叠 300 字符
    - 向量重排序：引入 DashScope 重排序模型提高对比准确率
    - 多嵌入模型支持：Ollama qwen3-embedding、DashScope text-embedding-v3，不同模型有独立向量表
    - 检索 Top-K：5，相似度阈值：0.7
  - 知识库管理功能
    - 文件夹树管理（创建、重命名、删除）
    - 文档上传、下载、预览、重新入库
    - 文档切片查看
    - 批量操作（批量删除、批量移动）
    - 网站导入任务（创建、取消、删除）
    - 待入库内容确认/驳回/批量确认

## 政策咨询智能体（Agent）

- 依赖 AI 大模型解决消费者以旧换新政策咨询问题。
- 核心特性
  - [x] 多轮对话支持（Redis 对话记忆 7 天）
  - [x] 引入 **ReAct (Reason + Act)** 框架，让 Agent 在每一步行动前先写下 `Thought`，再执行 `Action`，最后观察 `Observation`
  - [x] 思维链
  - [x] 工具意图分类器（`ToolIntentClassifier`）：工具调用前进行参数校验，拦截无效调用
  - [x] Agent 计划解析器（`AgentPlanParser`）：解析和执行多步计划
  - [x] 会话事实缓存（`SessionFactCacheService`）：结构化存储价格、地区、设备型号等关键事实，Redis TTL 7 天
- 提示词工程 `prompt`
  - 系统提示词：角色设定，引导指示（零样本提示），支持管理员动态配置
  - 聊天提示词：提示词模板（思维链 Chain）+ 少样本提示词 + 多模态思维链
  - 提示词技巧
    - 零样本提示词
    - 少样本提示词
    - RAG 检索增强搜索
    - 提示词模板
      - 思维链 `Chain` 写法：基于上下文 + RAG 结果
      - 标准写法：`[xxx]` 变量注入
  - 开场白配置，支持管理员动态设置
- 模型 `Model`
  - 模型参数
    - 模型温度 `Temperature`
    - 核采样大小 `Top_p`
    - 输出大小 `Max Length`
  - 多模态输入与解析
    - 视觉模型：图像分析、设备识别、发票识别
    - 文本模型
    - 语音模型：语音识别（ASR）
  - 动态模型管理
    - 支持四类模型：LLM、VISION、AUDIO、EMBEDDING
    - 管理员可在控制台新增、编辑、删除模型提供商
    - 设为默认模型、连接测试功能
    - API Key 加密存储（AES），支持密钥轮换
    - 模型绑定到智能体配置
    - 运行时动态 ChatClient 工厂（`DynamicChatClientFactory`）
- 上下文管理 `history`
  - 长期记忆：存储每次会话完整记录
  - 多轮对话：RAG 检索 + 上下文提示 + 多模态思维链
- 工具 `Tools`
  - 联网搜索 `webSearch`
    - Tavily Search API
    - Redis 缓存，TTL 120 分钟
    - 重试策略：2 次最大尝试，退避 350ms
  - 价格计算器 `calculateSubsidy`
    - 补贴比例：15%
    - 家电类补贴上限：2000 元（空调、冰箱、洗衣机、电视）
    - 手机、平板补贴上限：500 元
    - 智能手表、手环补贴上限：200 元
    - 支持品类：空调、冰箱、洗衣机、电视、热水器、微波炉、油烟机、洗碗机、燃气灶、净水器、手机、平板、智能手表、手环
  - 文件解析 `parseFile`：发票、旧机参数文件解析
  - 工具失败策略中心（`ToolFailurePolicyCenter`）：统一管理重试、退避与兜底提示模板
- 模型上下文协议 `MCP`
  - [ ] 日历/提醒 MCP (Google Calendar/Notion)
  - [ ] 实时电商/价格 MCP (Price Tracking)
  - [x] 地图 MCP（`amap-mcp`）
  - [ ] `fetch-mcp` 代替爬虫
  - 可拓展
    - [ ] 数据库
- 多级降级策略：流式 -> 非流式 -> 原生 REST 直接调用 -> 工具失败兜底

## 后端实现 `backend`

- 基于 Spring Boot 3.4.1 + Spring AI 1.0.3 (Java 21) + Redis 实现。
- 整体架构
  - Advisor 执行顺序：`SecurityAdvisor (order=10) -> MessageChatMemoryAdvisor -> ReReadingAdvisor (order=50) -> QuestionAnswerAdvisor -> LoggingAdvisor (order=90)`
- 用户系统
  - [x] 用户注册
  - [x] 用户登录
  - [x] 管理员登录
  - [x] 管理员修改密码
- 身份验证：用户密码采用 JWT-based 安全验证，不会泄漏用户密码，保证了用户信息安全。
- 多模态输入与解析
  - 支持图片上传，图片识别，自动识别图片中的家电类型等相关信息
  - 语音识别（ASR）
  - 发票识别
  - 设备识别
- 会话存储：Redis 缓存
- 核心服务
  - `ChatService`：对话核心逻辑（流式 + 非流式）
  - `RagRetrievalService`：检索服务
  - `TextSplitterService`：文本切片
  - `VectorStoreService`：向量存储服务
  - `KnowledgeService`：知识库业务服务
  - `ModelProviderService`：模型管理 CRUD
  - `UrlImportService`：URL 导入服务

## API 端点

- `POST /api/chat` - 标准对话
- `POST /api/chat/stream` - 流式对话（SSE）
- `GET /api/chat/health` - 健康检查
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/me` - 当前用户信息（需 JWT）
- `GET /api/conversations` - 会话列表（需 JWT）
- `GET /api/conversations/{sessionId}` - 获取会话（需 JWT）
- `DELETE /api/conversations/{sessionId}` - 删除会话（需 JWT）
- `POST /api/admin/auth/login` - 管理员登录
- `POST /api/admin/auth/change-password` - 管理员修改密码（需管理员 JWT）
- `GET /api/admin/models` - 获取模型列表（需管理员 JWT）
- `GET /api/admin/models/{id}` - 获取模型详情（需管理员 JWT）
- `POST /api/admin/models` - 新增模型（需管理员 JWT）
- `PUT /api/admin/models/{id}` - 更新模型（需管理员 JWT）
- `DELETE /api/admin/models/{id}` - 删除模型（需管理员 JWT）
- `PUT /api/admin/models/{id}/set-default` - 设为默认模型（需管理员 JWT）
- `POST /api/admin/models/{id}/test` - 测试模型连接（需管理员 JWT）
- `GET /api/admin/models/options` - 获取模型下拉选项（需管理员 JWT）
- `GET /api/admin/agent-config` - 获取智能体配置（需管理员 JWT）
- `PUT /api/admin/agent-config` - 更新智能体配置（需管理员 JWT）
- `POST /api/admin/agent-config/reset` - 重置智能体配置（需管理员 JWT）
- `POST /api/admin/agent-config/test` - 配置测试对话（需管理员 JWT）
- `GET /api/admin/knowledge/folders` - 获取知识库目录树（需管理员 JWT）
- `POST /api/admin/knowledge/folders` - 创建知识库文件夹（需管理员 JWT）
- `PUT /api/admin/knowledge/folders/{id}` - 更新知识库文件夹（需管理员 JWT）
- `DELETE /api/admin/knowledge/folders/{id}` - 删除知识库文件夹（需管理员 JWT）
- `POST /api/admin/knowledge/documents` - 上传知识库文档（需管理员 JWT）
- `POST /api/admin/knowledge/documents/extract-metadata` - 智能提取文档元数据（需管理员 JWT）
- `GET /api/admin/knowledge/documents/{id}/chunks` - 查询文档切片（需管理员 JWT）
- `GET /api/admin/knowledge/documents/{id}/download` - 下载原始文档（需管理员 JWT）
- `GET /api/admin/knowledge/documents/{id}/preview` - 获取预览地址（需管理员 JWT）
- `DELETE /api/admin/knowledge/documents/{id}` - 删除文档（需管理员 JWT）
- `POST /api/admin/knowledge/documents/{id}/reingest` - 重新入库文档（需管理员 JWT）
- `POST /api/admin/knowledge/documents/batch-delete` - 批量删除文档（需管理员 JWT）
- `POST /api/admin/knowledge/documents/batch-move` - 批量移动文档（需管理员 JWT）
- `GET /api/admin/knowledge/embedding-models` - 获取可用嵌入模型（需管理员 JWT）
- `GET /api/admin/knowledge/config` - 获取知识库配置（需管理员 JWT）
- `PUT /api/admin/knowledge/config` - 更新知识库配置（需管理员 JWT）
- `POST /api/admin/knowledge/url-imports` - 创建网站导入任务（需管理员 JWT）
- `GET /api/admin/knowledge/url-imports` - 查询网站导入任务与待处理条目（需管理员 JWT）
- `GET /api/admin/knowledge/url-imports/{id}` - 获取待入库内容详情（需管理员 JWT）
- `POST /api/admin/knowledge/url-imports/{id}/confirm` - 确认入库（需管理员 JWT）
- `POST /api/admin/knowledge/url-imports/batch-confirm` - 批量确认入库（需管理员 JWT）
- `POST /api/admin/knowledge/url-imports/{id}/reject` - 驳回待入库内容（需管理员 JWT）
- `POST /api/admin/knowledge/url-imports/{id}/cancel` - 取消网站导入任务（需管理员 JWT）
- `DELETE /api/admin/knowledge/url-imports/{id}` - 删除网站导入任务（需管理员 JWT）
- `DELETE /api/admin/knowledge/url-import-items/{id}` - 删除待入库内容（需管理员 JWT）
- `POST /api/multimodal/transcribe` - 语音识别
- `POST /api/multimodal/analyze-image` - 图像分析
- `POST /api/multimodal/analyze-invoice` - 发票识别
- `POST /api/multimodal/analyze-device` - 设备识别
- `GET /api/public/config/agent` - 获取公开智能体配置（无需认证）

## 前端 `frontend`

- React 19 + Vite 7。
- 主要页面
  - `HomePage` - 首页
  - `ChatPage` - 对话页（需登录）
  - `LoginPage` - 登录页
  - `RegisterPage` - 注册页
  - `PolicyQueryPage` - 政策查询页
  - `PolicyMatchingPage` - 政策匹配页
  - `UserCenterPage` - 用户中心页
  - `AdminConsolePage` - 管理员控制台（需登录）
- 核心组件
  - `ChatWindow` - 聊天窗口
  - `MessageBubble` - 消息气泡
  - `InputArea` - 输入区域
  - `Sidebar` - 侧边栏（会话列表）
  - `TopNavbar` - 顶部导航
  - `MainLayout` - 主布局
  - `ReferencesBlock` - 参考文献块
  - `ProtectedRoute` - 路由保护
- 管理员控制台功能
  - `agent` 标签页：概述卡片、配置编辑面板、效果预览、对话测试、JSON 配置，支持保存与重置
  - `knowledge` 标签页：文件夹树管理、文档上传、网站导入任务、文档切片查看、批量操作、待入库内容确认/驳回
  - `tools` 标签页：工具启用/禁用配置
  - `models` 标签页：模型 CRUD、设为默认、连接测试

## 数据库设计

- 主要表
  - `agent_config` - 智能体配置（id=1 为单例）
  - `model_provider` - 模型提供商（LLM、VISION、AUDIO、EMBEDDING 四类）
  - `users` - 用户表
  - `knowledge_folders` - 知识库文件夹
  - `knowledge_documents` - 知识库文档
  - `knowledge_config` - 知识库配置（单例）
  - `url_import_jobs` - 网站导入任务（软删除支持）
  - `url_import_items` - 待处理条目
  - `url_import_attachments` - 导入附件
  - `knowledge_document_sources` - 文档来源关联
  - `vector_store / vector_store_*` - 向量存储表（不同嵌入模型）
- 数据库迁移
  - `V2__create_agent_config.sql`
  - `V3__create_model_provider_and_extend_agent_config.sql`
  - `V4__create_url_import_tables.sql`
  - `V5__add_deleted_at_to_url_import_jobs.sql`

## 部署与运维

- Docker Compose 完整编排
  - `postgres (pgvector/pg16)` - 向量数据库
  - `redis (7-alpine)` - 会话存储与缓存
  - `minio (latest)` - 对象存储
  - `ollama (latest)` - 本地嵌入模型服务
  - `ollama-init` - 自动拉取 `qwen3-embedding:0.6b` 模型
  - `backend` - Spring Boot 应用
- 宝塔 Nginx 反向代理配置
  - `/` -> `127.0.0.1:5173`
  - `/api/` -> `127.0.0.1:8080/api/`
- 健康检查端点
  - `GET /actuator/health`
  - `GET /api/chat/health`
  - `GET /health`（前端）
- 环境变量
  - `DASHSCOPE_API_KEY` - 必需，DashScope API 密钥
  - `TAVILY_API_KEY` - 可选，联网搜索工具密钥
  - `APP_JWT_SECRET` - 必需（生产），JWT 签名密钥（Base64）
  - `APP_SECURITY_CORS_ALLOWED_ORIGIN_PATTERNS` - 生产域名 CORS 放行
  - `APP_EMBEDDING_OLLAMA_BASE_URL` - 可选，Ollama 嵌入地址
  - `APP_MODEL_PROVIDER_ENCRYPTION_SECRET` - 可选但推荐，模型管理 API Key 加密主密钥
  - `APP_MODEL_PROVIDER_LEGACY_ENCRYPTION_SECRETS` - 可选，历史加密密钥兼容列表

## 关键技术亮点

- 动态模型管理：管理员可在控制台配置多种第三方模型，并绑定到智能体。
- 多嵌入模型支持：不同文档可使用不同嵌入模型，有独立向量表。
- 工具意图分类：前置参数校验，减少无效工具调用。
- 会话事实缓存：结构化存储关键信息供多轮对话复用。
- 多级降级策略：流式 -> 非流式 -> 原生 REST -> 工具失败兜底。
- 向量重排序：DashScope 重排序提高检索准确率。
- URL 导入审核：爬虫结果支持人工审核后再入库。
- API Key 加密：模型密钥使用加密存储，支持密钥轮换。

## 版本更新记录

- 正式版 V1.0
- `20260310-管理员-控制台-知识库`：完善知识库从外部网站导入功能，去掉重复的文档做筛选
- `20260310-管理员-控制台-知识库`：增加功能，支持添加网页作为知识库来源、批量操作功能与爬虫脚本优化
- `20260309-管理员-控制台-智能体配置`：前端 UI 更新
- `feat: add model provider management and refresh docs`
