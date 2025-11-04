# Synopsys VCS 設置與使用指南

Synopsys VCS (Verilog Compiled Simulator) 是一款業界領先的高性能 Verilog/SystemVerilog 編譯型仿真器。它將 HDL 程式碼編譯成優化的 C 程式碼，然後再編譯成可執行檔 `simv`，從而實現極快的仿真速度。

本指南將介紹 VCS 的基本概念、**必要設定**、**情境設定**以及**使用範例**。

---

## 一、 VCS 基本概念與工作流程

VCS 的工作流程主要分為兩個階段：**編譯階段 (Compilation)** 和 **運行階段 (Runtime)**。

1.  **編譯階段 (Compilation)**：
    *   VCS 將 Verilog/SystemVerilog 原始碼、Testbench 程式碼以及任何 C/C++ DPI 程式碼編譯成一個可執行檔，預設名稱為 `simv`。
    *   在這個階段，您需要指定設計檔案、包含路徑、巨集定義、語言標準、以及是否啟用除錯功能等。

2.  **運行階段 (Runtime)**：
    *   執行編譯階段產生的 `simv` 可執行檔。
    *   在這個階段，您可以指定仿真時間、波形輸出格式、以及傳遞給 Testbench 的參數等。

---

## 二、 VCS 必要設定 (The Must-Haves)

以下是使用 VCS 進行基本仿真時**絕對必要**的設定和選項。

### 1. 核心編譯選項

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-sverilog` | **啟用 SystemVerilog 支援**。對於現代設計，這是必不可少的。 | `vcs -sverilog ...` |
| `-full64` | **啟用 64 位元模式**。建議在 64 位元系統上使用，以處理大型設計和記憶體需求。 | `vcs -full64 ...` |
| `-timescale=1ns/1ps` | **指定時間單位和時間精度**。這是 Verilog/SystemVerilog 仿真中定義時間的基礎。 | `vcs -timescale=1ns/1ps ...` |
| `-f <file.list>` 或 直接列出檔案 | **指定所有設計和 Testbench 檔案**。通常使用檔案列表 (`-f`) 來管理大量檔案。 | `vcs -f filelist.f ...` |

### 2. 運行選項

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-R` | **編譯完成後立即運行**。這是最常用的選項，用於一鍵完成編譯和仿真。 | `vcs -R ...` |
| `+vcs+finish+<time>` | **指定仿真自動結束的時間**。在運行 `simv` 時使用，例如 `simv +vcs+finish+1000`。 | `vcs -R +vcs+finish+1000` |

### 3. 波形輸出設定 (除錯必要)

為了進行除錯和波形觀察，您需要啟用波形資料庫的生成。

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-kdb` | **啟用 Knowledge Database (KDB)**。這是支援 Synopsys Verdi 等除錯工具的必要選項。 | `vcs -sverilog -kdb ...` |
| `+vcs+vcdpluson` | **啟用波形記錄**。在運行階段 (Runtime) 傳遞給 `simv`，用於生成 `.vpd` 或 `.vcd` 檔案。 | `vcs -R +vcs+vcdpluson` |
| `$vcdpluson` / `$dumpvars` | **在 Testbench 中使用系統任務**。更精確地控制波形記錄的範圍和時間點。 | 參見範例 |

---

## 三、 特定情境下的必要設定

在不同的設計和驗證情境下，您需要額外配置特定的 VCS 選項。

### 情境一：使用外部 IP 或 Library

當您的設計依賴於預先編譯好的 IP 或標準單元庫時，需要指定庫的搜尋路徑和編譯模型。

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-y <dir>` | **指定模組/實例的搜尋路徑**。VCS 會在這個目錄下尋找未定義的模組。 | `vcs -y /path/to/lib ...` |
| `+libext+.v+.sv` | **指定搜尋路徑中的檔案副檔名**。 | `vcs -y /path/to/lib +libext+.v` |
| `-v <file>` | **指定預編譯的 Verilog 庫檔案**。通常用於標準單元庫 (Standard Cell Library)。 | `vcs -v std_cell.v ...` |
| `-LDFLAGS -Wl,-rpath=<dir>` | **設定運行時庫路徑**。如果庫是 DPI/C 程式碼，確保運行時能找到共享庫。 | 參見 DPI 範例 |

### 情境二：與 Verdi 協同除錯

Verdi 是業界標準的除錯工具。要讓 VCS 產生的資料能被 Verdi 讀取，必須啟用 KDB。

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-kdb` | **啟用 Knowledge Database**。 | `vcs -sverilog -kdb ...` |
| `-l <log_file>` | **指定編譯日誌檔案**。方便追蹤編譯錯誤。 | `vcs -sverilog -kdb -l compile.log ...` |
| **環境變數** | 設置 `NOVAS_HOME` 和 `NOVAS_LIB_PATH`，確保 VCS 能找到 Verdi 的相關庫。 | 在 `.bashrc` 或腳本中設定 |

### 情境三：使用 UVM 驗證方法學

UVM (Universal Verification Methodology) 驗證環境需要特定的編譯選項來啟用 UVM 庫。

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `+incdir+<dir>` | **指定包含路徑**。UVM 程式碼通常需要包含路徑來找到 UVM 庫檔案。 | `vcs +incdir+/path/to/uvm/src ...` |
| `-ntb_opts uvm` | **啟用內建 UVM 支援**。VCS 內建了 UVM 庫，使用此選項可以編譯 UVM 程式碼。 | `vcs -sverilog -ntb_opts uvm ...` |
| `+UVM_TESTNAME=<test>` | **運行階段指定要執行的 UVM Test**。 | `simv +UVM_TESTNAME=my_test` |

### 情境四：使用 C/C++ DPI (Direct Programming Interface)

當您需要將 C/C++ 程式碼整合到 SystemVerilog 驗證環境中時。

| 選項 | 說明 | 範例 |
| :--- | :--- | :--- |
| `-cc <compiler>` | **指定 C 編譯器**。 | `vcs -cc gcc ...` |
| `-cpp <compiler>` | **指定 C++ 編譯器**。 | `vcs -cpp g++ ...` |
| `-CFLAGS -I<dir>` | **指定 C/C++ 包含路徑**。 | `vcs -CFLAGS -I/path/to/c_headers ...` |
| `-LDFLAGS -L<dir>` | **指定 C/C++ 庫路徑**。 | `vcs -LDFLAGS -L/path/to/c_libs ...` |
| `-l<lib_name>` | **連結 C/C++ 庫**。 | `vcs -lmy_c_lib ...` |

---

## 四、 VCS 使用範例

以下是一個簡單的 Verilog 設計和 Testbench 的 VCS 仿真範例。

### 範例檔案結構

```
.
├── adder.v           # 設計檔案 (Design Under Test, DUT)
├── adder_tb.sv       # 驗證環境 (Testbench)
└── run_sim.sh        # 仿真腳本
```

### 1. `adder.v` (DUT)

```verilog
module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [8:0] sum
);

    assign sum = a + b;

endmodule
```

### 2. `adder_tb.sv` (Testbench)

```systemverilog
`timescale 1ns/1ps

module adder_tb;

    logic [7:0] a, b;
    logic [8:0] sum;

    // 實例化 DUT
    adder u_adder (
        .a   (a),
        .b   (b),
        .sum (sum)
    );

    initial begin
        // 啟用波形記錄
        $dumpfile("adder.vpd");
        $dumpvars(0, adder_tb); // 記錄所有信號

        // 測試案例 1
        a = 8'h0A; b = 8'h05;
        #10; // 等待 10ns

        // 測試案例 2
        a = 8'hFF; b = 8'h01;
        #10;

        // 結束仿真
        $finish;
    end

    // 顯示結果
    always @(sum) begin
        $display("Time=%0t: A=%h, B=%h, Sum=%h", $time, a, b, sum);
    end

endmodule
```

### 3. `run_sim.sh` (仿真腳本)

```bash
#!/bin/bash

# 1. 清理舊檔案
rm -rf csrc simv* *.log *.vpd

# 2. VCS 編譯指令
# -sverilog: 啟用 SystemVerilog
# -full64: 啟用 64 位元模式
# -kdb: 啟用 Verdi 除錯支援
# -timescale: 設定時間單位
# -R: 編譯完成後立即運行
vcs -sverilog -full64 -kdb -timescale=1ns/1ps \
    adder.v \
    adder_tb.sv \
    -R \
    -l compile_and_run.log

# 3. 運行後提示
if [ -f simv ]; then
    echo "仿真完成。波形檔案：adder.vpd"
    echo "日誌檔案：compile_and_run.log"
else
    echo "編譯或運行失敗，請檢查日誌檔案。"
fi
```

### 4. 執行步驟

1.  將上述三個檔案儲存到同一個目錄。
2.  賦予腳本執行權限：`chmod +x run_sim.sh`
3.  執行仿真：`./run_sim.sh`

執行後，您將得到 `simv` 可執行檔、`csrc` 目錄、`compile_and_run.log` 日誌檔案和 `adder.vpd` 波形檔案。您可以使用 Verdi 開啟 `adder.vpd` 進行波形分析。

---

## 五、 環境變數設定 (推薦)

為了方便使用，建議在您的 shell 環境 (例如 `~/.bashrc` 或 `~/.cshrc`) 中設定以下環境變數：

| 變數 | 說明 | 範例 (Bash) |
| :--- | :--- | :--- |
| `VCS_HOME` | VCS 安裝路徑。 | `export VCS_HOME=/path/to/synopsys/vcs` |
| `PATH` | 將 VCS 的執行檔路徑加入 PATH。 | `export PATH=$VCS_HOME/bin:$PATH` |
| `NOVAS_HOME` | Verdi 安裝路徑 (如果使用 Verdi)。 | `export NOVAS_HOME=/path/to/synopsys/verdi` |
| `NOVAS_LIB_PATH` | Verdi 庫路徑 (如果使用 Verdi)。 | `export NOVAS_LIB_PATH=$NOVAS_HOME/share/PLI/VCS/LINUX64` |

**注意**：實際路徑請根據您的 EDA 環境安裝情況進行調整。
