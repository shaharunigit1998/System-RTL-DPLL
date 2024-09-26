Welcome to our Project!
In order to operate this project please do the following steps:
1.combine all the files from Samples,Test_Benches, and Verilog_Modules in a Verilog Environment such as euclide
*pay attention to the hierarchical order where Loop.v is the top Module TDC_ENCODER.v,PER.V,DPD.v and DLF.v are beneath it, DCO.v and tdc.sv are not part of this order
2.First run Looptb.vs to see that our Loop module is logically equivalent to the MATLAB DPLL.
3.Secondly run the Behavioral Model in tb.sv, it will print you a file called new_fdco.txt please copy it and paste it in the MATLAB folder.
4.Run The MATLAB simulation at Main.m and see that the Phase Noises Look the Same!
5.If you wish to see the result of the synthesis please look at the Synthesis_Files directory.
