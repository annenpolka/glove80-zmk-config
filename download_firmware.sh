#!/bin/bash

# 配列の参照で見つからないインデックスでもエラーを出さないようにする
set -eo pipefail
# 文字化け防止のためロケールを設定
export LC_ALL=C

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
    BOOTLOADER_FOUND=false
    declare -a BOOTLOADER_PATHS
    
    # 可能なブートローダーパスを確認
    if [ -d "/Volumes/NO NAME" ]; then
        BOOTLOADER_PATHS+=("/Volumes/NO NAME")
        BOOTLOADER_FOUND=true
    fi
    
    if [ -d "/Volumes/NO NAME 1" ]; then
        BOOTLOADER_PATHS+=("/Volumes/NO NAME 1")
        BOOTLOADER_FOUND=true
    fi
    
    # GLVで始まるボリュームを探す
    for vol in /Volumes/GLV*; do
        if [ -d "$vol" ]; then
            BOOTLOADER_PATHS+=("$vol")
            BOOTLOADER_FOUND=true
        fi
    done
    
    if [ "$BOOTLOADER_FOUND" = true ]; then
        echo "ブートローダーが検出されました！"
        
        # 自動コピーを実行
        echo "検出されたブートローダーパス: ${#BOOTLOADER_PATHS[@]}"
        for i in "${!BOOTLOADER_PATHS[@]}"; do
            current_path="${BOOTLOADER_PATHS[$i]}"
            echo "ファームウェアを「${current_path}」にコピー中..."
            if cp "glove80.uf2/glove80.uf2" "$current_path/"; then
                echo "✅ コピー成功: ${current_path}"
            else
                echo "❌ コピー失敗: ${current_path}"
            fi
        done
        
        echo "⚠️ 書き込み完了後、キーボードが自動的に再起動します"
        echo "🔄 Bluetoothの場合、再ペアリングが必要な場合があります"
    else
        echo "ブートローダーモードが検出されませんでした。"
        echo ""
        echo "⚠️ キーボードをブートローダーモードにするには："
        echo "1. マジックキー + シングルクォート（右半分）または Esc（左半分）を押す"
        echo "2. ボリュームが「NO NAME」または「GLV80*BOOT」として表示されるのを確認"
        echo "3. その後、このスクリプトを再実行してください"
        echo ""
        echo "または、手動でコピーすることもできます:"
        echo "cp \"$(pwd)/glove80.uf2/glove80.uf2\" /Volumes/ブートローダー名/"
        
        # ファームウェアの保存場所を作成
        if [ ! -d "firmware" ]; then
            mkdir -p firmware
        fi
        
        # ファームウェアをfirmwareディレクトリにコピー
        cp "glove80.uf2/glove80.uf2" "firmware/glove80-$(date +%Y%m%d-%H%M%S).uf2"
        echo ""
        echo "✅ ファームウェアを「firmware」ディレクトリに保存しました"
        echo "📁 保存場所: $(pwd)/firmware/"
    fi
else
    echo "Error: ファームウェアのダウンロードに失敗したか、予期しないファイル構造です"
    exit 1
fi