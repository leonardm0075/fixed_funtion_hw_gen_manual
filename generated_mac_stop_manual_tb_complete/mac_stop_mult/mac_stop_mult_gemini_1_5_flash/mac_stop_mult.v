module unit #(
    parameter M = 2,
    parameter K = 2,
    parameter N = 2,
    parameter DATA_WIDTH_INIT_MATRIX = 32,
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K))
)(
    input clk,
    input resetn,
    input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a,
    input [DATA_WIDTH_INIT_MATRIX-1:0] data_in_b,
    input do_mac,
    output reg [($clog2(M))-1:0] row_addr_a,
    output reg [($clog2(K))-1:0] col_addr_a,
    output reg [($clog2(K))-1:0] row_addr_b,
    output reg [($clog2(N))-1:0] col_addr_b,
    output reg matrix_a_re,
    output reg matrix_b_re,
    output reg [DATA_WIDTH_RESULT_MATRIX-1:0] product_reg,
    output reg mult_done_reg,
    output reg mac_done,
    output reg [($clog2(M))-1:0] matrix_a_row_addr_counter_reg,
    output reg [($clog2(K))-1:0] matrix_a_col_addr_counter_reg,
    output reg [($clog2(K))-1:0] matrix_b_row_addr_counter_reg,
    output reg [($clog2(N))-1:0] matrix_b_col_addr_counter_reg
);

    // Internal counters
    reg [($clog2(M))-1:0] a_row_counter;
    reg [($clog2(K))-1:0] a_col_counter;
    reg [($clog2(K))-1:0] b_row_counter;
    reg [($clog2(N))-1:0] b_col_counter;

    // Sequential Logic
    always @(posedge clk) begin
        if (!resetn) begin
            a_row_counter <= 0;
            a_col_counter <= 0;
            b_row_counter <= 0;
            b_col_counter <= 0;

            matrix_a_row_addr_counter_reg <= 0;
            matrix_a_col_addr_counter_reg <= 0;
            matrix_b_row_addr_counter_reg <= 0;
            matrix_b_col_addr_counter_reg <= 0;

            product_reg <= 0;
            mult_done_reg <= 0;
            mac_done <= 0;

            row_addr_a <= 0;
            col_addr_a <= 0;
            row_addr_b <= 0;
            col_addr_b <= 0;
            matrix_a_re <= 0;
            matrix_b_re <= 0;
        end else begin
            if (do_mac) begin
                a_col_counter <= a_col_counter + 1'b1;
                b_row_counter <= b_row_counter + 1'b1;

                matrix_a_col_addr_counter_reg <= a_col_counter;
                matrix_b_row_addr_counter_reg <= b_row_counter;
                mult_done_reg <= 1'b1;

                if (a_col_counter == K - 1) begin
                    a_col_counter <= 0;
                    b_row_counter <= 0;
                    b_col_counter <= b_col_counter + 1'b1;
                end

                if ((a_col_counter == K - 1) && (b_col_counter == N - 1)) begin
                    b_col_counter <= 0;
                    a_row_counter <= a_row_counter + 1'b1;
                    matrix_a_row_addr_counter_reg <= a_row_counter;
                end

                if ((a_row_counter == M - 1) && 
                    (b_col_counter == N - 1) && 
                    (b_row_counter == K - 1)) begin
                    a_row_counter <= 0;
                    a_col_counter <= 0;
                    b_row_counter <= 0;
                    b_col_counter <= 0;
                    mac_done <= 1'b1;
                end
            end else begin
                mult_done_reg <= 1'b0;
                mac_done <= 1'b0;
            end

            matrix_a_row_addr_counter_reg <= a_row_counter;
            matrix_a_col_addr_counter_reg <= a_col_counter;
            matrix_b_row_addr_counter_reg <= b_row_counter;
            matrix_b_col_addr_counter_reg <= b_col_counter;
        end
    end

    // Combinational Logic
    always @(*) begin
        if (do_mac) begin
            row_addr_a = a_row_counter;
            col_addr_a = a_col_counter;
            row_addr_b = b_row_counter;
            col_addr_b = b_col_counter;

            matrix_a_re = 1'b1;
            matrix_b_re = 1'b1;

            product_reg = data_in_a * data_in_b;
        end else begin
            matrix_a_re = 1'b0;
            matrix_b_re = 1'b0;
        end

        if ((matrix_a_col_addr_counter_reg == K - 1) &&
            (matrix_a_row_addr_counter_reg == M - 1) &&
            (matrix_b_col_addr_counter_reg == N - 1) &&
            (matrix_b_row_addr_counter_reg == K - 1)) begin
            mac_done = 1'b1;
        end else begin
            mac_done = 1'b0;
        end
    end
endmodule
