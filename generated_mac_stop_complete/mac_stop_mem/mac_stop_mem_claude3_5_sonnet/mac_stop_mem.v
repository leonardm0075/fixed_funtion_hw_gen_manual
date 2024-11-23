module mac_stop_mem #(
    parameter M = 4,
    parameter K = 4,
    parameter N = 4,
    parameter DATA_WIDTH_INIT_MATRIX = 32,
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
)(
    input logic clk,
    input logic resetn,
    input logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b,
    input logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c,
    input logic [$clog2(M)-1:0] row_addr_a, row_addr_c,
    input logic [$clog2(K)-1:0] col_addr_a, row_addr_b,
    input logic [$clog2(N)-1:0] col_addr_b, col_addr_c,
    input logic matrix_a_we, matrix_b_we, matrix_c_we,
    input logic matrix_a_re, matrix_b_re, matrix_c_re,
    output logic [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b,
    output logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c
);

    // Memory declarations
    logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a;
    logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b;
    logic [M-1:0][N-1:0][DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c;

    // Synchronous write operations
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            matrix_a <= '{default:0};
            matrix_b <= '{default:0};
            matrix_c <= '{default:0};
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

    // Asynchronous read operations
    always_comb begin
        // Default outputs
        data_out_a = 0;
        data_out_b = 0;
        data_out_c = 0;

        // Read from matrix_a
        if (matrix_a_re) begin
            data_out_a = matrix_a[row_addr_a][col_addr_a];
        end
        // Read from matrix_b
        if (matrix_b_re) begin
            data_out_b = matrix_b[row_addr_b][col_addr_b];
        end
        // Read from matrix_c
        if (matrix_c_re) begin
            data_out_c = matrix_c[row_addr_c][col_addr_c];
        end
    end

endmodule