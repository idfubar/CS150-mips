module mux4 #(parameter WIDTH = 32)
             (input  [WIDTH-1:0] d0, d1, d2, d3,
              input  [1:0] s, 
              output [WIDTH-1:0] y);

  assign y = (s[1] ? (s[0] ? d2 : d3) : (s[0] ? d1 : d0)); 
endmodule
