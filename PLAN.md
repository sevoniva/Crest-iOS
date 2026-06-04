# Crest iOS App 规划

> 基于 AGENTS.md 规范：明确假设、最小可行、目标驱动。

---

## 0. 项目背景与假设

**Crest** 是一个 BI 数据可视化平台（基于 DataEase），已有 Web 端完整功能。目标是构建一个 **iOS 原生 App**，让用户在移动端查看仪表板、图表和数据集。

**关键假设（需确认）：**
- 服务器地址：`https://crest.sevoniva.com/`
- 认证方式：`X-CREST-TOKEN` header（从登录接口获取）
- 后端 API 已支持移动端（`X-CREST-MOBILE: true` header）
- **MVP 目标**：只读展示，暂不支持编辑/创建

---

## 1. 核心决策与方案对比

### 决策 1：图表渲染方式

| 方案 | 描述 | 优点 | 缺点 | 推荐度 |
|---|---|---|---|---|
| **A. 纯原生图表** | 用 DGCharts/Swift Charts 原生渲染所有图表 | 性能最好，交互原生 | 开发量极大，需映射 Crest 所有图表类型（柱状图、折线图、饼图、地图、表格等 20+ 种） | ⭐⭐ |
| **B. WebView 嵌入** | 用 WKWebView 加载 Crest 前端渲染的图表 HTML | 复用现有图表逻辑，100% 还原 | 性能一般，内存占用高，离线体验差 | ⭐⭐⭐ |
| **C. 混合方案 (Recommended)** | 简单图表（柱状/折线/饼图）用 DGCharts 原生渲染；复杂图表（地图、表格、自定义）用 WebView | 平衡性能与开发量 | 架构稍复杂 | ⭐⭐⭐⭐ |
| **D. 服务端截图 (最快)** | 服务端生成图表 PNG，App 只展示图片 | 开发最快 | 无交互，无法下钻，实时性差 | ⭐⭐⭐ |

**建议：先采用方案 B（WebView）作为 MVP**，快速验证产品价值。后续迭代再逐步替换高频图表为原生渲染（过渡到方案 C）。

### 决策 2：技术栈

- **语言/框架**：Swift + SwiftUI（iOS 15+）
- **网络层**：`URLSession` + 自定义 `APIService`（轻量封装，不引入 Alamofire）
- **状态管理**：`@Observable` / `ObservableObject`（SwiftUI 原生）
- **图表渲染**：`WKWebView`（MVP 阶段）
- **数据缓存**：`UserDefaults`（Token）+ 内存缓存（API 响应）
- **图片加载**：`AsyncImage`（SwiftUI 原生）

### 决策 3：认证流程

```
1. 获取公钥      GET  /public-key
2. RSA 加密密码   前端用公钥加密密码
3. 登录          POST /login/local-login  → 获取 X-CREST-TOKEN
4. 后续请求       每个请求 header 带 X-CREST-TOKEN
5. Token 刷新     过期时自动刷新
```

---

## 2. MVP 功能范围（第一阶段）

**只读展示，不涉及编辑。**

### 2.1 登录模块
- [ ] 账号密码登录（支持 RSA 加密）
- [ ] Token 持久化存储
- [ ] 自动登录 / Token 过期处理

### 2.2 工作台（首页）
- [ ] 展示用户有权限的**仪表板/数据大屏列表**
- [ ] 搜索 / 筛选
- [ ] 下拉刷新

### 2.3 仪表板详情
- [ ] 展示单个仪表板的所有组件（图表、文字、图片等）
- [ ] 支持**移动端布局**（复用 Crest 已有的 `mobileLayout` 能力）
- [ ] 图表交互：点击查看详情、下钻（如有）
- [ ] 下拉刷新数据

### 2.4 个人中心
- [ ] 显示当前用户信息
- [ ] 退出登录（清除 Token）

---

## 3. API 梳理（已验证可用）

```
BASE_URL: https://crest.sevoniva.com
```

| 功能 | Method | Path | 说明 |
|---|---|---|---|
| 获取公钥 | GET | `/public-key` | 登录前获取 RSA 公钥 |
| 登录 | POST | `/login/local-login` | body: `{username, password}` |
| 刷新 Token | GET | `/login/refresh` | 延长会话 |
| 获取 UI 配置 | GET | `/sys-parameter/ui` | 主题、Logo 等 |
| 可视化树 | POST | `/data-visualization/tree` | 获取仪表板目录树 |
| 可视化详情 | POST | `/data-visualization/detail` | 获取单个仪表板配置 |
| 图表数据 | POST | `/chart-data/data` | 获取图表渲染数据 |
| 数据集树 | POST | `/dataset/tree` | 获取数据集目录 |
| 数据集详情 | GET | `/dataset/detail/{id}` | 获取数据集元数据 |
| 数据集数据 | POST | `/dataset/previewData` | 预览数据集数据 |
| 用户信息 | GET | `/user/info` | 获取当前用户信息 |
| 水印配置 | GET | `/watermark` | 获取水印设置 |

**通用 Header：**
```
X-CREST-TOKEN: <登录返回的 token>
X-CREST-MOBILE: true
Accept-Language: zh-CN
```

---

## 4. 架构设计（极简）

```
Crest-iOS
├── App
│   ├── CrestIOSApp.swift          # 入口
│   └── AppState.swift             # 全局状态（登录态）
├── Core
│   ├── API
│   │   ├── APIService.swift       # 网络请求封装
│   │   ├── AuthAPI.swift          # 登录相关接口
│   │   ├── DashboardAPI.swift     # 仪表板相关接口
│   │   └── ChartAPI.swift         # 图表数据接口
│   ├── Models
│   │   ├── AuthModels.swift       # 登录响应模型
│   │   ├── DashboardModels.swift  # 仪表板模型
│   │   └── ChartModels.swift      # 图表模型
│   └── Utils
│       ├── RSAEncryptor.swift     # RSA 加密工具
│       └── TokenStorage.swift     # Token 存储
├── Features
│   ├── Login
│   │   └── LoginView.swift        # 登录页
│   ├── DashboardList
│   │   ├── DashboardListView.swift      # 工作台列表
│   │   └── DashboardListViewModel.swift # 列表 VM
│   ├── DashboardDetail
│   │   ├── DashboardDetailView.swift      # 仪表板详情
│   │   ├── DashboardDetailViewModel.swift # 详情 VM
│   │   └── ChartWebView.swift             # 图表 WebView
│   └── Profile
│       └── ProfileView.swift      # 个人中心
└── Resources
    └── Assets.xcassets
```

---

## 5. 验证标准（Goal-Driven）

### Phase 1 完成标准
```
1. 能成功登录 crest.sevoniva.com
   → verify: 输入 admin / d6f86b496a895c526b92d639 后能进入工作台

2. 能看到仪表板列表
   → verify: 工作台至少显示 1 个用户有权限的仪表板

3. 能进入仪表板详情并看到图表
   → verify: 点击进入仪表板后，图表正常渲染（WebView 方式）

4. 能退出登录
   → verify: 点击退出后回到登录页，Token 已清除
```

---

## 6. 风险提示

1. **Crest 后端 API 可能未完全适配移动端**：虽然前端有 `X-CREST-MOBILE` header，但某些接口可能返回 HTML 或不支持移动端布局。
2. **图表交互复杂度**：WebView 方案下，图表的下钻、联动等交互需要额外处理 JS Bridge。
3. **Token 安全**：Token 存储在 Keychain 中，不要存 UserDefaults。
4. **证书问题**：服务器使用 HTTPS，需确认证书在 iOS 上可信。

---

## 7. 下一步行动

等待你确认以下事项后即可开始编码：

1. **图表渲染方案**：确认采用方案 B（WebView）作为 MVP？
2. **iOS 版本要求**：最低支持 iOS 16 还是 17？
3. **功能优先级**：MVP 只做只读展示，还是也需要支持简单的筛选/查询？
4. **是否需要离线能力**：MVP 阶段是否需要缓存仪表板数据供离线查看？
