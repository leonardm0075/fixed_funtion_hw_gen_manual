// Testbench Code
module mac_stop_mult_tb;
parameter M = 4;
parameter N = 4;
parameter K = 4;
parameter DATA_WIDTH_INIT_MATRIX = 32;
parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

reg clk;
reg resetn;
reg [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b;
reg do_mac;
wire [$clog2(M)-1:0] row_addr_a;
wire [$clog2(K)-1:0] col_addr_a, row_addr_b;
wire [$clog2(N)-1:0] col_addr_b;
wire matrix_a_re, matrix_b_re;
wire [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg;
wire mult_done_reg;
wire mac_done;
wire [$clog2(M)-1:0] matrix_a_row_addr_counter_reg;
wire [$clog2(K)-1:0] matrix_a_col_addr_counter_reg, matrix_b_row_addr_counter_reg;
wire [$clog2(N)-1:0] matrix_b_col_addr_counter_reg;

integer output_file;
integer passed;
reg [(DATA_WIDTH_INIT_MATRIX*2)-1:0] local_product_reg;

mac_stop_mult #(.M(M), .K(K), .N(N), .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX), .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)) dut (
.clk(clk),
.resetn(resetn),
.data_in_a(data_in_a),
.data_in_b(data_in_b),
.do_mac(do_mac),
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

reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_a [M-1:0][K-1:0];
reg [DATA_WIDTH_INIT_MATRIX-1:0] matrix_b [K-1:0][N-1:0];

always #5 clk = ~clk;

initial begin
clk = 0;
resetn = 0;
do_mac = 0;
passed = 1;
output_file = $fopen("gemini-1.5-pro_tb_results.txt");

#10 resetn = 1;

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

#10;

while (!mac_done) begin
do_mac = 1;
#5;
if (matrix_a_re) data_in_a = matrix_a[row_addr_a][col_addr_a];
if (matrix_b_re) data_in_b = matrix_b[row_addr_b][col_addr_b];
#5;
local_product_reg = data_in_a * data_in_b;
if (local_product_reg != product_reg) passed = 0;
$fwrite(output_file, "Test Case 1 %s\n", (passed) ? "Passed" : "Failed");
$fwrite(output_file, "local_product_reg_val = %d || module_under_test_product_reg_val = %d\n", local_product_reg, product_reg);
end

if (passed) begin
$fwrite(output_file, "All test cases passed\n");
end else begin
$fwrite(output_file, "Not all test cases passed\n");
end

$fclose(output_file);
$finish;
end

endmodule