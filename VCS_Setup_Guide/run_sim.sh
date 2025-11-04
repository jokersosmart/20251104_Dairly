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
