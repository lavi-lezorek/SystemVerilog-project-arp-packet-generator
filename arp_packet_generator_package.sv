package arp_packet_generator_package;
	typedef logic [47:0] mac_address;
	typedef logic [31:0] ip_address;
	typedef logic [15:0] arp_operator;
	
	typedef logic [543:0] arp_packet;
	
	//ethernet constants
	localparam [55:0] PREAMBLE = 56'h55555555555555;
	localparam [7:0] SFD = 8'hd5;
	localparam [15:0] ARP_ETHERTYPE = 16'h0806;
	//arp packet constants
	localparam [15:0] HTYPE = 16'd1;
	localparam [15:0] PTYPE = 16'h0800;
	localparam [7:0] HLEN = 8'd6;
	localparam [7:0] PLEN = 8'd4;
	localparam [143:0] PADDING = 144'd0;
	
endpackage 