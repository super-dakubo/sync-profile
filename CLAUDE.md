# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

sync-profile 是一个"开发者知识系统"种子包，将个人侧写、AI 协作规则、踩坑记录、权限配置、项目骨架打包成可跨环境复制的模板集。核心操作由 [SKILL.md](./SKILL.md) 定义，通过 Claude Code Skill 系统触发。**本仓库不是应用项目，而是"知识基础设施"。**

### 核心概念：双目录架构

| 角色 | 路径 | 说明 |
|------|------|------|
| **代码仓库**（编辑用） | `d:\code\sync-profile\sync-profile\` | 用 git 管理版本，在此编辑 |
| **全局 Skill**（运行时用） | `C:\Users\PC_WIN10\.claude\skills\sync-profile\` | Claude Code 执行时读取此路径 |

两个目录内容几乎一致，但全局 Skill 不包含 `CLAUDE.md`、`README.md`、`.git/`。修改仓库后需手动复制到 Skill 目录部署。

## 目录结构

```
sync-profile/
├── SKILL.md                  ← 入口：定义四个 Skill 操作
├── seed.yaml                 ← 版本号 + changelog + 文件 MD5 校验码
├── README.md / README.html   ← 项目说明（仅仓库持有，不部署到 skill）
├── profile/                  ← 个人侧写（跨环境通用）
│   ├── coding.md             ←   编码规范（通用约束）
│   ├── personal.md           ←   个人侧写（技术栈、习惯）
│   └── workflow.md           ←   AI 协作规则
├── config/                   ← 全局权限配置模板
│   ├── global-settings.json  ←   通用 allow/deny 列表
│   └── permissions.md        ←   权限设计原则
├── knowledge/                ← 踩坑记录，按语言/版本分层
│   ├── common/debugging.md   ←   通用调试方法论
│   └── rust/tauri-pitfalls.md←   Rust/Tauri 2.0 专项
├── scaffolds/                ← 项目骨架模板（handlebars .hbs）
│   ├── generic/              ←   通用项目模板
│   │   └── CLAUDE.md.hbs
│   └── rust-tauri/           ←   Rust + Tauri 项目模板
│       ├── CLAUDE.md.hbs
│       ├── LESSONS.md.hbs
│       └── settings.local.json.hbs
└── scripts/                  ← PowerShell 自动化脚本
    ├── generate-scaffold.ps1 ←   用 .hbs 模板生成项目文件
    ├── merge-settings.ps1    ←   合并种子包与目标权限配置
    └── compute-hash.ps1      ←   计算所有文件 MD5（用于 merge）
```

## Skill 工作流（由 SKILL.md 定义）

种子包通过 `/sync-profile init|pull|refresh|merge` 触发，每个操作有精确步骤：

- **`/sync-profile init`** — 新项目初始化：询问语言/框架 → 按版本过滤 knowledge 生成 LESSONS.md → 选 scaffold 生成骨架 → 合并权限配置
- **`/sync-profile pull`** — 回收项目经验：从项目 LESSONS.md 提取新踩坑记录，按语言归类追加到 seed knowledge
- **`/sync-profile refresh`** — 同步种子包更新：对比版本号，增量覆盖 scaffolds/ 和配置，保留用户自定义内容
- **`/sync-profile merge`** — 合并两个种子包：基于 MD5 校验码逐文件对比，展示 diff 由用户决策

## 关键技术决策

- **模板引擎**：Handlebars（.hbs），PowerShell 脚本去掉后缀后写入目标项目
- **权限分层**：通用权限放全局 `~/.claude/settings.json`，项目特有权限放 `.claude/settings.local.json`
- **知识过滤**：knowledge 条目用 `**适用：**` 标签标记版本范围，init 时根据目标项目版本过滤
- **版本管理**：`seed.yaml` 记录版本号、changelog、各文件的 MD5 校验码（自身用 `SKIP_SELF_HASH` 占位）
- **权限 defaultMode**：始终为 `acceptEdits`

## 常用命令

```powershell
# 生成项目骨架
pwsh scripts/generate-scaffold.ps1 -SeedPath <path> -ProjectPath <path> -ScaffoldType <rust-tauri|generic>

# 合并权限配置
pwsh scripts/merge-settings.ps1 -SeedPath <path> -TargetPath <path>

# 计算文件 MD5（更新 seed.yaml 用）
pwsh scripts/compute-hash.ps1 -SeedPath <path>

# 部署仓库 → 全局 Skill
Copy-Item "d:\code\sync-profile\sync-profile\*" "C:\Users\PC_WIN10\.claude\skills\sync-profile\" -Recurse -Force -Exclude "CLAUDE.md","README.md",".git"

# 验证部署结果
diff -rq "d:\code\sync-profile\sync-profile" "C:\Users\PC_WIN10\.claude\skills\sync-profile" --exclude="CLAUDE.md" --exclude="README.md" --exclude=".git"
```

## 扩展指南

| 操作 | 步骤 |
|------|------|
| **添加踩坑记录** | 在 `knowledge/` 下按 `语言/主题.md` 创建文件，条目用 `**适用：**` 标签标记版本范围 |
| **添加脚手架** | 在 `scaffolds/` 下创建目录，放入 `.hbs` 模板文件（写入目标项目时会自动去掉 `.hbs` 后缀） |
| **添加侧写项** | 编辑 `profile/` 下对应文件（coding.md / personal.md / workflow.md） |
| **新增权限** | 编辑 `config/global-settings.json`，然后运行 merge-settings 合并到目标项目 |
| **部署更新** | 修改仓库 → 更新 `seed.yaml` 版本号和 changelog → 复制文件到全局 skill 目录 |

## 重要约束

- 修改仓库后必须手动复制到全局 Skill 目录（`C:\Users\PC_WIN10\.claude\skills\sync-profile\`）才能生效
- 部署到 Skill 时不包含 `CLAUDE.md`、`README.md`、`.git/`
- `seed.yaml` 中的 `files` MD5 用于 merge 操作的文件比对，每次修改后需用 `compute-hash.ps1` 重新计算
- 所有 PowerShell 脚本用 `pwsh` 执行（非 `powershell.exe`）
