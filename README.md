# AES-Hardware-Implementation-Efficiency-Improvement
By modifying the computation method, the speed of AES key generation is improved.
# AES 硬體實現效率提升 (Optimized AES Hardware Implementation)

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-FPGA-blue)
![Language](https://img.shields.io/badge/language-Verilog-orange)

## 📖 專案簡介
本專案實作 **AES-128 加密演算法** 的硬體架構，並透過 **改變計算方式** ，有效提升加密效率與硬體資源利用率。  
專案目標平台為 **Altera DE0 (Cyclone III FPGA)**，開發工具為 **Quartus II**。

- 透過改變計算方式，提高 AES 密碼生成速度  
- 改良 平方計算電路、反元計算電路、MixColumns 模組  
- 實現高效能、高頻率的硬體加速  

## ⚡ 功能特色
- **AES-128 硬體實現**（支援加密流程）  
- **效能優化**：減少 LUT/FF 使用，提升 Fmax  
- **驗證完整**：對照 FIPS 197 附錄範例向量（AES-128/192/256）

## 🖥️ 硬體與開發環境
- **FPGA 平台**：Altera DE0 (Cyclone III)  
- **開發工具**：Quartus II / ModelSim-Altera  
- **語言**：Verilog HDL  
- **驗證**：我用 Python 介面餵資料、讀結果、比對是否正確

- ## 🚀 使用方式
1. 開啟 Quartus II，匯入專案檔  
2. 編譯並下載至 DE0 FPGA  
3. 使用Python 介面餵資料進行驗證  

## 📑 專案報告
完整說明請見 [AES 硬體實現效率提升報告 (PDF)](aes_report.pdf)

## 📌 未來改進
- 加入 AES-192/256 支援  
- 新增解密模組  
- 更佳的 pipeline 架構  

## 📜 授權
本專案採用 MIT License
