module mac_stop_mult #(
    parameter M = 2,
    parameter K = 2,
    parameter N = 2,
    parameter DATA_WIDTH_INIT_MATRIX = 32,
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
) (
    input logic clk,
    input logic resetn,
    input logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a,
    input logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_b,
    input logic do_mac,
    output logic [$clog2(M)-1:0] row_addr_a,
    output logic [$clog2(K)-1:0] col_addr_a,
    output logic [$clog2(K)-1:0] row_addr_b,
    output logic [$clog2(N)-1:0] col_addr_b,
    output logic matrix_a_re,
    output logic matrix_b_re,
    output logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg,
    output logic mult_done_reg,
    output logic mac_done,
    output logic [$clog2(M)-1:0] matrix_a_row_addr_counter_reg,
    output logic [$clog2(K)-1:0] matrix_a_col_addr_counter_reg,
    output logic [$clog2(K)-1:0] matrix_b_row_addr_counter_reg,
    output logic [$clog2(N)-1:0] matrix_b_col_addr_counter_reg
);

    logic [$clog2(M)-1:0] a_row_counter;
    logic [$clog2(K)-1:0] a_col_counter;
    logic [$clog2(K)-1:0] b_row_counter;
    logic [$clog2(N)-1:0] b_col_counter;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            a_row_counter <= '0;
            a_col_counter <= '0;
            b_row_counter <= '0;
            b_col_counter <= '0;
            product_reg <= '0;
            mult_done_reg <= '0;
            matrix_a_row_addr_counter_reg <= '0;
            matrix_a_col_addr_counter_reg <= '0;
            matrix_b_row_addr_counter_reg <= '0;
            matrix_b_col_addr_counter_reg <= '0;
        end else begin
            if (do_mac) begin
                product_reg <= data_in_a * data_in_b;
                mult_done_reg <= 1'b1;
                
                // Increment counters
                a_col_counter <= a_col_counter + 1'b1;
                b_row_counter <= b_row_counter + 1'b1;
                
                // Register counter values
                matrix_a_row_addr_counter_reg <= a_row_counter;
                matrix_a_col_addr_counter_reg <= a_col_counter;
                matrix_b_row_addr_counter_reg <= b_row_counter;
                matrix_b_col_addr_counter_reg <= b_col_counter;
            end else begin
                mult_done_reg <= 1'b0;
            end

            // Reset a_col and b_row counters when they reach max
            if (a_col_counter == K-1) begin
                a_col_counter <= '0;
                b_row_counter <= '0;
                b_col_counter <= b_col_counter + 1'b1;
            end

            // Reset b_col counter and increment a_row counter
            if ((b_col_counter == N-1) && (a_col_counter == K-1)) begin
                b_col_counter <= '0;
                a_row_counter <= a_row_counter + 1'b1;
            end

            // Reset all counters
            if ((a_row_counter == M-1) && (b_col_counter == N-1) && (a_col_counter == K-1)) begin
                a_row_counter <= '0;
                a_col_counter <= '0;
                b_row_counter <= '0;
                b_col_counter <= '0;
            end
        end
    end

    always_comb begin
        // Read enables
        matrix_a_re = do_mac;
        matrix_b_re = do_mac;

        // Address assignments
        row_addr_a = a_row_counter;
        col_addr_a = a_col_counter;
        row_addr_b = b_row_counter;
        col_addr_b = b_col_counter;

        // mac_done signal
        mac_done = (matrix_a_row_addr_counter_reg == M-1) &&
                   (matrix_a_col_addr_counter_reg == K-1) &&
                   (matrix_b_row_addr_counter_reg == K-1) &&
                   (matrix_b_col_addr_counter_reg == N-1);
    end

endmodule