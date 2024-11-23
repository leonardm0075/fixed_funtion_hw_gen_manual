module unit #(
    parameter M                         = 4,
    parameter K                         = 4,
    parameter N                         = 4,
    parameter DATA_WIDTH_INIT_MATRIX    = 32,
    parameter DATA_WIDTH_RESULT_MATRIX  = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)),
    parameter ADDR_WIDTH_A              = $clog2(M),
    parameter ADDR_WIDTH_B              = $clog2(K),
    parameter ADDR_WIDTH_C              = $clog2(N)
) (
    input  clk,
    input  resetn,
    input  [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a,
    input  [DATA_WIDTH_INIT_MATRIX-1:0] data_in_b,
    input  [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c,
    input  [ADDR_WIDTH_A-1:0] row_addr_a,
    input  [ADDR_WIDTH_B-1:0] col_addr_a,
    input  [ADDR_WIDTH_B-1:0] row_addr_b,
    input  [ADDR_WIDTH_C-1:0] col_addr_b,
    input  [ADDR_WIDTH_A-1:0] row_addr_c,
    input  [ADDR_WIDTH_C-1:0] col_addr_c,
    input  matrix_a_we,
    input  matrix_b_we,
    input  matrix_c_we,
    input  matrix_a_re,
    input  matrix_b_re,
    input  matrix_c_re,
    output [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a,
    output [DATA_WIDTH_INIT_MATRIX-1:0] data_out_b,
    output [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c
);

    reg [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a;
    reg [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b;
    reg [M-1:0][N-1:0][DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            matrix_a <= '{default:'0};
            matrix_b <= '{default:'0};
            matrix_c <= '{default:'0};
        end
        else begin
            if (matrix_a_we)
                matrix_a[row_addr_a][col_addr_a] <= data_in_a;
            if (matrix_b_we)
                matrix_b[row_addr_b][col_addr_b] <= data_in_b;
            if (matrix_c_we)
                matrix_c[row_addr_c][col_addr_c] <= data_in_c;
        end
    end

    assign data_out_a = matrix_a[row_addr_a][col_addr_a];
    assign data_out_b = matrix_b[row_addr_b][col_addr_b];
    assign data_out_c = matrix_c[row_addr_c][col_addr_c];

endmodule