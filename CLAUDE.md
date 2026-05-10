# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

sync-profile 是一个"开发者知识系统"种子包。它将个人侧写、AI 协作规则、踩坑记录、权限配置、项目骨架打包成可跨环境复制的模板集。核心操作由 [SKILL.md](./SKILL.md) 定义，通过 Claude Code Skill 系统触发。

## 目录结构

```
sync-profile/
├── SKILL.md            ← 入口：定义 init / pull / refresh 三个操作
├── seed.yaml           ← 版本号 + changelog
├── profile/            ← 个人侧写（编码规范、技术栈、工作习惯）
│   ├── coding.md
│   ├── personal.md
│   └── workflow.md
├── config/             ← 全局权限配置模板
│   ├── global-settings.json   ← 通用允许/拒绝命令列表
│   └── permissions.md         ← 权限配置设计原则说明
├── knowledge/          ← 踩坑记录，按语言/版本分层
│   ├── common/debugging.md    ← 通用调试方法论
│   └── rust/tauri-pitfalls.md ← Rust/Tauri 2.0 踩坑
├── scaffolds/          ← 项目骨架模板（handlebars 模板）
│   ├── generic/               ← 通用项目
│   └── rust-tauri/            ← Rust + Tauri 项目
└── scripts/            ← PowerShell 自动化脚本
    ├── generate-scaffold.ps1  ← 用模板生成项目初始文件
    └── merge-settings.ps1     ← 合并种子包与现有权限配置
```

## 核心工作流

种子包通过 SKILL.md 定义三个 Skill 操作，在 Claude Code 中通过 `/sync-profile init|pull|refresh` 触发：

- **init** — 新项目初始化：问语言/框架 → 过滤 knowledge 生成 LESSONS.md → 选 scaffold 生成骨架 → 合并权限配置
- **pull** — 回收项目经验：从项目 LESSONS.md 提取新踩坑记录，归类追加到 seed knowledge
- **refresh** — 同步种子包更新：对比版本号，增量更新 scaffolds 和配置，保留用户自定义内容

## 常用命令

- `pwsh scripts/generate-scaffold.ps1 -SeedPath <path> -ProjectPath <path> -ScaffoldType <rust-tauri|generic>` — 生成项目骨架
- `pwsh scripts/merge-settings.ps1 -SeedPath <path> -TargetPath <path>` — 合并权限配置
- 种子包无语言特定构建命令（非应用程序项目）

## 部署到全局 Skill

此仓库内容映射到 `C:\Users\PC_WIN10\.claude\skills\sync-profile\`。修改仓库文件后，运行以下命令部署：

```powershell
Copy-Item "d:\code\sync-profile\sync-profile\*" "C:\Users\PC_WIN10\.claude\skills\sync-profile\" -Recurse -Force -Exclude "CLAUDE.md","README.md",".git"
```

**不被复制到 skill 的文件：** `CLAUDE.md`、`README.md`、`.git/`（仅仓库所需，skill 运行时不使用）。

部署后更新 `seed.yaml` 中的 `version` 和 `changelog`。

## 扩展指南

- 添加踩坑记录 → 在 `knowledge/` 下按 `语言/主题.md` 创建文件，条目用 `**适用：**` 标签标记版本范围
- 添加脚手架 → 在 `scaffolds/` 下创建目录放 `.hbs` 模板文件（会自动去掉 `.hbs` 后缀写入目标项目）
- 添加侧写项 → 编辑 `profile/` 下对应文件
- 添加权限 → 编辑 `config/global-settings.json` 后运行 merge-settings 合并
