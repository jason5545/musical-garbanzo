#!/bin/bash
# 此腳本適用於 Debian/Ubuntu 與 macOS 系統，不支援 Windows。
# 會自動安裝 Tesseract OCR 及語言包，接著建立並啟動名為 ocrmypdf 的虛擬環境，
# 並於其中安裝 ocrmypdf。

set -e

# Debian/Ubuntu 系統安裝 Tesseract 與語言包
install_tesseract_debian() {
  echo "偵測到 Debian/Ubuntu 系統..."
  echo "更新套件清單中..."
  sudo apt-get update
  echo "安裝 Tesseract OCR 及語言包 (繁體中文、日語、韓語)..."
  sudo apt-get install -y tesseract-ocr tesseract-ocr-chi-tra tesseract-ocr-jpn tesseract-ocr-kor
}

# macOS 系統安裝 Tesseract 與語言包（使用 Homebrew）
install_tesseract_macos() {
  echo "偵測到 macOS 系統（使用 Homebrew）..."
  echo "使用 Homebrew 安裝 Tesseract OCR..."
  brew install tesseract
  
  TESSDATA_DIR=$(brew --prefix)/share/tessdata
  echo "Tesseract 語言資料路徑：$TESSDATA_DIR"
  mkdir -p "$TESSDATA_DIR"
  
  for lang in chi_tra jpn kor; do
    echo "下載 ${lang}.traineddata 中..."
    curl -L -o "$TESSDATA_DIR/${lang}.traineddata" "https://github.com/tesseract-ocr/tessdata/raw/main/${lang}.traineddata"
  done
}

# 根據系統判斷 Tesseract 安裝方式
if command -v apt-get >/dev/null 2>&1; then
  install_tesseract_debian
elif command -v brew >/dev/null 2>&1; then
  install_tesseract_macos
else
  echo "無法自動判斷作業系統或不支援之套件管理工具，請手動安裝 Tesseract OCR 與相關語言包。"
  exit 1
fi

# 建立 Python 虛擬環境（venv）並命名為 ocrmypdf
echo "建立虛擬環境 'ocrmypdf' 中..."
python3 -m venv ocrmypdf

# 啟動虛擬環境
echo "啟動虛擬環境 'ocrmypdf'..."
source ocrmypdf/bin/activate

# 更新 pip 並安裝 ocrmypdf
echo "安裝 ocrmypdf..."
pip install --upgrade pip
pip install ocrmypdf

echo "全部安裝完成！"
echo "日後啟動虛擬環境請執行："
echo "source ocrmypdf/bin/activate"
