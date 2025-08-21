# CleverVpnKit 发布管理指南

本项目使用自动化脚本来管理本地开发和 GitHub 发布流程。

## 前置要求

1. **GitHub CLI**: 安装并配置 GitHub CLI
   ```bash
   brew install gh
   gh auth login
   ```

2. **Swift**: 确保已安装 Swift 开发工具

3. **构建脚本**: 确保 `../apple/clever-vpn-apple-kit/DistributeTools/build.sh` 已按照 [BUILD_SCRIPT_GUIDE.md](BUILD_SCRIPT_GUIDE.md) 的要求修改，能够生成三个必要文件：
   - `CleverVpnKit.xcframework/` (目录)
   - `CleverVpnKit.xcframework.zip` (文件)  
   - `checksum.txt` (文件)

## 使用流程

### 快速开始

```bash
# 本地开发模式
make local

# 查看当前状态
make status

# 仅构建库文件
make build

# 测试当前配置
make test

# 发布新版本
make release VERSION=1.1.0
```

详细使用指南请参考下面的说明。

### 工具说明

- `manage_release.sh`: 完整的发布管理脚本（统一入口）
- `Makefile`: 简化常用操作
- `RELEASE_GUIDE.md`: 详细使用指南

## 工作流程示例

```bash
# 1. 开始本地开发
./manage_release.sh local

# 2. 在本地测试你的更改
# ... 进行开发和测试 ...

# 3. 测试完成后发布新版本
./manage_release.sh release 1.2.0

# 4. 发布完成！
```

## Package.swift 模式

### 本地开发模式
```swift
.binaryTarget(
    name: "CleverVpnKit",
    // url: "https://github.com/clever-vpn/clever-vpn-kit/releases/download/1.0.0/CleverVpnKit.xcframework.zip",
    path: "../apple/clever-vpn-apple-kit/DistributeTools/output/CleverVpnKit.xcframework.zip"
    // checksum: "1d2214d2857e94b0ba2219268dbbfd27a0be0a641077dc06742e67b91e6d82f8"
),
```

### 发布模式
```swift
.binaryTarget(
    name: "CleverVpnKit",
    url: "https://github.com/clever-vpn/clever-vpn-kit/releases/download/1.1.0/CleverVpnKit.xcframework.zip",
    // path: "../apple/clever-vpn-apple-kit/DistributeTools/output/CleverVpnKit.xcframework.zip",
    checksum: "新的checksum值"
),
```

## 注意事项

1. **备份**: 脚本会自动备份 `Package.swift`，如果出现问题可以使用 `restore` 命令恢复

2. **版本管理**: 确保使用语义化版本号（如 1.0.0, 1.1.0, 2.0.0）

3. **权限**: 确保对 GitHub 仓库有推送权限

4. **构建文件**: 发布前确保 `../apple/clever-vpn-apple-kit/DistributeTools/output/` 目录下有最新的构建文件

5. **测试**: 在发布前务必在本地模式下充分测试

6. **Git 状态**: 发布前确保：
   - 在 main 或 master 分支
   - 工作目录干净（除了 Package.swift 的更改）
   - 与远程仓库同步

7. **发布顺序**: 脚本遵循标准 Git 流程：
   - 先提交代码更改
   - 创建并推送 Git tag
   - 基于 tag 创建 GitHub Release

8. **验证**: 发布完成后脚本会自动验证：
   - GitHub Release 是否创建成功
   - Assets 是否上传完成
   - Git tag 是否推送成功

## 文件结构

```
clever-vpn-kit/
├── Package.swift              # SPM 包配置文件
├── manage_release.sh         # 发布管理脚本
├── .release-config          # 配置文件
├── README.md               # 项目说明
└── RELEASE_GUIDE.md       # 本文档（发布指南）
```
