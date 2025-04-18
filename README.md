# OCR 文檔處理工具

這個專案提供了一個方便的工具，用於將掃描的 PDF 文件轉換為可搜尋的文本格式。使用 OCRmyPDF 與 Tesseract OCR 引擎處理文檔，支援繁體中文、日語和韓語辨識。

## 一鍵安裝腳本

我們提供了一個一鍵安裝腳本，適用於 Debian/Ubuntu 和 macOS 系統（不支援 Windows）。

### 安裝步驟

**注意：** 安裝過程中腳本將會在需要時自動請求 sudo 權限來安裝系統相依套件。

在終端機中執行以下命令：

```bash
curl -sSL https://github.com/jason5545/musical-garbanzo/raw/refs/heads/main/install.sh | bash
```

或

```bash
wget -qO- https://github.com/jason5545/musical-garbanzo/raw/refs/heads/main/install.sh | bash
```

**重要：** 請勿使用 `sudo bash` 來執行整個腳本，否則 `ocr` 別名（alias）會被設定到 root 使用者的設定檔中，而非您的使用者設定檔，導致無法正常使用該別名。腳本已針對需要管理員權限的命令添加 `sudo` 前綴。

### 安裝腳本功能

該腳本會自動：

- 安裝 Ghostscript、Tesseract OCR 及語言包（繁體中文、日語、韓語）與 GNU Parallel
- 在 Debian/Ubuntu 系統，會先透過 apt 安裝 python3.12-venv
- 使用 Python 3.12 建立名為 ocrmypdf 的虛擬環境，並在其中安裝 OCRmyPDF
- 設定 alias `ocr`，讓您可以直接進入虛擬環境
- 同時建立 output 目錄用於存放處理後的文件

### 使用方法

安裝完成後，您可以：

1. 使用 `ocr` 命令進入 OCRmyPDF 虛擬環境
2. 使用 OCRmyPDF 處理您的 PDF 文件，例如：

```bash
ocrmypdf --language chi_tra+jpn+kor input.pdf output/output.pdf
```

3. 使用 GNU Parallel 批次處理多個 PDF 檔案，例如：

```bash
parallel --tag -j 2 ocrmypdf --output-type pdf --optimize 01 -l eng+kor --oversample 600  --redo-ocr '{}' 'output/{}' ::: *.pdf
```

此命令會以 2 個並行處理程序進行 OCR，處理目前目錄下所有的 PDF 檔案，並將結果存放在 output 目錄中。參數說明：
- `--tag`：在輸出中顯示檔案名稱
- `-j 2`：同時處理 2 個檔案
- `--output-type pdf`：輸出 PDF 格式
- `--optimize 01`：使用第 1 級優化
- `-l eng+kor`：使用英文和韓文識別
- `--oversample 600`：提高採樣率至 600 DPI
- `--redo-ocr`：重新處理已有 OCR 的檔案

## 系統需求

- Debian/Ubuntu Linux 或 macOS
- Python 3.12
- 足夠的磁碟空間用於安裝依賴項和處理文件
- 擁有 sudo 權限的使用者帳號

## 支援的語言

- 繁體中文（chi_tra）
- 日語（jpn）
- 韓語（kor）
- 英語（預設）

## 注意事項

- 安裝過程需要管理員權限（sudo），但腳本會自動在需要時請求權限
- 腳本會安裝系統相依套件
- 首次執行後，建議重新載入您的終端配置：
  - Bash: `source ~/.bashrc`
  - Zsh: `source ~/.zshrc` 