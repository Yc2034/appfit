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

## 4. MVP Scope (v0.1)
### 4.1 页面
1. 课程列表页
- 展示课程卡片（封面、标题、时长、难度、标签）
- 支持关键字搜索（标题/标签/目标）

2. 课程详情页
- 展示课程简介与章节（Session）
- 每个章节可进入训练模式

3. 训练模式页
- 按 Step 顺序展示：动作名、说明、时长、休息、图片
- 支持上一步/下一步
- 展示当前步骤进度（Step x / n）

### 4.2 数据
- 数据源：本地 `courses.json`
- 媒体：本地图片资源（PNG/JPG）
- 读取方式：Bundle 内离线读取

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

## 6. File/Module Convention
当前 SwiftUI MVP 代码位置：`ios/AppFitMVP`

- `AppFitMVP/Models`: 数据模型
- `AppFitMVP/Services`: 本地数据读取
- `AppFitMVP/ViewModels`: 页面状态管理
- `AppFitMVP/Views`: 页面与组件
- `AppFitMVP/Resources/Data`: JSON
- `AppFitMVP/Resources/Images`: 本地图片

## 7. Acceptance Criteria (MVP)
满足以下全部条件即视为 v0.1 完成：
1. App 启动后可看到至少 2 门课程
2. 课程搜索可正常筛选
3. 可进入课程详情并看到章节列表
4. 可进入训练模式并完成步骤切换
5. 全程不依赖网络
6. `courses.json` 修改后可驱动页面内容变化

## 8. Iteration Plan
### Phase A (已开始)
- 建立 SwiftUI 原生 MVP 骨架
- 完成本地 JSON 驱动展示

### Phase B
- 训练模式增强：倒计时、自动跳下一步、震动提示
- 收藏/最近训练入口
- 课程筛选（目标肌群、器械、时长）

### Phase C
- 内容生产效率：模板化 JSON、批量导入图片
- 本地数据库（可选，SQLite/CoreData）用于索引/性能
- iPad 布局适配

## 9. How We Iterate From This File
后续每次迭代，你只需要在本文件追加/修改以下区块：
1. `Change Request`：你想加什么
2. `Scope`：本次只做哪些
3. `Out of Scope`：明确不做什么
4. `Acceptance Criteria`：如何判断完成

建议模板：

```md
## Change Request (YYYY-MM-DD)
- Goal:
- Scope:
- Out of Scope:
- Acceptance Criteria:
```

## 10. Immediate Next Slice (v0.2 建议)
1. 训练模式倒计时（动作计时 + 休息计时）
2. 训练中屏幕常亮选项
3. 按“今日训练”聚合入口（1-2 个推荐 session）

