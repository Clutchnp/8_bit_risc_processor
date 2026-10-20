
module testbench;

  reg clock;
  reg reset;

  integer tests;
  integer failures;
  integer i;
  integer cycles;

  cpu test_processor (
      .clk  (clock),
      .reset(reset)
  );

  initial begin
    clock = 1'b0;
    forever #5 clock = ~clock;
  end

  initial begin
    $dumpfile("output_wave.vcd");
    $dumpvars(0, testbench);
  end

  task check_register;
    input [2:0] reg_num;
    input [7:0] expected;
    reg [7:0] actual;
    begin
      actual = test_processor.rf.memory[reg_num];
      tests  = tests + 1;

      if (actual !== expected) begin
        $display("FAIL: R%0d expected %0d, got %0d", reg_num, expected, actual);
        failures = failures + 1;
      end else begin
        $display("PASS: R%0d = %0d", reg_num, actual);
      end
    end
  endtask

  task check_memory;
    input [7:0] address;
    input [7:0] expected;
    reg [7:0] actual;
    begin
      actual = test_processor.dmem.memory[address];
      tests  = tests + 1;

      if (actual !== expected) begin
        $display("FAIL: MEM[%0d] expected %0d, got %0d", address, expected, actual);
        failures = failures + 1;
      end else begin
        $display("PASS: MEM[%0d] = %0d", address, actual);
      end
    end
  endtask

  task check_pc;
    input [7:0] expected;
    reg [7:0] actual;
    begin
      actual = test_processor.pc;
      tests  = tests + 1;

      if (actual !== expected) begin
        $display("FAIL: PC expected %0d, got %0d", expected, actual);
        failures = failures + 1;
      end else begin
        $display("PASS: PC = %0d", actual);
      end
    end
  endtask

  initial begin
    tests = 0;
    failures = 0;
    cycles = 0;
    reset = 1'b1;

    #1;

    for (i = 0; i < 256; i = i + 1) test_processor.dmem.memory[i] = 8'd0;
    //injecting instructions into the memory
    test_processor.imem.memory[0]  = {4'hA, 3'd1, 3'd0, 6'd42};
    test_processor.imem.memory[1]  = {4'h1, 3'd2, 3'd0, 6'd10};
    test_processor.imem.memory[2]  = {4'h0, 3'd3, 3'd1, 3'd2, 3'b000};
    test_processor.imem.memory[3]  = {4'h3, 3'd3, 3'd0, 6'd10};
    test_processor.imem.memory[4]  = {4'h0, 3'd4, 3'd1, 3'd2, 3'b001};
    test_processor.imem.memory[5]  = {4'h3, 3'd4, 3'd0, 6'd11};
    test_processor.imem.memory[6]  = {4'h0, 3'd5, 3'd1, 3'd2, 3'b010};
    test_processor.imem.memory[7]  = {4'h3, 3'd5, 3'd0, 6'd12};
    test_processor.imem.memory[8]  = {4'h0, 3'd6, 3'd1, 3'd2, 3'b011};
    test_processor.imem.memory[9]  = {4'h3, 3'd6, 3'd0, 6'd13};
    test_processor.imem.memory[10] = {4'h0, 3'd7, 3'd1, 3'd2, 3'b100};
    test_processor.imem.memory[11] = {4'h3, 3'd7, 3'd0, 6'd14};
    test_processor.imem.memory[12] = {4'h7, 3'd3, 3'd2, 6'd2};
    test_processor.imem.memory[13] = {4'h3, 3'd3, 3'd0, 6'd15};
    test_processor.imem.memory[14] = {4'h8, 3'd4, 3'd1, 6'd1};
    test_processor.imem.memory[15] = {4'h3, 3'd4, 3'd0, 6'd16};
    test_processor.imem.memory[16] = {4'h9, 3'd5, 3'd1, 6'd15};
    test_processor.imem.memory[17] = {4'h3, 3'd5, 3'd0, 6'd17};
    test_processor.imem.memory[18] = {4'hA, 3'd6, 3'd2, 6'd32};
    test_processor.imem.memory[19] = {4'h3, 3'd6, 3'd0, 6'd18};
    test_processor.imem.memory[20] = {4'hB, 3'd7, 3'd1, 6'd15};
    test_processor.imem.memory[21] = {4'h3, 3'd7, 3'd0, 6'd19};
    test_processor.imem.memory[22] = {4'h2, 3'd2, 3'd0, 6'd10};
    test_processor.imem.memory[23] = {4'h3, 3'd2, 3'd0, 6'd20};
    test_processor.imem.memory[24] = {4'h1, 3'd0, 3'd0, 6'd7};
    test_processor.imem.memory[25] = {4'h4, 3'd0, 3'd1, 6'd3};
    test_processor.imem.memory[26] = {4'h1, 3'd3, 3'd0, 6'd11};
    test_processor.imem.memory[27] = {4'h3, 3'd3, 3'd0, 6'd21};
    test_processor.imem.memory[28] = {4'h5, 3'd0, 3'd1, 6'd2};
    test_processor.imem.memory[29] = {4'h1, 3'd3, 3'd0, 6'd63};
    test_processor.imem.memory[30] = {4'h1, 3'd3, 3'd0, 6'd62};
    test_processor.imem.memory[31] = {4'h6, 4'b0000, 8'd33};
    test_processor.imem.memory[32] = {4'h1, 3'd3, 3'd0, 6'd49};
    test_processor.imem.memory[33] = {4'hF, 12'b0};

    #9;
    reset = 1'b0;

    while ((test_processor.halt !== 1'b1) && (cycles < 100)) begin
      @(posedge clock);
      #1;
      cycles = cycles + 1;
    end

    if (test_processor.halt !== 1'b1) begin
      $display("FAIL: CPU timed out after %0d cycles", cycles);
      failures = failures + 1;
    end else begin
      $display("CPU halted after %0d cycles", cycles);
    end

    $display("");
    $display("Chcking Registers");

    check_register(3'd0, 8'd0);
    check_register(3'd1, 8'd42);
    check_register(3'd2, 8'd52);
    check_register(3'd3, 8'd11);
    check_register(3'd4, 8'd21);
    check_register(3'd5, 8'd10);
    check_register(3'd6, 8'd42);
    check_register(3'd7, 8'd37);

    $display("");
    $display("Checking Memory:");

    check_memory(8'd10, 8'd52);
    check_memory(8'd11, 8'd32);
    check_memory(8'd12, 8'd10);
    check_memory(8'd13, 8'd42);
    check_memory(8'd14, 8'd32);
    check_memory(8'd15, 8'd40);
    check_memory(8'd16, 8'd21);
    check_memory(8'd17, 8'd10);
    check_memory(8'd18, 8'd42);
    check_memory(8'd19, 8'd37);
    check_memory(8'd20, 8'd52);
    check_memory(8'd21, 8'd11);

    $display("");
    $display("Checking Control flow");

    check_pc(8'd33);

    $display("");
    $display("Summary\n");
    $display("Cycles: %0d", cycles);
    $display("Tests:  %0d", tests);
    $display("Passed: %0d", tests - failures);
    $display("Failed: %0d", failures);

    if (failures == 0) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");

    $finish;
  end

endmodule
