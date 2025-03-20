#!/bin/bash
# 此腳本適用於 Debian/Ubuntu 與 macOS 系統（不支援 Windows）。
# 功能：
#  1. 自動安裝 Ghostscript、Tesseract OCR 及語言包 (繁體中文、日語、韓語) 與 GNU Parallel
#  2. Debian/Ubuntu 系統會先透過 apt 安裝 python3.12-venv
#  3. 使用 Python 3.12 建立名為 ocrmypdf 的虛擬環境，並在其中安裝 ocrmypdf
#  4. 設定 alias ocr，可直接進入虛擬環境
#  5. 同時建立 output 目錄

set -e

# Debian/Ubuntu 系統安裝 Ghostscript、Tesseract、語言包及 GNU Parallel
install_tesseract_debian() {
  echo "偵測到 Debian/Ubuntu 系統..."
  echo "更新套件清單中..."
  sudo apt-get update
  echo "安裝 Ghostscript、Tesseract OCR、語言包 (繁體中文、日語、韓語) 及 GNU Parallel..."
  sudo apt-get install -y ghostscript tesseract-ocr tesseract-ocr-chi-tra tesseract-ocr-jpn tesseract-ocr-kor parallel
}

# macOS 系統安裝 Ghostscript、Tesseract、語言包及 GNU Parallel（使用 Homebrew）
install_tesseract_macos() {
  echo "偵測到 macOS 系統（使用 Homebrew）..."
  echo "使用 Homebrew 安裝 Ghostscript、Tesseract OCR 與 GNU Parallel..."
  brew install ghostscript tesseract parallel
  
  TESSDATA_DIR=$(brew --prefix)/share/tessdata
  echo "Tesseract 語言資料路徑：$TESSDATA_DIR"
  mkdir -p "$TESSDATA_DIR"
  
  for lang in chi_tra jpn kor; do
    echo "下載 ${lang}.traineddata 中..."
    curl -L -o "$TESSDATA_DIR/${lang}.traineddata" "https://github.com/tesseract-ocr/tessdata/raw/main/${lang}.traineddata"
  done
}

# 根據作業系統判斷 Ghostscript、Tesseract 與 GNU Parallel 的安裝方式
if command -v apt-get >/dev/null 2>&1; then
  install_tesseract_debian
elif command -v brew >/dev/null 2>&1; then
  install_tesseract_macos
else
  echo "無法自動判斷作業系統或不支援之套件管理工具，請手動安裝 Ghostscript、Tesseract OCR、語言包及 GNU Parallel。"
  exit 1
fi

# 若為 Debian/Ubuntu，先透過 apt 安裝 python3.12-venv
if command -v apt-get >/dev/null 2>&1; then
  echo "安裝 python3.12-venv..."
  sudo apt-get install -y python3.12-venv
fi

# 使用 Python 3.12 建立虛擬環境（venv）並命名為 ocrmypdf
echo "建立 Python 3.12 虛擬環境 'ocrmypdf' 中..."
python3.12 -m venv ocrmypdf

# 啟動虛擬環境
echo "啟動虛擬環境 'ocrmypdf'..."
source ocrmypdf/bin/activate

# 更新 pip 並安裝 ocrmypdf
echo "安裝 ocrmypdf..."
pip install --upgrade pip
pip install ocrmypdf

# 設定 alias ocr 自動進入虛擬環境
absolute_path="$(pwd)/ocrmypdf"
alias_line="alias ocr='source ${absolute_path}/bin/activate'"
echo "設定 alias: ${alias_line}"

# 自動加入 alias 至 ~/.bashrc 與 ~/.zshrc（若存在）
if [ -f "$HOME/.bashrc" ]; then
  if ! grep -Fxq "$alias_line" "$HOME/.bashrc"; then
    echo "$alias_line" >> "$HOME/.bashrc"
    echo "已新增 alias 至 ~/.bashrc"
  else
    echo "alias 已存在於 ~/.bashrc"
  fi
fi

if [ -f "$HOME/.zshrc" ]; then
  if ! grep -Fxq "$alias_line" "$HOME/.zshrc"; then
    echo "$alias_line" >> "$HOME/.zshrc"
    echo "已新增 alias 至 ~/.zshrc"
  else
    echo "alias 已存在於 ~/.zshrc"
  fi
fi

# 建立 output 目錄
mkdir -p output
echo "已建立 output 目錄"

echo "全部安裝完成！"
echo "日後若要啟動虛擬環境，可直接執行： ocr （記得重新載入設定檔）"
