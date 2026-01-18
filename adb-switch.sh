#!/bin/bash

# ADB Switch - Manage multiple ADB versions
# Usage: adb-switch [command] [options]

set -e

# 配置文件路径
CONFIG_FILE="$HOME/.adb-switch-windows/config"
ADB_DIR="${ADB_DIR:-$HOME/.adb-switch-windows/adb}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印帮助信息
show_help() {
    cat << EOF
ADB Switch - Manage multiple ADB versions

Usage:
    adb-switch [command] [options]

Commands:
    install <version>     Install ADB version (e.g., latest, r34.0.5)
    list                  List installed ADB versions
    use <version>         Switch to ADB version
    current               Show current ADB version
    available             List available ADB versions
    detect                Detect available versions from Google server
    help                  Show this help message

Options:
    --dir <path>          Specify ADB directory (for make install)

Environment Variables:
    ADB_DIR               ADB storage directory (default: ~/.adb-switch-windows/adb)

Examples (simplified version numbers):
    adb-switch install latest
    adb-switch install r34.0.5
    adb-switch list
    adb-switch use latest
    adb-switch use r34.0.5

Full version names also supported:
    adb-switch install platform-tools-latest-windows
    adb-switch install platform-tools-r34.0.5-windows

EOF
}

# 创建必要的目录
init_dirs() {
    # 展开路径中的 ~
    ADB_DIR="${ADB_DIR/#\~/$HOME}"

    mkdir -p "$ADB_DIR"
    mkdir -p "$(dirname "$CONFIG_FILE")"

    # 创建配置文件
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
ADB_DIR="$ADB_DIR"
CURRENT_VERSION=
EOF
    fi

    # 加载配置
    source "$CONFIG_FILE"

    # 再次展开，确保路径正确
    ADB_DIR="${ADB_DIR/#\~/$HOME}"
}

# 下载 ADB
install_adb() {
    local input_version="$1"

    if [ -z "$input_version" ]; then
        echo -e "${RED}错误: 请指定要安装的版本${NC}"
        echo "用法: adb-switch install <version>"
        echo ""
        echo "简化版本号示例:"
        echo "  adb-switch install latest         # 安装最新版本"
        echo "  adb-switch install r35.0.0        # 安装指定版本"
        echo ""
        echo "完整名称也支持:"
        echo "  adb-switch install platform-tools-latest-windows"
        echo "  adb-switch install platform-tools-r35.0.0-windows"
        exit 1
    fi

    init_dirs

    # 转换简化版本号为完整名称
    local version_dir_name
    local download_filename

    # 如果已经是完整的 platform-tools-xxx-windows 格式
    if [[ "$input_version" =~ ^platform-tools-.*-windows$ ]]; then
        version_dir_name="$input_version"
        download_filename="$input_version"
    # 如果是简化版本号（latest 或 rXX.XX.X）
    else
        version_dir_name="platform-tools-${input_version}-windows"
        download_filename="${version_dir_name}"
    fi

    local target_dir="$ADB_DIR/$version_dir_name"

    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}Version $input_version already installed${NC}"
        echo "Path: $target_dir"
        exit 0
    fi

    echo -e "${GREEN}Installing ADB $input_version...${NC}"

    # 构建下载 URL
    # 注意：版本号格式使用下划线，latest 使用连字符
    local url
    if [ "$input_version" = "latest" ]; then
        url="https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    elif [[ "$input_version" =~ ^r[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # 版本号格式：platform-tools_r33.0.1-windows.zip (使用下划线)
        url="https://dl.google.com/android/repository/platform-tools_${input_version}-windows.zip"
    else
        # 完整格式，直接使用
        url="https://dl.google.com/android/repository/${download_filename}.zip"
    fi

    echo "Download URL: $url"

    # 创建临时目录
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # 下载
    echo "正在下载..."
    if command -v curl >/dev/null 2>&1; then
        curl -L -o platform-tools.zip "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O platform-tools.zip "$url"
    else
        echo -e "${RED}错误: 需要 curl 或 wget 来下载文件${NC}"
        exit 1
    fi

    # 验证下载的文件是否为有效的 ZIP 文件
    if [ ! -f "platform-tools.zip" ]; then
        echo -e "${RED}错误: 下载失败，文件不存在${NC}"
        exit 1
    fi

    # 检查文件大小（小于 10KB 可能是错误页面）
    local file_size=$(stat -c%s "platform-tools.zip" 2>/dev/null || stat -f% "platform-tools.zip" 2>/dev/null)
    if [ "$file_size" -lt 10240 ]; then
        echo -e "${RED}错误: 下载的文件大小异常 (${file_size} bytes)${NC}"
        echo -e "${YELLOW}这通常表示该版本不存在或下载 URL 不正确${NC}"
        echo ""
        echo "请检查:"
        echo "1. 版本号是否正确 (运行 'adb-switch detect' 查看帮助)"
        echo "2. 访问官方页面确认可用版本:"
        echo "   https://developer.android.com/tools/releases/platform-tools"
        rm -rf "$temp_dir"
        exit 1
    fi

    # 检查文件是否为有效的 ZIP 文件（忽略大小写）
    if ! file platform-tools.zip | grep -iq "zip archive"; then
        echo -e "${RED}错误: 下载的文件不是有效的 ZIP 压缩包${NC}"
        echo -e "${YELLOW}文件类型:${NC}"
        file platform-tools.zip
        echo ""
        echo "这可能是因为:"
        echo "1. 该版本不存在于 Google 服务器"
        echo "2. 版本号格式不正确"
        echo ""
        echo "请访问官方页面确认正确的版本号:"
        echo "https://developer.android.com/tools/releases/platform-tools"
        rm -rf "$temp_dir"
        exit 1
    fi

    # 解压
    echo "Extracting..."
    unzip -q platform-tools.zip || {
        echo -e "${RED}错误: 解压失败${NC}"
        echo "下载的文件可能已损坏"
        rm -rf "$temp_dir"
        exit 1
    }

    # 创建目标目录
    mkdir -p "$target_dir"

    # 移动文件
    mv platform-tools/* "$target_dir/"

    # 清理
    cd /
    rm -rf "$temp_dir"

    echo -e "${GREEN}[OK] ADB $input_version installed successfully!${NC}"
    echo "Path: $target_dir"
    echo ""
    echo "Switch to this version using:"
    echo "  adb-switch use $input_version"
}

# 列出已安装的版本
list_installed() {
    init_dirs

    if [ ! -d "$ADB_DIR" ]; then
        echo -e "${YELLOW}还没有安装任何 ADB 版本${NC}"
        echo "使用 'adb-switch install <version>' 来安装"
        exit 0
    fi

    echo -e "${GREEN}已安装的 ADB 版本:${NC}"
    echo ""

    local found=0
    for dir in "$ADB_DIR"/*; do
        if [ -d "$dir" ]; then
            local version=$(basename "$dir")
            found=1

            # 检查是否是当前版本
            source "$CONFIG_FILE"
            if [ "$CURRENT_VERSION" = "$version" ]; then
                echo -e "  * ${GREEN}$version${NC} (当前)"
            else
                echo "    $version"
            fi
        fi
    done

    if [ $found -eq 0 ]; then
        echo -e "${YELLOW}  (空)${NC}"
    fi
}

# 切换版本
use_version() {
    local input_version="$1"

    if [ -z "$input_version" ]; then
        echo -e "${RED}错误: 请指定要切换的版本${NC}"
        echo "用法: adb-switch use <version>"
        echo "使用 'adb-switch list' 查看已安装的版本"
        exit 1
    fi

    init_dirs

    # 转换简化版本号为完整目录名
    local version_dir_name
    if [[ "$input_version" =~ ^platform-tools-.*-windows$ ]]; then
        version_dir_name="$input_version"
    else
        version_dir_name="platform-tools-${input_version}-windows"
    fi

    local target_dir="$ADB_DIR/$version_dir_name"

    if [ ! -d "$target_dir" ]; then
        echo -e "${RED}错误: 版本 $input_version 未安装${NC}"
        echo "使用 'adb-switch install $input_version' 来安装"
        exit 1
    fi

    # 检查 adb.exe 是否存在
    if [ ! -f "$target_dir/adb.exe" ]; then
        echo -e "${RED}错误: 在 $target_dir 中找不到 adb.exe${NC}"
        exit 1
    fi

    # 更新配置（保存完整目录名）
    sed -i "s|^CURRENT_VERSION=.*|CURRENT_VERSION=$version_dir_name|g" "$CONFIG_FILE"

    # 创建包装脚本到 bin 目录
    local bin_dir="$HOME/.adb-switch-windows/bin"
    mkdir -p "$bin_dir"

    # 创建 adb 包装脚本
    cat > "$bin_dir/adb" << ADBEOF
#!/bin/bash
# Wrapper for adb.exe - runs adb from version directory
cd "$target_dir"
exec ./adb.exe "\$@"
ADBEOF
    chmod +x "$bin_dir/adb"

    # 创建 fastboot 包装脚本（如果存在）
    if [ -f "$target_dir/fastboot.exe" ]; then
        cat > "$bin_dir/fastboot" << FASTBOOTEOF
#!/bin/bash
# Wrapper for fastboot.exe - runs fastboot from version directory
cd "$target_dir"
exec ./fastboot.exe "\$@"
FASTBOOTEOF
        chmod +x "$bin_dir/fastboot"
    fi

    echo -e "${GREEN}[OK] Switched to ADB $input_version${NC}"
    echo ""
    echo "ADB path: $target_dir"
    echo ""
    echo "Please ensure $bin_dir is in your PATH environment variable"

    # 显示当前版本
    local version_info=$("$bin_dir/adb" version 2>&1 | head -n 1)
    if [ -n "$version_info" ]; then
        echo "Current version: $version_info"
    fi
}

# 显示当前版本
show_current() {
    init_dirs

    source "$CONFIG_FILE"

    if [ -z "$CURRENT_VERSION" ]; then
        echo -e "${YELLOW}还没有设置当前版本${NC}"
        echo "使用 'adb-switch use <version>' 来切换版本"
        exit 0
    fi

    local bin_dir="$HOME/.adb-switch-windows/bin"
    if [ -f "$bin_dir/adb.exe" ]; then
        echo -e "${GREEN}当前 ADB 版本: $CURRENT_VERSION${NC}"
        echo ""
        "$bin_dir/adb.exe" version
    else
        echo -e "${YELLOW}当前版本: $CURRENT_VERSION (但 adb.exe 未找到)${NC}"
    fi
}

# 列出可用版本
show_available() {
    echo -e "${GREEN}Available ADB versions:${NC}"
    echo ""
    echo "Latest version:"
    echo "  latest (or: platform-tools-latest-windows)"
    echo ""
    echo "Release versions (from Google official):"
    echo "  r34.0.5, r34.0.4, r34.0.3, r33.0.3, r33.0.2, ..."
    echo ""
    echo "Usage examples:"
    echo "  adb-switch install latest"
    echo "  adb-switch install r34.0.5"
    echo ""
    echo "View all versions: https://developer.android.com/tools/releases/platform-tools"
}

# 检测可用版本
detect_versions() {
    echo -e "${GREEN}Detecting available ADB versions...${NC}"
    echo ""

    # 注意：Google 不提供版本列表 API
    # 这个命令会打开官方页面供您查看

    echo "Google does not provide an API to list all versions."
    echo "Please check the official page for available versions:"
    echo ""
    echo -e "${YELLOW}https://developer.android.com/tools/releases/platform-tools${NC}"
    echo ""

    # 检测网络连接
    if command -v curl >/dev/null 2>&1; then
        echo "Checking connectivity to Google servers..."
        if curl -s -I "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" | grep -q "200 OK"; then
            echo -e "${GREEN}[OK]${NC} Google servers are accessible"
            echo ""
            echo "Latest version is available for installation:"
            echo "  adb-switch install latest"
        else
            echo -e "${RED}[ERROR]${NC} Cannot connect to Google servers"
            echo "Please check your internet connection"
        fi
    elif command -v wget >/dev/null 2>&1; then
        echo "Checking connectivity to Google servers..."
        if wget --spider -q "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" 2>/dev/null; then
            echo -e "${GREEN}[OK]${NC} Google servers are accessible"
            echo ""
            echo "Latest version is available for installation:"
            echo "  adb-switch install latest"
        else
            echo -e "${RED}[ERROR]${NC} Cannot connect to Google servers"
            echo "Please check your internet connection"
        fi
    else
        echo "Note: curl or wget is required for connectivity check"
    fi

    echo ""
    echo "Common version format:"
    echo "  latest        - Always the most recent version"
    echo "  rXX.XX.X      - Release versions (check official page for exact numbers)"
    echo ""
    echo "Example usage:"
    echo "  adb-switch install latest"
    echo "  adb-switch install r34.0.5"
}

# 主函数
main() {
    case "$1" in
        install)
            install_adb "$2"
            ;;
        list)
            list_installed
            ;;
        use)
            use_version "$2"
            ;;
        current)
            show_current
            ;;
        available)
            show_available
            ;;
        detect)
            detect_versions
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            echo -e "${RED}错误: 未知命令 '$1'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
