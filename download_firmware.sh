#!/bin/bash

set -euo pipefail

echo "GitHub CLIを使って最新のファームウェアをダウンロードします..."

# 最新のワークフロー実行IDを取得
echo "最新のビルド実行を検索中..."
LATEST_RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$LATEST_RUN_ID" ]; then
    echo "Error: 最新のワークフロー実行が見つかりません"
    exit 1
fi

echo "最新のワークフロー実行 ID: $LATEST_RUN_ID を使用します"

# 既存のglove80.uf2ディレクトリがあれば削除
if [ -d "glove80.uf2" ]; then
    echo "既存のglove80.uf2ディレクトリを削除中..."
    rm -rf glove80.uf2
fi

# アーティファクトをダウンロード
echo "ファームウェアをダウンロード中..."
gh run download $LATEST_RUN_ID

# ファイルの存在を確認
if [ -f "glove80.uf2/glove80.uf2" ]; then
    echo "ダウンロード成功！"
    echo "ファームウェアの場所: $(pwd)/glove80.uf2/glove80.uf2"
    
    # ブートローダーの確認
    echo "ブートローダーの検索中..."
    if [ -d "/Volumes/NO NAME" ] || [ -d "/Volumes/NO NAME 1" ]; then
        echo "ブートローダーが検出されました！"
        echo "以下のコマンドでファームウェアを書き込みできます:"
        
        if [ -d "/Volumes/NO NAME" ]; then
            echo "cp glove80.uf2/glove80.uf2 \"/Volumes/NO NAME/\""
        fi
        
        if [ -d "/Volumes/NO NAME 1" ]; then
            echo "cp glove80.uf2/glove80.uf2 \"/Volumes/NO NAME 1/\""
        fi
    else
        echo "ブートローダーが検出されませんでした。キーボードをブートローダーモードにしてください。"
    fi
else
    echo "Error: ファームウェアのダウンロードに失敗したか、予期しないファイル構造です"
    exit 1
fi