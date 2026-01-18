# ADB Switch Windows

一个用于在 Windows 上管理和切换多个 ADB (Android Debug Bridge) 版本的工具。

[English](README.md) | 简体中文

## ⚠️ 重要提示

**环境支持：**
- ✅ **已测试并支持：** Git Bash on Windows
- ❌ **未测试：** MSYS2, WSL, PowerShell, CMD
- **注意：** 此工具专为 Windows 上的 Git Bash 环境设计。

## 功能特性

- 🔄 轻松切换不同版本的 ADB
- 📦 自动下载和安装 ADB Platform Tools
- 📋 管理多个 ADB 版本
- 🚀 全局命令行工具
- ⚡ 简化版本号（例如：`latest`、`r34.0.5`）

## 安装

### 1. 获取代码

首先，从 GitHub 克隆项目到本地：

```bash
# 克隆项目
git clone https://github.com/yourusername/adb-switch-windows.git

# 进入项目目录
cd adb-switch-windows
```

### 2. 环境要求

**必需：Git Bash**

此工具需要 Git Bash 才能在 Windows 上工作。Git Bash 包含在 [Git for Windows](https://git-scm.com/download/win) 中。

**安装步骤：**
1. 下载并安装 [Git for Windows](https://git-scm.com/download/win)
2. 安装过程中保持默认设置（Git Bash 会自动安装）
3. 从开始菜单打开 Git Bash
4. 继续下面的安装步骤

**注意：** 此工具仅在 Windows 的 Git Bash 中测试过。其他环境（MSYS2、WSL）未经测试。

### 使用 Makefile 安装（推荐）

**💡 提示：建议指定自定义路径，更好地管理文件**

默认安装会将 ADB 文件存放在 `~/.adb-switch-windows/adb`，也就是在您的 C 盘上。每个 platform-tools 文件夹解压后约 10-20 MB。如果您计划安装多个版本，建议指定其他盘符的自定义目录，这样可以更好地组织您的文件。

**推荐安装方式（使用自定义路径）：**

```bash
# 在 D 盘（或其他盘符）指定 ADB 存放目录
make install ADB_DIR=/d/adb-tools

# 或者指定其他路径
make install ADB_DIR="D:/Android/adb-tools"
```

**使用默认路径安装（不推荐）：**

```bash
# 仅在 C 盘空间充足时使用
make install
```

**查看帮助：**

```bash
make help
```

安装完成后，在当前终端执行以下命令使配置生效：

```bash
source ~/.bashrc
```

或者打开一个新的终端窗口。

## 使用方法

### 安装 ADB 版本

**简化版本号（推荐）：**

```bash
# 安装最新版本
adb-switch install latest

# 安装指定版本
adb-switch install r34.0.5
adb-switch install r35.0.0
```

**完整版本名称也支持：**

```bash
adb-switch install platform-tools-latest-windows
adb-switch install platform-tools-r34.0.5-windows
```

**手动安装（替代方法）：**

如果自动下载失败或您更喜欢手动安装：

1. 从官方页面下载 platform-tools：
   - https://developer.android.com/tools/releases/platform-tools
   - 或直接使用链接：https://dl.google.com/android/repository/platform-tools-latest-windows.zip

2. 解压下载的 zip 文件

3. 手动将文件放入 adb-switch 目录：

```bash
# 对于最新版本
mkdir -p ~/.adb-switch-windows/adb/platform-tools-latest-windows
# 将解压后的 platform-tools/ 中的所有文件复制到此目录

# 对于特定版本（例如 r33.0.1）
mkdir -p ~/.adb-switch-windows/adb/platform-tools-r33.0.1-windows
# 将解压后的 platform-tools/ 中的所有文件复制到此目录
```

4. 验证安装：

```bash
adb-switch list
adb-switch use <版本号>
```

### 查看已安装的版本

```bash
adb-switch list
```

示例输出：
```
已安装的 ADB 版本：

  * platform-tools-latest-windows (当前)
    platform-tools-r34.0.5-windows
```

### 切换 ADB 版本

**简化版本号：**

```bash
adb-switch use latest
adb-switch use r34.0.5
```

**完整版本名称也支持：**

```bash
adb-switch use platform-tools-latest-windows
adb-switch use platform-tools-r34.0.5-windows
```

### 查看当前版本

```bash
adb-switch current
```

### 查看可用版本

```bash
adb-switch available
```

## 版本号格式

工具支持简化版本号。您可以使用简短形式如 `latest` 或 `r34.0.5`，无需输入完整名称。

**重要提示：** Google 的下载 URL 使用不同的连接符：
- 版本号在 URL 中使用**下划线** `_`：`platform-tools_r34.0.5-windows.zip`
- latest 版本在 URL 中使用**连字符** `-`：`platform-tools-latest-windows.zip`

工具会自动处理这些差异。只需使用简化版本号即可：

| 简化输入 | 实际下载 URL | 创建的目录 |
|---------|-------------|-----------|
| `latest` | `platform-tools-latest-windows.zip` | `platform-tools-latest-windows/` |
| `r34.0.5` | `platform-tools_r34.0.5-windows.zip` | `platform-tools-r34.0.5-windows/` |
| `r33.0.1` | `platform-tools_r33.0.1-windows.zip` | `platform-tools-r33.0.1-windows/` |

**注意：** 简化输入和完整名称都可用于所有命令（`install`、`use` 等）。

## 目录结构

```
~/.adb-switch-windows/
├── adb/                               # ADB 版本存放目录
│   ├── platform-tools-latest-windows/ # 最新版本
│   └── platform-tools-r34.0.5-windows/ # r34.0.5 版本
├── bin/                               # 可执行文件目录（已添加到 PATH）
│   ├── adb                            # ADB 包装脚本
│   ├── fastboot                       # Fastboot 包装脚本
│   └── adb-switch                     # 主命令
├── scripts/                           # 核心脚本
│   └── adb-switch.sh
└── config                             # 配置文件
```

## 工作原理

在 Git Bash 环境中，Windows 可执行文件（adb.exe、fastboot.exe）在被复制到不同目录时可能会遇到库加载问题。为了解决这个问题，工具创建了包装脚本：

1. 切换到 ADB 版本目录
2. 从原始位置执行 Windows 可执行文件
3. 传递所有命令行参数

这确保了 ADB 在 bash 环境中能够正确运行。

## 卸载

```bash
make uninstall
```

卸载过程将：
1. 删除安装目录（`~/.adb-switch-windows`）
2. 可选删除 ADB 存放目录
3. **自动移除** `~/.bashrc` 中的 adb-switch 配置
4. 提示您运行 `source ~/.bashrc` 使更改生效

## 常见问题

### 1. 安装后命令未找到？

确保执行了 `source ~/.bashrc` 或打开了新的终端窗口。

### 2. 如何更改 ADB 存放路径？

使用新路径重新安装：

```bash
make install ADB_DIR=/your/new/path
```

### 3. 支持哪些 ADB 版本？

所有 Google 官方发布的 Platform Tools 版本：
- `latest` 或 `platform-tools-latest-windows`
- `r34.0.5`、`r34.0.4`、`r33.0.3` 等

查看所有版本：https://developer.android.com/tools/releases/platform-tools

### 4. 这个工具可以在 PowerShell 中使用吗？

**不可以，此工具未在 PowerShell 中测试。** 它专为类 Bash 环境（Git Bash、MSYS2、WSL）设计。目前不支持 PowerShell 和 CMD。

### 5. 应该使用什么版本号？

使用简化版本号：
- `latest` - 总是最新版本
- `r34.0.5`、`r33.0.1` 等 - 特定的发布版本

工具会自动将其转换为正确的下载 URL 格式：
- 版本号 → 在 URL 中使用下划线 `_`
- `latest` → 在 URL 中使用连字符 `-`

**正确用法：**
```bash
adb-switch install latest
adb-switch install r33.0.1
adb-switch install r34.0.5
```

### 6. 可以和 Android Studio 一起使用吗？

可以！您可以使用此工具管理的 ADB 版本配合 Android Studio 使用。只需使用 `adb-switch use <version>` 切换到所需版本即可。

## 环境变量

- `ADB_DIR`：ADB 存放目录（默认：`~/.adb-switch-windows/adb`）

## 使用示例

### 完整工作流程

```bash
# 1. 克隆项目
git clone https://github.com/yourusername/adb-switch-windows.git
cd adb-switch-windows

# 2. 安装工具
make install
source ~/.bashrc

# 3. 安装 ADB 版本
adb-switch install latest
adb-switch install r34.0.5

# 4. 查看已安装版本
adb-switch list

# 5. 切换到所需版本
adb-switch use r34.0.5

# 6. 验证当前版本
adb version

# 7. 使用 ADB 命令
adb devices
adb logcat
```

### 在不同版本间切换

```bash
# 使用最新版本工作
adb-switch use latest
adb devices

# 切换到特定版本以保持兼容性
adb-switch use r33.0.3
adb devices
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
