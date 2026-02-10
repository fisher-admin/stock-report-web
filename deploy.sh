#!/bin/bash
# GitHub部署脚本 - 完整版
# 用法: bash deploy.sh

set -e

# 配置
GITHUB_USER="fisher0472"
REPO_NAME="stock-report-web"
REPO_DESC="A股量化精选报告可视化网站 - 深市CYQ筹码分析"
EMAIL="fish0472@gmail.com"

echo "🚀 GitHub部署 - A股量化报告网站"
echo "=================================="
echo ""

# 检查GitHub Token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN 未设置"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 请先获取GitHub Token:"
    echo ""
    echo "1. 访问: https://github.com/settings/tokens"
    echo "2. 点击: Generate new token (classic)"
    echo "3. 设置:"
    echo "   - Note: stock-report-deploy"
    echo "   - Expiration: No expiration"
    echo "   - 勾选: repo"
    echo "4. 点击 Generate"
    echo "5. 复制token"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 然后执行:"
    echo ""
    echo 'export GITHUB_TOKEN="ghp_xxxxx..."'
    echo "cd /root/.openclaw/workspace/stock-report-web"
    echo "bash deploy.sh"
    echo ""
    exit 0
fi

echo "✅ GITHUB_TOKEN 已设置"
echo ""

# 1. 创建仓库
echo "📦 [1/4] 创建GitHub仓库..."
CREATE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/repos \
    -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESC\",\"private\":false}")

REPO_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -n "$REPO_ID" ]; then
    echo "   ✅ 仓库创建成功 (ID: $REPO_ID)"
else
    if echo "$CREATE_RESPONSE" | grep -q "already exists"; then
        echo "   ⚠️ 仓库已存在，跳过创建"
    else
        echo "   ❌ 创建失败: $CREATE_RESPONSE"
        exit 1
    fi
fi

# 2. 配置Git
echo ""
echo "⚙️  [2/4] 配置Git..."
git config user.email "$EMAIL"
git config user.name "Fisher"
echo "   ✅ Git配置完成"

# 3. 重命名分支
echo ""
echo "🔀  [3/4] 重命名分支为main..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "master" ] || [ -z "$CURRENT_BRANCH" ]; then
    git branch -M main
    echo "   ✅ 已重命名为 main"
else
    echo "   ⚠️ 当前分支已是 main"
fi

# 4. 推送
echo ""
echo "📤  [4/4] 推送到GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
git push -u origin main --force

echo ""
echo "=================================="
echo "✅ 代码推送完成!"
echo ""
echo "🎯 下一步 - 启用GitHub Pages:"
echo ""
echo "1. 访问: https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/pages"
echo "2. Source: Deploy from a branch"
echo "3. Branch: main / (root)"
echo "4. 点击 Save"
echo ""
echo "🌐 你的网站将在1-2分钟后上线:"
echo "   https://${GITHUB_USER}.github.io/${REPO_NAME}/"
echo ""
echo "=================================="
