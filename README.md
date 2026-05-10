# sync-profile — 可复制的开发者知识系统

把你的个人侧写、AI 协作规则、踩坑记录、权限配置、项目骨架打包成可跨环境复用的种子包。

> 详细使用说明见同目录下的 [`README.html`](./README.html)。

## 快速开始

在 Claude Code 中通过 Skill 命令触发：

| 命令 | 用途 |
|------|------|
| `/sync-profile init` | 新项目初始化：生成 LESSONS.md + 项目骨架 + 权限配置 |
| `/sync-profile pull` | 回收项目经验：将新踩坑记录归入种子包 |
| `/sync-profile refresh` | 同步种子包更新：增量覆盖模板，保留自定义内容 |
| `/sync-profile merge` | 合并两个环境（家里/公司）的种子包差异 |

## 目录结构

```
sync-profile/
├── SKILL.md                  ← 入口文件，定义四个 Skill 操作
├── seed.yaml                 ← 版本管理 + changelog + 文件 MD5 校验码
├── README.md / README.html   ← 项目说明（仅仓库持有）
├── profile/                  ← 个人侧写（编码规范、技术栈、工作习惯）
│   ├── coding.md
│   ├── personal.md
│   └── workflow.md
├── config/                   ← 全局权限配置模板
│   ├── global-settings.json  ← 通用 allow/deny 列表
│   └── permissions.md        ← 权限设计原则说明
├── knowledge/                ← 踩坑记录，按语言/版本分层
│   ├── common/debugging.md   ← 通用调试方法论
│   └── rust/tauri-pitfalls.md← Rust/Tauri 2.0 专项
├── scaffolds/                ← 项目骨架模板（.hbs handlebars）
│   ├── generic/              ← 通用项目模板
│   └── rust-tauri/           ← Rust + Tauri 项目模板
└── scripts/                  ← PowerShell 自动化脚本
    ├── generate-scaffold.ps1 ← 用 .hbs 模板生成项目文件
    ├── merge-settings.ps1    ← 合并种子包与目标权限配置
    └── compute-hash.ps1      ← 计算文件 MD5（用于 merge 比对）
```

## 双目录架构

此仓库直接映射到 Claude Code 全局 skill 配置，编辑与运行分离：

| 角色 | 路径 | 说明 |
|------|------|------|
| **代码仓库（编辑用）** | `d:\code\sync-profile\sync-profile\` | 用 git 管理版本，在此编辑 |
| **全局 skill（运行时用）** | `C:\Users\PC_WIN10\.claude\skills\sync-profile\` | Claude Code 执行时读取 |

两套目录内容除 `CLAUDE.md`、`README.md`、`.git/`（仅仓库持有）外完全一致。

## 部署：仓库 → 全局 Skill

修改仓库内容后，将变更文件复制到全局 skill 目录即可生效：

```powershell
# 手动部署（增量更新）
Copy-Item "d:\code\sync-profile\sync-profile\*" "C:\Users\PC_WIN10\.claude\skills\sync-profile\" -Recurse -Force -Exclude "CLAUDE.md","README.md",".git"

# 验证部署结果（应无差异）
diff -rq "d:\code\sync-profile\sync-profile" "C:\Users\PC_WIN10\.claude\skills\sync-profile" --exclude="CLAUDE.md" --exclude="README.md" --exclude=".git"
```

**不被复制到 skill 的文件：** `CLAUDE.md`、`README.md`、`README.html`、`.git/`。

## 版本管理

编辑 `seed.yaml` 记录版本号和 changelog。每次功能变更后：

1. 递增 `version`
2. 添加 changelog 条目，列出变更文件
3. 运行 `pwsh scripts/compute-hash.ps1 -SeedPath <path>` 更新文件 MD5 校验码
4. 部署到全局 skill 目录

## 扩展指南

| 操作 | 说明 |
|------|------|
| **添加踩坑记录** | 在 `knowledge/` 下按 `语言/主题.md` 创建文件 |
| **添加脚手架** | 在 `scaffolds/` 下创建目录，放入 `.hbs` 模板文件 |
| **添加权限** | 编辑 `config/global-settings.json`，用 merge-settings 合并 |

## 适用场景

- 在多台机器间同步一致的 AI 协作规则
- 新项目快速初始化：自动生成 CLAUDE.md + LESSONS.md + 权限配置
- 跨项目经验沉淀：从项目中回收踩坑记录到种子包
- 多环境种子包同步：merge 操作比较差异，由用户决策合并
