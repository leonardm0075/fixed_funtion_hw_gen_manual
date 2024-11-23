module mac_stop_accum_tb;

    // Parameters
    parameter M = 4;
    parameter K = 4;
    parameter N = 4;
    parameter DATA_WIDTH_INIT_MATRIX = 32;
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    // Testbench signals
    reg clk;
    reg resetn;
    reg [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg;
    reg [$clog2(K)-1:0] matrix_a_col_addr_counter_reg;
    reg [$clog2(K)-1:0] matrix_b_row_addr_counter_reg;
    reg [$clog2(M)-1:0] matrix_a_row_addr_counter_reg;
    reg [$clog2(N)-1:0] matrix_b_col_addr_counter_reg;
    reg mult_done_reg;

    wire [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c;
    wire matrix_c_we;
    wire mac_done;
    wire [$clog2(M)-1:0] row_addr_c;
    wire [$clog2(N)-1:0] col_addr_c;

    // Arrays to store test vectors
    reg [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg_array [(M*N*K)-1:0];
    reg [$clog2(K)-1:0] matrix_a_col_addr_counter_reg_array [(M*N*K)-1:0];
    reg [$clog2(K)-1:0] matrix_b_row_addr_counter_reg_array [(M*N*K)-1:0];
    reg [$clog2(M)-1:0] matrix_a_row_addr_counter_reg_array [(M*N*K)-1:0];
    reg [$clog2(N)-1:0] matrix_b_col_addr_counter_reg_array [(M*N*K)-1:0];

    // File handle
    integer output_file;

    // Module instantiation
    mac_stop_accum #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .product_reg(product_reg),
        .matrix_a_col_addr_counter_reg(matrix_a_col_addr_counter_reg),
        .matrix_b_row_addr_counter_reg(matrix_b_row_addr_counter_reg),
        .matrix_a_row_addr_counter_reg(matrix_a_row_addr_counter_reg),
        .matrix_b_col_addr_counter_reg(matrix_b_col_addr_counter_reg),
        .mult_done_reg(mult_done_reg),
        .data_out_c(data_out_c),
        .matrix_c_we(matrix_c_we),
        .mac_done(mac_done),
        .row_addr_c(row_addr_c),
        .col_addr_c(col_addr_c)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // Open output file
        output_file = $fopen("claude-3-5-sonnet-20241022_tb_results.txt", "w");
        
        // Write test case header
        $fdisplay(output_file, "Test Case 1");

        // Initialize test vectors
        //product_reg_array = '{6, 2, 15, 4, 6, 14, 10, 2, 24, 4, 5, 12, 24, 2, 5, 12, 6, 2, 18, 2, 6, 14, 12, 1, 24, 4, 6, 6, 24, 2, 6, 6, 2, 4, 15, 4, 2, 28, 10, 2, 8, 8, 5, 12, 8, 4, 5, 12, 7, 2, 15, 2, 7, 14, 10, 1, 28, 4, 5, 6, 28, 2, 5, 6};
        //matrix_a_col_addr_counter_reg_array = '{3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0};
        //matrix_b_row_addr_counter_reg_array = '{3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0};
        //matrix_a_row_addr_counter_reg_array = '{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        //matrix_b_col_addr_counter_reg_array = '{3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0};

        //Test Case 2 values
        product_reg_array = '{28, 18, 16, 25, 24, 21, 10, 40, 20, 24, 14, 30, 32, 15, 12, 35, 21, 24, 40, 10, 18, 28, 25, 16, 15, 32, 35, 12, 24, 20, 30, 14, 35, 12, 32, 15, 30, 14, 20, 24, 25, 16, 28, 18, 40, 10, 24, 21, 14, 30, 24, 20, 12, 35, 15, 32, 10, 40, 21, 24, 16, 25, 18, 28};
        matrix_a_col_addr_counter_reg_array = '{3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0};
        matrix_b_row_addr_counter_reg_array = '{3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0};
        matrix_a_row_addr_counter_reg_array = '{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        matrix_b_col_addr_counter_reg_array = '{3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0};


        //Test Case 3 Values
        //product_reg_array = '{32, 21, 45, 32, 28, 27, 40, 36, 36, 24, 35, 32, 32, 21, 45, 28, 24, 35, 36, 40, 21, 45, 32, 45, 27, 40, 28, 40, 24, 35, 36, 35, 40, 28, 36, 40, 35, 36, 32, 45, 45, 32, 28, 40, 40, 28, 36, 35, 32, 35, 45, 32, 28, 45, 40, 36, 36, 40, 35, 32, 32, 35, 45, 28};
        //matrix_a_col_addr_counter_reg_array = '{3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0};
        //matrix_b_row_addr_counter_reg_array = '{3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0};
        //matrix_a_row_addr_counter_reg_array = '{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        //matrix_b_col_addr_counter_reg_array = '{3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0};


        // Initialize signals
        clk = 0;
        resetn = 0;
        mult_done_reg = 0;

        // Reset
        #10 resetn = 1;

        // Test loop
        for (int i = 0; i < M*N*K; i++) begin
            mult_done_reg = 1;
            product_reg = product_reg_array[i];
            matrix_a_col_addr_counter_reg = matrix_a_col_addr_counter_reg_array[i];
            matrix_b_row_addr_counter_reg = matrix_b_row_addr_counter_reg_array[i];
            matrix_a_row_addr_counter_reg = matrix_a_row_addr_counter_reg_array[i];
            matrix_b_col_addr_counter_reg = matrix_b_col_addr_counter_reg_array[i];

            #5; // Half clock cycle
            if (matrix_c_we) begin
                $fdisplay(output_file, "data_out_c = %0d", data_out_c);
            end
            #5; // Complete clock cycle
        end

        // Close file and finish simulation
        $fclose(output_file);
        $finish;
    end

endmodule