module unit #(
    parameter M = 4,
    parameter K = 4,
    parameter N = 4,
    parameter DATA_WIDTH_INIT_MATRIX = 32,
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)
) ) (
    input clk,
    input resetn,
    input [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg,
    input [$clog2(K)-1:0] matrix_a_col_addr_counter_reg,
    input [$clog2(M)-1:0] matrix_a_row_addr_counter_reg,
    input [$clog2(N)-1:0] matrix_b_col_addr_counter_reg,
    input [$clog2(M)-1:0] matrix_b_row_addr_counter_reg,
    input mult_done_reg,
    output reg [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c,
    output reg matrix_c_we,
    output reg mac_done,
    output reg [$clog2(M)-1:0] row_addr_c,
    output reg [$clog2(N)-1:0] col_addr_c
);

    reg [(DATA_WIDTH_INIT_MATRIX * 2)-1:0] accum_reg;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            accum_reg <= 0;
            data_out_c <= 0;
            matrix_c_we <= 0;
            mac_done <= 0;
        end else begin
            if (mult_done_reg) begin
                accum_reg <= accum_reg + product_reg;
                if (matrix_b_row_addr_counter_reg == (M - 1)) begin
                    accum_reg <= 0; // Reset accum_reg if max reached
                end
            end
        end
    end

    always @(*) begin
        mac_done = (matrix_a_col_addr_counter_reg == (K - 1) &&
                    matrix_a_row_addr_counter_reg == (M - 1) &&
                    matrix_b_col_addr_counter_reg == (N - 1) &&
                    matrix_b_row_addr_counter_reg == (K - 1));
        
        if (matrix_b_row_addr_counter_reg == (K - 1)) begin
            matrix_c_we = 1;
            row_addr_c = matrix_a_row_addr_counter_reg;
            col_addr_c = matrix_b_col_addr_counter_reg;
            data_out_c = accum_reg + product_reg;
        end else begin
            matrix_c_we = 0;
        end
    end

endmodule