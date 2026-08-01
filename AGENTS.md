AIエージェント ガイドライン
=========================

ユーザーとのやり取りは日本語で行ってください。

プロジェクト目的
-------------------------

Packer + VirtualBox を使用して Debian 13(trixie) ARM64 の Vagrant box をビルドし、
Ansible プロビジョニングで LEMP スタックの動作確認環境を構築・検証するプロジェクトです。
詳細は [README.md](README.md) を参照してください。

プロジェクト構造
-------------------------

```
├ http/                     # OS インストーラー用 preseed/kickstart 設定
├ provision/                # Packer ビルド用シェルプロビジョニングスクリプト
├ debian-trixie/            # Debian Trixie 固有ファイル
├ files/                    # プロビジョニング配布ファイル
├ .ticket/                  # MD-Ticket チケット管理
├ .github/                  # プロセス・インストラクション・スキル
├ debian-13.pkr.hcl         # Packer テンプレート(Debian 13)
├ Vagrantfile               # Vagrant VM 設定
├ setup_lemp.yml            # LEMP 環境構築 Ansible プレイブック
├ prepare.yml               # メタデータ整合確認 Ansible プレイブック
├ verify.yml                # 動作確認 Ansible プレイブック
├ metadata.yml              # Box バージョン・アーキテクチャ定義
└ requirements.yml          # Ansible ロール定義
```

主要コマンド
-------------------------

```bash
# Vagrant box ビルド
packer build -force debian-13.pkr.hcl

# VM 操作
vagrant up                  # VM 起動(Ansible プロビジョニング自動実行)
vagrant provision           # プロビジョニング再実行
vagrant destroy -f          # VM 削除

# Ansible ロールのインストール(初回 / requirements.yml 更新後)
ansible-galaxy install -r requirements.yml -p .vagrant/provisioners/ansible/roles
```

チケット管理
-------------------------

Markdown ベースの軽量チケット管理(MD-Ticket)を使用しています。
チケットの作成・管理は `.ticket/` 配下で行います。

詳細なルールとテンプレートは [チケット管理ガイド](.ticket/AGENTS.md) を参照してください。

絶対遵守ルール
-------------------------

- 前提の明示: 不明点や複数解釈がある場合は、推測で決め打ちせず前提条件と判断分岐を短く整理する
- 段階的進行: 大きな作業は小さな単位に分け、各段階を確認しながら進める
- 回答簡潔化: 結論を先に述べ、詳細は要求時のみ提示する
- セキュリティ優先: SSH 設定・VM ネットワーク設定等の変更はユーザー確認必須
- Single Source of Truth: 情報の重複を避け、一元管理を維持する
- プロセス準拠: 作業内容に応じて `.github/processes/index.md` を確認し、該当するプロセスに従うこと
- インストラクション準拠: ファイル作成・編集時は `.github/instructions/` 配下から対象ファイルに該当するルールを確認し、準拠すること

推奨ルール
-------------------------

- 単純性優先: 依頼範囲を超える根拠の薄い抽象化・先回りの柔軟性を持ち込まず、近い将来の変更が明確に見えかつ可読性コストが小さい場合のみ備えを許容する
- 変更の局所化: 依頼に直接関係しない改善・リファクタリングは原則避け、ボーイスカウトルールで即座に修正可能な小さな改善のみ許容する
- 高速検索手段の優先: テキスト検索は `rg`・`ag`・`fd` などの高速ツールを優先して使うこと

状況判断の指針
-------------------------

トレードオフが発生した場合は、前提条件・選択肢・メリット/デメリット・残余リスクを短く整理し、ユーザーへ確認します。
案件ごとに判断基準が異なるため、AI が推測で判断を下さないでください。

参照ポリシー
-------------------------

**常時参照セット**(作業横断で常に参照)

- [README.md](README.md): プロジェクト概要、ビルド手順

**条件付き参照セット**(必要時のみ参照)

- [Markdown 作成ルール](.github/instructions/markdown.instructions.md): `**/*.md` を編集するとき
- [日本語文書ルール](.github/instructions/japanese.instructions.md): `**/*.{md,txt}` を編集するとき
- [YAML ルール](.github/instructions/yaml.instructions.md): `**/*.{yml,yaml}` を編集するとき
- [Git 運用プロセス](.github/processes/git.md): コミット・ブランチ操作を行うとき
