module unit #(
  parameter M = 4,
  parameter K = 4,
  parameter N = 4,
  parameter DATA_WIDTH_INIT_MATRIX = 32,
  parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
)(
  input clk,
  input resetn,
  input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a,
  input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_b,
  input [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c,
  input [$clog2(M)-1:0] row_addr_a,
  input [$clog2(K)-1:0] col_addr_a,
  input [$clog2(N)-1:0] row_addr_b,
  input [$clog2(N)-1:0] col_addr_b,
  input [$clog2(M)-1:0] row_addr_c,
  input [$clog2(K)-1:0] col_addr_c,
  input matrix_a_we,
  input matrix_b_we,
  input matrix_c_we,
  input matrix_a_re,
  input matrix_b_re,
  input matrix_c_re,
  output reg [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a,
  output reg [DATA_WIDTH_INIT_MATRIX-1:0] data_out_b,
  output reg [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c
);

  // Memory declaration
  reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_a [0:M-1][0:K-1];
  reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_b [0:K-1][0:N-1];
  reg [DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c [0:M-1][0:N-1];

  // Synchronous write logic for SRAMs
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      // Initialize memories to 0 on reset
      integer i, j;
      for (i = 0; i < M; i = i + 1) begin
        for (j = 0; j < K; j = j + 1) begin
          matrix_a[i][j] <= 0;
        end
      end
      for (i = 0; i < K; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
          matrix_b[i][j] <= 0;
        end
      end
      for (i = 0; i < M; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
          matrix_c[i][j] <= 0;
        end
      end
    end else begin
      // Write to matrix_a
      if (matrix_a_we) begin
        matrix_a[row_addr_a][col_addr_a] <= data_in_a;
      end
      // Write to matrix_b
      if (matrix_b_we) begin
        matrix_b[row_addr_b][col_addr_b] <= data_in_b;
      end
      // Write to matrix_c
      if (matrix_c_we) begin
        matrix_c[row_addr_c][col_addr_c] <= data_in_c;
      end
    end
  end

  // Combinational read logic for SRAMs
  always @(*) begin
    // Read data from matrix_a
    if (matrix_a_re) begin
      data_out_a = matrix_a[row_addr_a][col_addr_a];
    end else begin
      data_out_a = '0;
    end
    // Read data from matrix_b
    if (matrix_b_re) begin
      data_out_b = matrix_b[row_addr_b][col_addr_b];
    end else begin
      data_out_b = '0;
    end
    // Read data from matrix_c
    if (matrix_c_re) begin
      data_out_c = matrix_c[row_addr_c][col_addr_c];
    end else begin
      data_out_c = '0;
    end
  end
endmodule
