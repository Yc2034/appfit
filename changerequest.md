# AppFit Change Requests

说明：
1. 此文件由你维护，负责提出变更请求。
2. 每个请求新增一个块，不覆盖旧块。
3. 我处理完成后会把 `Status` 从 `Open` 更新为 `Done`，并把结果写入 `requirement.md` 的 `Delivery Log`。

模板：

```md
## CR-YYYYMMDD-XX
- Status: Open
- Goal:
- Scope:
- Out of Scope:
- Acceptance Criteria:
- UI Reference: (可选，Figma 链接或截图说明)
- Notes: (可选)
```

---

## CR-20260310-01
- Status: Done
- Goal: 构建 SwiftUI 原生 iOS MVP，替换旧 RN 项目
- Scope: 课程列表、课程详情、训练模式；本地 JSON + 本地图片
- Out of Scope: 登录、云端同步、训练记录统计
- Acceptance Criteria: 可离线查看课程并按步骤进行训练
- UI Reference: 无
- Notes: 已交付，详情见 `requirement.md` -> `Delivery Log`

## CR-20260310-02
- Status: Done
- Goal: 新增三栏 Tab 导航，并建立可驱动页面渲染的基础本地 JSON 数据结构。
- Scope:
  - 新增 3 个 Tab：
    - Tab 1: 课件搜索（课程检索与结果展示）
    - Tab 2: 动作细节（按训练动作查看详细说明）
    - Tab 3: 训练数据（展示体重变化和每周训练时长图表）
  - 为上述 3 个 Tab 设计并接入最小可用 JSON 结构。
  - Tab 3 的数据支持在 App 内手动编辑（至少可修改体重记录与每周训练时长）。
- Out of Scope:
  - 大规模真实数据录入
  - 云端同步与账号系统
- Acceptance Criteria:
  - 可以在 App 内稳定切换 3 个 Tab。
  - 每个 Tab 均能基于本地 JSON 完成基础渲染（非空白页）。
  - 在 Tab 3 修改数据后，页面能立即反映更新结果。
- UI Reference: 暂无（先按系统风格做可用版本）
- Notes: 已交付。实现了 3 Tab 架构、3 份基础 JSON 数据源、Tab 3 的手动编辑与图表实时更新。

## CR-20260310-03
- Status: Done
- Goal: 建立统一且现代化的 AppFit UI 架构（Design System），实现 UI 与业务逻辑代码的高效解耦。
- Scope: 
  - 提取全局定义文件 `Theme.swift`（统一管理 AppColor, AppFont, AppLayout 等设计规范）。
  - 封装可复用的核心基础组件（如 `AppFitCard`, `AppFitButton`, `TagView` 等）。
  - 运用新主题和组件重构现有页面（各 Tab 首页、课程详情页、训练模式页等）。
  - 本次必须覆盖的文件范围：
    - `Views/MainTabView.swift`
    - `Views/CourseSearchTabView.swift`
    - `Views/CourseDetailView.swift`
    - `Views/SessionPlayerView.swift`
    - `Views/MovementLibraryTabView.swift`
    - `Views/ProgressTabView.swift`
    - `Views/LocalImageView.swift`（按新主题适配占位态）
  - 确立视觉风格：灵动、明快、极具健身氛围，并能良好适配系统暗/亮色模式。
- Out of Scope: 核心业务逻辑架构变更、添加新业务特性、极其复杂的转场动画。
- Acceptance Criteria: 
  - 新增 Design System 文件后，页面层不再散落硬编码 Color/Font（图表库必要配置除外）。
  - 各个页面的卡片、按钮、文字排版在视觉形态上保持高度一致。
  - 暗色模式与亮色模式下，以上覆盖页面均可正常阅读（无明显对比度问题）。
  - 现有业务行为不变：3 Tab 导航、课程检索、动作详情、数据新增/编辑/删除均保持可用。
  - 作为未来的 UI 风格基石，后续开发可直接复用这套组件。
- UI Reference: 现代运动类 App (高饱和度强调色、深/浅色卡片背景的层级分离)
- Notes: 已交付。已新增 Theme + Components，并完成主要页面 UI 重构，暗/亮色可用，业务行为保持不变。

## CR-20260310-04
- Status: Done
- Goal: 将整体视觉升级为“青春运动风”，强调轻快与专注，不走高饱和刺眼路线，适合连续 30 分钟训练时观看。
- Scope:
  - 调整全局色板：降低饱和度与对比冲击，保留运动感但避免荧光感。
  - 优化训练场景可读性：大字号关键信息、清晰层级、降低视觉噪音。
  - 重做关键页面视觉细节：Tab 首页、训练模式页、动作详情页、数据页。
  - 增加适度动效（切换/反馈），但避免花哨与分散注意力。
  - 在课程页面加入本地音频播放能力（支持长时音频，目标可覆盖约 45 分钟训练音频）。
  - 音频控制至少包含：播放/暂停、进度显示、进度拖动、已播/总时长显示。
- Out of Scope:
  - 新业务功能开发
  - 大规模页面结构重排
- Acceptance Criteria:
  - 连续浏览 20-30 分钟不产生明显视觉疲劳（主观体验目标）。
  - 页面整体风格一致，且“青春运动感”明显提升。
  - 训练模式页在单手快速扫读下可在 1 秒内识别当前动作名、倒计时/步骤信息。
  - 课程页面可加载并播放本地音频文件，长音频播放过程稳定。
  - 本地音频文件不存在时，页面给出明确提示且不影响其他功能使用。
  - 不影响现有功能与数据流程（搜索、详情、编辑、图表等均可用）。
- UI Reference: 年轻运动感、低饱和、清爽分层、偏实用导向。
- Notes: 已交付。完成低饱和青春运动风升级，并在课程页接入本地音频播放（播放/暂停/进度拖动/时长显示/缺失文件提示）。

## CR-20260311-01
- Status: Done
- Goal: 优化体重数据可视化体验，将体重趋势改为按月份观察，核心是稳定渲染好看的月度曲线图（无需体重编辑交互）。
- Scope:
  - 调整 `progress_seed.json` 体重相关数据结构，使其支持月度趋势展示和后续扩展。
  - 修改 Tab 3 体重可视化逻辑，按月份展示体重变化曲线。
  - 优化体重曲线图样式（可读性、层级、视觉美观）。
  - 体重模块按“展示优先”实现，不提供体重新增/编辑/删除交互入口。
- Out of Scope:
  - 云端同步、账号系统、跨设备数据同步。
  - 接入 HealthKit 或第三方健康平台数据。
  - 新增体脂率等其他生理指标模块。
- Acceptance Criteria:
  - 在 Tab 3 可按月份查看体重变化趋势，图表不再仅依赖按日散点展示。
  - 对于当前 `progress_seed.json` 的 4 条月体重样例，图表应渲染出 4 个数据点。
  - 体重图展示以本地 JSON 为准，不受历史本地缓存干扰。
  - 曲线图视觉风格与现有 Design System 保持一致，且在深浅色模式下可读性良好。
  - 该改动不影响每周训练时长模块的新增/编辑/删除与图表展示。
- UI Reference: 低饱和、清爽、偏实用导向；强化“月度趋势”的可读性与线条质感。
- Notes: 已交付。体重数据已升级为月度结构，Tab 3 体重图改为按月趋势展示，并按最新口径移除体重编辑交互，专注图表展示。
