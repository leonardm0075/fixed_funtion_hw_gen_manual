// Synthesizable Design Code
module mac_stop_mult #(
parameter M                         = 2,
parameter K                         = 2,
parameter N                         = 2,
parameter DATA_WIDTH_INIT_MATRIX    = 32,
parameter DATA_WIDTH_RESULT_MATRIX  = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
)(
input clk,
input resetn,
input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b,
input do_mac,
output [$clog2(M)-1:0] row_addr_a,
output [$clog2(K)-1:0] col_addr_a, row_addr_b,
output [$clog2(N)-1:0] col_addr_b,
output matrix_a_re, matrix_b_re,
output reg [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg,
output reg mult_done_reg,
output mac_done,
output reg [$clog2(M)-1:0] matrix_a_row_addr_counter_reg,
output reg [$clog2(K)-1:0] matrix_a_col_addr_counter_reg, matrix_b_row_addr_counter_reg,
output reg [$clog2(N)-1:0] matrix_b_col_addr_counter_reg
);

reg [$clog2(M)-1:0] a_row_counter;
reg [$clog2(K)-1:0] a_col_counter;
reg [$clog2(K)-1:0] b_row_counter;
reg [$clog2(N)-1:0] b_col_counter;

always_ff @(posedge clk or negedge resetn) begin
if (!resetn) begin
a_row_counter <= 0;
a_col_counter <= 0;
b_row_counter <= 0;
b_col_counter <= 0;
product_reg <= 0;
mult_done_reg <= 0;
matrix_a_row_addr_counter_reg <= 0;
matrix_a_col_addr_counter_reg <= 0;
matrix_b_row_addr_counter_reg <= 0;
matrix_b_col_addr_counter_reg <= 0;
end else begin
if (do_mac) begin
product_reg <= data_in_a * data_in_b;
mult_done_reg <= 1;

a_col_counter <= a_col_counter + 1;
b_row_counter <= b_row_counter + 1;

if (a_col_counter == K-1) begin
a_col_counter <= 0;
b_row_counter <= 0;
b_col_counter <= b_col_counter + 1;
end

if (b_col_counter == N-1 && a_col_counter == K-1) begin
b_col_counter <= 0;
a_row_counter <= a_row_counter + 1;
end

if (a_row_counter == M-1 && b_col_counter == N-1 && b_row_counter == K-1) begin
a_col_counter <= 0;
a_row_counter <= 0;
b_row_counter <= 0;
b_col_counter <= 0;
end

matrix_a_row_addr_counter_reg <= a_row_counter;
matrix_a_col_addr_counter_reg <= a_col_counter;
matrix_b_row_addr_counter_reg <= b_row_counter;
matrix_b_col_addr_counter_reg <= b_col_counter;
end else begin
mult_done_reg <= 0;
end
end
end

assign row_addr_a = a_row_counter;
assign col_addr_a = a_col_counter;
assign row_addr_b = b_row_counter;
assign col_addr_b = b_col_counter;
assign matrix_a_re = do_mac;
assign matrix_b_re = do_mac;
assign mac_done = (matrix_a_row_addr_counter_reg == M-1 && matrix_a_col_addr_counter_reg == K-1 && matrix_b_row_addr_counter_reg == K-1 && matrix_b_col_addr_counter_reg == N-1);

endmodule