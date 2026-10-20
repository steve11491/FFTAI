-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Sep 13 17:30:48 2024
-- Host        : DESKTOP-09TG138 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/code/test/verilog/ai_engine/ai_engine/vivado/psoc_end/project_psoc/project_psoc.srcs/sources_1/bd/design_1/ip/design_1_s00_pchk_3/design_1_s00_pchk_3_stub.vhdl
-- Design      : design_1_s00_pchk_3
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z045ffg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_s00_pchk_3 is
  Port ( 
    pc_status : out STD_LOGIC_VECTOR ( 159 downto 0 );
    pc_asserted : out STD_LOGIC;
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    pc_axi_awid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    pc_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pc_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pc_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pc_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pc_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pc_axi_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pc_axi_awuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_awvalid : in STD_LOGIC;
    pc_axi_awready : in STD_LOGIC;
    pc_axi_wlast : in STD_LOGIC;
    pc_axi_wdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    pc_axi_wstrb : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pc_axi_wuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_wvalid : in STD_LOGIC;
    pc_axi_wready : in STD_LOGIC;
    pc_axi_bid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_buser : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_bvalid : in STD_LOGIC;
    pc_axi_bready : in STD_LOGIC;
    pc_axi_arid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    pc_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pc_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pc_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pc_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pc_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pc_axi_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pc_axi_aruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_arvalid : in STD_LOGIC;
    pc_axi_arready : in STD_LOGIC;
    pc_axi_rid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_rlast : in STD_LOGIC;
    pc_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    pc_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pc_axi_ruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    pc_axi_rvalid : in STD_LOGIC;
    pc_axi_rready : in STD_LOGIC
  );

end design_1_s00_pchk_3;

architecture stub of design_1_s00_pchk_3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "pc_status[159:0],pc_asserted,aclk,aresetn,pc_axi_awid[1:0],pc_axi_awaddr[31:0],pc_axi_awlen[7:0],pc_axi_awsize[2:0],pc_axi_awburst[1:0],pc_axi_awlock[0:0],pc_axi_awcache[3:0],pc_axi_awprot[2:0],pc_axi_awqos[3:0],pc_axi_awregion[3:0],pc_axi_awuser[0:0],pc_axi_awvalid,pc_axi_awready,pc_axi_wlast,pc_axi_wdata[63:0],pc_axi_wstrb[7:0],pc_axi_wuser[0:0],pc_axi_wvalid,pc_axi_wready,pc_axi_bid[1:0],pc_axi_bresp[1:0],pc_axi_buser[0:0],pc_axi_bvalid,pc_axi_bready,pc_axi_arid[1:0],pc_axi_araddr[31:0],pc_axi_arlen[7:0],pc_axi_arsize[2:0],pc_axi_arburst[1:0],pc_axi_arlock[0:0],pc_axi_arcache[3:0],pc_axi_arprot[2:0],pc_axi_arqos[3:0],pc_axi_arregion[3:0],pc_axi_aruser[0:0],pc_axi_arvalid,pc_axi_arready,pc_axi_rid[1:0],pc_axi_rlast,pc_axi_rdata[63:0],pc_axi_rresp[1:0],pc_axi_ruser[0:0],pc_axi_rvalid,pc_axi_rready";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axi_protocol_checker_v2_0_4_top,Vivado 2018.3";
begin
end;
