#!/bin/bash

set -euo pipefail

# ユーザー名とリポジトリ名
USER="annenpolka"
REPO="glove80-zmk-config"

# GitHubのAPIエンドポイント
API_URL="https://api.github.com/repos/$USER/$REPO/actions/artifacts"

# 最新のワークフローランのアーティファクトを取得
echo "最新のビルドアーティファクトを検索中..."
ARTIFACTS=$(curl -s $API_URL)

# アーティファクトの詳細確認
echo "アーティファクト情報:"
echo $ARTIFACTS | jq '.'

# 最新のglove80.uf2アーティファクトを見つける
ARTIFACT_ID=$(echo $ARTIFACTS | jq -r '.artifacts[] | select(.name == "glove80-zmk") | .id')

if [ -z "$ARTIFACT_ID" ]; then
    echo "Error: 最新のファームウェアアーティファクトが見つかりません"
    exit 1
fi

echo "ファームウェアアーティファクト ID: $ARTIFACT_ID が見つかりました"

# ダウンロードURL取得
DOWNLOAD_URL="https://github.com/$USER/$REPO/actions/artifacts/$ARTIFACT_ID/zip"

# ダウンロードとエクストラクト
echo "ファームウェアのダウンロード中..."
curl -L -o firmware.zip $DOWNLOAD_URL

echo "ファイルの展開中..."
unzip -o firmware.zip

echo "完了! glove80.uf2ファイルが現在のディレクトリに保存されました"