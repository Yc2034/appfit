# AppFit Native iOS Requirement

## 1. Product Goal
构建一个 **离线可用的健身课程课件 App**，用于训练时跟随课程内容执行动作，而不是记录打卡。

核心价值：
- 打开即能找到今天要练的课
- 进入课程后按步骤顺滑执行
- 每一步有清晰文字说明 + 配图
- 数据完全本地化，无云端依赖

## 2. Target User
- 主要用户：你自己（个人训练流程）
- 次要用户：未来可分享给少量朋友测试

## 3. Non-Goals (当前版本不做)
- 不做登录/注册
- 不做云端数据库与同步
- 不做社交、排行榜
- 不做训练记录统计
- 不做视频流媒体（先用本地图片 + 文本）

## 4. Current Scope (v0.5)
### 4.1 页面
1. Tab 1 - 课件
- 课程列表展示（基于本地课程 JSON）。
- 基于标签（Tag）的本地筛选能力（支持多选）。
- 可进入课程详情与训练步骤页面。
- 课程详情支持本地音频引导播放（可选，按课程配置）。

2. Tab 2 - 动作细节
- 动作列表与搜索（动作名、类别、目标肌群），列表以双列网格展示。
- 动作详情（说明、目标肌群、器械、常见错误、配图）。

3. Tab 3 - 训练数据
- 月度体重变化图表（折线图，按 `yyyy-MM` 展示，只读）。
- 每周训练时长图表（柱状图）。
- 支持在 App 内手动新增、编辑、删除每周训练数据（体重模块当前不提供交互编辑）。

### 4.2 数据
- `courses.json`：课件筛选与训练步骤。
- `courses.json` 可为课程配置 `audioGuide`（本地音频标题 + 文件名）。
- `exercise_library.json`：动作细节内容。
- `progress_seed.json`：训练数据初始值（当前 `schemaVersion: 2`，体重为月度结构）。
- 用户修改后的训练数据落地到 `UserDefaults`（本地持久化）。

### 4.3 技术
- 原生 iOS：SwiftUI
- 架构：`View + ViewModel + Local Repository`
- UI 架构：`DesignSystem + Reusable Components`
- 本地音频：`AVAudioPlayer`（播放/暂停/拖动/时长显示）
- 最低系统：iOS 17（当前实现）

## 5. Data Schema (Single Source of Truth)
`courses.json` 顶层是数组，每个 Course 结构如下：

```json
{
  "id": "string",
  "title": "string",
  "subtitle": "string",
  "focus": "string",
  "level": "Beginner|Intermediate|Advanced",
  "totalMinutes": 45,
  "tags": ["string"],
  "coverImageName": "local_image_name",
  "audioGuide": {
    "title": "string",
    "fileName": "local_audio_file_name.mp3"
  },
  "sessions": [
    {
      "id": "string",
      "title": "string",
      "goal": "string",
      "estimatedMinutes": 20,
      "steps": [
        {
          "id": "string",
          "title": "string",
          "instruction": "string",
          "durationSeconds": 45,
          "restSeconds": 30,
          "imageName": "local_image_name"
        }
      ]
    }
  ]
}
```

说明：`audioGuide` 为可选字段；未配置时课程页不展示音频模块。

`exercise_library.json` 顶层是数组，每个 Movement 结构如下：

```json
{
  "id": "string",
  "name": "string",
  "category": "string",
  "targetArea": "string",
  "equipment": "string",
  "instruction": "string",
  "commonMistakes": ["string"],
  "imageName": "local_image_name"
}
```

`progress_seed.json` 结构如下：

```json
{
  "schemaVersion": 2,
  "bodyWeightMonthlyEntries": [
    { "id": "string", "month": "yyyy-MM", "weight": 71.2, "updatedAt": "2026-03-11T12:30:00Z" }
  ],
  "weeklyTrainingEntries": [
    { "id": "string", "weekLabel": "2026-W10", "minutes": 210 }
  ]
}
```

说明：`progress_seed.json` 兼容旧字段 `bodyWeightEntries` 的解码路径，但当前体重图展示以 `bodyWeightMonthlyEntries` 为准。

## 6. File/Module Convention
当前 SwiftUI 代码位置：`ios/AppFitMVP`

- `AppFitMVP/Models`: 数据模型
- `AppFitMVP/Services`: 本地数据读取
- `AppFitMVP/ViewModels`: 页面状态管理
- `AppFitMVP/Views`: 页面
- `AppFitMVP/DesignSystem`: 主题与设计 token（Color / Font / Layout）
- `AppFitMVP/Components`: 可复用 UI 组件（Card / Button / Tag / Section Header）
- `AppFitMVP/Resources/Data`: JSON
- `AppFitMVP/Resources/Images`: 本地图片
- `AppFitMVP/Resources/Audio`: 本地音频（放置与接入规则见 `Audio/README.md`）

## 7. Acceptance Criteria
满足以下全部条件即视为当前版本完成：
1. 可稳定切换 3 个 Tab（课件、动作、数据）。
2. Tab 1 可基于 `courses.json` 按标签筛选课程并进入训练步骤。
3. Tab 2 可基于 `exercise_library.json` 渲染双列动作列表与动作详情。
4. Tab 3 可基于 `progress_seed.json` 渲染“月度体重折线 + 每周训练柱状”图表，月体重样例数据点数量需完整呈现。
5. Tab 3 支持手动新增、编辑、删除“周训练”数据，且界面立即更新（体重模块当前为只读展示）。
6. 数据功能全程不依赖网络。
7. 页面层不再散落硬编码 Color/Font（图表库必要配置除外）。
8. 亮色/暗色模式下核心页面具备可读性和一致视觉层级。
9. 当课程配置 `audioGuide` 时，课程页可进行本地音频播放/暂停、进度拖动与时长显示。
10. 当本地音频文件缺失时，页面给出明确提示且不影响课程浏览与训练流程。
11. 当本地存在历史缓存时，体重图仍以 `progress_seed.json` 的月度数据为准，不应出现“4 个点只渲染 1 个”的情况。

## 8. Iteration Plan
### Phase A (Completed)
- SwiftUI 原生骨架完成。
- 本地 JSON 驱动完成。
- 三栏 Tab 结构完成。

### Phase B (In Progress)
- UI Design System（Theme + Components）完成，并已重构核心页面。
- 视觉风格升级为“青春运动风（低饱和、长时间可读）”。
- 课程页本地音频引导能力完成（长时音频可播放）。
- 训练模式增强：倒计时、自动跳下一步、震动提示。
- 课程与动作页面的筛选与排序增强。
- 数据页面增加更多统计维度（周/月对比）。
- `CR-20260311-01` 已完成（按最终口径）：体重数据升级为月度结构，体重趋势图按 JSON 只读展示，修复历史缓存导致的数据点丢失问题。

### Phase C
- 内容生产效率：模板化 JSON、批量导入图片。
- 数据导入/导出（本地文件）。
- iPad 布局适配。

## 9. Collaboration Contract
我们采用双文件协作：
1. `changerequest.md`：你维护，只写“想改什么”。
2. `requirement.md`：我维护，记录“当前真实状态、已实现范围、下一步计划”。

执行规则：
1. 你在 `changerequest.md` 新增一个请求块。
2. 我实现代码后，会回写 `requirement.md`：`Product Scope`（如有变化）、`Acceptance Criteria`（完成项勾选或更新）、`Iteration Plan`（阶段进度更新）、`Delivery Log`（记录本次实现）。
3. 我不会改写你在 `changerequest.md` 的原始诉求，只会追加处理状态。

`changerequest.md` 请求模板如下：

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

## 10. Delivery Log
### CR-20260311-01 (Done, 2026-03-11)
- 体重数据模型由按日 `bodyWeightEntries` 升级为按月 `bodyWeightMonthlyEntries`。
- `progress_seed.json` 升级到 `schemaVersion: 2`，并提供月度体重样例数据。
- `ProgressStore` 体重数据改为优先读取本地 JSON（避免历史缓存导致图表仅渲染 1 个点）。
- `Tab 3` 体重图改为月度趋势展示（平滑折线 + 点位 + 面积层），并优化月份轴标签可读性。
- 按最终需求移除体重编辑交互入口，体重模块改为只读展示。
- 每周训练时长模块保持原有行为，未发生功能回归。
