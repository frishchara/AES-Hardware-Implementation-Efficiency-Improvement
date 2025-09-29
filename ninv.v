module ninv (
    input [7:0] I,   
    output [7:0] O    
);

    wire[7:0] I2,I4,I8,IO3,IO4,IO5,IO6,O1,O2,O3,O4;
	
	
   a2_function i(.i(I), .o(I2));
	a2_function i2(.i(I2), .o(I4));
	a2_function i3(.i(I4), .o(I8));
	GFM o1 (.a(I2), .b(I4), .c(O1));
	GFM o2 (.a(O1), .b(I8), .c(O2));
	a2_function i4(.i(O2), .o(IO3));
	a2_function i5(.i(IO3), .o(IO4));
	a2_function i6(.i(IO4), .o(IO5));
	a2_function i7(.i(IO5), .o(IO6));
	GFM o3 (.a(IO3), .b(I2), .c(O4));
	GFM o4 (.a(O4), .b(IO6), .c(O));

	
endmodule
