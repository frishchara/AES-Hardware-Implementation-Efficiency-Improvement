module uart_tx
#(
    parameter UART_BPS = 9600,        // 串口波特率
    parameter CLK_FREQ = 50000000     // 時鐘頻率
)
(
    input wire sys_clk,          // 系統時鐘50MHz
    input wire sys_rst_n,        // 全局復位
    input wire [7:0] pi_data,    // 模組輸入的8bit數據
    input wire pi_flag,          // 並行數據有效標誌信號
    output reg tx,               // 串轉並後的1bit數據
    output reg tx_busy           // 傳輸忙碌標誌
);

// 參數和內部信號定義
localparam BAUD_CNT_MAX = CLK_FREQ / UART_BPS;
reg [15:0] baud_cnt;  // 增加位寬以支持更大計數值
reg bit_flag;
reg [3:0] bit_cnt;
reg work_en;

// work_en 和 tx_busy 控制
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0) begin
        work_en <= 1'b0;
        tx_busy <= 1'b0;
    end else if (pi_flag == 1'b1) begin
        work_en <= 1'b1;
        tx_busy <= 1'b1;
    end else if ((bit_flag == 1'b1) && (bit_cnt == 4'd9)) begin
        // 當停止位發送完成後，釋放 busy 信號
        work_en <= 1'b0;
        tx_busy <= 1'b0;
    end
end

// 波特率計數器：baud_cnt
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        baud_cnt <= 16'b0;
    else if ((baud_cnt == BAUD_CNT_MAX - 1) || (work_en == 1'b0))
        baud_cnt <= 16'b0;
    else if (work_en == 1'b1)
        baud_cnt <= baud_cnt + 1'b1;
end

// 當 baud_cnt 計數到中間位置時，產生 bit_flag
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        bit_flag <= 1'b0;
    else if (baud_cnt == 16'd1)
        bit_flag <= 1'b1;
    else
        bit_flag <= 1'b0;
end 
// 修改 bit_cnt 和 bit_flag 的邏輯以支持兩個停止位
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        bit_cnt <= 4'b0;
    else if ((bit_cnt == 4'd9) && (bit_flag == 1'b1)) //支持 1 位開始位，8 位數據，1 位停止位
        bit_cnt <= 4'b0;
    else if ((bit_flag == 1'b1) && (work_en == 1'b1))
        bit_cnt <= bit_cnt + 1'b1;
end

// 發送數據邏輯，增加兩個停止位
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        tx <= 1'b1; // 空閒時為高電平
    else if (bit_flag == 1'b1) begin
        case (bit_cnt)
            4'd0: tx <= 1'b0; // 開始位
            4'd1: tx <= pi_data[0]; // 數據位
            4'd2: tx <= pi_data[1];
            4'd3: tx <= pi_data[2];
            4'd4: tx <= pi_data[3];
            4'd5: tx <= pi_data[4];
            4'd6: tx <= pi_data[5];
            4'd7: tx <= pi_data[6];
            4'd8: tx <= pi_data[7];
            4'd9: tx <= 1'b1; // 停止位
            default: tx <= 1'b1;
        endcase
    end
end

endmodule
