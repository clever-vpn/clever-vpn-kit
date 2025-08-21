#!/bin/bash

# 创建测试项目来验证 CleverVpnKit 是否能正常导入和使用

set -e

# 配置
TEST_DIR="TestProject"
CURRENT_DIR=$(pwd)

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# 清理之前的测试项目
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

log_info "创建测试项目..."

# 创建测试项目目录
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# 创建测试项目的 Package.swift
cat > Package.swift << EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TestProject",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "TestProject",
            targets: ["TestProject"]),
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "TestProject",
            dependencies: ["CleverVpnKit"]),
    ]
)
EOF

# 创建源码目录
mkdir -p Sources/TestProject

# 创建测试代码
cat > Sources/TestProject/main.swift << 'EOF'
import Foundation
import CleverVpnKit

print("🚀 CleverVpnKit 测试项目")
print("✅ CleverVpnKit 库导入成功!")

// 这里可以添加对 CleverVpnKit 的具体测试
// 由于这是一个二进制库，我们主要验证能否正常导入和链接

print("🎉 测试完成!")
EOF

log_info "构建测试项目..."

# 尝试构建测试项目
if swift build > build.log 2>&1; then
    log_success "测试项目构建成功!"
    log_info "运行测试..."
    
    # 运行测试程序
    if ./.build/debug/TestProject; then
        log_success "CleverVpnKit 库验证通过!"
    else
        log_error "测试程序运行失败"
        exit 1
    fi
else
    log_error "测试项目构建失败"
    echo "构建日志:"
    cat build.log
    exit 1
fi

# 清理
cd "$CURRENT_DIR"
rm -rf "$TEST_DIR"

log_success "CleverVpnKit 集成测试完成!"
