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
