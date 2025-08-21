# CleverVpnKit 发布管理 Makefile

.PHONY: help local build test status version auto-release release clean restore

# 默认目标
help:
	@echo "CleverVpnKit 发布管理"
	@echo ""
	@echo "可用命令:"
	@echo "  make local              # 切换到本地开发模式并构建测试"
	@echo "  make build              # 仅构建二进制库"
	@echo "  make test               # 测试当前配置"
	@echo "  make status             # 显示当前模式状态"
	@echo "  make version            # 显示版本信息"
	@echo "  make auto-release       # 自动发布基于 Apple Kit 版本"
	@echo "  make release VERSION=x.x.x # 发布指定版本"
	@echo "  make restore            # 恢复备份的 Package.swift"
	@echo "  make clean              # 清理构建文件"

# 本地开发模式
local:
	@echo "启动本地开发模式..."
	./manage_release.sh local

# 仅构建
build:
	@echo "构建二进制库..."
	./manage_release.sh build

# 测试当前配置
test:
	@echo "测试当前 Package.swift 配置..."
	./manage_release.sh test

# 显示当前状态
status:
	./manage_release.sh status

# 显示版本信息
version:
	./manage_release.sh version

# 自动发布
auto-release:
	@echo "自动发布基于 Apple Kit 版本..."
	./manage_release.sh auto-release

# 发布版本 (需要指定 VERSION 参数)
release:
ifndef VERSION
	@echo "错误: 请指定版本号"
	@echo "用法: make release VERSION=1.1.0"
	@exit 1
endif
	@echo "发布版本 $(VERSION)..."
	./manage_release.sh release $(VERSION)

# 恢复备份
restore:
	./manage_release.sh restore

# 清理构建文件
clean:
	swift package clean
	rm -rf .build
	@echo "构建文件已清理"

# 显示项目信息
info:
	@echo "项目信息:"
	@echo "  名称: CleverVpnKit"
	@echo "  类型: Swift Package (Binary Target)"
	@echo "  仓库: https://github.com/clever-vpn/clever-vpn-kit"
	@echo ""
	@echo "构建配置:"
	@echo "  构建脚本: ../apple/clever-vpn-apple-kit/DistributeTools/build.sh"
	@echo "  输出目录: ../apple/clever-vpn-apple-kit/DistributeTools/output"
	@echo ""
	make status
