#!/bin/bash
# 生成 adb-switch 包装脚本

# 确保目录存在
mkdir -p ~/.adb-switch-windows/bin

cat > ~/.adb-switch-windows/bin/adb-switch << 'WRAPPER_EOF'
#!/bin/bash
export ADB_DIR="$HOME/.adb-switch-windows/adb"
"$HOME/.adb-switch-windows/scripts/adb-switch.sh" "$@"
WRAPPER_EOF

chmod +x ~/.adb-switch-windows/bin/adb-switch
