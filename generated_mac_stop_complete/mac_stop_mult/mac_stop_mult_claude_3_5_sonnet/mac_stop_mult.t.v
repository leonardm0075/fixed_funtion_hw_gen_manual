`timescale 1ns/1ps

module mac_stop_mult_tb;

    parameter M = 4;
    parameter K = 4;
    parameter N = 4;
    parameter DATA_WIDTH_INIT_MATRIX = 32;
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    logic clk;
    logic resetn;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_b;
    logic do_mac;
    logic [$clog2(M)-1:0] row_addr_a;
    logic [$clog2(K)-1:0] col_addr_a;
    logic [$clog2(K)-1:0] row_addr_b;
    logic [$clog2(N)-1:0] col_addr_b;
    logic matrix_a_re;
    logic matrix_b_re;
    logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg;
    logic mult_done_reg;
    logic mac_done;
    logic [$clog2(M)-1:0] matrix_a_row_addr_counter_reg;
    logic [$clog2(K)-1:0] matrix_a_col_addr_counter_reg;
    logic [$clog2(K)-1:0] matrix_b_row_addr_counter_reg;
    logic [$clog2(N)-1:0] matrix_b_col_addr_counter_reg;

    // Local SRAMs
    logic [DATA_WIDTH_INIT_MATRIX-1:0] matrix_a [M-1:0][K-1:0];
    logic [DATA_WIDTH_INIT_MATRIX-1:0] matrix_b [K-1:0][N-1:0];

    // Local variables
    logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] local_product_reg;
    integer test_passed;
    integer output_file;

    // Module instantiation
    mac_stop_mult #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) dut (
        .*
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Create output file
        output_file = $fopen("claude-3-5-sonnet-20241022_tb_results.txt", "w");

        // Initialize test case flag
        test_passed = 1;

        // Test Case 1 
        matrix_a = '{
            '{6, 2, 5, 2},
            '{6, 2, 6, 1},
            '{2, 4, 5, 2},
            '{7, 2, 5, 1}
        };

        matrix_b = '{
            '{1, 1, 4, 4},
            '{1, 7, 2, 1},
            '{3, 2, 1, 1},
            '{2, 1, 6, 6}
        };

        // Test Case 2 
        //matrix_a = '{
        //    '{4, 3, 2, 5},
        //    '{3, 4, 5, 2},
        //    '{5, 2, 4, 3},
        //    '{2, 5, 3, 4}
        //};
//
        //matrix_b = '{
        //    '{7, 6, 5, 8},
        //    '{6, 7, 8, 5},
        //    '{8, 5, 7, 6},
        //    '{5, 8, 6, 7}
        //};


        // Test Case 3 
        //matrix_a = '{
        //    '{4, 3, 5, 4},
        //    '{3, 5, 4, 5},
        //    '{5, 4, 4, 5},
        //    '{4, 5, 5, 4}
        //};
//
        //matrix_b = '{
        //    '{8, 7, 9, 8},
        //    '{7, 9, 8, 7},
        //    '{9, 8, 7, 9},
        //    '{8, 9, 8, 7}
        //};

        // Reset
        resetn = 0;
        do_mac = 0;
        #20;
        resetn = 1;

        // Begin test
        $fdisplay(output_file, "Test Case 1 Passed");

        // Main test loop
        while (!mac_done) begin
            do_mac = 1;
            #5;

            // Handle read operations
            if (matrix_a_re) begin
                data_in_a = matrix_a[row_addr_a][col_addr_a];
            end
            if (matrix_b_re) begin
                data_in_b = matrix_b[row_addr_b][col_addr_b];
            end
            #5;

            // Compare results
            if (mult_done_reg) begin
                local_product_reg = data_in_a * data_in_b;
                if (local_product_reg !== product_reg) begin
                    test_passed = 0;
                end
                $fdisplay(output_file, "local_product_reg_val = %0d || module_under_test_product_reg_val = %0d", local_product_reg, product_reg);
            end
        end

        // Write final status
        if (test_passed) begin
            $fdisplay(output_file, "All test cases passed");
        end else begin
            $fdisplay(output_file, "Not all test cases passed");
        end

        // Close file and end simulation
        $fclose(output_file);
        $finish;
    end

endmodule