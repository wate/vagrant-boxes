QEMU対応
=========================

概要
-------------------------

VirtualBox に加えて、QEMU への対応を行う。

- 現在のビルド基盤は VirtualBox(Packer + VirtualBox)に依存している
- QEMU でも同じ Debian 13(trixie) ARM64 の Vagrant box をビルド・動作確認できるようにする

背景・理由
-------------------------

現在の開発環境は Apple Silicon 上の VirtualBox で VM を動作させているが、
VirtualBox の ARM 対応は実験的な段階にあり、実用上の問題が確認されている。

実測で確認している問題点は以下のとおり。

- VirtualBox 7.2.14(Apple Silicon 版)のチップセットは armv8virtual で、x86 版と比べて最適化が不足している
- ネットワークアダプタは e1000(82540EM)の完全エミュレーションで、apt-get や Ansible、SSH などネットワークを伴う処理が著しく遅い
- グラフィックコントローラは qemuramfb(簡易フレームバッファ)で、ハードウェアアクセラレーションを利用できない
- vagrant provision が数十分かかるなど、開発サイクルに支障が出ている

Apple Silicon を利用する開発者が増える中、このまま VirtualBox のみの構成では作業効率を損なう。QEMU など VirtualBox 以外の仮想化基盤への対応が必要である。

前提条件・制約事項
-------------------------

### 前提条件

- 実行環境は Apple Silicon の macOS(既存環境と同じ)で完結させる
- 追加ツール: QEMU 11.0.3 / vagrant-qemu 0.3.12 / xorriso 1.5.8 は導入済み(2026-08-01 確認)

### 制約事項

- 既存の VirtualBox ビルドは**維持**し、QEMU ビルドは追加対応とする(並存)
- `provision/40-install-virtualbox-guest-additions.sh` など VirtualBox 専用スクリプトは、QEMU ビルドではスキップする
- QEMU 用 box 名は既存の VirtualBox 用(`debian-13`)と衝突させない
- `metadata.yml` はビルド結果の環境情報(バージョン・アーキテクチャ)を記録するもので、QEMU / VirtualBox で共通でよい
- `Vagrantfile` はプロバイダ(virtualbox / qemu)で分岐させる
- Ansible プレイブック(`prepare.yml` / `setup_lemp.yml` / `verify.yml`)は共通利用する

詳細
-------------------------

### 変更対象ファイルと変更内容

#### 1. `debian-13-virtualbox.pkr.hcl`(既存 `debian-13.pkr.hcl` をリネーム)

既存 `debian-13.pkr.hcl` は VirtualBox 専用テンプレートとして `debian-13-virtualbox.pkr.hcl` へリネームする(実装時に実施)。内容は変更しない。

#### 1.1. `debian-13-qemu.pkr.hcl`(新規作成・Packer テンプレート)

QEMU ビルド専用のテンプレートを新規作成する。**カスタム ISO 方式**(2026-08-01 に方針変更)。

- `required_plugins` に QEMU プラグインを追加する
- QEMU 用の source を定義する(カスタム ISO + preseed から自前ビルド)
    - `qemu-system-aarch64` を使用し、EFI ファームウェア(AAVMF)を指定する
    - boot_command(VNC キー入力)は不使用。カスタム ISO の grub.cfg に preseed/url を直書きする
- provisioner の scripts は共通スクリプトのみ適用する
    - `20-remove-vbox-isos.sh` と `40-install-virtualbox-guest-additions.sh` は除外(10 / 30 / 50 のみ)
- post-processor の box 登録名を QEMU 用に変更する(既存 `debian-13` と衝突しない名前)
- `metadata.yml` 生成は共通(既存の生成処理と同様の処理を追加する)
- 変数定義(version 系・arch など)は既存ファイルから複製する

#### 1.1.1. `build-custom-iso.sh`(新規作成・追加タスク)

カスタム ISO 生成スクリプト。以下の処理を再現可能に固定する。

- 公式 ISO を展開し、`boot/grub/grub.cfg` の `Install` エントリに preseed/url を直書き(`http://10.0.2.2:8000/preseed.cfg` + `auto=true priority=critical` + `console=ttyS0,115200`)
- `set default=0` + `set timeout=5` を追加(GRUB 自動起動)
- xorriso で再パッケージ(UEFI エントリのみ。`-b` を付けない)
- 生成後に El Torito レポートで UEFI のみを検証

#### 1.5. `http/debian-13/preseed.cfg`(新規作成)

**公式 trixie サンプル**(https://www.debian.org/releases/trixie/example-preseed.txt)をベースに作成する(2026-08-01 に再作成)。

- インストーラーは英語(en_US.UTF-8 / keymap us)+ `priority=critical` で自動化する
    - preseed/url では言語を preseed できない(Debian 仕様)ため
- 最終イメージの日本語化(ロケール ja_JP.UTF-8 生成・設定)は provision が担う
- late_command で vagrant ユーザーの sudo 設定を適用する

#### 2. `Vagrantfile`

- `config.vm.box` をプロバイダで分岐させる
- provider ブロックを virtualbox / qemu で分岐させる
- ネットワーク設定をプロバイダで分岐させる(`192.168.56.101` は VirtualBox host-only 前提)
- trigger(`up_before_local.sh`)を VirtualBox 時のみ実行するよう分岐させる
- Ansible provision(3本)は共通のまま利用する

#### 3. `build-and-up.sh`

- ビルド対象の Packer テンプレートを選択できるようにする
- 既存テンプレートのリネームに伴い、参照パスを更新する(`debian-13.pkr.hcl` → `debian-13-virtualbox.pkr.hcl`)

#### 4. `README.md`

- Requirements に QEMU を追加する
- QEMU ビルド手順を追記する
- 既存テンプレートのリネームに伴い、ビルドコマンドの参照を更新する

#### 4.5. `AGENTS.md`

- プロジェクト構造と主要コマンドの参照を更新する(`debian-13.pkr.hcl` → `debian-13-virtualbox.pkr.hcl`、`debian-13-qemu.pkr.hcl` を追加)

#### 5. provision スクリプト(スクリプト自体は変更不要)

- `provision/20-remove-vbox-isos.sh`: VirtualBox 固有(スキップ対象)
- `provision/40-install-virtualbox-guest-additions.sh`: VirtualBox 固有(スキップ対象)
- 適用分岐は Packer の provisioner で対応する

#### 6. 変更不要(確認済み)

- `metadata.yml`: 共通(ビルド環境情報のみでプロバイダ非依存)
- `prepare.yml` / `setup_lemp.yml` / `verify.yml`: プロバイダ非依存のため共通利用
- `ansible.cfg` / `requirements.yml`: プロバイダ非依存
- `provision/10-base-setup-and-upgrade.sh` / `30-package-prune.sh` / `50-zero-free-space.sh`: 共通

### 決定事項

- Packer テンプレートは2ファイル構成にする
    - `debian-13-virtualbox.pkr.hcl`: 既存 `debian-13.pkr.hcl` をリネーム(内容は変更しない)
    - `debian-13-qemu.pkr.hcl`: 新規作成
- QEMU source は bento 等の既存 box を使わず、カスタム ISO + preseed から自前ビルドする
    - 既存 box は VirtualBox でキーボード入力を受け付けない問題の原因と切り分けできないため使わない
    - Packer の boot_command(VNC キー入力)は edk2-aarch64 + QEMU で動作しない既知問題があるため、カスタム ISO 方式で回避する
    - カスタム ISO は `build-custom-iso.sh` で生成する(xorriso 使用・UEFI エントリのみ)
    - preseed は公式 trixie サンプルをベースに作成する
    - インストーラーは英語 + `priority=critical` で自動化し、日本語化は provision が担う

期待する成果物
-------------------------

- QEMU で Debian 13(trixie) ARM64 の Vagrant box をビルドできる
- ビルドした box で `vagrant up` / `vagrant provision` による動作確認ができる

参考情報
-------------------------

### 関連ドキュメント

- [README.md](../../README.md): プロジェクト概要、ビルド手順

### その他の参考情報

- Packer は QEMU builder をサポートしている
- Vagrant は QEMU(libvirt 経由含む)プロバイダをサポートしている
- **既知問題**: [Packer cannot send boot commands to QEMU (hashicorp/packer-plugin-qemu#28)](https://github.com/hashicorp/packer-plugin-qemu/issues/28) — edk2-aarch64 ファームウェア + QEMU で VNC キー入力が GRUB に届かない問題。カスタム ISO 方式の採用理由
- **参考**: [Debian 公式 preseed サンプル (trixie)](https://www.debian.org/releases/trixie/example-preseed.txt) — preseed.cfg のベース
- **参考**: [Debian Installation Guide - Automating the installation using preseeding](https://www.debian.org/releases/trixie/arm64/apb.en.html) — preseed の仕様(言語は preseed/url では設定不可など)

関連ファイル
-------------------------

### 作業プラン

実際の作業は作業プランを作成した上で開始する。

- [作業プラン - QEMU対応](../../workplan-qemu-support.md)
    - 作成日: 2026-08-01
    - 最終更新: 2026-08-01
    - 状況: 進行中(タスク1〜4・6〜7 完了、タスク5・8・9 未着手)
    - 進捗: 約60%

### 作業プラン作成時に検討・明確化すべき事項

詳細は作業プラン側で詰める。チケットには箇条書きで要点のみ記載する。

- 検証手順と成功基準
    - ビルド成功基準(`packer build` 完了、box 登録まで)
    - 動作確認基準(`vagrant up` で SSH 接続、`prepare.yml` / `setup_lemp.yml` / `verify.yml` が全て pass)
- スコープ外の明示
    - x86_64 対応は対象外
    - libvirt プロバイダ対応は対象外(vagrant-qemu のみ)
    - VirtualBox ビルドの機能変更は対象外(リネームのみ)
- ~~リスク・既知の課題(解消済み)~~
    - ~~preseed でのキーボード問題回避~~ → カスタム ISO 方式で解決済み
    - ~~`qemu-system-aarch64` + AAVMF のブート構成の初期調整~~ → QEMU 同梱の edk2 で解決済み
    - ~~vagrant-qemu プラグインのネットワーク設定制約~~ → ポートフォワードのみ方針で解決済み
- 優先度・期日(任意)

### チェックリスト

- [チェックリスト - QEMU対応](../../checklist-qemu-support.md): 作業完了確認用チェックリスト
