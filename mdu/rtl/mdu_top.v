`default_nettype none

/* Multiplication Division Unit */
module mdu_top
#(
  parameter WIDTH = 32
)(
  input  wire             i_clk,  
  input  wire             i_rst,
  input  wire [WIDTH-1:0] i_mdu_rs1,
  input  wire [WIDTH-1:0] i_mdu_rs2,
  input  wire [ 2:0]      i_mdu_op,
  input  wire             i_mdu_valid,
  output wire             o_mdu_ready,
  output wire [WIDTH-1:0] o_mdu_rd
);
  wire [31:0] rdata_a;
  wire [31:0] rdata_b;
  wire        en_q;
  reg         done;
  reg [63:0]  result_64;
  reg         high;
  
  assign rdata_a = i_mdu_rs1;
  assign rdata_b = i_mdu_rs2;

  
  assign  en_q  = i_mdu_valid;

  always @(posedge i_clk) begin
    if (i_rst) begin
      done        <= 1'b0;
      result_64   <= 64'b0;
      high        <= 1'b0;
    end else begin
      done        <= 1'b0;
      result_64   <= 64'b0;
      high        <= 1'b0;
      case (i_mdu_op)
        3'b000: begin
          if (en_q) begin // MUL
            result_64 <= rdata_a * rdata_b;
            done <= 1'b1;
          end
        end
        3'b001: begin  // MULH
          if (en_q) begin
            result_64 <= rdata_a * rdata_b;
            high <= 1'b1;
            done <= 1'b1;
          end
        end
        3'b010: begin  // MULHSU  
          if (en_q) begin
            result_64 <= $signed(rdata_a) * $unsigned(rdata_b);
            high <= 1'b1;
            done <= 1'b1;
          end
        end
        3'b011: begin  // MULHU
          if (en_q) begin
            result_64 <= $unsigned(rdata_a) * $unsigned(rdata_b);
            high <= 1'b1;
            done <= 1'b1;
          end
        end
        3'b100: begin  // DIV
          if (en_q) begin
            result_64 <= {32'b0,$signed(rdata_a) / $signed(rdata_b)};
            done <= 1'b1;
          end
        end
        3'b101: begin  // DIVU
          if (en_q) begin
            result_64 <= $unsigned(rdata_a) * $unsigned(rdata_b);
            done <= 1'b1;
          end
        end
        3'b110: begin  // REM 
          if (en_q) begin
            result_64 <= {32'b0,$signed(rdata_a) % $signed(rdata_b)};
            done <= 1'b1;
          end
        end
        3'b111: begin  // REMU
          if (en_q) begin
            result_64 <= {32'b0,$unsigned(rdata_a) % $unsigned(rdata_b)};
            done <= 1'b1;
          end
        end
        default: begin
          result_64 <= 64'b0;
        end
      endcase
    end
  end

  assign o_mdu_ready = i_mdu_valid & done;
  assign o_mdu_rd = high ? result_64[63:32] : result_64[31:0];

endmodule
`default_nettype wire
