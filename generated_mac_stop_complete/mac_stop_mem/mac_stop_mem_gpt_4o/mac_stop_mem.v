module mac_stop_mem #(
    parameter M = 4,
    parameter K = 4,
    parameter N = 4,
    parameter DATA_WIDTH_INIT_MATRIX = 32,
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
) (
    input clk,
    input resetn,
    input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b,
    input [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c,
    input [$clog2(M)-1:0] row_addr_a, row_addr_c,
    input [$clog2(K)-1:0] col_addr_a, row_addr_b,
    input [$clog2(N)-1:0] col_addr_b, col_addr_c,
    input matrix_a_we, matrix_b_we, matrix_c_we,
    input matrix_a_re, matrix_b_re, matrix_c_re,
    output [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b,
    output [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c
);

    // Declare matrices
    reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_a [0:M-1][0:K-1];
    reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_b [0:K-1][0:N-1];
    reg [DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c [0:M-1][0:N-1];

    // Temporary registers for outputs
    reg [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a_reg;
    reg [DATA_WIDTH_INIT_MATRIX-1:0] data_out_b_reg;
    reg [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c_reg;

    // Assign outputs
    assign data_out_a = data_out_a_reg;
    assign data_out_b = data_out_b_reg;
    assign data_out_c = data_out_c_reg;

    // Clocked block for synchronous writes
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Asynchronous reset
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
            // Write operations
            if (matrix_a_we) begin
                matrix_a[row_addr_a][col_addr_a] <= data_in_a;
            end
            if (matrix_b_we) begin
                matrix_b[row_addr_b][col_addr_b] <= data_in_b;
            end
            if (matrix_c_we) begin
                matrix_c[row_addr_c][col_addr_c] <= data_in_c;
            end
        end
    end

    // Combinational block for asynchronous reads
    always @(*) begin
        // Read operations
        if (matrix_a_re) begin
            data_out_a_reg = matrix_a[row_addr_a][col_addr_a];
        end else begin
            data_out_a_reg = {DATA_WIDTH_INIT_MATRIX{1'bz}}; // High Z state
        end
        if (matrix_b_re) begin
            data_out_b_reg = matrix_b[row_addr_b][col_addr_b];
        end else begin
            data_out_b_reg = {DATA_WIDTH_INIT_MATRIX{1'bz}}; // High Z state
        end
        if (matrix_c_re) begin
            data_out_c_reg = matrix_c[row_addr_c][col_addr_c];
        end else begin
            data_out_c_reg = {DATA_WIDTH_RESULT_MATRIX{1'bz}}; // High Z state
        end
    end

endmodule