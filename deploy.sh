#!/bin/bash

# Deploy script for Linux Character Device Driver
# This script helps with building, testing, and deploying the kernel module

set -e  # Exit on error

echo "=== Linux Character Device Driver - Deployment Script ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please don't run this script as root"
        print_info "Run without sudo, it will ask for password when needed"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    # Check for kernel headers
    if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
        print_error "Kernel headers not found"
        print_info "Installing kernel headers..."
        sudo apt-get update
        sudo apt-get install -y linux-headers-$(uname -r) build-essential
    fi
    
    # Check for gcc
    if ! command -v gcc &> /dev/null; then
        print_error "GCC not found"
        print_info "Installing build tools..."
        sudo apt-get install -y build-essential
    fi
    
    print_success "All dependencies checked"
}

# Build the module
build_module() {
    print_info "Building kernel module..."
    make clean
    make all
    print_success "Module built successfully"
}

# Load the module
load_module() {
    print_info "Loading kernel module..."
    
    # Check if module is already loaded
    if lsmod | grep -q "char_device"; then
        print_info "Module already loaded, unloading first..."
        sudo rmmod char_device_driver
    fi
    
    sudo insmod char_device_driver.ko
    print_success "Module loaded successfully"
    
    # Show device file
    print_info "Device file created:"
    ls -la /dev/char_device
}

# Unload the module
unload_module() {
    print_info "Unloading kernel module..."
    
    if lsmod | grep -q "char_device"; then
        sudo rmmod char_device_driver
        print_success "Module unloaded successfully"
    else
        print_info "Module not loaded"
    fi
}

# Test the driver
test_driver() {
    print_info "Testing driver..."
    
    # Check if module is loaded
    if ! lsmod | grep -q "char_device"; then
        print_error "Module not loaded. Run './deploy.sh load' first"
        exit 1
    fi
    
    # Run test application
    ./test_app
    
    print_success "Test completed"
    
    # Show kernel messages
    echo ""
    print_info "Recent kernel messages:"
    dmesg | grep "char_device" | tail -10
}

# Show logs
show_logs() {
    print_info "Kernel messages:"
    dmesg | grep "char_device" | tail -20
}

# Show module info
show_info() {
    print_info "Module information:"
    echo ""
    
    if lsmod | grep -q "char_device"; then
        echo "Module Status: Loaded"
        lsmod | grep char_device
        echo ""
        echo "Device File:"
        ls -la /dev/char_device 2>/dev/null || echo "Device file not found"
    else
        echo "Module Status: Not loaded"
    fi
}

# Clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."
    make clean
    print_success "Clean completed"
}

# Show help
show_help() {
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build kernel module and test application"
    echo "  load      - Load kernel module"
    echo "  unload    - Unload kernel module"
    echo "  reload    - Reload kernel module (unload + load)"
    echo "  test      - Test the driver"
    echo "  logs      - Show kernel messages"
    echo "  info      - Show module information"
    echo "  clean     - Clean build artifacts"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh build     # Build the module"
    echo "  ./deploy.sh load      # Load the module"
    echo "  ./deploy.sh test      # Test the driver"
    echo "  ./deploy.sh reload    # Reload the module"
}

# Main script
main() {
    check_root
    
    case "${1:-help}" in
        build)
            check_dependencies
            build_module
            ;;
        load)
            load_module
            ;;
        unload)
            unload_module
            ;;
        reload)
            unload_module
            load_module
            ;;
        test)
            test_driver
            ;;
        logs)
            show_logs
            ;;
        info)
            show_info
            ;;
        clean)
            clean_build
            ;;
        help|*)
            show_help
            ;;
    esac
}

main "$@"
