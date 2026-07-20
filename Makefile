# Makefile for Linux Character Device Driver
# 
# This Makefile supports:
# - Building the kernel module
# - Building the userspace test application
# - Loading/unloading the module
# - Testing the driver
# - Cleaning build artifacts

# Kernel module name
obj-m += char_device_driver.o

# Compiler for userspace application
CC = gcc
CFLAGS = -Wall -Wextra -O2

# Default kernel build directory
KDIR ?= /lib/modules/$(shell uname -r)/build

# Userspace test application
TEST_APP = test_app

# Default target
all: module test_app

# Build kernel module
module:
	@echo "Building kernel module..."
	$(MAKE) -C $(KDIR) M=$(PWD) modules
	@echo "Kernel module built successfully: char_device_driver.ko"

# Build userspace test application
test_app: src/test_app.c
	@echo "Building test application..."
	$(CC) $(CFLAGS) -o $(TEST_APP) src/test_app.c
	@echo "Test application built successfully: $(TEST_APP)"

# Load the kernel module
load:
	@echo "Loading kernel module..."
	sudo insmod char_device_driver.ko
	@echo "Module loaded. Check dmesg for output."
	@echo "Device file created at: /dev/char_device"

# Unload the kernel module
unload:
	@echo "Unloading kernel module..."
	sudo rmmod char_device_driver
	@echo "Module unloaded."

# Reload the kernel module (unload + load)
reload: unload load

# Test the driver
test: test_app
	@echo "Running test application..."
	@echo "Note: Make sure the module is loaded first (make load)"
	./$(TEST_APP)

# View kernel messages
logs:
	@echo "Recent kernel messages:"
	dmesg | tail -20

# Show module information
info:
	@echo "Module information:"
	@lsmod | grep char_device || echo "Module not loaded"
	@echo ""
	@echo "Device file:"
	@ls -la /dev/char_device 2>/dev/null || echo "Device file not found"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	rm -f $(TEST_APP)
	@echo "Clean completed."

# Install dependencies (for Ubuntu/Debian)
install-deps:
	@echo "Installing kernel headers..."
	sudo apt-get update
	sudo apt-get install -y linux-headers-$(shell uname -r) build-essential

# Help
help:
	@echo "Available targets:"
	@echo "  all          - Build kernel module and test application"
	@echo "  module       - Build kernel module only"
	@echo "  test_app     - Build test application only"
	@echo "  load         - Load kernel module"
	@echo "  unload       - Unload kernel module"
	@echo "  reload       - Reload kernel module"
	@echo "  test         - Run test application"
	@echo "  logs         - View kernel messages"
	@echo "  info         - Show module information"
	@echo "  clean        - Clean build artifacts"
	@echo "  install-deps - Install build dependencies"
	@echo "  help         - Show this help message"

.PHONY: all module test_app load unload reload test logs info clean install-deps help
