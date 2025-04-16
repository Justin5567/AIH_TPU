set cycle  15         ;#clock period defined by designer

create_clock -period $cycle [get_ports  clk]
set_clock_uncertainty  0.1  [get_clocks clk]
set_clock_latency      0.5  [get_clocks clk]

set_input_delay 5 -clock clk [all_inputs]
set_output_delay 0.5    -clock clk [all_outputs] 
set_load         1     [all_outputs]
set_drive        1     [all_inputs]
                      

set_max_capacitance 0.1 [all_outputs]
set_max_transition 0.2 [all_outputs]

set_max_fanout 20 [all_inputs]

                       
