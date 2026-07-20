# Linux Character Device Driver

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Linux](https://img.shields.io/badge/Linux-Kernel_Module-orange.svg)](https://www.kernel.org/)
[![C](https://img.shields.io/badge/Language-C-blue.svg)](https://en.wikipedia.org/wiki/C_(programming_language))

A simple Linux character device driver implemented as a loadable kernel module (LKM). This project demonstrates core Linux kernel development concepts including module initialization/cleanup, file_operations structure, device registration, kernel-space memory management, and user-kernel data transfer.

## 📋 Features

- **Loadable Kernel Module (LKM)** - Dynamically loadable/unloadable driver
- **file_operations Structure** - Complete implementation of open, read, write, release
- **Device Registration** - Automatic major/minor number allocation
- **Kernel Memory Management** - kmalloc/kfree for buffer allocation
- **User-Kernel Data Transfer** - copy_to_user/copy_from_user
- **Kernel Logging** - printk for debugging and monitoring
- **Device Class Creation** - Automatic /dev file creation

## 🛠️ Technologies Used

- **Language:** C
- **Kernel APIs:** Linux Kernel Module API, file_operations, kmalloc, copy_to_user
- **Build System:** Makefile with kernel build system
- **Debug Tools:** dmesg, printk, strace

## 📁 Project Structure

```
linux-character-device-driver/
├── src/
│   ├── char_device_driver.c    # Kernel module source code
│   └── test_app.c              # Userspace test application
├── Makefile                     # Build configuration
├── deploy.sh                    # Deployment script
├── setup_github.sh              # GitHub setup script
├── README.md                    # This file
└── LICENSE                      # License file
```

## 🚀 Quick Start

### Prerequisites

- Linux system (Ubuntu/Debian recommended)
- Kernel headers installed
- Build tools (gcc, make)
- Root/sudo access

### Install Dependencies

```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y linux-headers-$(uname -r) build-essential
```

### Build the Module

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/linux-character-device-driver.git
cd linux-character-device-driver

# Build kernel module and test application
make all

# Or build individually
make module      # Build kernel module only
make test_app    # Build test application only
```

### Load the Module

```bash
# Load the kernel module
sudo insmod char_device_driver.ko

# Verify module is loaded
lsmod | grep char_device

# Check kernel messages
dmesg | tail -10
```

### Test the Driver

```bash
# Run the test application
./test_app

# Or use make
make test
```

### Unload the Module

```bash
# Unload the kernel module
sudo rmmod char_device_driver

# Verify module is unloaded
lsmod | grep char_device
```

## 📖 How It Works

### 1. Module Initialization (`char_device_init`)

When the module is loaded using `insmod`, the initialization function:

1. **Allocates device number** dynamically using `alloc_chrdev_region()`
2. **Creates device class** using `class_create()`
3. **Initializes cdev structure** with `cdev_init()`
4. **Adds cdev to system** with `cdev_add()`
5. **Creates device file** at `/dev/char_device` using `device_create()`
6. **Allocates kernel buffer** using `kmalloc()`

### 2. File Operations

The driver implements four main file operations:

#### `char_device_open()`
- Called when userspace opens the device file
- Logs the open event using `printk()`

#### `char_device_read()`
- Called when userspace reads from the device
- Uses `copy_to_user()` to transfer data from kernel to userspace
- Handles offset tracking for sequential reads

#### `char_device_write()`
- Called when userspace writes to the device
- Uses `copy_from_user()` to transfer data from userspace to kernel
- Stores data in kernel buffer allocated with `kmalloc()`

#### `char_device_release()`
- Called when userspace closes the device file
- Logs the close event using `printk()`

### 3. Module Cleanup (`char_device_exit`)

When the module is unloaded using `rmmod`, the cleanup function:

1. **Frees kernel buffer** using `kfree()`
2. **Destroys device file** using `device_destroy()`
3. **Removes cdev** using `cdev_del()`
4. **Destroys device class** using `class_destroy()`
5. **Unregisters device number** using `unregister_chrdev_region()`

## 🧪 Testing

### Manual Testing

```bash
# Load the module
sudo insmod char_device_driver.ko

# Write data to device
echo "Hello Kernel!" > /dev/char_device

# Read data from device
cat /dev/char_device

# Check kernel messages
dmesg | tail -10

# Unload the module
sudo rmmod char_device_driver
```

### Using the Test Application

```bash
# Build and run test application
make test_app
./test_app
```

The test application will:
1. Open the device file
2. Write test data to the device
3. Read data back from the device
4. Verify data integrity
5. Close the device file

### Expected Output

```
=== Character Device Driver Test Application ===

[1] Opening device file: /dev/char_device
    Device opened successfully (fd = 3)

[2] Writing data to device...
    Data: "Hello from userspace! Testing character device driver."
    Successfully wrote 53 bytes to device

[3] Resetting file offset to beginning...
    File offset reset successfully

[4] Reading data from device...
    Read 53 bytes from device
    Data: "Hello from userspace! Testing character device driver."

[5] Verifying data integrity...
    ✓ SUCCESS: Data matches!
    Write buffer and read buffer contain identical data.

[6] Closing device file...
    Device closed successfully

=== Test completed successfully! ===
```

## 📊 Kernel Messages

After loading the module and running tests, you should see messages like:

```
[  123.456789] char_device: Initializing character device driver
[  123.456790] char_device: Registered with major number 237
[  123.456791] char_device: Device class created successfully
[  123.456792] char_device: Character device driver loaded successfully
[  123.456793] char_device: Device created at /dev/char_device
[  124.567890] char_device: Device opened
[  124.567891] char_device: Wrote 53 bytes to device
[  124.567892] char_device: Read 53 bytes from device
[  124.567893] char_device: Device closed
```

## 🔍 Debugging

### View Module Information

```bash
# Check if module is loaded
lsmod | grep char_device

# View module info
modinfo char_device_driver

# Check device file
ls -la /dev/char_device

# View kernel messages
dmesg | grep char_device
```

### Common Issues

1. **Module fails to load:**
   - Ensure kernel headers are installed
   - Check kernel version compatibility
   - Run `dmesg` for error messages

2. **Device file not created:**
   - Verify module loaded successfully
   - Check kernel messages for errors

3. **Permission denied:**
   - Run with `sudo` or check device permissions

## 🎯 Key Concepts Demonstrated

- **Loadable Kernel Modules (LKM)** - Dynamic module loading/unloading
- **file_operations** - Implementing device file operations
- **Device Registration** - Major/minor number allocation
- **Kernel Memory Management** - kmalloc/kfree
- **User-Kernel Data Transfer** - copy_to_user/copy_from_user
- **Kernel Logging** - printk for debugging
- **Device Class** - Automatic /dev file creation

## 📚 Learning Resources

- [Linux Kernel Module Programming Guide](https://tldp.org/LDP/lkmpg/2.6/html/)
- [Linux Device Drivers, 3rd Edition](https://lwn.net/Kernel/LDD3/)
- [The Linux Kernel documentation](https://www.kernel.org/doc/html/latest/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the GPL License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Tushar Kumar**
- Email: sparrow000iv@gmail.com

## 🙏 Acknowledgments

- Linux Kernel Documentation
- The Linux Kernel Module Programming Guide
- Linux Device Drivers, 3rd Edition

---

⭐ If you found this project helpful, please give it a star!
