# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

这是一个 **ADB (Android Debug Bridge) 版本管理工具**，用于在 Windows 上（通过 Git Bash/MSYS2）管理和切换多个 ADB 版本。

## 项目结构

```
adb-switch-windows/
├── adb-switch.sh       # 核心功能脚本
├── Makefile            # 安装和构建配置
├── README.md           # 用户文档
├── CLAUDE.md           # 此文件
└── LICENSE             # MIT 许可证
```

安装后的目录结构（在用户主目录）：
```
~/.adb-switch-windows/
├── adb/                # ADB 版本存放目录
├── bin/                # 可执行文件（添加到 PATH）
├── scripts/            # 核心脚本
└── config              # 配置文件
```

## 核心架构

### 主要组件

1. **adb-switch.sh**: Bash 脚本，实现所有核心功能
   - 下载和解压 ADB Platform Tools
   - 版本管理和切换
   - 配置文件管理
   - 环境变量更新

2. **Makefile**: 提供安装和卸载功能
   - `make install [ADB_DIR=/path]`: 安装工具
   - `make uninstall`: 卸载工具
   - `make help`: 显示帮助信息

3. **配置文件**: `~/.adb-switch-windows/config`
   - 存储当前使用的版本
   - 存储 ADB 目录路径

## 常用命令

### 安装
```bash
# 默认安装（ADB 放在 ~/.adb-switch-windows/adb）
make install

# 指定 ADB 存放路径
make install ADB_DIR=/custom/path

# 使配置生效
source ~/.bashrc
```

### 使用
```bash
# 安装 ADB 版本
adb-switch install platform-tools-latest-windows
adb-switch install r34.0.5

# 列出已安装的版本
adb-switch list

# 切换版本
adb-switch use r34.0.5

# 查看当前版本
adb-switch current
```

## 开发说明

### 修改核心功能
- 编辑 `adb-switch.sh` 脚本
- 主要函数：`install_adb()`, `use_version()`, `list_installed()`, `show_current()`

### 修改安装流程
- 编辑 `Makefile`
- 安装目标：`install`，卸载目标：`uninstall`

### 环境变量
- `ADB_DIR`: 控制 ADB 存放目录（可在安装时通过 `make install ADB_DIR=/path` 设置）

## 依赖要求

- Git Bash / MSYS2 / WSL on Windows
- `curl` 或 `wget`（用于下载）
- `unzip`（用于解压）

## License

MIT License - See LICENSE file for details.
