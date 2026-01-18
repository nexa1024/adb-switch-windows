.PHONY: install uninstall help clean

# Default ADB directory
# Use default value if ADB_DIR is not specified
HOME_DIR=$(shell echo ~)
ADB_DIR ?= $(HOME_DIR)/.adb-switch-windows/adb

INSTALL_DIR=$(HOME_DIR)/.adb-switch-windows
BIN_DIR=$(INSTALL_DIR)/bin
SCRIPT_DIR=$(INSTALL_DIR)/scripts
BASHRC=$(HOME_DIR)/.bashrc

help:
	@echo "ADB Switch Windows - Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make install [ADB_DIR=/path/to/adb]    Install adb-switch"
	@echo "  make uninstall                         Uninstall adb-switch"
	@echo "  make clean                             Clean temporary files"
	@echo "  make help                              Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make install                           # Use default path (~/.adb-switch-windows/adb)"
	@echo "  make install ADB_DIR=/d/adb-tools     # Specify custom ADB directory"
	@echo ""
	@echo "Default ADB directory: ~/.adb-switch-windows/adb"

install:
	@echo "Installing ADB Switch..."
	@echo "ADB directory: $(ADB_DIR)"
	@echo ""

	@# Create necessary directories
	@mkdir -p $(INSTALL_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(SCRIPT_DIR)
	@mkdir -p $(ADB_DIR)

	@# Copy core script
	@cp adb-switch.sh $(SCRIPT_DIR)/adb-switch.sh
	@chmod +x $(SCRIPT_DIR)/adb-switch.sh

	@# Create wrapper script
	@bash generate-wrapper.sh

	@# Update .bashrc
	@echo ""
	@echo "Configuring PATH environment variable..."
	@if ! grep -q 'adb-switch-windows/bin' $(BASHRC) 2>/dev/null; then \
		echo "" >> $(BASHRC); \
		echo "# ADB Switch Windows" >> $(BASHRC); \
		echo "export PATH=\"\$$PATH:~/.adb-switch-windows/bin\"" >> $(BASHRC); \
		echo "export ADB_DIR=\"$(ADB_DIR)\"" >> $(BASHRC); \
		echo "[OK] Updated $(BASHRC)"; \
	else \
		echo "[OK] PATH already configured"; \
	fi

	@# Create config file
	@printf "ADB_DIR=\"$(ADB_DIR)\"\n" > $(INSTALL_DIR)/config
	@printf "CURRENT_VERSION=\n" >> $(INSTALL_DIR)/config

	@echo ""
	@echo "[OK] Installation completed!"
	@echo ""
	@echo "=========================================="
	@echo "IMPORTANT: Apply changes to your shell"
	@echo "=========================================="
	@echo ""
	@echo "To use adb-switch in your CURRENT terminal, run:"
	@echo "  source ~/.bashrc"
	@echo ""
	@echo "OR open a NEW terminal window"
	@echo ""
	@echo "=========================================="
	@echo "Quick start commands (simplified):"
	@echo "=========================================="
	@echo "  adb-switch install latest"
	@echo "  adb-switch list"
	@echo "  adb-switch use latest"

uninstall:
	@echo "Uninstalling ADB Switch..."
	@echo ""
	@echo "Install directory: $(INSTALL_DIR)"
	@echo "ADB directory: $(ADB_DIR)"
	@echo ""
	@read -p "Are you sure you want to delete these directories? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -rf $(INSTALL_DIR); \
		echo ""; \
		echo "[OK] Deleted $(INSTALL_DIR)"; \
		echo ""; \
		read -p "Also delete ADB directory ($(ADB_DIR))? [y/N] " confirm_adb; \
		if [ "$$confirm_adb" = "y" ] || [ "$$confirm_adb" = "Y" ]; then \
			rm -rf $(ADB_DIR); \
			echo "[OK] Deleted $(ADB_DIR)"; \
		fi; \
		echo ""; \
		echo "Removing configuration from $(BASHRC)..."; \
		sed -i '/ADB Switch Windows/d' $(BASHRC); \
		sed -i '/adb-switch-windows/d' $(BASHRC); \
		echo "[OK] Removed configuration from $(BASHRC)"; \
		echo ""; \
		echo "Please run 'source ~/.bashrc' to apply changes in your current terminal"; \
	else \
		echo "Uninstall cancelled"; \
	fi

clean:
	@echo "Cleaning temporary files..."
	@rm -f *.zip
	@rm -rf platform-tools
	@echo "[OK] Clean completed"
