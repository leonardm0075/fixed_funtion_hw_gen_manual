module mac_stop_mem_tb;

    // Parameters
    localparam M = 4;
    localparam K = 4;
    localparam N = 4;
    localparam DATA_WIDTH_INIT_MATRIX = 32;
    localparam DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    // Signals
    logic clk;
    logic resetn;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c;
    logic [$clog2(M)-1:0] row_addr_a, row_addr_c;
    logic [$clog2(K)-1:0] col_addr_a, row_addr_b;
    logic [$clog2(N)-1:0] col_addr_b, col_addr_c;
    logic matrix_a_we, matrix_b_we, matrix_c_we;
    logic matrix_a_re, matrix_b_re, matrix_c_re;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c;

    // Local matrices
    logic [DATA_WIDTH_INIT_MATRIX-1:0] matrix_a [M-1:0][K-1:0];
    logic [DATA_WIDTH_INIT_MATRIX-1:0] matrix_b [K-1:0][N-1:0];
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c [M-1:0][N-1:0];

    // File handle for output
    integer output_file;

    // DUT instantiation
    mac_stop_mem #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) dut (
        .*
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    initial begin
        // Open output file
        output_file = $fopen("claude-3-5-sonnet-20241022_tb_results.txt", "w");

        // Initialize signals
        resetn = 0;
        matrix_a_we = 0;
        matrix_b_we = 0;
        matrix_c_we = 0;
        matrix_a_re = 0;
        matrix_b_re = 0;
        matrix_c_re = 0;
        data_in_a = 0;
        data_in_b = 0;
        data_in_c = 0;
        row_addr_a = 0;
        col_addr_a = 0;
        row_addr_b = 0;
        col_addr_b = 0;
        row_addr_c = 0;
        col_addr_c = 0;

        // Initialize test matrices Test Case 1
        //matrix_a = '{
        //    '{6, 2, 5, 2},
        //    '{6, 2, 6, 1},
        //    '{2, 4, 5, 2},
        //    '{7, 2, 5, 1}
        //};
//
        //matrix_b = '{
        //    '{1, 1, 4, 4},
        //    '{1, 7, 2, 1},
        //    '{3, 2, 1, 1},
        //    '{2, 1, 6, 6}
        //};
//
        //matrix_c = '{
        //    '{27, 32, 45, 43},
        //    '{28, 33, 40, 38},
        //    '{25, 42, 33, 29},
        //    '{26, 32, 43, 41}
        //};

        //Test Case 2
        matrix_a = '{
            '{4, 3, 2, 5},
            '{3, 4, 5, 2},
            '{5, 2, 4, 3},
            '{2, 5, 3, 4}
        };

        matrix_b = '{
            '{7, 6, 5, 8},
            '{6, 7, 8, 5},
            '{8, 5, 7, 6},
            '{5, 8, 6, 7}
        };

        matrix_c = '{
            '{87, 95, 88, 94},
            '{95, 87, 94, 88},
            '{94, 88, 87, 95},
            '{88, 94, 95, 87}
        };



        //Test Case 3
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
//
        //matrix_c = '{
        //    '{130, 131, 127, 126},
        //    '{135, 143, 135, 130},
        //    '{144, 148, 145, 139},
        //    '{144, 149, 143, 140}
        //};

        // Wait for reset
        @(posedge clk);
        resetn = 1;

        // Write test case number
        $fdisplay(output_file, "Test Case 1");

        // Write to matrix_a
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                matrix_a_we = 1;
                row_addr_a = i;
                col_addr_a = j;
                data_in_a = matrix_a[i][j];
                @(posedge clk);
            end
        end
        matrix_a_we = 0;

        // Write to matrix_b
        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_b_we = 1;
                row_addr_b = i;
                col_addr_b = j;
                data_in_b = matrix_b[i][j];
                @(posedge clk);
            end
        end
        matrix_b_we = 0;

        // Write to matrix_c
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_c_we = 1;
                row_addr_c = i;
                col_addr_c = j;
                data_in_c = matrix_c[i][j];
                @(posedge clk);
            end
        end
        matrix_c_we = 0;

        // Read and verify matrix_a
        matrix_a_re = 1;
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                row_addr_a = i;
                col_addr_a = j;
                #5;
                $fdisplay(output_file, "matrix_a[%0d][%0d] = %0d", i, j, data_out_a);
                #5;
            end
        end
        matrix_a_re = 0;

        // Read and verify matrix_b
        matrix_b_re = 1;
        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                row_addr_b = i;
                col_addr_b = j;
                #5;
                $fdisplay(output_file, "matrix_b[%0d][%0d] = %0d", i, j, data_out_b);
                #5;
            end
        end
        matrix_b_re = 0;

        // Read and verify matrix_c
        matrix_c_re = 1;
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                row_addr_c = i;
                col_addr_c = j;
                #5;
                $fdisplay(output_file, "matrix_c[%0d][%0d] = %0d", i, j, data_out_c);
                #5;
            end
        end
        matrix_c_re = 0;

        // Close file and finish simulation
        $fclose(output_file);
        #100;
        $finish;
    end

endmodule