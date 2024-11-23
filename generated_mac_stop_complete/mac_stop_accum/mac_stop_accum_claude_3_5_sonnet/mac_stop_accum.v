module mac_stop_accum #(
    parameter M = 4,
    parameter K = 4, 
    parameter N = 4,
    parameter DATA_WIDTH_INIT_MATRIX = 32,
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
)(
    input wire clk,
    input wire resetn,
    input wire [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg,
    input wire [$clog2(K)-1:0] matrix_a_col_addr_counter_reg,
    input wire [$clog2(K)-1:0] matrix_b_row_addr_counter_reg,
    input wire [$clog2(M)-1:0] matrix_a_row_addr_counter_reg,
    input wire [$clog2(N)-1:0] matrix_b_col_addr_counter_reg,
    input wire mult_done_reg,
    
    output reg [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c,
    output reg matrix_c_we,
    output reg mac_done,
    output reg [$clog2(M)-1:0] row_addr_c,
    output reg [$clog2(N)-1:0] col_addr_c
);

    reg [DATA_WIDTH_RESULT_MATRIX-1:0] accum_reg;
    
    // Clocked block
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            accum_reg <= 0;
        end
        else if (mult_done_reg) begin
            if (matrix_b_row_addr_counter_reg == K-1) begin
                accum_reg <= 0;
            end
            else begin
                accum_reg <= accum_reg + product_reg;
            end
        end
    end

    // Combinational block
    always @* begin
        // Default assignments
        matrix_c_we = 1'b0;
        mac_done = 1'b0;
        data_out_c = 0;
        row_addr_c = matrix_a_row_addr_counter_reg;
        col_addr_c = matrix_b_col_addr_counter_reg;

        // Check if we need to write to matrix_c
        if (matrix_b_row_addr_counter_reg == K-1) begin
            matrix_c_we = 1'b1;
            data_out_c = accum_reg + product_reg;
        end

        // Check if matrix multiplication is complete
        if ((matrix_a_col_addr_counter_reg == K-1) &&
            (matrix_a_row_addr_counter_reg == M-1) &&
            (matrix_b_col_addr_counter_reg == N-1) &&
            (matrix_b_row_addr_counter_reg == K-1)) begin
            mac_done = 1'b1;
        end
    end

endmodule