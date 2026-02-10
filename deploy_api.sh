#!/bin/bash
# GitHub API Deployment Script

GITHUB_USER="fisher0472"
REPO_NAME="stock-report-web"
REPO_DESC="A股量化精选报告可视化网站 - 深市CYQ筹码分析"
ACCESS_TOKEN="${GITHUB_TOKEN}"

echo "🚀 GitHub API 部署脚本"
echo "========================"
echo ""

# 检查token
if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ 错误: 未设置 GITHUB_TOKEN 环境变量"
    echo ""
    echo "请执行:"
    echo 'export GITHUB_TOKEN="你的GitHub_Personal_Access_Token"'
    echo ""
    echo "如何获取Token:"
    echo "1. 访问 https://github.com/settings/tokens"
    echo "2. 点击 'Generate new token (classic)'"
    echo "3. Note: stock-report-deploy"
    echo "4. 勾选: repo (完整仓库权限)"
    echo "5. 点击 Generate"
    exit 1
fi

# 创建仓库
echo "📦 创建GitHub仓库..."
curl -X POST -H "Authorization: token $ACCESS_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/repos \
    -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESC\",\"private\":false,\"auto_init\":false}" \
    2>/dev/null | grep -E '"id"|"message"' | head -5

echo ""
echo "✅ 仓库创建完成（或已存在）"

# 配置Git
echo ""
echo "⚙️ 配置Git..."
git config user.email "fish0472@gmail.com"
git config user.name "Fisher"

# 重命名分支为main
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "master" ] || [ -z "$BRANCH" ]; then
    git branch -M main
    echo "📛 重命名分支为 main"
fi

# 添加远程仓库
echo ""
echo "🔗 添加远程仓库..."
git remote remove origin 2>/dev/null
git remote add origin "https://${GITHUB_USER}:${ACCESS_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

# 推送
echo ""
echo "📤 推送代码到GitHub..."
git push -u origin main

echo ""
echo "========================"
echo "✅ 部署完成!"
echo ""
echo "🌐 下一步 - 启用GitHub Pages:"
echo "1. 访问: https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/pages"
echo "2. Source: Deploy from a branch"
echo "3. Branch: main / (root)"
echo "4. Save"
echo ""
echo "🔗 你的网站将在几分钟后上线:"
echo "https://${GITHUB_USER}.github.io/${REPO_NAME}/"
