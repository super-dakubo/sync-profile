# sync-profile — 可复制的开发者知识系统

把你的个人侧写、AI 协作规则、踩坑记录、权限配置打包成可跨环境复用的种子包。

## 快速开始

在 Claude Code 中通过 Skill 命令触发：

| 命令 | 用途 |
|------|------|
| `/sync-profile init` | 新项目初始化：生成 LESSONS.md + 项目骨架 + 权限配置 |
| `/sync-profile pull` | 回收项目经验：将新踩坑记录归入种子包 |
| `/sync-profile refresh` | 同步种子包更新：增量覆盖模板，保留自定义内容 |

> 完整使用说明见 [docs/sync-profile-intro.html](docs/sync-profile-intro.html)。

## 目录结构

```
sync-profile/
├── SKILL.md            ← 入口文件，定义三个 Skill 操作
├── seed.yaml           ← 版本管理 + changelog
├── profile/            ← 个人侧写（编码规范、技术栈、工作习惯）
├── config/             ← 全局权限配置模板
├── knowledge/          ← 踩坑记录，按语言/版本分层
├── scaffolds/          ← 项目骨架模板（handlebars）
└── scripts/            ← PowerShell 自动化脚本
```

## 代码库 ↔ 全局 Skill 对应关系

此仓库直接映射到 Claude Code 全局 skill 配置：

| 位置 | 路径 |
|------|------|
| **代码仓库（编辑用）** | `d:\code\sync-profile\sync-profile\` |
| **全局 skill（运行时用）** | `C:\Users\PC_WIN10\.claude\skills\sync-profile\` |

两套目录结构除 `CLAUDE.md` 和 `README.md`（仅仓库持有）外完全一致。全局 skill 中的 `SKILL.md` 是入口文件，定义 `/sync-profile init`、`/sync-profile pull`、`/sync-profile refresh` 三个操作。

> SKILL.md 第 22 行写明：种子包路径默认是 `.claude/skills/sync-profile/`。

## 部署：仓库 → 全局 Skill

修改仓库内容后，将变更文件复制到全局 skill 目录即可生效：

```powershell
# 手动部署（增量更新）
Copy-Item "d:\code\sync-profile\sync-profile\*" "C:\Users\PC_WIN10\.claude\skills\sync-profile\" -Recurse -Force -Exclude "CLAUDE.md","README.md",".git"

# 验证部署结果（应无差异）
diff -rq "d:\code\sync-profile\sync-profile" "C:\Users\PC_WIN10\.claude\skills\sync-profile" --exclude="CLAUDE.md" --exclude="README.md" --exclude=".git"
```

**不包括的文件：** `CLAUDE.md` 和 `README.md` 是仓库的文档文件，不会被复制到全局 skill。

## 版本管理

编辑 `seed.yaml` 记录版本号和 changelog。每次功能变更后递增 `version`，添加 changelog 条目，再部署到全局 skill。

## 适用场景

- 在多台机器间同步一致的 AI 协作规则
- 新项目快速初始化：自动生成 CLAUDE.md + LESSONS.md + 权限配置
- 跨项目经验沉淀：从项目中回收踩坑记录到种子包
