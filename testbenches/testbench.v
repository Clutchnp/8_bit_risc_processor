module testbench ();

  reg clock;
  reg reset;

  cpu test_processor (
      clock,
      reset
  );

  initial begin
    $dumpfile("output_wave.vcd");
    $dumpvars(0, testbench);
  end

  initial begin
    reset = 1;
    #50 reset = 0;
  end

  initial begin
    clock = 0;
    forever #20 clock = ~clock;
  end

  initial begin
    #200;

    $display("R0 = %d", test_processor.rf.memory[0]);
    $display("R1 = %d", test_processor.rf.memory[1]);
    $display("R2 = %d", test_processor.rf.memory[2]);
    $display("R3 = %d", test_processor.rf.memory[3]);

    $finish;
  end

endmodule
