# AppFit Native iOS Requirement (MVP)

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

## 3. Non-Goals (MVP 不做)
- 不做登录/注册
- 不做云端数据库与同步
- 不做社交、排行榜
- 不做训练记录统计
- 不做视频流媒体（先用本地图片 + 文本）

## 4. Current Scope (v0.2)
### 4.1 页面
1. Tab 1 - 搜索课件
- 课程搜索与结果展示（基于本地课程 JSON）。
- 可进入课程详情与训练步骤页面。

2. Tab 2 - 动作细节
- 动作列表与搜索（动作名、类别、目标肌群）。
- 动作详情（说明、目标肌群、器械、常见错误、配图）。

3. Tab 3 - 训练数据
- 体重变化图表（折线图）。
- 每周训练时长图表（柱状图）。
- 支持在 App 内手动新增、编辑、删除体重与周训练数据。

### 4.2 数据
- `courses.json`：课件搜索与训练步骤。
- `exercise_library.json`：动作细节内容。
- `progress_seed.json`：训练数据初始值。
- 用户修改后的训练数据落地到 `UserDefaults`（本地持久化）。

### 4.3 技术
- 原生 iOS：SwiftUI
- 架构：`View + ViewModel + Local Repository`
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
  "bodyWeightEntries": [
    { "id": "string", "date": "yyyy-MM-dd", "weight": 71.2 }
  ],
  "weeklyTrainingEntries": [
    { "id": "string", "weekLabel": "2026-W10", "minutes": 210 }
  ]
}
```

## 6. File/Module Convention
当前 SwiftUI MVP 代码位置：`ios/AppFitMVP`

- `AppFitMVP/Models`: 数据模型
- `AppFitMVP/Services`: 本地数据读取
- `AppFitMVP/ViewModels`: 页面状态管理
- `AppFitMVP/Views`: 页面与组件
- `AppFitMVP/Resources/Data`: JSON
- `AppFitMVP/Resources/Images`: 本地图片

## 7. Acceptance Criteria
满足以下全部条件即视为当前版本完成：
1. 可稳定切换 3 个 Tab（课件、动作、数据）。
2. Tab 1 可基于 `courses.json` 搜索课程并进入训练步骤。
3. Tab 2 可基于 `exercise_library.json` 渲染动作列表与动作详情。
4. Tab 3 可基于 `progress_seed.json` 渲染图表。
5. Tab 3 支持手动新增、编辑、删除数据，且界面立即更新。
6. 数据功能全程不依赖网络。

## 8. Iteration Plan
### Phase A (Completed)
- SwiftUI 原生 MVP 骨架完成。
- 本地 JSON 驱动完成。
- 三栏 Tab 结构完成。

### Phase B (In Progress)
- 训练模式增强：倒计时、自动跳下一步、震动提示。
- 课程与动作页面的筛选与排序增强。
- 数据页面增加更多统计维度（周/月对比）。

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
2. 我实现代码后，会回写 `requirement.md`：`MVP Scope`（如有变化）、`Acceptance Criteria`（完成项勾选或更新）、`Iteration Plan`（阶段进度更新）、`Delivery Log`（记录本次实现）。
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

## 10. Immediate Next Slice (v0.3 建议)
1. 训练模式倒计时（动作计时 + 休息计时）。
2. 数据页支持按周自动生成标签，减少手输。
3. 动作详情增加“替代动作”和“进阶/回退版本”。

## 11. Delivery Log
> 由 Codex 维护。每次完成一个 Change Request，就在这里追加一条。

### 2026-03-10 - Bootstrap
- Delivered: SwiftUI 原生 MVP（课程列表 / 课程详情 / 训练模式）；本地 `courses.json` 驱动与离线图片资源加载；新建 `ios/AppFitMVP` 工程并完成编译验证。
- Build: `xcodebuild ... build` 通过。

### 2026-03-10 - CR-20260310-02
- Delivered: 完成三栏 Tab 架构。Tab 1 为课件搜索与训练步骤；Tab 2 为动作细节列表与详情；Tab 3 为体重/每周训练时长图表与手动编辑能力。
- Data: 新增 `exercise_library.json` 与 `progress_seed.json`，并接入 `UserDefaults` 本地持久化。
- Build: `xcodebuild -project ios/AppFitMVP/AppFitMVP.xcodeproj -scheme AppFitMVP -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/AppFitMVPDerived build` 通过。
