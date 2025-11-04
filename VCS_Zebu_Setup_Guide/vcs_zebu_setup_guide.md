# Synopsys VCS 與 ZeBu 協同仿真設置指南

Synopsys ZeBu (Zero-Time Bug Detection) 是一款高性能的硬體模擬 (Emulation) 系統，用於加速 SoC (System-on-Chip) 的驗證。當在 ZeBu 環境下進行協同仿真 (Co-simulation) 或模擬加速 (Simulation Acceleration) 時，VCS 扮演著關鍵的軟體介面和編譯管理角色。

本指南將專注於在 **ZeBu 情境下**，VCS 需要的**特殊設定**和**關鍵選項**。

---

## 一、 ZeBu 協同仿真的基本概念

在 ZeBu 流程中，VCS 的作用不再是執行完整的軟體仿真，而是作為一個**前端編譯器**和**運行時控制器**，負責：

1.  **RTL 編譯與映射**：將設計 RTL 程式碼編譯並準備好，以便映射到 ZeBu 的 FPGA 硬體上。
2.  **Testbench 運行**：Testbench (TB) 通常仍在 VCS 軟體環境中運行，並通過專門的介面（如 ZEMI-3 或 DPI/PLI）與 ZeBu 硬體上的 DUT (Design Under Test) 進行通訊。
3.  **波形與除錯**：管理波形數據的採集，並與 Verdi 等除錯工具協同工作。

---

## 二、 VCS 針對 ZeBu 的關鍵設定 (The ZeBu-Specific Options)

在 ZeBu 協同仿真中，VCS 的編譯指令會包含特定的選項來啟用與 ZeBu 系統的連接和加速功能。

### 1. 編譯階段 (Compilation)

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-zebu` | **啟用 ZeBu 模式**。這是最關鍵的選項，它指示 VCS 產生適用於 ZeBu 模擬器的程式碼和資料結構。 | `vcs -zebu ...` |
| `-zebu_top <module>` | **指定 ZeBu 模擬的頂層模組**。這個模組將被映射到 ZeBu 硬體上。 | `vcs -zebu -zebu_top soc_top ...` |
| `-zebu_tb_top <module>` | **指定在 VCS 軟體中運行的 Testbench 頂層模組**。 | `vcs -zebu -zebu_tb_top tb_top ...` |
| `-zebu_rtl` | **指定哪些檔案是 RTL 程式碼**。這些檔案將被編譯並映射到 ZeBu 硬體。 | `vcs -zebu_rtl file1.v file2.v ...` |
| `-zebu_tb` | **指定哪些檔案是 Testbench 程式碼**。這些檔案將在 VCS 軟體中運行。 | `vcs -zebu_tb tb_file.sv ...` |
| `-zebu_cfg <file.cfg>` | **指定 ZeBu 的配置檔案**。包含硬體資源分配、時鐘設定等資訊。 | `vcs -zebu_cfg zebu.cfg ...` |
| `-zebu_dump_rtl` | **生成用於 ZeBu 映射的 RTL 檔案**。 | `vcs -zebu_dump_rtl ...` |

### 2. 運行階段 (Runtime)

在運行階段，`simv` 可執行檔會自動連接到 ZeBu 伺服器。

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-zebu_server <host:port>` | **指定 ZeBu 伺服器的位址和埠號**。 | `simv -zebu_server zebu_host:12345` |
| `-zebu_run_mode <mode>` | **指定運行模式**，例如 `fast` (加速) 或 `debug` (除錯)。 | `simv -zebu_run_mode fast` |
| `+zebu_timeout=<sec>` | **設定連接 ZeBu 伺服器的超時時間**。 | `simv +zebu_timeout=300` |

---

## 三、 VCS 與 ZeBu 協同除錯設定

在 ZeBu 模擬中，波形資料的採集方式與純軟體仿真有所不同，通常需要使用 **Verdi** 進行除錯。

### 1. 啟用 KDB 和 ZeBu 波形

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-kdb` | **啟用 Knowledge Database (KDB)**。這是 Verdi 除錯的基礎。 | `vcs -zebu -kdb ...` |
| `-zebu_dump_scope <scope>` | **指定要在 ZeBu 硬體上採集波形的範圍**。通常是頂層模組或關鍵子模組。 | `vcs -zebu_dump_scope soc_top.cpu_subsys ...` |
| `-zebu_dump_file <file.fsdb>` | **指定 ZeBu 產生的波形檔案名稱**。ZeBu 通常產生 FSDB 格式的波形。 | `vcs -zebu_dump_file zebu.fsdb ...` |

### 2. 運行時波形控制

在 Testbench 中，您可能需要使用特定的系統任務來控制 ZeBu 上的波形採集。

| 系統任務 | 說明 |
| :--- | :--- |
| `$zebu_dump_on` | **開始波形採集**。 |
| `$zebu_dump_off` | **停止波形採集**。 |
| `$zebu_dump_all` | **採集所有信號** (需謹慎使用，可能導致檔案過大)。 |

---

## 四、 典型 ZeBu 協同仿真流程

一個典型的 VCS + ZeBu 協同仿真流程通常包含以下步驟：

1.  **RTL 準備**：確保 RTL 程式碼符合 ZeBu 映射要求。
2.  **VCS 編譯 (RTL to ZeBu)**：
    ```bash
    # 假設設計檔案在 rtl.f，Testbench 在 tb.f
    vcs -sverilog -full64 -zebu -zebu_top soc_top -zebu_tb_top tb_top \
        -f rtl.f -f tb.f \
        -zebu_cfg zebu.cfg \
        -zebu_dump_rtl \
        -kdb \
        -l zebu_compile.log
    ```
3.  **ZeBu 映射與硬體配置**：使用 ZeBu 專用工具將編譯後的 RTL 映射到硬體。
4.  **VCS 運行 (Co-simulation)**：
    ```bash
    # 運行 simv，連接到 ZeBu 伺服器
    ./simv -zebu_server <host:port> -zebu_run_mode fast -l zebu_run.log
    ```
5.  **除錯**：使用 Verdi 開啟 KDB 資訊和 FSDB 波形檔案進行除錯。

---

## 五、 環境變數設定 (ZeBu 相關)

除了基本的 VCS 環境變數外，使用 ZeBu 時還需要設定相關的環境變數。

| 變數 | 說明 | 範例 (Bash) |
| :--- | :--- | :--- |
| `ZEBU_HOME` | ZeBu 軟體安裝路徑。 | `export ZEBU_HOME=/path/to/synopsys/zebu` |
| `PATH` | 將 ZeBu 的執行檔路徑加入 PATH。 | `export PATH=$ZEBU_HOME/bin:$PATH` |
| `ZEMI3_HOME` | ZEMI-3 介面庫路徑 (如果使用 ZEMI-3 介面)。 | `export ZEMI3_HOME=$ZEBU_HOME/zemi3` |

**注意**：實際路徑請根據您的 EDA 環境安裝情況進行調整。由於 ZeBu 是一個硬體模擬系統，其設置通常比純軟體仿真更複雜，需要與硬體團隊緊密協作。
