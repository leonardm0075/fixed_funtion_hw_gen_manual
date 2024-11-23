module unit #(parameter M = 4, K = 4, N = 4, DATA_WIDTH_INIT_MATRIX = 32, DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)))(
	input clk,
	input resetn,
	input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b,
	input [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c,
	input [$clog2(M)-1:0] row_addr_a, row_addr_c,
	input [$clog2(K)-1:0] col_addr_a, row_addr_b,
	input [$clog2(N)-1:0] col_addr_b, col_addr_c,
	input matrix_a_we, matrix_b_we, matrix_c_we,
	input matrix_a_re, matrix_b_re, matrix_c_re,
	output reg [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b,
	output reg [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c
); 

	reg [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a;
	reg [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b;
	reg [M-1:0][N-1:0][DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c;

	always @(posedge clk) begin
		if (~resetn) begin
			matrix_a <= 0;
			matrix_b <= 0;
			matrix_c <= 0;
			end else begin
			if (matrix_a_we) matrix_a[row_addr_a][col_addr_a] <= data_in_a;
			if (matrix_b_we) matrix_b[row_addr_b][col_addr_b] <= data_in_b;
			if (matrix_c_we) matrix_c[row_addr_c][col_addr_c] <= data_in_c;
			end
		end

	always @(*) begin
		if (matrix_a_re) data_out_a = matrix_a[row_addr_a][col_addr_a];
		else data_out_a = 0;
		if (matrix_b_re) data_out_b = matrix_b[row_addr_b][col_addr_b];
		else data_out_b = 0;
		if (matrix_c_re) data_out_c = matrix_c[row_addr_c][col_addr_c];
		else data_out_c = 0;
		end

endmodule