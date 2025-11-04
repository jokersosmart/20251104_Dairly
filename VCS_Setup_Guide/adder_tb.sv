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

        // 測試案例 1: 10 + 5 = 15
        a = 8'h0A; b = 8'h05;
        #10; // 等待 10ns

        // 測試案例 2: FF + 01 = 100 (溢位)
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
