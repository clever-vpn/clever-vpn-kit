# clever-vpn-kit

They are the libraries of Clever VPN Client. include:
1. clever-vpn-kit for MacOS/iOS
2. clever-vpn-kit for Android
3. clever-vpn-kit for Windows

## 发布管理

本项目提供了统一的发布管理脚本来处理本地开发和 GitHub 发布流程。

### 快速开始

```bash
# 查看当前状态
./manage_release.sh status

# 本地开发模式
make local

# 仅构建库文件
make build

# 测试当前配置  
make test

# 发布新版本
make release VERSION=1.1.0
```

### 所有可用命令

```bash
# 主要命令
./manage_release.sh local                    # 本地开发模式
./manage_release.sh release 1.1.0            # 发布版本
./manage_release.sh status                   # 查看状态

# 辅助命令
./manage_release.sh build                    # 仅构建
./manage_release.sh test                     # 仅测试
./manage_release.sh restore                  # 恢复备份
./manage_release.sh help                     # 显示帮助
```

详细使用指南请参考 [RELEASE_GUIDE.md](RELEASE_GUIDE.md)。

### 工具说明

- `manage_release.sh`: 统一的发布管理脚本
- `Makefile`: 简化常用操作
- `RELEASE_GUIDE.md`: 详细使用指南
