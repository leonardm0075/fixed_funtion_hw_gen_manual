
module mac_stop_mult_tb;

    parameter int M = 4;
    parameter int K = 4;
    parameter int N = 4;
    parameter int DATA_WIDTH_INIT_MATRIX = 32;
    parameter int DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    logic clk;
    logic resetn;
    logic do_mac;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b;
    logic [$clog2(M)-1:0] row_addr_a;
    logic [$clog2(K)-1:0] col_addr_a, row_addr_b;
    logic [$clog2(N)-1:0] col_addr_b;
    logic matrix_a_re, matrix_b_re;
    logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg;
    logic mult_done_reg, mac_done;
    logic [$clog2(M)-1:0] matrix_a_row_addr_counter_reg;
    logic [$clog2(K)-1:0] matrix_a_col_addr_counter_reg, matrix_b_row_addr_counter_reg;
    logic [$clog2(N)-1:0] matrix_b_col_addr_counter_reg;

    integer output_file;

    mac_stop_mult #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .do_mac(do_mac),
        .data_in_a(data_in_a),
        .data_in_b(data_in_b),
        .row_addr_a(row_addr_a),
        .col_addr_a(col_addr_a),
        .row_addr_b(row_addr_b),
        .col_addr_b(col_addr_b),
        .matrix_a_re(matrix_a_re),
        .matrix_b_re(matrix_b_re),
        .product_reg(product_reg),
        .mult_done_reg(mult_done_reg),
        .mac_done(mac_done),
        .matrix_a_row_addr_counter_reg(matrix_a_row_addr_counter_reg),
        .matrix_a_col_addr_counter_reg(matrix_a_col_addr_counter_reg),
        .matrix_b_row_addr_counter_reg(matrix_b_row_addr_counter_reg),
        .matrix_b_col_addr_counter_reg(matrix_b_col_addr_counter_reg)
    );

    // Test Case 1
    logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a = '{
            '{6, 2, 5, 2},
            '{6, 2, 6, 1},
            '{2, 4, 5, 2},
            '{7, 2, 5, 1}
        };
    logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b = '{
            '{1, 1, 4, 4},
            '{1, 7, 2, 1},
            '{3, 2, 1, 1},
            '{2, 1, 6, 6}
        };

    // Test Case 2
    //logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a = '{
        //    '{4, 3, 2, 5},
        //    '{3, 4, 5, 2},
        //    '{5, 2, 4, 3},
        //    '{2, 5, 3, 4}
        //};
    //logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b = '{
        //    '{7, 6, 5, 8},
        //    '{6, 7, 8, 5},
        //    '{8, 5, 7, 6},
        //    '{5, 8, 6, 7}
        //};

    // Test Case 3
    //logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a = '{
        //    '{4, 3, 5, 4},
        //    '{3, 5, 4, 5},
        //    '{5, 4, 4, 5},
        //    '{4, 5, 5, 4}
        //};
    //logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b = '{
        //    '{8, 7, 9, 8},
        //    '{7, 9, 8, 7},
        //    '{9, 8, 7, 9},
        //    '{8, 9, 8, 7}
        //};






    int i, j, k;
    logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] local_product_value;
    integer test_case_passed;

    initial begin
        // Initialize output
        output_file = $fopen("gpt-4o_tb_results.txt", "w");
        test_case_passed = 1;
        // Clock Generation
        forever #5 clk = ~clk;
    end

    initial begin
        // Testbench
        clk = 0;
        resetn = 0;
        do_mac = 0;
        #10;
        resetn = 1;
        while (!mac_done) begin
            do_mac = 1;
            #5;
            if (matrix_a_re) begin
                data_in_a = matrix_a[row_addr_a][col_addr_a];
            end
            if (matrix_b_re) begin
                data_in_b = matrix_b[row_addr_b][col_addr_b];
            end
            #5;
            local_product_value = data_in_a * data_in_b;
            if (local_product_value !== product_reg) begin
                test_case_passed = 0;
            end
            $fwrite(output_file, "local_product_reg_val = %d || module_under_test_product_reg_val = %d\n", local_product_value, product_reg);
        end
        if (test_case_passed) begin
            $fwrite(output_file, "Test Case 1 Passed\n");
        end else begin
            $fwrite(output_file, "Test Case 1 Failed\n");
        end
        if (test_case_passed) begin
            $fwrite(output_file, "All test cases passed\n");
        end else begin
            $fwrite(output_file, "Not all test cases passed\n");
        end
        $fclose(output_file);
        $finish;
    end

endmodule
