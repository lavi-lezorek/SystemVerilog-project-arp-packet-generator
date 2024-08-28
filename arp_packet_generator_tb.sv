module arp_packet_generator_tb
import arp_packet_generator_package::*, crc_32_byte_package::*;
();
	logic clk = 1'b0;
	logic rst_n = 1'b1;
	
	mac_address src_mac_add = 48'hAA_BB_CC_DD_EE_FF;
	mac_address des_mac_add = 48'h00_11_22_33_44_55;
	
	ip_address src_ip_add = 32'hC0_A8_01_01;
	ip_address des_ip_add = 32'hC0_A8_01_64;
	
	arp_operator operator = 16'd2;
	
	logic req = 1'b0;
	
	logic gmii_tx_en = 1'b0;
	logic [7:0] gmii_txd = 8'd0;
	
	int cnt = 0;
	bit flag = 1'b0;
	
	logic [31:0] check_fcs = 32'd0;
	localparam [31:0] ARP_FCS = 32'h96484937;
	
	arp_packet_generator u0
	(
		.*
	);
	
	always begin
		#8ps clk = ~clk;
	end
	
	always_ff@(posedge clk) begin
		req <= 1'b1;
	end
	
	always_ff@(posedge clk) begin
		if(gmii_tx_en == 1'b1 && gmii_txd == 8'hd5) begin
			flag <= 1'b1;
			cnt <= cnt + 1;
		end else if(gmii_tx_en == 1'b0) begin
			flag <= 1'b0;
			cnt <= 0;
			if(check_fcs == ARP_FCS) begin
				$display("the core is good");
			end else begin
				$display("the core is NOT good");
			end
		end
		
		if(flag == 1'b1) begin
			cnt <= cnt + 1;
		end
		
		if(62 <= cnt <= 65) begin
			case(cnt)
				62: begin
					check_fcs[7:0] <= gmii_txd;
				end
				
				63: begin
					check_fcs[15:8] <= gmii_txd;
				end
				
				64: begin
					check_fcs[23:16] <= gmii_txd;
				end
				
				65: begin
					check_fcs[31:24] <= gmii_txd;
				end
			endcase
		end
	end
endmodule 