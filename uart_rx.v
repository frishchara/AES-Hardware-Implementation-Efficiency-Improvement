module uart_rx 
#(
    parameter UART_BPS = 9600,        // 串口波特率
    parameter CLK_FREQ = 50000000       // 時鐘頻率
)
(
    input wire sys_clk,          // 系統時鐘50MHz
    input wire sys_rst_n,        // 全局復位
    input wire rx,               // 串口接收數據
    output reg [7:0] po_data,    // 串轉並後的8bit數據
    output reg po_flag          // 串轉並後的數據有效標誌信號
);

// 寄存器和變數定義
reg rx_reg1;
reg rx_reg2;
reg rx_reg3;
reg start_nedge;
reg work_en;
reg [15:0] baud_cnt;   // 調整位寬以支持更大計數值
reg bit_flag;
reg [3:0] bit_cnt;
reg [7:0] rx_data;
reg rx_flag;

localparam BAUD_CNT_MAX = CLK_FREQ / UART_BPS;

// 插入兩級寄存器進行數據同步，用來消除亞穩態
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        rx_reg1 <= 1'b1;
    else
        rx_reg1 <= rx;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        rx_reg2 <= 1'b1;
    else
        rx_reg2 <= rx_reg1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        rx_reg3 <= 1'b1;
    else
        rx_reg3 <= rx_reg2;
end

// start_nedge: 檢測到下降沿時 start_nedge 產生一個時鐘的高電平
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        start_nedge <= 1'b0; 
    else if ((~rx_reg2) && (rx_reg3))
        start_nedge <= 1'b1;
    else
        start_nedge <= 1'b0;
end

// work_en: 接收數據工作使能信號
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        work_en <= 1'b0;
    else if (start_nedge)
        work_en <= 1'b1;
    else if ((bit_cnt == 4'd8) && (bit_flag ))
        work_en <= 1'b0;
end

// baud_cnt: 波特率計數器計數
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        baud_cnt <= 16'b0;
    else if ((baud_cnt == BAUD_CNT_MAX - 1) || !work_en) 
        baud_cnt <= 16'b0;
    else if (work_en ) 
        baud_cnt <= baud_cnt + 1'b1;
end

// bit_flag: 當 baud_cnt 計數器計數到中間數時拉高一個標誌信號
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        bit_flag <= 1'b0;
    else if (baud_cnt == (BAUD_CNT_MAX / 2 - 1))
        bit_flag <= 1'b1;
    else 
        bit_flag <= 1'b0;
end

// bit_cnt: 有效數據個數計數器
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        bit_cnt <= 4'b0;
    else if ((bit_cnt == 4'd8) && (bit_flag == 1'b1))
        bit_cnt <= 4'b0;
    else if (bit_flag == 1'b1)
        bit_cnt <= bit_cnt + 1'b1;
end

// rx_data: 移位接收的數據
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        rx_data <= 8'b0;
    else if ((bit_cnt >= 4'd1) && (bit_cnt <= 4'd8) && (bit_flag == 1'b1))
        rx_data <= {rx_reg3, rx_data[7:1]};
end

// rx_flag: 當輸入數據移位完成時拉高一個時鐘的高電平
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        rx_flag <= 1'b0;
    else if ((bit_cnt == 4'd8) && (bit_flag == 1'b1))
        rx_flag <= 1'b1;
    else 
        rx_flag <= 1'b0;
end

// po_data: 輸出完整的8位有效數據
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        po_data <= 8'b0;
    else if (rx_flag == 1'b1)
        po_data <= rx_data;
end

// po_flag: 輸出數據有效標誌（延後一個時鐘周期）
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        po_flag <= 1'b0;
    else 
        po_flag <= rx_flag;
end


endmodule
