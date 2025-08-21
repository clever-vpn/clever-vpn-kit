# 构建脚本修改指南

为了支持本地开发和发布的完整流程，需要修改 `../apple/clever-vpn-apple-kit/DistributeTools/build.sh` 脚本，使其生成三个文件：

## 期望的输出文件

在 `../apple/clever-vpn-apple-kit/DistributeTools/output/` 目录下应该生成：

1. **`CleverVpnKit.xcframework/`** - 未压缩的 XCFramework 目录
   - 用于本地开发和测试
   - SPM 在本地模式下直接引用这个目录

2. **`CleverVpnKit.xcframework.zip`** - 压缩的 XCFramework 文件
   - 用于 GitHub Release 分发
   - 包含完整的 XCFramework 结构

3. **`checksum.txt`** - SHA256 校验和文件
   - 包含 ZIP 文件的 SHA256 哈希值
   - 用于 SPM 的完整性验证

## 建议的构建脚本修改

```bash
#!/bin/bash

# 你的现有构建逻辑...
# ... 生成 XCFramework ...

# 确保输出目录存在
mkdir -p output

# 1. 复制/移动生成的 XCFramework 到输出目录
cp -R path/to/generated/CleverVpnKit.xcframework output/

# 2. 创建 ZIP 文件
cd output
zip -r CleverVpnKit.xcframework.zip CleverVpnKit.xcframework/
cd ..

# 3. 生成 SHA256 校验和
shasum -a 256 output/CleverVpnKit.xcframework.zip | cut -d ' ' -f 1 > output/checksum.txt

echo "构建完成！"
echo "生成的文件："
echo "  - XCFramework: output/CleverVpnKit.xcframework/"
echo "  - ZIP 文件: output/CleverVpnKit.xcframework.zip"
echo "  - Checksum: output/checksum.txt"
echo "  - SHA256: $(cat output/checksum.txt)"
```

## 验证生成的文件

修改后，可以通过以下命令验证：

```bash
# 运行构建脚本
./build.sh

# 检查生成的文件
ls -la output/
# 应该看到：
# CleverVpnKit.xcframework/     (目录)
# CleverVpnKit.xcframework.zip  (文件)
# checksum.txt                  (文件)

# 验证 checksum
shasum -a 256 output/CleverVpnKit.xcframework.zip
cat output/checksum.txt
# 这两个值应该相同
```

## 与发布管理脚本的集成

修改完成后，`manage_release.sh` 脚本将能够：

1. **本地模式**: 直接使用 `output/CleverVpnKit.xcframework/` 目录
2. **发布模式**: 使用 `output/CleverVpnKit.xcframework.zip` 和 `output/checksum.txt`

这样可以避免重复的压缩/解压操作，提高开发效率。

## 注意事项

1. 确保生成的 XCFramework 目录具有正确的权限
2. ZIP 文件应该在目录内部创建，保持相对路径结构
3. Checksum 文件只包含 64 位十六进制哈希值，没有文件名
4. 构建脚本应该是幂等的，可以重复运行

## 测试修改结果

```bash
# 运行本地开发模式测试
./manage_release.sh local

# 查看状态
./manage_release.sh status

# 测试配置
./manage_release.sh test
```
