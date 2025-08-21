#!/bin/bash

# CleverVpnKit 发布管理脚本
# 用于管理本地开发和 GitHub 发布流程

set -e

# 配置
APPLE_KIT_PATH="../apple/clever-vpn-apple-kit"
BUILD_SCRIPT="$APPLE_KIT_PATH/DistributeTools/build.sh"
OUTPUT_DIR="$APPLE_KIT_PATH/DistributeTools/output"
FRAMEWORK_ZIP="CleverVpnKit.xcframework.zip"
CHECKSUM_FILE="checksum.txt"
PACKAGE_FILE="Package.swift"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要的工具
check_dependencies() {
    log_info "检查依赖工具..."
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) 未安装。请安装: brew install gh"
        exit 1
    fi
    
    if ! command -v swift &> /dev/null; then
        log_error "Swift 未安装"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装"
        exit 1
    fi
    
    log_success "依赖检查完成"
}

# 检查 Git 状态
check_git_status() {
    log_info "检查 Git 状态..."
    
    # 检查是否在 Git 仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是 Git 仓库"
        exit 1
    fi
    
    # 检查当前分支
    local current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
        log_warning "当前分支是 '$current_branch'，建议在 main/master 分支进行发布"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "取消操作"
            exit 1
        fi
    fi
    
    # 检查是否有未提交的更改（除了 Package.swift）
    if [ -n "$(git status --porcelain | grep -v "^.M Package.swift$")" ]; then
        log_error "工作目录有未提交的更改，请先提交或暂存:"
        git status --porcelain | grep -v "^.M Package.swift$"
        exit 1
    fi
    
    # 检查是否与远程同步
    git fetch origin
    local behind=$(git rev-list --count HEAD..origin/$(git branch --show-current) 2>/dev/null || echo "0")
    if [ "$behind" -gt 0 ]; then
        log_error "本地分支落后远程 $behind 个提交，请先拉取最新代码"
        exit 1
    fi
    
    log_success "Git 状态检查通过"
}

# 备份原始 Package.swift
backup_package() {
    log_info "备份 Package.swift..."
    cp "$PACKAGE_FILE" "$PACKAGE_FILE.backup"
    log_success "Package.swift 已备份"
}

# 恢复 Package.swift
restore_package() {
    if [ -f "$PACKAGE_FILE.backup" ]; then
        log_info "恢复 Package.swift..."
        mv "$PACKAGE_FILE.backup" "$PACKAGE_FILE"
        log_success "Package.swift 已恢复"
    fi
}

# 切换到本地开发模式
switch_to_local_mode() {
    log_info "切换到本地开发模式..."
    
    # 创建本地模式的 Package.swift
    cat > "$PACKAGE_FILE" << 'EOF'
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleverVpnKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CleverVpnKit",
            targets: ["CleverVpnKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "CleverVpnKit",
            // url: "https://github.com/clever-vpn/clever-vpn-kit/releases/download/1.0.0/CleverVpnKit.xcframework.zip",
            path: "../apple/clever-vpn-apple-kit/DistributeTools/output/CleverVpnKit.xcframework.zip"
            // checksum: "1d2214d2857e94b0ba2219268dbbfd27a0be0a641077dc06742e67b91e6d82f8"
        ),
    ]
)
EOF
    
    log_success "已切换到本地开发模式"
}

# 构建本地库
build_local_library() {
    log_info "构建本地库..."
    
    if [ ! -f "$BUILD_SCRIPT" ]; then
        log_error "构建脚本不存在: $BUILD_SCRIPT"
        exit 1
    fi
    
    log_info "执行构建脚本: $BUILD_SCRIPT"
    cd "$(dirname "$BUILD_SCRIPT")"
    bash "$(basename "$BUILD_SCRIPT")"
    cd - > /dev/null
    
    # 检查输出文件
    if [ ! -f "$OUTPUT_DIR/$FRAMEWORK_ZIP" ]; then
        log_error "构建失败: $OUTPUT_DIR/$FRAMEWORK_ZIP 不存在"
        exit 1
    fi
    
    if [ ! -f "$OUTPUT_DIR/$CHECKSUM_FILE" ]; then
        log_error "构建失败: $OUTPUT_DIR/$CHECKSUM_FILE 不存在"
        exit 1
    fi
    
    log_success "本地库构建完成"
}

# 测试本地库
test_local_library() {
    log_info "测试本地库..."
    
    # 解析 Package.swift
    swift package describe > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log_success "Package.swift 解析成功"
    else
        log_error "Package.swift 解析失败"
        exit 1
    fi
    
    # 构建测试
    swift build > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log_success "本地库测试通过"
    else
        log_error "本地库测试失败"
        exit 1
    fi
}

# 切换到发布模式
switch_to_release_mode() {
    local version=$1
    local checksum=$2
    
    log_info "切换到发布模式 (版本: $version)..."
    
    # 创建发布模式的 Package.swift
    cat > "$PACKAGE_FILE" << EOF
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleverVpnKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CleverVpnKit",
            targets: ["CleverVpnKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "CleverVpnKit",
            url: "https://github.com/clever-vpn/clever-vpn-kit/releases/download/$version/CleverVpnKit.xcframework.zip",
            // path: "../apple/clever-vpn-apple-kit/DistributeTools/output/CleverVpnKit.xcframework.zip",
            checksum: "$checksum"
        ),
    ]
)
EOF
    
    log_success "已切换到发布模式"
}

# 创建 GitHub Release
create_github_release() {
    local version=$1
    
    log_info "创建 GitHub Release: $version"
    
    # 检查是否已登录 GitHub CLI
    if ! gh auth status &> /dev/null; then
        log_error "请先登录 GitHub CLI: gh auth login"
        exit 1
    fi
    
    # 检查 tag 是否存在
    if ! git tag -l | grep -q "^$version$"; then
        log_error "Tag $version 不存在，请先创建 tag"
        exit 1
    fi
    
    # 检查版本是否已存在
    if gh release view "$version" &> /dev/null; then
        log_warning "Release $version 已存在"
        read -p "是否要删除并重新创建? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "删除现有 release..."
            gh release delete "$version" --yes
        else
            log_error "取消发布"
            exit 1
        fi
    fi
    
    # 基于 tag 创建 release
    log_info "基于 tag $version 创建 release..."
    gh release create "$version" \
        --title "CleverVpnKit $version" \
        --notes "Release $version of CleverVpnKit

## Changes
- Updated binary framework
- See commit history for detailed changes

## Installation
Add this to your Package.swift:
\`\`\`swift
.package(url: \"https://github.com/clever-vpn/clever-vpn-kit.git\", from: \"$version\")
\`\`\`" \
        "$OUTPUT_DIR/$FRAMEWORK_ZIP"
    
    log_success "GitHub Release 创建成功: $version"
}

# 验证发布结果
verify_release() {
    local version=$1
    
    log_info "验证发布结果..."
    
    # 检查 GitHub release
    if gh release view "$version" &> /dev/null; then
        log_success "✓ GitHub Release $version 存在"
        
        # 检查 assets
        local assets=$(gh release view "$version" --json assets --jq '.assets[].name')
        if echo "$assets" | grep -q "$FRAMEWORK_ZIP"; then
            log_success "✓ Framework ZIP 文件已上传"
        else
            log_error "✗ Framework ZIP 文件未找到"
        fi
    else
        log_error "✗ GitHub Release $version 不存在"
    fi
    
    # 检查 tag
    if git tag -l | grep -q "^$version$"; then
        log_success "✓ Git tag $version 存在"
    else
        log_error "✗ Git tag $version 不存在"
    fi
    
    # 检查远程 tag
    git fetch origin --tags
    if git ls-remote --tags origin | grep -q "refs/tags/$version"; then
        log_success "✓ 远程 tag $version 存在"
    else
        log_error "✗ 远程 tag $version 不存在"
    fi
    
    log_info "发布验证完成"
}

# 显示当前状态
show_status() {
    log_info "当前项目状态"
    echo ""
    
    # 显示 Package.swift 模式
    if grep -q "^[[:space:]]*path:" "$PACKAGE_FILE"; then
        echo "📦 Package.swift 模式: 本地开发模式"
        local path=$(grep "path:" "$PACKAGE_FILE" | sed 's/.*path: "\([^"]*\)".*/\1/')
        echo "   路径: $path"
        
        # 检查本地文件是否存在
        if [ -f "$path" ]; then
            echo "   ✅ 本地文件存在"
        else
            echo "   ❌ 本地文件不存在"
        fi
    elif grep -q "^[[:space:]]*url:" "$PACKAGE_FILE"; then
        echo "📦 Package.swift 模式: 发布模式"
        local url=$(grep "url:" "$PACKAGE_FILE" | sed 's/.*url: "\([^"]*\)".*/\1/')
        local checksum=$(grep "checksum:" "$PACKAGE_FILE" | sed 's/.*checksum: "\([^"]*\)".*/\1/')
        echo "   URL: $url"
        echo "   Checksum: $checksum"
    else
        echo "📦 Package.swift 模式: 未知"
    fi
    
    echo ""
    
    # 显示构建文件状态
    if [ -f "$OUTPUT_DIR/$FRAMEWORK_ZIP" ]; then
        echo "🔨 构建文件: ✅ $FRAMEWORK_ZIP 存在"
        local size=$(ls -lh "$OUTPUT_DIR/$FRAMEWORK_ZIP" | awk '{print $5}')
        local date=$(ls -l "$OUTPUT_DIR/$FRAMEWORK_ZIP" | awk '{print $6, $7, $8}')
        echo "   大小: $size, 修改时间: $date"
    else
        echo "🔨 构建文件: ❌ $FRAMEWORK_ZIP 不存在"
    fi
    
    if [ -f "$OUTPUT_DIR/$CHECKSUM_FILE" ]; then
        echo "📋 Checksum 文件: ✅ 存在"
        local checksum=$(cat "$OUTPUT_DIR/$CHECKSUM_FILE")
        echo "   内容: $checksum"
    else
        echo "📋 Checksum 文件: ❌ 不存在"
    fi
    
    echo ""
    
    # 显示 Git 状态
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current)
        echo "🌿 Git 分支: $branch"
        
        local status=$(git status --porcelain)
        if [ -z "$status" ]; then
            echo "📁 工作目录: ✅ 干净"
        else
            echo "📁 工作目录: ⚠️  有未提交的更改"
            echo "$status" | head -5
        fi
        
        # 检查最新 tag
        local latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "无")
        echo "🏷️  最新 tag: $latest_tag"
    else
        echo "🌿 Git: ❌ 不在 Git 仓库中"
    fi
}

# 提交和推送更改
commit_and_push() {
    local version=$1
    
    log_info "提交更改到 Git..."
    
    # 检查是否有未提交的更改
    if ! git diff --quiet "$PACKAGE_FILE"; then
        git add "$PACKAGE_FILE"
        git commit -m "Release $version: Update Package.swift for release"
        log_success "已提交 Package.swift 更改"
    else
        log_info "Package.swift 没有更改，跳过提交"
    fi
    
    # 检查 tag 是否已存在
    if git tag -l | grep -q "^$version$"; then
        log_warning "Tag $version 已存在"
        read -p "是否要删除并重新创建 tag? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "删除现有 tag..."
            git tag -d "$version"
            git push origin --delete "$version" 2>/dev/null || true
        else
            log_error "取消操作"
            exit 1
        fi
    fi
    
    # 创建 tag
    log_info "创建 tag $version..."
    git tag "$version"
    
    # 推送代码和 tag
    log_info "推送到远程仓库..."
    git push origin main
    git push origin "$version"
    
    log_success "更改和 tag 已推送到 GitHub"
}

# 显示帮助信息
show_help() {
    echo "CleverVpnKit 发布管理脚本"
    echo ""
    echo "用法:"
    echo "  $0 local                    # 切换到本地开发模式并构建测试"
    echo "  $0 release <version>        # 发布新版本到 GitHub"
    echo "  $0 status                   # 显示当前模式和状态"
    echo "  $0 build                    # 仅构建二进制库"
    echo "  $0 test                     # 仅测试当前配置"
    echo "  $0 restore                  # 恢复备份的 Package.swift"
    echo "  $0 help                     # 显示此帮助信息"
    echo ""
    echo "发布流程:"
    echo "  1. 检查依赖工具和 Git 状态"
    echo "  2. 构建二进制库（如需要）"
    echo "  3. 更新 Package.swift 为发布模式"
    echo "  4. 提交代码更改"
    echo "  5. 创建并推送 Git tag"
    echo "  6. 基于 tag 创建 GitHub Release"
    echo "  7. 上传二进制文件作为 release asset"
    echo "  8. 验证发布结果"
    echo ""
    echo "示例:"
    echo "  $0 local                    # 本地开发测试"
    echo "  $0 build                    # 仅构建库文件"
    echo "  $0 test                     # 测试当前配置"
    echo "  $0 status                   # 查看当前状态"
    echo "  $0 release 1.1.0            # 发布版本 1.1.0"
    echo ""
    echo "注意事项:"
    echo "  - 发布前请确保在 main 分支且与远程同步"
    echo "  - 需要安装并配置 GitHub CLI (gh)"
    echo "  - 版本号建议使用语义化版本 (如 1.0.0)"
}

# 主函数
main() {
    case "${1:-}" in
        "local")
            check_dependencies
            backup_package
            build_local_library
            switch_to_local_mode
            test_local_library
            log_success "本地开发环境准备完成！现在可以进行本地测试。"
            log_info "测试完成后，运行 '$0 release <version>' 进行发布"
            ;;
        "build")
            log_info "仅构建二进制库..."
            build_local_library
            log_success "构建完成！"
            ;;
        "test")
            log_info "测试当前 Package.swift 配置..."
            test_local_library
            log_success "测试通过！"
            ;;
        "status")
            show_status
            ;;
        "release")
            if [ -z "${2:-}" ]; then
                log_error "请指定版本号，例如: $0 release 1.1.0"
                exit 1
            fi
            
            local version=$2
            
            check_dependencies
            check_git_status
            
            # 确保有最新的构建
            if [ ! -f "$OUTPUT_DIR/$FRAMEWORK_ZIP" ] || [ ! -f "$OUTPUT_DIR/$CHECKSUM_FILE" ]; then
                log_info "未找到构建文件，开始构建..."
                build_local_library
            fi
            
            # 读取 checksum
            local checksum=$(cat "$OUTPUT_DIR/$CHECKSUM_FILE")
            log_info "使用 checksum: $checksum"
            
            # 切换到发布模式
            switch_to_release_mode "$version" "$checksum"
            
            # 提交更改并创建 tag
            commit_and_push "$version"
            
            # 创建 GitHub Release（基于已存在的 tag）
            create_github_release "$version"
            
            # 验证发布结果
            verify_release "$version"
            
            log_success "版本 $version 发布完成！"
            log_info "Release URL: https://github.com/clever-vpn/clever-vpn-kit/releases/tag/$version"
            ;;
        "restore")
            restore_package
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "未知命令: ${1:-}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 错误处理
trap 'log_error "脚本执行失败！"; restore_package; exit 1' ERR

# 执行主函数
main "$@"
