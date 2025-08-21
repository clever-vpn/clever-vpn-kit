# clever-vpn-kit

They are the libraries of Clever VPN Client. include:
1. clever-vpn-kit for MacOS/iOS
2. clever-vpn-kit for Android
3. clever-vpn-kit for Windows

## 功能特性

- **双模式切换**：本地开发 vs GitHub 发布无缝切换
- **自动版本同步**：基于 Apple Kit 源项目的最新 Git 标签自动版本管理
- **智能测试**：自动检测二进制目标类型，采用适当的验证方式
- **状态监控**：实时显示配置状态和版本同步情况
- **安全发布**：完整的构建、测试、发布流程
- **版本建议**：智能分析并建议下一个版本号

### 快速开始

```bash
# 查看版本状态（包含 Apple Kit 版本同步信息）
./manage_release.sh status

# 查看版本信息和建议
./manage_release.sh version

# 本地开发模式
make local

# 自动发布（推荐：基于 Apple Kit 版本）
make auto-release

# 仅构建库文件
make build

# 测试当前配置  
make test
```

### 所有可用命令

```bash
# 版本管理（推荐）
./manage_release.sh version                  # 查看版本信息和建议
./manage_release.sh auto-release             # 基于 Apple Kit 自动发布

# 主要命令
./manage_release.sh local                    # 本地开发模式
./manage_release.sh release 1.1.0            # 手动发布版本
./manage_release.sh status                   # 查看状态

# 辅助命令
./manage_release.sh build                    # 仅构建
./manage_release.sh test                     # 仅测试
./manage_release.sh restore                  # 恢复备份
./manage_release.sh help                     # 显示帮助
```

详细使用指南请参考 [RELEASE_GUIDE.md](RELEASE_GUIDE.md)。
自动版本功能说明请参考 [AUTO_VERSION_GUIDE.md](AUTO_VERSION_GUIDE.md)。

### 工具说明

- `manage_release.sh`: 统一的发布管理脚本
- `Makefile`: 简化常用操作
- `RELEASE_GUIDE.md`: 详细使用指南
- `AUTO_VERSION_GUIDE.md`: 自动版本功能说明
