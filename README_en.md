# ADB Switch Windows

A tool for managing and switching between multiple ADB (Android Debug Bridge) versions on Windows.

English | [简体中文](README.md)

## ⚠️ Important Notice

**Environment Support:**
- ✅ **Tested and Supported:** Git Bash on Windows
- ❌ **Not Tested:** MSYS2, WSL, PowerShell, CMD
- **Note:** This tool is specifically designed for Git Bash environment on Windows.

## Features

- 🔄 Switch between different ADB versions easily
- 📦 Automatically download and install ADB Platform Tools
- 📋 Manage multiple ADB versions
- 🚀 Global command-line tool
- ⚡ Simplified version numbers (e.g., `latest`, `r34.0.5`)

## Installation

### 1. Get the Code

First, clone the project from GitHub:

```bash
# Clone the project
git clone https://github.com/yourusername/adb-switch-windows.git

# Enter the project directory
cd adb-switch-windows
```

### 2. Prerequisites

**Required: Git Bash**

This tool requires Git Bash to work on Windows. Git Bash is included with [Git for Windows](https://git-scm.com/download/win).

**Installation Steps:**
1. Download and install [Git for Windows](https://git-scm.com/download/win)
2. During installation, keep default settings (Git Bash will be installed automatically)
3. Open Git Bash from the Start Menu
4. Continue with installation steps below

**Note:** This tool is tested only with Git Bash on Windows. Other environments (MSYS2, WSL) are not tested.

### Install using Makefile (Recommended)

**💡 Tip: Specify custom ADB directory to better organize your files**

The default installation stores ADB files in `~/.adb-switch-windows/adb` (on your C drive). Each platform-tools folder is about 10-20 MB after extraction. If you plan to install multiple versions, it's recommended to specify a custom directory on another drive to better organize your files.

**Recommended installation (with custom path):**

```bash
# Install with custom ADB directory on D drive (or other drive)
make install ADB_DIR=/d/adb-tools

# Or specify a different path
make install ADB_DIR="D:/Android/adb-tools"
```

**Installation with default path (NOT recommended):**

```bash
# Only use if you have enough space on C drive
make install
```

**View help:**

```bash
make help
```

After installation, apply the configuration to your current terminal:

```bash
source ~/.bashrc
```

Or open a new terminal window.

## Usage

### Install ADB Versions

**Simplified version numbers (recommended):**

```bash
# Install latest version
adb-switch install latest

# Install specific version
adb-switch install r34.0.5
adb-switch install r35.0.0
```

**Full version names also supported:**

```bash
adb-switch install platform-tools-latest-windows
adb-switch install platform-tools-r34.0.5-windows
```

**Manual Installation (Alternative Method):**

If automatic download fails or you prefer manual installation:

1. Download platform-tools from the official page:
   - https://developer.android.com/tools/releases/platform-tools
   - Or use direct link: https://dl.google.com/android/repository/platform-tools-latest-windows.zip

2. Extract the downloaded zip file

3. Manually place the files in the adb-switch directory:

```bash
# For latest version
mkdir -p ~/.adb-switch-windows/adb/platform-tools-latest-windows
# Copy all files from extracted platform-tools/ to this directory

# For specific version (e.g., r33.0.1)
mkdir -p ~/.adb-switch-windows/adb/platform-tools-r33.0.1-windows
# Copy all files from extracted platform-tools/ to this directory
```

4. Verify installation:

```bash
adb-switch list
adb-switch use <version>
```

### List Installed Versions

```bash
adb-switch list
```

Example output:
```
Installed ADB versions:

  * platform-tools-latest-windows (current)
    platform-tools-r34.0.5-windows
```

### Switch ADB Version

**Simplified version numbers:**

```bash
adb-switch use latest
adb-switch use r34.0.5
```

**Full version names also supported:**

```bash
adb-switch use platform-tools-latest-windows
adb-switch use platform-tools-r34.0.5-windows
```

### Show Current Version

```bash
adb-switch current
```

### View Available Versions

```bash
adb-switch available
```

## Version Number Format

The tool supports simplified version numbers. You can use short forms like `latest` or `r34.0.5` instead of the full name.

**Important:** Google's download URLs use different separators:
- Version numbers use **underscore** `_` in URL: `platform-tools_r34.0.5-windows.zip`
- Latest version uses **hyphen** `-` in URL: `platform-tools-latest-windows.zip`

The tool automatically handles this for you. Just use the simplified version numbers:

| Simplified Input | Download URL Used | Directory Created |
|-----------------|-------------------|-------------------|
| `latest` | `platform-tools-latest-windows.zip` | `platform-tools-latest-windows/` |
| `r34.0.5` | `platform-tools_r34.0.5-windows.zip` | `platform-tools-r34.0.5-windows/` |
| `r33.0.1` | `platform-tools_r33.0.1-windows.zip` | `platform-tools-r33.0.1-windows/` |

**Note:** Both simplified inputs and full names work for all commands (`install`, `use`, etc.).

## Directory Structure

```
~/.adb-switch-windows/
├── adb/                               # ADB version storage
│   ├── platform-tools-latest-windows/ # Latest version
│   └── platform-tools-r34.0.5-windows/ # Version r34.0.5
├── bin/                               # Executable directory (in PATH)
│   ├── adb                            # ADB wrapper script
│   ├── fastboot                       # Fastboot wrapper script
│   └── adb-switch                     # Main command
├── scripts/                           # Core scripts
│   └── adb-switch.sh
└── config                             # Configuration file
```

## How It Works

In Git Bash environment, Windows executables (adb.exe, fastboot.exe) may encounter library loading issues when copied to different directories. To solve this, the tool creates wrapper scripts that:

1. Change to the ADB version directory
2. Execute the Windows executable from its original location
3. Pass through all command-line arguments

This ensures ADB runs correctly in the bash environment.

## Uninstall

```bash
make uninstall
```

The uninstall process will:
1. Delete the installation directory (`~/.adb-switch-windows`)
2. Optionally delete the ADB storage directory
3. **Automatically remove** adb-switch configuration from `~/.bashrc`
4. Prompt you to run `source ~/.bashrc` to apply changes

## FAQ

### 1. Command not found after installation?

Ensure you've run `source ~/.bashrc` or opened a new terminal window.

### 2. How to change ADB storage directory?

Reinstall with the new path:

```bash
make install ADB_DIR=/your/new/path
```

### 3. Which ADB versions are supported?

All Google officially released Platform Tools versions:
- `latest` or `platform-tools-latest-windows`
- `r34.0.5`, `r34.0.4`, `r33.0.3`, etc.

View all versions: https://developer.android.com/tools/releases/platform-tools

### 4. Does this work in PowerShell?

**No, this tool is not tested in PowerShell.** It's designed for bash-like environments (Git Bash, MSYS2, WSL). PowerShell and CMD are not currently supported.

### 5. What version numbers should I use?

Use the simplified version numbers:
- `latest` - Always the most recent version
- `r34.0.5`, `r33.0.1`, etc. - Specific release versions

The tool automatically converts these to the correct download URL format:
- Version numbers → uses underscore `_` in URL
- `latest` → uses hyphen `-` in URL

**Correct usage:**
```bash
adb-switch install latest
adb-switch install r33.0.1
adb-switch install r34.0.5
```

### 6. Can I use this with Android Studio?

Yes! You can use the ADB version managed by this tool with Android Studio. Just ensure you've switched to the desired version with `adb-switch use <version>`.

## Environment Variables

- `ADB_DIR`: ADB storage directory (default: `~/.adb-switch-windows/adb`)

## Examples

### Complete Workflow

```bash
# 1. Clone the project
git clone https://github.com/yourusername/adb-switch-windows.git
cd adb-switch-windows

# 2. Install the tool
make install
source ~/.bashrc

# 3. Install ADB versions
adb-switch install latest
adb-switch install r34.0.5

# 4. List installed versions
adb-switch list

# 5. Switch to desired version
adb-switch use r34.0.5

# 6. Verify current version
adb version

# 7. Use ADB commands
adb devices
adb logcat
```

### Switching Between Versions

```bash
# Work with latest version
adb-switch use latest
adb devices

# Switch to specific version for compatibility
adb-switch use r33.0.3
adb devices
```

## License

MIT License - See [LICENSE](LICENSE) file for details.
