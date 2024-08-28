module arp_packet_generator
import arp_packet_generator_package::*, crc_32_byte_package::*;

(
	input wire clk,
	input wire rst_n,
	
	input mac_address src_mac_add,
	input mac_address des_mac_add,
	
	input ip_address src_ip_add,
	input ip_address des_ip_add,
	
	input arp_operator operator,
	
	input wire req,
	
	output logic gmii_tx_en = 1'b0,
	output logic [7:0] gmii_txd = 8'd0
	
);

	arp_packet packet = '{default:0};
	
	enum {STATE_IDLE, STATE_PRE_SFD, STATE_DATA, STATE_FCS} state_mashine;
	
	logic [5:0] cnt = 6'd0;
	
	logic crc_en = 1'b0;
	logic crc_clr = 1'b0;
	logic crc_ready;
	logic [31:0] crc_out;
	
	crc_32_byte u0
	(
		.clk(clk),
		.rst_n(rst_n),
		.data_in(gmii_txd),
		.crc_en(crc_en),
		.clr(crc_clr),
		.crc_out(crc_out),
		.crc_ready(crc_ready)
	);
	
	always_ff@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0) begin
			packet <= '{default:0};
			gmii_tx_en <= 1'b0;
			gmii_txd <= 8'd0;
			cnt <= 6'd0;
			crc_en <= 1'b0;
			crc_clr <= 1'b0;
			state_mashine <= STATE_IDLE;
		end else begin
			case(state_mashine)
				STATE_IDLE: begin
					crc_clr <= 1'b1;
					gmii_tx_en <= 1'b0;
					gmii_txd <= 8'd0;
					if(req == 1'b1) begin
						packet <= {PREAMBLE, SFD, des_mac_add,
									  src_mac_add, ARP_ETHERTYPE,
									  HTYPE, PTYPE, HLEN, PLEN,
									  operator, src_mac_add,
									  src_ip_add, des_mac_add,
									  des_ip_add, PADDING
									 };
						state_mashine <= STATE_PRE_SFD;
					end
				end
				
				STATE_PRE_SFD: begin
					crc_clr <= 1'b0;
					gmii_tx_en <= 1'b1;
					gmii_txd <= packet[543-:8];
					packet <= {packet[535:0], 8'd0};
					if(gmii_txd == 8'hd5) begin
						state_mashine <= STATE_DATA;
						crc_en <= 1'b1;
						cnt <= cnt + 6'd1;
					end
				end
				
				STATE_DATA: begin
					gmii_txd <= packet[543-:8];
					if(cnt == 6'd60) begin
						cnt <= 6'd0;
						crc_en <= 1'b0;
						state_mashine <= STATE_FCS;
					end else begin
						packet <= {packet[535:0], 8'd0};
						cnt <= cnt + 6'd1;
					end
				end
				
				STATE_FCS: begin
					if(cnt == 6'd3) begin
						gmii_txd <= crc_out[31:24];
						cnt <= 6'd0;
						state_mashine <= STATE_IDLE; 
					end else begin
						cnt <= cnt + 6'd1;
						case(cnt)
							6'd2: begin
								gmii_txd <= crc_out[23:16];
							end
							
							6'd1: begin
								gmii_txd <= crc_out[15:8];
							end
							
							6'd0: begin
								gmii_txd <= crc_out[7:0];
							end
						endcase
					end
				end
			endcase
		end
	end
endmodule 