# 自动版本同步使用示例

基于 Apple Kit 项目的 Git tags 自动管理版本发布。

## 查看版本信息

```bash
# 查看 Apple Kit 和当前仓库的版本信息
./manage_release.sh version
```

输出示例：
```
正在获取版本信息...
Apple Kit 最新版本: 1.0.1
当前仓库最新 tag: 1.0.0

[INFO] 当前版本: 1.0.1
[INFO] 建议的版本号:
  补丁版本 (patch): 1.0.2
  次要版本 (minor): 1.1.0
  主要版本 (major): 2.0.0
```

## 自动发布

```bash
# 自动使用 Apple Kit 的版本号进行发布
./manage_release.sh auto-release
```

该命令会：
1. 获取 Apple Kit 项目的最新 Git tag
2. 检查本仓库是否已有相同版本的 tag
3. 如果版本冲突，提供选项使用建议的版本号
4. 自动执行完整的发布流程

## 状态监控

```bash
# 查看版本同步状态
./manage_release.sh status
```

状态显示会包含：
- 📦 当前 Package.swift 模式
- 🔨 构建文件状态
- 🍎 Apple Kit 版本信息
- ⚠️ 版本不同步警告（如适用）

## 工作流程示例

### 典型的开发到发布流程

```bash
# 1. 切换到本地开发模式
./manage_release.sh local

# 2. 进行开发和测试...

# 3. 查看版本状态
./manage_release.sh status

# 4. 自动发布（推荐）
./manage_release.sh auto-release
```

### 手动版本控制

```bash
# 查看版本信息和建议
./manage_release.sh version

# 手动指定版本发布
./manage_release.sh release 1.1.0
```

## Makefile 快捷命令

```bash
# 查看版本信息
make version

# 自动发布
make auto-release

# 查看状态
make status
```

## 版本策略

### 自动版本同步
- 默认使用 Apple Kit 项目的最新 Git tag
- 如果版本已存在，自动建议补丁版本 (+0.0.1)

### 版本号格式
- 支持 `1.0.0` 格式
- 支持 `v1.0.0` 格式（会自动移除 'v' 前缀）
- 必须符合语义化版本规范

### 冲突处理
```bash
Apple Kit 版本: 1.0.1
本仓库已有: 1.0.1

建议版本:
  补丁版本: 1.0.2
  次要版本: 1.1.0
  主要版本: 2.0.0
```

## 配置

Apple Kit 项目路径在 `manage_release.sh` 中配置：
```bash
APPLE_KIT_PATH="../apple/clever-vpn-apple-kit"
```

确保：
1. 路径正确指向 Apple Kit 项目
2. Apple Kit 项目是有效的 Git 仓库
3. Apple Kit 项目有符合格式的版本 tags

## 故障排除

### 常见问题

**1. "Apple Kit 项目路径不存在"**
- 检查 `APPLE_KIT_PATH` 配置
- 确保相对路径正确

**2. "Apple Kit 项目不是 Git 仓库"**  
- 确保 Apple Kit 项目已初始化为 Git 仓库
- 检查 `.git` 目录是否存在

**3. "未找到有效的版本 tag"**
- 在 Apple Kit 项目中创建版本 tag：
  ```bash
  cd ../apple/clever-vpn-apple-kit
  git tag 1.0.0
  git push origin 1.0.0
  ```

**4. "版本格式不正确"**
- 确保 tag 格式为 `x.y.z` 或 `vx.y.z`
- 使用语义化版本号

### 调试命令

```bash
# 检查 Apple Kit 项目的 tags
cd ../apple/clever-vpn-apple-kit && git tag -l

# 手动测试版本获取
cd ../apple/clever-vpn-apple-kit && git tag -l | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1
```
