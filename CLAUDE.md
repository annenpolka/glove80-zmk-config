# Glove80 ZMK設定ガイドライン

## ビルドコマンド
- ローカルビルド: `./build.sh`
- 特定ブランチ/タグからビルド: `./build.sh v25.01`
- GitHub Actionsでのビルド: コミット後自動実行

## デバイス確認方法
- 通常モード確認: `system_profiler SPUSBDataType | grep -A15 "Glove"`
- ブートローダー確認: `ls -la /Volumes/ | grep -i glv` または `df -h | grep disk`

## コード規約
- キーマップはDTSIフォーマットで記述（config/glove80.keymap）
- 設定はKconfigで定義（config/glove80.conf）
- ZMK機能はcompatible = "zmk,behavior-*"形式で定義

## ファームウェアの書き込み
- マジックキー + シングルクォート（右半分）または Esc（左半分）でブートローダーモード
- uf2ファイルをドライブにコピー: `cp glove80.uf2 /Volumes/GLV80*BOOT/`
- Bluetooth機能変更時は再ペアリングが必要

## コーディングスタイル
- インデントはスペース2個
- コメントは日本語を優先
- キーマップのエイリアスは分かりやすい名前を使用
- バインディングは機能グループごとにまとめる