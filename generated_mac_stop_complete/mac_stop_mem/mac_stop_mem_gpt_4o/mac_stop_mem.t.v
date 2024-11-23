`timescale 1ns/1ps

module mac_stop_mem_tb;

  parameter M = 4;
  parameter K = 4;
  parameter N = 4;
  parameter DATA_WIDTH_INIT_MATRIX = 32;
  parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

  reg clk;
  reg resetn;
  reg [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b;
  reg [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c;
  reg [$clog2(M)-1:0] row_addr_a, row_addr_c;
  reg [$clog2(K)-1:0] col_addr_a, row_addr_b;
  reg [$clog2(N)-1:0] col_addr_b, col_addr_c;
  reg matrix_a_we, matrix_b_we, matrix_c_we;
  reg matrix_a_re, matrix_b_re, matrix_c_re;
  wire [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b;
  wire [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c;

  integer output_file;

  mac_stop_mem uut (
    .clk(clk),
    .resetn(resetn),
    .data_in_a(data_in_a),
    .data_in_b(data_in_b),
    .data_in_c(data_in_c),
    .row_addr_a(row_addr_a),
    .row_addr_c(row_addr_c),
    .col_addr_a(col_addr_a),
    .row_addr_b(row_addr_b),
    .col_addr_b(col_addr_b),
    .col_addr_c(col_addr_c),
    .matrix_a_we(matrix_a_we),
    .matrix_b_we(matrix_b_we),
    .matrix_c_we(matrix_c_we),
    .matrix_a_re(matrix_a_re),
    .matrix_b_re(matrix_b_re),
    .matrix_c_re(matrix_c_re),
    .data_out_a(data_out_a),
    .data_out_b(data_out_b),
    .data_out_c(data_out_c)
  );

  reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_a [M-1:0][K-1:0];
  reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_b [K-1:0][N-1:0];
  reg [DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c [M-1:0][N-1:0];

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    // Open the output file
    output_file = $fopen("gpt-4o_tb_results.txt", "w");
    // Initialize inputs
    resetn = 0;
    matrix_a_we = 0;
    matrix_b_we = 0;
    matrix_c_we = 0;
    matrix_a_re = 0;
    matrix_b_re = 0;
    matrix_c_re = 0;

    // Initialize matrices with sample data
    //Test Case 1
    //matrix_a = '{'{6, 2, 5, 2}, '{6, 2, 6, 1}, '{2, 4, 5, 2}, '{7, 2, 5, 1}};
    //matrix_b = '{'{1, 1, 4, 4}, '{1, 7, 2, 1}, '{3, 2, 1, 1}, '{2, 1, 6, 6}};
    //matrix_c = '{'{27, 32, 45, 43}, '{28, 33, 40, 38}, '{25, 42, 33, 29}, '{26, 32, 43, 41}};

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

    // Reset and initialize
    #10;
    resetn = 1;
    #10;
    resetn = 0;
    #10;
    resetn = 1;

    // Write to matrix_a
    for (int i = 0; i < M; i++) begin
      for (int j = 0; j < K; j++) begin
        @(posedge clk);
        matrix_a_we = 1;
        row_addr_a = i;
        col_addr_a = j;
        data_in_a = matrix_a[i][j];
        @(posedge clk);
        matrix_a_we = 0;
      end
    end

    // Write to matrix_b
    for (int i = 0; i < K; i++) begin
      for (int j = 0; j < N; j++) begin
        @(posedge clk);
        matrix_b_we = 1;
        row_addr_b = i;
        col_addr_b = j;
        data_in_b = matrix_b[i][j];
        @(posedge clk);
        matrix_b_we = 0;
      end
    end

    // Write to matrix_c
    for (int i = 0; i < M; i++) begin
      for (int j = 0; j < N; j++) begin
        @(posedge clk);
        matrix_c_we = 1;
        row_addr_c = i;
        col_addr_c = j;
        data_in_c = matrix_c[i][j];
        @(posedge clk);
        matrix_c_we = 0;
      end
    end

    // Test Case 1
    $fwrite(output_file, "Test Case 1\n");

    // Read from matrix_a
    for (int i = 0; i < M; i++) begin
      for (int j = 0; j < K; j++) begin
        @(posedge clk);
        matrix_a_re = 1;
        row_addr_a = i;
        col_addr_a = j;
        @(negedge clk); // Half clock
        $fwrite(output_file, "matrix_a[%0d][%0d] = %0d\n", i, j, data_out_a);
        @(posedge clk); // Full clock
      end
    end
    matrix_a_re = 0;

    // Read from matrix_b
    for (int i = 0; i < K; i++) begin
      for (int j = 0; j < N; j++) begin
        @(posedge clk);
        matrix_b_re = 1;
        row_addr_b = i;
        col_addr_b = j;
        @(negedge clk); // Half clock
        $fwrite(output_file, "matrix_b[%0d][%0d] = %0d\n", i, j, data_out_b);
        @(posedge clk); // Full clock
      end
    end
    matrix_b_re = 0;

    // Read from matrix_c
    for (int i = 0; i < M; i++) begin
      for (int j = 0; j < N; j++) begin
        @(posedge clk);
        matrix_c_re = 1;
        row_addr_c = i;
        col_addr_c = j;
        @(negedge clk); // Half clock
        $fwrite(output_file, "matrix_c[%0d][%0d] = %0d\n", i, j, data_out_c);
        @(posedge clk); // Full clock
      end
    end
    matrix_c_re = 0;

    $fclose(output_file);
    $finish;
  end

endmodule