//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Fri Sep 13 17:30:00 2024
//Host        : DESKTOP-09TG138 running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=42,numReposBlks=26,numNonXlnxBlks=0,numHierBlks=16,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=1,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=1,da_clkrst_cnt=13,da_ps7_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb);
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250" *) inout [14:0]DDR_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR BA" *) inout [2:0]DDR_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CAS_N" *) inout DDR_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_N" *) inout DDR_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_P" *) inout DDR_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CKE" *) inout DDR_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CS_N" *) inout DDR_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DM" *) inout [3:0]DDR_dm;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQ" *) inout [31:0]DDR_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_N" *) inout [3:0]DDR_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_P" *) inout [3:0]DDR_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ODT" *) inout DDR_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RAS_N" *) inout DDR_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RESET_N" *) inout DDR_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR WE_N" *) inout DDR_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false" *) inout FIXED_IO_ddr_vrn;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP" *) inout FIXED_IO_ddr_vrp;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO" *) inout [53:0]FIXED_IO_mio;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK" *) inout FIXED_IO_ps_clk;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB" *) inout FIXED_IO_ps_porb;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB" *) inout FIXED_IO_ps_srstb;

  wire [31:0]ai_fft_0_M00_AXI_ARADDR;
  wire [1:0]ai_fft_0_M00_AXI_ARBURST;
  wire [3:0]ai_fft_0_M00_AXI_ARCACHE;
  wire [1:0]ai_fft_0_M00_AXI_ARID;
  wire [7:0]ai_fft_0_M00_AXI_ARLEN;
  wire ai_fft_0_M00_AXI_ARLOCK;
  wire [2:0]ai_fft_0_M00_AXI_ARPROT;
  wire [3:0]ai_fft_0_M00_AXI_ARQOS;
  wire ai_fft_0_M00_AXI_ARREADY;
  wire [2:0]ai_fft_0_M00_AXI_ARSIZE;
  wire [0:0]ai_fft_0_M00_AXI_ARUSER;
  wire ai_fft_0_M00_AXI_ARVALID;
  wire [31:0]ai_fft_0_M00_AXI_AWADDR;
  wire [1:0]ai_fft_0_M00_AXI_AWBURST;
  wire [3:0]ai_fft_0_M00_AXI_AWCACHE;
  wire [1:0]ai_fft_0_M00_AXI_AWID;
  wire [7:0]ai_fft_0_M00_AXI_AWLEN;
  wire ai_fft_0_M00_AXI_AWLOCK;
  wire [2:0]ai_fft_0_M00_AXI_AWPROT;
  wire [3:0]ai_fft_0_M00_AXI_AWQOS;
  wire ai_fft_0_M00_AXI_AWREADY;
  wire [2:0]ai_fft_0_M00_AXI_AWSIZE;
  wire [0:0]ai_fft_0_M00_AXI_AWUSER;
  wire ai_fft_0_M00_AXI_AWVALID;
  wire [1:0]ai_fft_0_M00_AXI_BID;
  wire ai_fft_0_M00_AXI_BREADY;
  wire [1:0]ai_fft_0_M00_AXI_BRESP;
  wire [0:0]ai_fft_0_M00_AXI_BUSER;
  wire ai_fft_0_M00_AXI_BVALID;
  wire [63:0]ai_fft_0_M00_AXI_RDATA;
  wire [1:0]ai_fft_0_M00_AXI_RID;
  wire ai_fft_0_M00_AXI_RLAST;
  wire ai_fft_0_M00_AXI_RREADY;
  wire [1:0]ai_fft_0_M00_AXI_RRESP;
  wire [0:0]ai_fft_0_M00_AXI_RUSER;
  wire ai_fft_0_M00_AXI_RVALID;
  wire [63:0]ai_fft_0_M00_AXI_WDATA;
  wire ai_fft_0_M00_AXI_WLAST;
  wire ai_fft_0_M00_AXI_WREADY;
  wire [7:0]ai_fft_0_M00_AXI_WSTRB;
  wire [0:0]ai_fft_0_M00_AXI_WUSER;
  wire ai_fft_0_M00_AXI_WVALID;
  wire [31:0]ai_fft_0_M01_AXI_ARADDR;
  wire [1:0]ai_fft_0_M01_AXI_ARBURST;
  wire [3:0]ai_fft_0_M01_AXI_ARCACHE;
  wire [1:0]ai_fft_0_M01_AXI_ARID;
  wire [7:0]ai_fft_0_M01_AXI_ARLEN;
  wire ai_fft_0_M01_AXI_ARLOCK;
  wire [2:0]ai_fft_0_M01_AXI_ARPROT;
  wire [3:0]ai_fft_0_M01_AXI_ARQOS;
  wire ai_fft_0_M01_AXI_ARREADY;
  wire [2:0]ai_fft_0_M01_AXI_ARSIZE;
  wire [0:0]ai_fft_0_M01_AXI_ARUSER;
  wire ai_fft_0_M01_AXI_ARVALID;
  wire [31:0]ai_fft_0_M01_AXI_AWADDR;
  wire [1:0]ai_fft_0_M01_AXI_AWBURST;
  wire [3:0]ai_fft_0_M01_AXI_AWCACHE;
  wire [1:0]ai_fft_0_M01_AXI_AWID;
  wire [7:0]ai_fft_0_M01_AXI_AWLEN;
  wire ai_fft_0_M01_AXI_AWLOCK;
  wire [2:0]ai_fft_0_M01_AXI_AWPROT;
  wire [3:0]ai_fft_0_M01_AXI_AWQOS;
  wire ai_fft_0_M01_AXI_AWREADY;
  wire [2:0]ai_fft_0_M01_AXI_AWSIZE;
  wire [0:0]ai_fft_0_M01_AXI_AWUSER;
  wire ai_fft_0_M01_AXI_AWVALID;
  wire [1:0]ai_fft_0_M01_AXI_BID;
  wire ai_fft_0_M01_AXI_BREADY;
  wire [1:0]ai_fft_0_M01_AXI_BRESP;
  wire [0:0]ai_fft_0_M01_AXI_BUSER;
  wire ai_fft_0_M01_AXI_BVALID;
  wire [63:0]ai_fft_0_M01_AXI_RDATA;
  wire [1:0]ai_fft_0_M01_AXI_RID;
  wire ai_fft_0_M01_AXI_RLAST;
  wire ai_fft_0_M01_AXI_RREADY;
  wire [1:0]ai_fft_0_M01_AXI_RRESP;
  wire [0:0]ai_fft_0_M01_AXI_RUSER;
  wire ai_fft_0_M01_AXI_RVALID;
  wire [63:0]ai_fft_0_M01_AXI_WDATA;
  wire ai_fft_0_M01_AXI_WLAST;
  wire ai_fft_0_M01_AXI_WREADY;
  wire [7:0]ai_fft_0_M01_AXI_WSTRB;
  wire [0:0]ai_fft_0_M01_AXI_WUSER;
  wire ai_fft_0_M01_AXI_WVALID;
  wire [31:0]ai_fft_0_M02_AXI_ARADDR;
  wire [1:0]ai_fft_0_M02_AXI_ARBURST;
  wire [3:0]ai_fft_0_M02_AXI_ARCACHE;
  wire [1:0]ai_fft_0_M02_AXI_ARID;
  wire [7:0]ai_fft_0_M02_AXI_ARLEN;
  wire ai_fft_0_M02_AXI_ARLOCK;
  wire [2:0]ai_fft_0_M02_AXI_ARPROT;
  wire [3:0]ai_fft_0_M02_AXI_ARQOS;
  wire ai_fft_0_M02_AXI_ARREADY;
  wire [2:0]ai_fft_0_M02_AXI_ARSIZE;
  wire [0:0]ai_fft_0_M02_AXI_ARUSER;
  wire ai_fft_0_M02_AXI_ARVALID;
  wire [31:0]ai_fft_0_M02_AXI_AWADDR;
  wire [1:0]ai_fft_0_M02_AXI_AWBURST;
  wire [3:0]ai_fft_0_M02_AXI_AWCACHE;
  wire [1:0]ai_fft_0_M02_AXI_AWID;
  wire [7:0]ai_fft_0_M02_AXI_AWLEN;
  wire ai_fft_0_M02_AXI_AWLOCK;
  wire [2:0]ai_fft_0_M02_AXI_AWPROT;
  wire [3:0]ai_fft_0_M02_AXI_AWQOS;
  wire ai_fft_0_M02_AXI_AWREADY;
  wire [2:0]ai_fft_0_M02_AXI_AWSIZE;
  wire [0:0]ai_fft_0_M02_AXI_AWUSER;
  wire ai_fft_0_M02_AXI_AWVALID;
  wire [1:0]ai_fft_0_M02_AXI_BID;
  wire ai_fft_0_M02_AXI_BREADY;
  wire [1:0]ai_fft_0_M02_AXI_BRESP;
  wire ai_fft_0_M02_AXI_BVALID;
  wire [63:0]ai_fft_0_M02_AXI_RDATA;
  wire [1:0]ai_fft_0_M02_AXI_RID;
  wire ai_fft_0_M02_AXI_RLAST;
  wire ai_fft_0_M02_AXI_RREADY;
  wire [1:0]ai_fft_0_M02_AXI_RRESP;
  wire [0:0]ai_fft_0_M02_AXI_RUSER;
  wire ai_fft_0_M02_AXI_RVALID;
  wire [63:0]ai_fft_0_M02_AXI_WDATA;
  wire ai_fft_0_M02_AXI_WLAST;
  wire ai_fft_0_M02_AXI_WREADY;
  wire [7:0]ai_fft_0_M02_AXI_WSTRB;
  wire [0:0]ai_fft_0_M02_AXI_WUSER;
  wire ai_fft_0_M02_AXI_WVALID;
  wire [31:0]ai_fft_0_M03_AXI_ARADDR;
  wire [1:0]ai_fft_0_M03_AXI_ARBURST;
  wire [3:0]ai_fft_0_M03_AXI_ARCACHE;
  wire [1:0]ai_fft_0_M03_AXI_ARID;
  wire [7:0]ai_fft_0_M03_AXI_ARLEN;
  wire ai_fft_0_M03_AXI_ARLOCK;
  wire [2:0]ai_fft_0_M03_AXI_ARPROT;
  wire [3:0]ai_fft_0_M03_AXI_ARQOS;
  wire ai_fft_0_M03_AXI_ARREADY;
  wire [2:0]ai_fft_0_M03_AXI_ARSIZE;
  wire [0:0]ai_fft_0_M03_AXI_ARUSER;
  wire ai_fft_0_M03_AXI_ARVALID;
  wire [31:0]ai_fft_0_M03_AXI_AWADDR;
  wire [1:0]ai_fft_0_M03_AXI_AWBURST;
  wire [3:0]ai_fft_0_M03_AXI_AWCACHE;
  wire [1:0]ai_fft_0_M03_AXI_AWID;
  wire [7:0]ai_fft_0_M03_AXI_AWLEN;
  wire ai_fft_0_M03_AXI_AWLOCK;
  wire [2:0]ai_fft_0_M03_AXI_AWPROT;
  wire [3:0]ai_fft_0_M03_AXI_AWQOS;
  wire ai_fft_0_M03_AXI_AWREADY;
  wire [2:0]ai_fft_0_M03_AXI_AWSIZE;
  wire [0:0]ai_fft_0_M03_AXI_AWUSER;
  wire ai_fft_0_M03_AXI_AWVALID;
  wire [1:0]ai_fft_0_M03_AXI_BID;
  wire ai_fft_0_M03_AXI_BREADY;
  wire [1:0]ai_fft_0_M03_AXI_BRESP;
  wire ai_fft_0_M03_AXI_BVALID;
  wire [63:0]ai_fft_0_M03_AXI_RDATA;
  wire [1:0]ai_fft_0_M03_AXI_RID;
  wire ai_fft_0_M03_AXI_RLAST;
  wire ai_fft_0_M03_AXI_RREADY;
  wire [1:0]ai_fft_0_M03_AXI_RRESP;
  wire [0:0]ai_fft_0_M03_AXI_RUSER;
  wire ai_fft_0_M03_AXI_RVALID;
  wire [63:0]ai_fft_0_M03_AXI_WDATA;
  wire ai_fft_0_M03_AXI_WLAST;
  wire ai_fft_0_M03_AXI_WREADY;
  wire [7:0]ai_fft_0_M03_AXI_WSTRB;
  wire [0:0]ai_fft_0_M03_AXI_WUSER;
  wire ai_fft_0_M03_AXI_WVALID;
  wire [31:0]axi_interconnect_0_M00_AXI_ARADDR;
  wire [2:0]axi_interconnect_0_M00_AXI_ARPROT;
  wire axi_interconnect_0_M00_AXI_ARREADY;
  wire axi_interconnect_0_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_0_M00_AXI_AWADDR;
  wire [2:0]axi_interconnect_0_M00_AXI_AWPROT;
  wire axi_interconnect_0_M00_AXI_AWREADY;
  wire axi_interconnect_0_M00_AXI_AWVALID;
  wire axi_interconnect_0_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_0_M00_AXI_BRESP;
  wire axi_interconnect_0_M00_AXI_BVALID;
  wire [31:0]axi_interconnect_0_M00_AXI_RDATA;
  wire axi_interconnect_0_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_0_M00_AXI_RRESP;
  wire axi_interconnect_0_M00_AXI_RVALID;
  wire [31:0]axi_interconnect_0_M00_AXI_WDATA;
  wire axi_interconnect_0_M00_AXI_WREADY;
  wire [3:0]axi_interconnect_0_M00_AXI_WSTRB;
  wire axi_interconnect_0_M00_AXI_WVALID;
  wire [31:0]axi_interconnect_0_M01_AXI_ARADDR;
  wire axi_interconnect_0_M01_AXI_ARREADY;
  wire axi_interconnect_0_M01_AXI_ARVALID;
  wire [31:0]axi_interconnect_0_M01_AXI_AWADDR;
  wire axi_interconnect_0_M01_AXI_AWREADY;
  wire axi_interconnect_0_M01_AXI_AWVALID;
  wire axi_interconnect_0_M01_AXI_BREADY;
  wire [1:0]axi_interconnect_0_M01_AXI_BRESP;
  wire axi_interconnect_0_M01_AXI_BVALID;
  wire [31:0]axi_interconnect_0_M01_AXI_RDATA;
  wire axi_interconnect_0_M01_AXI_RREADY;
  wire [1:0]axi_interconnect_0_M01_AXI_RRESP;
  wire axi_interconnect_0_M01_AXI_RVALID;
  wire [31:0]axi_interconnect_0_M01_AXI_WDATA;
  wire axi_interconnect_0_M01_AXI_WREADY;
  wire [3:0]axi_interconnect_0_M01_AXI_WSTRB;
  wire axi_interconnect_0_M01_AXI_WVALID;
  wire [31:0]axi_interconnect_1_M00_AXI_ARADDR;
  wire [1:0]axi_interconnect_1_M00_AXI_ARBURST;
  wire [3:0]axi_interconnect_1_M00_AXI_ARCACHE;
  wire [2:0]axi_interconnect_1_M00_AXI_ARID;
  wire [3:0]axi_interconnect_1_M00_AXI_ARLEN;
  wire [1:0]axi_interconnect_1_M00_AXI_ARLOCK;
  wire [2:0]axi_interconnect_1_M00_AXI_ARPROT;
  wire [3:0]axi_interconnect_1_M00_AXI_ARQOS;
  wire axi_interconnect_1_M00_AXI_ARREADY;
  wire [2:0]axi_interconnect_1_M00_AXI_ARSIZE;
  wire axi_interconnect_1_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_1_M00_AXI_AWADDR;
  wire [1:0]axi_interconnect_1_M00_AXI_AWBURST;
  wire [3:0]axi_interconnect_1_M00_AXI_AWCACHE;
  wire [2:0]axi_interconnect_1_M00_AXI_AWID;
  wire [3:0]axi_interconnect_1_M00_AXI_AWLEN;
  wire [1:0]axi_interconnect_1_M00_AXI_AWLOCK;
  wire [2:0]axi_interconnect_1_M00_AXI_AWPROT;
  wire [3:0]axi_interconnect_1_M00_AXI_AWQOS;
  wire axi_interconnect_1_M00_AXI_AWREADY;
  wire [2:0]axi_interconnect_1_M00_AXI_AWSIZE;
  wire axi_interconnect_1_M00_AXI_AWVALID;
  wire [5:0]axi_interconnect_1_M00_AXI_BID;
  wire axi_interconnect_1_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_1_M00_AXI_BRESP;
  wire axi_interconnect_1_M00_AXI_BVALID;
  wire [63:0]axi_interconnect_1_M00_AXI_RDATA;
  wire [5:0]axi_interconnect_1_M00_AXI_RID;
  wire axi_interconnect_1_M00_AXI_RLAST;
  wire axi_interconnect_1_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_1_M00_AXI_RRESP;
  wire axi_interconnect_1_M00_AXI_RVALID;
  wire [63:0]axi_interconnect_1_M00_AXI_WDATA;
  wire [2:0]axi_interconnect_1_M00_AXI_WID;
  wire axi_interconnect_1_M00_AXI_WLAST;
  wire axi_interconnect_1_M00_AXI_WREADY;
  wire [7:0]axi_interconnect_1_M00_AXI_WSTRB;
  wire axi_interconnect_1_M00_AXI_WVALID;
  wire [31:0]axi_interconnect_2_M00_AXI_ARADDR;
  wire [1:0]axi_interconnect_2_M00_AXI_ARBURST;
  wire [3:0]axi_interconnect_2_M00_AXI_ARCACHE;
  wire [2:0]axi_interconnect_2_M00_AXI_ARID;
  wire [3:0]axi_interconnect_2_M00_AXI_ARLEN;
  wire [1:0]axi_interconnect_2_M00_AXI_ARLOCK;
  wire [2:0]axi_interconnect_2_M00_AXI_ARPROT;
  wire [3:0]axi_interconnect_2_M00_AXI_ARQOS;
  wire axi_interconnect_2_M00_AXI_ARREADY;
  wire [2:0]axi_interconnect_2_M00_AXI_ARSIZE;
  wire axi_interconnect_2_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_2_M00_AXI_AWADDR;
  wire [1:0]axi_interconnect_2_M00_AXI_AWBURST;
  wire [3:0]axi_interconnect_2_M00_AXI_AWCACHE;
  wire [2:0]axi_interconnect_2_M00_AXI_AWID;
  wire [3:0]axi_interconnect_2_M00_AXI_AWLEN;
  wire [1:0]axi_interconnect_2_M00_AXI_AWLOCK;
  wire [2:0]axi_interconnect_2_M00_AXI_AWPROT;
  wire [3:0]axi_interconnect_2_M00_AXI_AWQOS;
  wire axi_interconnect_2_M00_AXI_AWREADY;
  wire [2:0]axi_interconnect_2_M00_AXI_AWSIZE;
  wire axi_interconnect_2_M00_AXI_AWVALID;
  wire [5:0]axi_interconnect_2_M00_AXI_BID;
  wire axi_interconnect_2_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_2_M00_AXI_BRESP;
  wire axi_interconnect_2_M00_AXI_BVALID;
  wire [63:0]axi_interconnect_2_M00_AXI_RDATA;
  wire [5:0]axi_interconnect_2_M00_AXI_RID;
  wire axi_interconnect_2_M00_AXI_RLAST;
  wire axi_interconnect_2_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_2_M00_AXI_RRESP;
  wire axi_interconnect_2_M00_AXI_RVALID;
  wire [63:0]axi_interconnect_2_M00_AXI_WDATA;
  wire [2:0]axi_interconnect_2_M00_AXI_WID;
  wire axi_interconnect_2_M00_AXI_WLAST;
  wire axi_interconnect_2_M00_AXI_WREADY;
  wire [7:0]axi_interconnect_2_M00_AXI_WSTRB;
  wire axi_interconnect_2_M00_AXI_WVALID;
  wire [31:0]axi_interconnect_3_M00_AXI_ARADDR;
  wire [1:0]axi_interconnect_3_M00_AXI_ARBURST;
  wire [3:0]axi_interconnect_3_M00_AXI_ARCACHE;
  wire [1:0]axi_interconnect_3_M00_AXI_ARID;
  wire [3:0]axi_interconnect_3_M00_AXI_ARLEN;
  wire [1:0]axi_interconnect_3_M00_AXI_ARLOCK;
  wire [2:0]axi_interconnect_3_M00_AXI_ARPROT;
  wire [3:0]axi_interconnect_3_M00_AXI_ARQOS;
  wire axi_interconnect_3_M00_AXI_ARREADY;
  wire [2:0]axi_interconnect_3_M00_AXI_ARSIZE;
  wire axi_interconnect_3_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_3_M00_AXI_AWADDR;
  wire [1:0]axi_interconnect_3_M00_AXI_AWBURST;
  wire [3:0]axi_interconnect_3_M00_AXI_AWCACHE;
  wire [1:0]axi_interconnect_3_M00_AXI_AWID;
  wire [3:0]axi_interconnect_3_M00_AXI_AWLEN;
  wire [1:0]axi_interconnect_3_M00_AXI_AWLOCK;
  wire [2:0]axi_interconnect_3_M00_AXI_AWPROT;
  wire [3:0]axi_interconnect_3_M00_AXI_AWQOS;
  wire axi_interconnect_3_M00_AXI_AWREADY;
  wire [2:0]axi_interconnect_3_M00_AXI_AWSIZE;
  wire axi_interconnect_3_M00_AXI_AWVALID;
  wire [5:0]axi_interconnect_3_M00_AXI_BID;
  wire axi_interconnect_3_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_3_M00_AXI_BRESP;
  wire axi_interconnect_3_M00_AXI_BVALID;
  wire [63:0]axi_interconnect_3_M00_AXI_RDATA;
  wire [5:0]axi_interconnect_3_M00_AXI_RID;
  wire axi_interconnect_3_M00_AXI_RLAST;
  wire axi_interconnect_3_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_3_M00_AXI_RRESP;
  wire axi_interconnect_3_M00_AXI_RVALID;
  wire [63:0]axi_interconnect_3_M00_AXI_WDATA;
  wire [1:0]axi_interconnect_3_M00_AXI_WID;
  wire axi_interconnect_3_M00_AXI_WLAST;
  wire axi_interconnect_3_M00_AXI_WREADY;
  wire [7:0]axi_interconnect_3_M00_AXI_WSTRB;
  wire axi_interconnect_3_M00_AXI_WVALID;
  wire [31:0]axi_interconnect_4_M00_AXI_ARADDR;
  wire [1:0]axi_interconnect_4_M00_AXI_ARBURST;
  wire [3:0]axi_interconnect_4_M00_AXI_ARCACHE;
  wire [1:0]axi_interconnect_4_M00_AXI_ARID;
  wire [3:0]axi_interconnect_4_M00_AXI_ARLEN;
  wire [1:0]axi_interconnect_4_M00_AXI_ARLOCK;
  wire [2:0]axi_interconnect_4_M00_AXI_ARPROT;
  wire [3:0]axi_interconnect_4_M00_AXI_ARQOS;
  wire axi_interconnect_4_M00_AXI_ARREADY;
  wire [2:0]axi_interconnect_4_M00_AXI_ARSIZE;
  wire axi_interconnect_4_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_4_M00_AXI_AWADDR;
  wire [1:0]axi_interconnect_4_M00_AXI_AWBURST;
  wire [3:0]axi_interconnect_4_M00_AXI_AWCACHE;
  wire [1:0]axi_interconnect_4_M00_AXI_AWID;
  wire [3:0]axi_interconnect_4_M00_AXI_AWLEN;
  wire [1:0]axi_interconnect_4_M00_AXI_AWLOCK;
  wire [2:0]axi_interconnect_4_M00_AXI_AWPROT;
  wire [3:0]axi_interconnect_4_M00_AXI_AWQOS;
  wire axi_interconnect_4_M00_AXI_AWREADY;
  wire [2:0]axi_interconnect_4_M00_AXI_AWSIZE;
  wire axi_interconnect_4_M00_AXI_AWVALID;
  wire [5:0]axi_interconnect_4_M00_AXI_BID;
  wire axi_interconnect_4_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_4_M00_AXI_BRESP;
  wire axi_interconnect_4_M00_AXI_BVALID;
  wire [63:0]axi_interconnect_4_M00_AXI_RDATA;
  wire [5:0]axi_interconnect_4_M00_AXI_RID;
  wire axi_interconnect_4_M00_AXI_RLAST;
  wire axi_interconnect_4_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_4_M00_AXI_RRESP;
  wire axi_interconnect_4_M00_AXI_RVALID;
  wire [63:0]axi_interconnect_4_M00_AXI_WDATA;
  wire [1:0]axi_interconnect_4_M00_AXI_WID;
  wire axi_interconnect_4_M00_AXI_WLAST;
  wire axi_interconnect_4_M00_AXI_WREADY;
  wire [7:0]axi_interconnect_4_M00_AXI_WSTRB;
  wire axi_interconnect_4_M00_AXI_WVALID;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FCLK_CLK0;
  wire processing_system7_0_FCLK_RESET0_N;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;
  wire [31:0]processing_system7_0_M_AXI_GP0_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARQOS;
  wire processing_system7_0_M_AXI_GP0_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARSIZE;
  wire processing_system7_0_M_AXI_GP0_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWQOS;
  wire processing_system7_0_M_AXI_GP0_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWSIZE;
  wire processing_system7_0_M_AXI_GP0_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP0_BID;
  wire processing_system7_0_M_AXI_GP0_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_BRESP;
  wire processing_system7_0_M_AXI_GP0_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_RID;
  wire processing_system7_0_M_AXI_GP0_RLAST;
  wire processing_system7_0_M_AXI_GP0_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_RRESP;
  wire processing_system7_0_M_AXI_GP0_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_WID;
  wire processing_system7_0_M_AXI_GP0_WLAST;
  wire processing_system7_0_M_AXI_GP0_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP0_WSTRB;
  wire processing_system7_0_M_AXI_GP0_WVALID;
  wire [31:0]resize_quantize_0_m_axi_in_r_ARADDR;
  wire [1:0]resize_quantize_0_m_axi_in_r_ARBURST;
  wire [3:0]resize_quantize_0_m_axi_in_r_ARCACHE;
  wire [7:0]resize_quantize_0_m_axi_in_r_ARLEN;
  wire [1:0]resize_quantize_0_m_axi_in_r_ARLOCK;
  wire [2:0]resize_quantize_0_m_axi_in_r_ARPROT;
  wire [3:0]resize_quantize_0_m_axi_in_r_ARQOS;
  wire resize_quantize_0_m_axi_in_r_ARREADY;
  wire [3:0]resize_quantize_0_m_axi_in_r_ARREGION;
  wire [2:0]resize_quantize_0_m_axi_in_r_ARSIZE;
  wire resize_quantize_0_m_axi_in_r_ARVALID;
  wire [31:0]resize_quantize_0_m_axi_in_r_AWADDR;
  wire [1:0]resize_quantize_0_m_axi_in_r_AWBURST;
  wire [3:0]resize_quantize_0_m_axi_in_r_AWCACHE;
  wire [7:0]resize_quantize_0_m_axi_in_r_AWLEN;
  wire [1:0]resize_quantize_0_m_axi_in_r_AWLOCK;
  wire [2:0]resize_quantize_0_m_axi_in_r_AWPROT;
  wire [3:0]resize_quantize_0_m_axi_in_r_AWQOS;
  wire resize_quantize_0_m_axi_in_r_AWREADY;
  wire [3:0]resize_quantize_0_m_axi_in_r_AWREGION;
  wire [2:0]resize_quantize_0_m_axi_in_r_AWSIZE;
  wire resize_quantize_0_m_axi_in_r_AWVALID;
  wire resize_quantize_0_m_axi_in_r_BREADY;
  wire [1:0]resize_quantize_0_m_axi_in_r_BRESP;
  wire resize_quantize_0_m_axi_in_r_BVALID;
  wire [31:0]resize_quantize_0_m_axi_in_r_RDATA;
  wire resize_quantize_0_m_axi_in_r_RLAST;
  wire resize_quantize_0_m_axi_in_r_RREADY;
  wire [1:0]resize_quantize_0_m_axi_in_r_RRESP;
  wire resize_quantize_0_m_axi_in_r_RVALID;
  wire [31:0]resize_quantize_0_m_axi_in_r_WDATA;
  wire resize_quantize_0_m_axi_in_r_WLAST;
  wire resize_quantize_0_m_axi_in_r_WREADY;
  wire [3:0]resize_quantize_0_m_axi_in_r_WSTRB;
  wire resize_quantize_0_m_axi_in_r_WVALID;
  wire [31:0]resize_quantize_0_m_axi_out_r_ARADDR;
  wire [1:0]resize_quantize_0_m_axi_out_r_ARBURST;
  wire [3:0]resize_quantize_0_m_axi_out_r_ARCACHE;
  wire [7:0]resize_quantize_0_m_axi_out_r_ARLEN;
  wire [1:0]resize_quantize_0_m_axi_out_r_ARLOCK;
  wire [2:0]resize_quantize_0_m_axi_out_r_ARPROT;
  wire [3:0]resize_quantize_0_m_axi_out_r_ARQOS;
  wire resize_quantize_0_m_axi_out_r_ARREADY;
  wire [3:0]resize_quantize_0_m_axi_out_r_ARREGION;
  wire [2:0]resize_quantize_0_m_axi_out_r_ARSIZE;
  wire resize_quantize_0_m_axi_out_r_ARVALID;
  wire [31:0]resize_quantize_0_m_axi_out_r_AWADDR;
  wire [1:0]resize_quantize_0_m_axi_out_r_AWBURST;
  wire [3:0]resize_quantize_0_m_axi_out_r_AWCACHE;
  wire [7:0]resize_quantize_0_m_axi_out_r_AWLEN;
  wire [1:0]resize_quantize_0_m_axi_out_r_AWLOCK;
  wire [2:0]resize_quantize_0_m_axi_out_r_AWPROT;
  wire [3:0]resize_quantize_0_m_axi_out_r_AWQOS;
  wire resize_quantize_0_m_axi_out_r_AWREADY;
  wire [3:0]resize_quantize_0_m_axi_out_r_AWREGION;
  wire [2:0]resize_quantize_0_m_axi_out_r_AWSIZE;
  wire resize_quantize_0_m_axi_out_r_AWVALID;
  wire resize_quantize_0_m_axi_out_r_BREADY;
  wire [1:0]resize_quantize_0_m_axi_out_r_BRESP;
  wire resize_quantize_0_m_axi_out_r_BVALID;
  wire [31:0]resize_quantize_0_m_axi_out_r_RDATA;
  wire resize_quantize_0_m_axi_out_r_RLAST;
  wire resize_quantize_0_m_axi_out_r_RREADY;
  wire [1:0]resize_quantize_0_m_axi_out_r_RRESP;
  wire resize_quantize_0_m_axi_out_r_RVALID;
  wire [31:0]resize_quantize_0_m_axi_out_r_WDATA;
  wire resize_quantize_0_m_axi_out_r_WLAST;
  wire resize_quantize_0_m_axi_out_r_WREADY;
  wire [3:0]resize_quantize_0_m_axi_out_r_WSTRB;
  wire resize_quantize_0_m_axi_out_r_WVALID;
  wire [0:0]rst_ps7_0_200M_peripheral_aresetn;

  design_1_ai_fft_0_0 ai_fft_0
       (.clk(processing_system7_0_FCLK_CLK0),
        .m00_axi_aclk(processing_system7_0_FCLK_CLK0),
        .m00_axi_araddr(ai_fft_0_M00_AXI_ARADDR),
        .m00_axi_arburst(ai_fft_0_M00_AXI_ARBURST),
        .m00_axi_arcache(ai_fft_0_M00_AXI_ARCACHE),
        .m00_axi_aresetn(rst_ps7_0_200M_peripheral_aresetn),
        .m00_axi_arid(ai_fft_0_M00_AXI_ARID),
        .m00_axi_arlen(ai_fft_0_M00_AXI_ARLEN),
        .m00_axi_arlock(ai_fft_0_M00_AXI_ARLOCK),
        .m00_axi_arprot(ai_fft_0_M00_AXI_ARPROT),
        .m00_axi_arqos(ai_fft_0_M00_AXI_ARQOS),
        .m00_axi_arready(ai_fft_0_M00_AXI_ARREADY),
        .m00_axi_arsize(ai_fft_0_M00_AXI_ARSIZE),
        .m00_axi_aruser(ai_fft_0_M00_AXI_ARUSER),
        .m00_axi_arvalid(ai_fft_0_M00_AXI_ARVALID),
        .m00_axi_awaddr(ai_fft_0_M00_AXI_AWADDR),
        .m00_axi_awburst(ai_fft_0_M00_AXI_AWBURST),
        .m00_axi_awcache(ai_fft_0_M00_AXI_AWCACHE),
        .m00_axi_awid(ai_fft_0_M00_AXI_AWID),
        .m00_axi_awlen(ai_fft_0_M00_AXI_AWLEN),
        .m00_axi_awlock(ai_fft_0_M00_AXI_AWLOCK),
        .m00_axi_awprot(ai_fft_0_M00_AXI_AWPROT),
        .m00_axi_awqos(ai_fft_0_M00_AXI_AWQOS),
        .m00_axi_awready(ai_fft_0_M00_AXI_AWREADY),
        .m00_axi_awsize(ai_fft_0_M00_AXI_AWSIZE),
        .m00_axi_awuser(ai_fft_0_M00_AXI_AWUSER),
        .m00_axi_awvalid(ai_fft_0_M00_AXI_AWVALID),
        .m00_axi_bid(ai_fft_0_M00_AXI_BID),
        .m00_axi_bready(ai_fft_0_M00_AXI_BREADY),
        .m00_axi_bresp(ai_fft_0_M00_AXI_BRESP),
        .m00_axi_buser(ai_fft_0_M00_AXI_BUSER),
        .m00_axi_bvalid(ai_fft_0_M00_AXI_BVALID),
        .m00_axi_rdata(ai_fft_0_M00_AXI_RDATA),
        .m00_axi_rid(ai_fft_0_M00_AXI_RID),
        .m00_axi_rlast(ai_fft_0_M00_AXI_RLAST),
        .m00_axi_rready(ai_fft_0_M00_AXI_RREADY),
        .m00_axi_rresp(ai_fft_0_M00_AXI_RRESP),
        .m00_axi_ruser(ai_fft_0_M00_AXI_RUSER),
        .m00_axi_rvalid(ai_fft_0_M00_AXI_RVALID),
        .m00_axi_wdata(ai_fft_0_M00_AXI_WDATA),
        .m00_axi_wlast(ai_fft_0_M00_AXI_WLAST),
        .m00_axi_wready(ai_fft_0_M00_AXI_WREADY),
        .m00_axi_wstrb(ai_fft_0_M00_AXI_WSTRB),
        .m00_axi_wuser(ai_fft_0_M00_AXI_WUSER),
        .m00_axi_wvalid(ai_fft_0_M00_AXI_WVALID),
        .m01_axi_aclk(processing_system7_0_FCLK_CLK0),
        .m01_axi_araddr(ai_fft_0_M01_AXI_ARADDR),
        .m01_axi_arburst(ai_fft_0_M01_AXI_ARBURST),
        .m01_axi_arcache(ai_fft_0_M01_AXI_ARCACHE),
        .m01_axi_aresetn(rst_ps7_0_200M_peripheral_aresetn),
        .m01_axi_arid(ai_fft_0_M01_AXI_ARID),
        .m01_axi_arlen(ai_fft_0_M01_AXI_ARLEN),
        .m01_axi_arlock(ai_fft_0_M01_AXI_ARLOCK),
        .m01_axi_arprot(ai_fft_0_M01_AXI_ARPROT),
        .m01_axi_arqos(ai_fft_0_M01_AXI_ARQOS),
        .m01_axi_arready(ai_fft_0_M01_AXI_ARREADY),
        .m01_axi_arsize(ai_fft_0_M01_AXI_ARSIZE),
        .m01_axi_aruser(ai_fft_0_M01_AXI_ARUSER),
        .m01_axi_arvalid(ai_fft_0_M01_AXI_ARVALID),
        .m01_axi_awaddr(ai_fft_0_M01_AXI_AWADDR),
        .m01_axi_awburst(ai_fft_0_M01_AXI_AWBURST),
        .m01_axi_awcache(ai_fft_0_M01_AXI_AWCACHE),
        .m01_axi_awid(ai_fft_0_M01_AXI_AWID),
        .m01_axi_awlen(ai_fft_0_M01_AXI_AWLEN),
        .m01_axi_awlock(ai_fft_0_M01_AXI_AWLOCK),
        .m01_axi_awprot(ai_fft_0_M01_AXI_AWPROT),
        .m01_axi_awqos(ai_fft_0_M01_AXI_AWQOS),
        .m01_axi_awready(ai_fft_0_M01_AXI_AWREADY),
        .m01_axi_awsize(ai_fft_0_M01_AXI_AWSIZE),
        .m01_axi_awuser(ai_fft_0_M01_AXI_AWUSER),
        .m01_axi_awvalid(ai_fft_0_M01_AXI_AWVALID),
        .m01_axi_bid(ai_fft_0_M01_AXI_BID),
        .m01_axi_bready(ai_fft_0_M01_AXI_BREADY),
        .m01_axi_bresp(ai_fft_0_M01_AXI_BRESP),
        .m01_axi_buser(ai_fft_0_M01_AXI_BUSER),
        .m01_axi_bvalid(ai_fft_0_M01_AXI_BVALID),
        .m01_axi_rdata(ai_fft_0_M01_AXI_RDATA),
        .m01_axi_rid(ai_fft_0_M01_AXI_RID),
        .m01_axi_rlast(ai_fft_0_M01_AXI_RLAST),
        .m01_axi_rready(ai_fft_0_M01_AXI_RREADY),
        .m01_axi_rresp(ai_fft_0_M01_AXI_RRESP),
        .m01_axi_ruser(ai_fft_0_M01_AXI_RUSER),
        .m01_axi_rvalid(ai_fft_0_M01_AXI_RVALID),
        .m01_axi_wdata(ai_fft_0_M01_AXI_WDATA),
        .m01_axi_wlast(ai_fft_0_M01_AXI_WLAST),
        .m01_axi_wready(ai_fft_0_M01_AXI_WREADY),
        .m01_axi_wstrb(ai_fft_0_M01_AXI_WSTRB),
        .m01_axi_wuser(ai_fft_0_M01_AXI_WUSER),
        .m01_axi_wvalid(ai_fft_0_M01_AXI_WVALID),
        .m02_axi_aclk(processing_system7_0_FCLK_CLK0),
        .m02_axi_araddr(ai_fft_0_M02_AXI_ARADDR),
        .m02_axi_arburst(ai_fft_0_M02_AXI_ARBURST),
        .m02_axi_arcache(ai_fft_0_M02_AXI_ARCACHE),
        .m02_axi_aresetn(rst_ps7_0_200M_peripheral_aresetn),
        .m02_axi_arid(ai_fft_0_M02_AXI_ARID),
        .m02_axi_arlen(ai_fft_0_M02_AXI_ARLEN),
        .m02_axi_arlock(ai_fft_0_M02_AXI_ARLOCK),
        .m02_axi_arprot(ai_fft_0_M02_AXI_ARPROT),
        .m02_axi_arqos(ai_fft_0_M02_AXI_ARQOS),
        .m02_axi_arready(ai_fft_0_M02_AXI_ARREADY),
        .m02_axi_arsize(ai_fft_0_M02_AXI_ARSIZE),
        .m02_axi_aruser(ai_fft_0_M02_AXI_ARUSER),
        .m02_axi_arvalid(ai_fft_0_M02_AXI_ARVALID),
        .m02_axi_awaddr(ai_fft_0_M02_AXI_AWADDR),
        .m02_axi_awburst(ai_fft_0_M02_AXI_AWBURST),
        .m02_axi_awcache(ai_fft_0_M02_AXI_AWCACHE),
        .m02_axi_awid(ai_fft_0_M02_AXI_AWID),
        .m02_axi_awlen(ai_fft_0_M02_AXI_AWLEN),
        .m02_axi_awlock(ai_fft_0_M02_AXI_AWLOCK),
        .m02_axi_awprot(ai_fft_0_M02_AXI_AWPROT),
        .m02_axi_awqos(ai_fft_0_M02_AXI_AWQOS),
        .m02_axi_awready(ai_fft_0_M02_AXI_AWREADY),
        .m02_axi_awsize(ai_fft_0_M02_AXI_AWSIZE),
        .m02_axi_awuser(ai_fft_0_M02_AXI_AWUSER),
        .m02_axi_awvalid(ai_fft_0_M02_AXI_AWVALID),
        .m02_axi_bid(ai_fft_0_M02_AXI_BID),
        .m02_axi_bready(ai_fft_0_M02_AXI_BREADY),
        .m02_axi_bresp(ai_fft_0_M02_AXI_BRESP),
        .m02_axi_buser(1'b0),
        .m02_axi_bvalid(ai_fft_0_M02_AXI_BVALID),
        .m02_axi_rdata(ai_fft_0_M02_AXI_RDATA),
        .m02_axi_rid(ai_fft_0_M02_AXI_RID),
        .m02_axi_rlast(ai_fft_0_M02_AXI_RLAST),
        .m02_axi_rready(ai_fft_0_M02_AXI_RREADY),
        .m02_axi_rresp(ai_fft_0_M02_AXI_RRESP),
        .m02_axi_ruser(ai_fft_0_M02_AXI_RUSER),
        .m02_axi_rvalid(ai_fft_0_M02_AXI_RVALID),
        .m02_axi_wdata(ai_fft_0_M02_AXI_WDATA),
        .m02_axi_wlast(ai_fft_0_M02_AXI_WLAST),
        .m02_axi_wready(ai_fft_0_M02_AXI_WREADY),
        .m02_axi_wstrb(ai_fft_0_M02_AXI_WSTRB),
        .m02_axi_wuser(ai_fft_0_M02_AXI_WUSER),
        .m02_axi_wvalid(ai_fft_0_M02_AXI_WVALID),
        .m03_axi_aclk(processing_system7_0_FCLK_CLK0),
        .m03_axi_araddr(ai_fft_0_M03_AXI_ARADDR),
        .m03_axi_arburst(ai_fft_0_M03_AXI_ARBURST),
        .m03_axi_arcache(ai_fft_0_M03_AXI_ARCACHE),
        .m03_axi_aresetn(rst_ps7_0_200M_peripheral_aresetn),
        .m03_axi_arid(ai_fft_0_M03_AXI_ARID),
        .m03_axi_arlen(ai_fft_0_M03_AXI_ARLEN),
        .m03_axi_arlock(ai_fft_0_M03_AXI_ARLOCK),
        .m03_axi_arprot(ai_fft_0_M03_AXI_ARPROT),
        .m03_axi_arqos(ai_fft_0_M03_AXI_ARQOS),
        .m03_axi_arready(ai_fft_0_M03_AXI_ARREADY),
        .m03_axi_arsize(ai_fft_0_M03_AXI_ARSIZE),
        .m03_axi_aruser(ai_fft_0_M03_AXI_ARUSER),
        .m03_axi_arvalid(ai_fft_0_M03_AXI_ARVALID),
        .m03_axi_awaddr(ai_fft_0_M03_AXI_AWADDR),
        .m03_axi_awburst(ai_fft_0_M03_AXI_AWBURST),
        .m03_axi_awcache(ai_fft_0_M03_AXI_AWCACHE),
        .m03_axi_awid(ai_fft_0_M03_AXI_AWID),
        .m03_axi_awlen(ai_fft_0_M03_AXI_AWLEN),
        .m03_axi_awlock(ai_fft_0_M03_AXI_AWLOCK),
        .m03_axi_awprot(ai_fft_0_M03_AXI_AWPROT),
        .m03_axi_awqos(ai_fft_0_M03_AXI_AWQOS),
        .m03_axi_awready(ai_fft_0_M03_AXI_AWREADY),
        .m03_axi_awsize(ai_fft_0_M03_AXI_AWSIZE),
        .m03_axi_awuser(ai_fft_0_M03_AXI_AWUSER),
        .m03_axi_awvalid(ai_fft_0_M03_AXI_AWVALID),
        .m03_axi_bid(ai_fft_0_M03_AXI_BID),
        .m03_axi_bready(ai_fft_0_M03_AXI_BREADY),
        .m03_axi_bresp(ai_fft_0_M03_AXI_BRESP),
        .m03_axi_buser(1'b0),
        .m03_axi_bvalid(ai_fft_0_M03_AXI_BVALID),
        .m03_axi_rdata(ai_fft_0_M03_AXI_RDATA),
        .m03_axi_rid(ai_fft_0_M03_AXI_RID),
        .m03_axi_rlast(ai_fft_0_M03_AXI_RLAST),
        .m03_axi_rready(ai_fft_0_M03_AXI_RREADY),
        .m03_axi_rresp(ai_fft_0_M03_AXI_RRESP),
        .m03_axi_ruser(ai_fft_0_M03_AXI_RUSER),
        .m03_axi_rvalid(ai_fft_0_M03_AXI_RVALID),
        .m03_axi_wdata(ai_fft_0_M03_AXI_WDATA),
        .m03_axi_wlast(ai_fft_0_M03_AXI_WLAST),
        .m03_axi_wready(ai_fft_0_M03_AXI_WREADY),
        .m03_axi_wstrb(ai_fft_0_M03_AXI_WSTRB),
        .m03_axi_wuser(ai_fft_0_M03_AXI_WUSER),
        .m03_axi_wvalid(ai_fft_0_M03_AXI_WVALID),
        .rstn(rst_ps7_0_200M_peripheral_aresetn),
        .s00_axi_aclk(processing_system7_0_FCLK_CLK0),
        .s00_axi_araddr(axi_interconnect_0_M00_AXI_ARADDR),
        .s00_axi_aresetn(rst_ps7_0_200M_peripheral_aresetn),
        .s00_axi_arprot(axi_interconnect_0_M00_AXI_ARPROT),
        .s00_axi_arready(axi_interconnect_0_M00_AXI_ARREADY),
        .s00_axi_arvalid(axi_interconnect_0_M00_AXI_ARVALID),
        .s00_axi_awaddr(axi_interconnect_0_M00_AXI_AWADDR),
        .s00_axi_awprot(axi_interconnect_0_M00_AXI_AWPROT),
        .s00_axi_awready(axi_interconnect_0_M00_AXI_AWREADY),
        .s00_axi_awvalid(axi_interconnect_0_M00_AXI_AWVALID),
        .s00_axi_bready(axi_interconnect_0_M00_AXI_BREADY),
        .s00_axi_bresp(axi_interconnect_0_M00_AXI_BRESP),
        .s00_axi_bvalid(axi_interconnect_0_M00_AXI_BVALID),
        .s00_axi_rdata(axi_interconnect_0_M00_AXI_RDATA),
        .s00_axi_rready(axi_interconnect_0_M00_AXI_RREADY),
        .s00_axi_rresp(axi_interconnect_0_M00_AXI_RRESP),
        .s00_axi_rvalid(axi_interconnect_0_M00_AXI_RVALID),
        .s00_axi_wdata(axi_interconnect_0_M00_AXI_WDATA),
        .s00_axi_wready(axi_interconnect_0_M00_AXI_WREADY),
        .s00_axi_wstrb(axi_interconnect_0_M00_AXI_WSTRB),
        .s00_axi_wvalid(axi_interconnect_0_M00_AXI_WVALID));
  design_1_axi_interconnect_0_0 axi_interconnect_0
       (.ACLK(processing_system7_0_FCLK_CLK0),
        .ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_ACLK(processing_system7_0_FCLK_CLK0),
        .M00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_AXI_araddr(axi_interconnect_0_M00_AXI_ARADDR),
        .M00_AXI_arprot(axi_interconnect_0_M00_AXI_ARPROT),
        .M00_AXI_arready(axi_interconnect_0_M00_AXI_ARREADY),
        .M00_AXI_arvalid(axi_interconnect_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_0_M00_AXI_AWADDR),
        .M00_AXI_awprot(axi_interconnect_0_M00_AXI_AWPROT),
        .M00_AXI_awready(axi_interconnect_0_M00_AXI_AWREADY),
        .M00_AXI_awvalid(axi_interconnect_0_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_interconnect_0_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_0_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_0_M00_AXI_RDATA),
        .M00_AXI_rready(axi_interconnect_0_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_0_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_0_M00_AXI_WDATA),
        .M00_AXI_wready(axi_interconnect_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_0_M00_AXI_WVALID),
        .M01_ACLK(processing_system7_0_FCLK_CLK0),
        .M01_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M01_AXI_araddr(axi_interconnect_0_M01_AXI_ARADDR),
        .M01_AXI_arready(axi_interconnect_0_M01_AXI_ARREADY),
        .M01_AXI_arvalid(axi_interconnect_0_M01_AXI_ARVALID),
        .M01_AXI_awaddr(axi_interconnect_0_M01_AXI_AWADDR),
        .M01_AXI_awready(axi_interconnect_0_M01_AXI_AWREADY),
        .M01_AXI_awvalid(axi_interconnect_0_M01_AXI_AWVALID),
        .M01_AXI_bready(axi_interconnect_0_M01_AXI_BREADY),
        .M01_AXI_bresp(axi_interconnect_0_M01_AXI_BRESP),
        .M01_AXI_bvalid(axi_interconnect_0_M01_AXI_BVALID),
        .M01_AXI_rdata(axi_interconnect_0_M01_AXI_RDATA),
        .M01_AXI_rready(axi_interconnect_0_M01_AXI_RREADY),
        .M01_AXI_rresp(axi_interconnect_0_M01_AXI_RRESP),
        .M01_AXI_rvalid(axi_interconnect_0_M01_AXI_RVALID),
        .M01_AXI_wdata(axi_interconnect_0_M01_AXI_WDATA),
        .M01_AXI_wready(axi_interconnect_0_M01_AXI_WREADY),
        .M01_AXI_wstrb(axi_interconnect_0_M01_AXI_WSTRB),
        .M01_AXI_wvalid(axi_interconnect_0_M01_AXI_WVALID),
        .S00_ACLK(processing_system7_0_FCLK_CLK0),
        .S00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S00_AXI_araddr(processing_system7_0_M_AXI_GP0_ARADDR),
        .S00_AXI_arburst(processing_system7_0_M_AXI_GP0_ARBURST),
        .S00_AXI_arcache(processing_system7_0_M_AXI_GP0_ARCACHE),
        .S00_AXI_arid(processing_system7_0_M_AXI_GP0_ARID),
        .S00_AXI_arlen(processing_system7_0_M_AXI_GP0_ARLEN),
        .S00_AXI_arlock(processing_system7_0_M_AXI_GP0_ARLOCK),
        .S00_AXI_arprot(processing_system7_0_M_AXI_GP0_ARPROT),
        .S00_AXI_arqos(processing_system7_0_M_AXI_GP0_ARQOS),
        .S00_AXI_arready(processing_system7_0_M_AXI_GP0_ARREADY),
        .S00_AXI_arsize(processing_system7_0_M_AXI_GP0_ARSIZE),
        .S00_AXI_arvalid(processing_system7_0_M_AXI_GP0_ARVALID),
        .S00_AXI_awaddr(processing_system7_0_M_AXI_GP0_AWADDR),
        .S00_AXI_awburst(processing_system7_0_M_AXI_GP0_AWBURST),
        .S00_AXI_awcache(processing_system7_0_M_AXI_GP0_AWCACHE),
        .S00_AXI_awid(processing_system7_0_M_AXI_GP0_AWID),
        .S00_AXI_awlen(processing_system7_0_M_AXI_GP0_AWLEN),
        .S00_AXI_awlock(processing_system7_0_M_AXI_GP0_AWLOCK),
        .S00_AXI_awprot(processing_system7_0_M_AXI_GP0_AWPROT),
        .S00_AXI_awqos(processing_system7_0_M_AXI_GP0_AWQOS),
        .S00_AXI_awready(processing_system7_0_M_AXI_GP0_AWREADY),
        .S00_AXI_awsize(processing_system7_0_M_AXI_GP0_AWSIZE),
        .S00_AXI_awvalid(processing_system7_0_M_AXI_GP0_AWVALID),
        .S00_AXI_bid(processing_system7_0_M_AXI_GP0_BID),
        .S00_AXI_bready(processing_system7_0_M_AXI_GP0_BREADY),
        .S00_AXI_bresp(processing_system7_0_M_AXI_GP0_BRESP),
        .S00_AXI_bvalid(processing_system7_0_M_AXI_GP0_BVALID),
        .S00_AXI_rdata(processing_system7_0_M_AXI_GP0_RDATA),
        .S00_AXI_rid(processing_system7_0_M_AXI_GP0_RID),
        .S00_AXI_rlast(processing_system7_0_M_AXI_GP0_RLAST),
        .S00_AXI_rready(processing_system7_0_M_AXI_GP0_RREADY),
        .S00_AXI_rresp(processing_system7_0_M_AXI_GP0_RRESP),
        .S00_AXI_rvalid(processing_system7_0_M_AXI_GP0_RVALID),
        .S00_AXI_wdata(processing_system7_0_M_AXI_GP0_WDATA),
        .S00_AXI_wid(processing_system7_0_M_AXI_GP0_WID),
        .S00_AXI_wlast(processing_system7_0_M_AXI_GP0_WLAST),
        .S00_AXI_wready(processing_system7_0_M_AXI_GP0_WREADY),
        .S00_AXI_wstrb(processing_system7_0_M_AXI_GP0_WSTRB),
        .S00_AXI_wvalid(processing_system7_0_M_AXI_GP0_WVALID));
  design_1_axi_interconnect_0_1 axi_interconnect_1
       (.ACLK(processing_system7_0_FCLK_CLK0),
        .ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_ACLK(processing_system7_0_FCLK_CLK0),
        .M00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_AXI_araddr(axi_interconnect_1_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_interconnect_1_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_interconnect_1_M00_AXI_ARCACHE),
        .M00_AXI_arid(axi_interconnect_1_M00_AXI_ARID),
        .M00_AXI_arlen(axi_interconnect_1_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_interconnect_1_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_interconnect_1_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_interconnect_1_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_interconnect_1_M00_AXI_ARREADY),
        .M00_AXI_arsize(axi_interconnect_1_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(axi_interconnect_1_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_1_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_interconnect_1_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_interconnect_1_M00_AXI_AWCACHE),
        .M00_AXI_awid(axi_interconnect_1_M00_AXI_AWID),
        .M00_AXI_awlen(axi_interconnect_1_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_interconnect_1_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_interconnect_1_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_interconnect_1_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_interconnect_1_M00_AXI_AWREADY),
        .M00_AXI_awsize(axi_interconnect_1_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(axi_interconnect_1_M00_AXI_AWVALID),
        .M00_AXI_bid(axi_interconnect_1_M00_AXI_BID),
        .M00_AXI_bready(axi_interconnect_1_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_1_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_1_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_1_M00_AXI_RDATA),
        .M00_AXI_rid(axi_interconnect_1_M00_AXI_RID),
        .M00_AXI_rlast(axi_interconnect_1_M00_AXI_RLAST),
        .M00_AXI_rready(axi_interconnect_1_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_1_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_1_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_1_M00_AXI_WDATA),
        .M00_AXI_wid(axi_interconnect_1_M00_AXI_WID),
        .M00_AXI_wlast(axi_interconnect_1_M00_AXI_WLAST),
        .M00_AXI_wready(axi_interconnect_1_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_1_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_1_M00_AXI_WVALID),
        .S00_ACLK(processing_system7_0_FCLK_CLK0),
        .S00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S00_AXI_araddr(ai_fft_0_M00_AXI_ARADDR),
        .S00_AXI_arburst(ai_fft_0_M00_AXI_ARBURST),
        .S00_AXI_arcache(ai_fft_0_M00_AXI_ARCACHE),
        .S00_AXI_arid(ai_fft_0_M00_AXI_ARID),
        .S00_AXI_arlen(ai_fft_0_M00_AXI_ARLEN),
        .S00_AXI_arlock(ai_fft_0_M00_AXI_ARLOCK),
        .S00_AXI_arprot(ai_fft_0_M00_AXI_ARPROT),
        .S00_AXI_arqos(ai_fft_0_M00_AXI_ARQOS),
        .S00_AXI_arready(ai_fft_0_M00_AXI_ARREADY),
        .S00_AXI_arsize(ai_fft_0_M00_AXI_ARSIZE),
        .S00_AXI_aruser(ai_fft_0_M00_AXI_ARUSER),
        .S00_AXI_arvalid(ai_fft_0_M00_AXI_ARVALID),
        .S00_AXI_awaddr(ai_fft_0_M00_AXI_AWADDR),
        .S00_AXI_awburst(ai_fft_0_M00_AXI_AWBURST),
        .S00_AXI_awcache(ai_fft_0_M00_AXI_AWCACHE),
        .S00_AXI_awid(ai_fft_0_M00_AXI_AWID),
        .S00_AXI_awlen(ai_fft_0_M00_AXI_AWLEN),
        .S00_AXI_awlock(ai_fft_0_M00_AXI_AWLOCK),
        .S00_AXI_awprot(ai_fft_0_M00_AXI_AWPROT),
        .S00_AXI_awqos(ai_fft_0_M00_AXI_AWQOS),
        .S00_AXI_awready(ai_fft_0_M00_AXI_AWREADY),
        .S00_AXI_awsize(ai_fft_0_M00_AXI_AWSIZE),
        .S00_AXI_awuser(ai_fft_0_M00_AXI_AWUSER),
        .S00_AXI_awvalid(ai_fft_0_M00_AXI_AWVALID),
        .S00_AXI_bid(ai_fft_0_M00_AXI_BID),
        .S00_AXI_bready(ai_fft_0_M00_AXI_BREADY),
        .S00_AXI_bresp(ai_fft_0_M00_AXI_BRESP),
        .S00_AXI_buser(ai_fft_0_M00_AXI_BUSER),
        .S00_AXI_bvalid(ai_fft_0_M00_AXI_BVALID),
        .S00_AXI_rdata(ai_fft_0_M00_AXI_RDATA),
        .S00_AXI_rid(ai_fft_0_M00_AXI_RID),
        .S00_AXI_rlast(ai_fft_0_M00_AXI_RLAST),
        .S00_AXI_rready(ai_fft_0_M00_AXI_RREADY),
        .S00_AXI_rresp(ai_fft_0_M00_AXI_RRESP),
        .S00_AXI_ruser(ai_fft_0_M00_AXI_RUSER),
        .S00_AXI_rvalid(ai_fft_0_M00_AXI_RVALID),
        .S00_AXI_wdata(ai_fft_0_M00_AXI_WDATA),
        .S00_AXI_wlast(ai_fft_0_M00_AXI_WLAST),
        .S00_AXI_wready(ai_fft_0_M00_AXI_WREADY),
        .S00_AXI_wstrb(ai_fft_0_M00_AXI_WSTRB),
        .S00_AXI_wuser(ai_fft_0_M00_AXI_WUSER),
        .S00_AXI_wvalid(ai_fft_0_M00_AXI_WVALID),
        .S01_ACLK(processing_system7_0_FCLK_CLK0),
        .S01_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S01_AXI_araddr(resize_quantize_0_m_axi_in_r_ARADDR),
        .S01_AXI_arburst(resize_quantize_0_m_axi_in_r_ARBURST),
        .S01_AXI_arcache(resize_quantize_0_m_axi_in_r_ARCACHE),
        .S01_AXI_arlen(resize_quantize_0_m_axi_in_r_ARLEN),
        .S01_AXI_arlock(resize_quantize_0_m_axi_in_r_ARLOCK),
        .S01_AXI_arprot(resize_quantize_0_m_axi_in_r_ARPROT),
        .S01_AXI_arqos(resize_quantize_0_m_axi_in_r_ARQOS),
        .S01_AXI_arready(resize_quantize_0_m_axi_in_r_ARREADY),
        .S01_AXI_arregion(resize_quantize_0_m_axi_in_r_ARREGION),
        .S01_AXI_arsize(resize_quantize_0_m_axi_in_r_ARSIZE),
        .S01_AXI_arvalid(resize_quantize_0_m_axi_in_r_ARVALID),
        .S01_AXI_awaddr(resize_quantize_0_m_axi_in_r_AWADDR),
        .S01_AXI_awburst(resize_quantize_0_m_axi_in_r_AWBURST),
        .S01_AXI_awcache(resize_quantize_0_m_axi_in_r_AWCACHE),
        .S01_AXI_awlen(resize_quantize_0_m_axi_in_r_AWLEN),
        .S01_AXI_awlock(resize_quantize_0_m_axi_in_r_AWLOCK),
        .S01_AXI_awprot(resize_quantize_0_m_axi_in_r_AWPROT),
        .S01_AXI_awqos(resize_quantize_0_m_axi_in_r_AWQOS),
        .S01_AXI_awready(resize_quantize_0_m_axi_in_r_AWREADY),
        .S01_AXI_awregion(resize_quantize_0_m_axi_in_r_AWREGION),
        .S01_AXI_awsize(resize_quantize_0_m_axi_in_r_AWSIZE),
        .S01_AXI_awvalid(resize_quantize_0_m_axi_in_r_AWVALID),
        .S01_AXI_bready(resize_quantize_0_m_axi_in_r_BREADY),
        .S01_AXI_bresp(resize_quantize_0_m_axi_in_r_BRESP),
        .S01_AXI_bvalid(resize_quantize_0_m_axi_in_r_BVALID),
        .S01_AXI_rdata(resize_quantize_0_m_axi_in_r_RDATA),
        .S01_AXI_rlast(resize_quantize_0_m_axi_in_r_RLAST),
        .S01_AXI_rready(resize_quantize_0_m_axi_in_r_RREADY),
        .S01_AXI_rresp(resize_quantize_0_m_axi_in_r_RRESP),
        .S01_AXI_rvalid(resize_quantize_0_m_axi_in_r_RVALID),
        .S01_AXI_wdata(resize_quantize_0_m_axi_in_r_WDATA),
        .S01_AXI_wlast(resize_quantize_0_m_axi_in_r_WLAST),
        .S01_AXI_wready(resize_quantize_0_m_axi_in_r_WREADY),
        .S01_AXI_wstrb(resize_quantize_0_m_axi_in_r_WSTRB),
        .S01_AXI_wvalid(resize_quantize_0_m_axi_in_r_WVALID));
  design_1_axi_interconnect_1_0 axi_interconnect_2
       (.ACLK(processing_system7_0_FCLK_CLK0),
        .ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_ACLK(processing_system7_0_FCLK_CLK0),
        .M00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_AXI_araddr(axi_interconnect_2_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_interconnect_2_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_interconnect_2_M00_AXI_ARCACHE),
        .M00_AXI_arid(axi_interconnect_2_M00_AXI_ARID),
        .M00_AXI_arlen(axi_interconnect_2_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_interconnect_2_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_interconnect_2_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_interconnect_2_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_interconnect_2_M00_AXI_ARREADY),
        .M00_AXI_arsize(axi_interconnect_2_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(axi_interconnect_2_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_2_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_interconnect_2_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_interconnect_2_M00_AXI_AWCACHE),
        .M00_AXI_awid(axi_interconnect_2_M00_AXI_AWID),
        .M00_AXI_awlen(axi_interconnect_2_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_interconnect_2_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_interconnect_2_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_interconnect_2_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_interconnect_2_M00_AXI_AWREADY),
        .M00_AXI_awsize(axi_interconnect_2_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(axi_interconnect_2_M00_AXI_AWVALID),
        .M00_AXI_bid(axi_interconnect_2_M00_AXI_BID),
        .M00_AXI_bready(axi_interconnect_2_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_2_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_2_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_2_M00_AXI_RDATA),
        .M00_AXI_rid(axi_interconnect_2_M00_AXI_RID),
        .M00_AXI_rlast(axi_interconnect_2_M00_AXI_RLAST),
        .M00_AXI_rready(axi_interconnect_2_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_2_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_2_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_2_M00_AXI_WDATA),
        .M00_AXI_wid(axi_interconnect_2_M00_AXI_WID),
        .M00_AXI_wlast(axi_interconnect_2_M00_AXI_WLAST),
        .M00_AXI_wready(axi_interconnect_2_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_2_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_2_M00_AXI_WVALID),
        .S00_ACLK(processing_system7_0_FCLK_CLK0),
        .S00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S00_AXI_araddr(ai_fft_0_M01_AXI_ARADDR),
        .S00_AXI_arburst(ai_fft_0_M01_AXI_ARBURST),
        .S00_AXI_arcache(ai_fft_0_M01_AXI_ARCACHE),
        .S00_AXI_arid(ai_fft_0_M01_AXI_ARID),
        .S00_AXI_arlen(ai_fft_0_M01_AXI_ARLEN),
        .S00_AXI_arlock(ai_fft_0_M01_AXI_ARLOCK),
        .S00_AXI_arprot(ai_fft_0_M01_AXI_ARPROT),
        .S00_AXI_arqos(ai_fft_0_M01_AXI_ARQOS),
        .S00_AXI_arready(ai_fft_0_M01_AXI_ARREADY),
        .S00_AXI_arsize(ai_fft_0_M01_AXI_ARSIZE),
        .S00_AXI_aruser(ai_fft_0_M01_AXI_ARUSER),
        .S00_AXI_arvalid(ai_fft_0_M01_AXI_ARVALID),
        .S00_AXI_awaddr(ai_fft_0_M01_AXI_AWADDR),
        .S00_AXI_awburst(ai_fft_0_M01_AXI_AWBURST),
        .S00_AXI_awcache(ai_fft_0_M01_AXI_AWCACHE),
        .S00_AXI_awid(ai_fft_0_M01_AXI_AWID),
        .S00_AXI_awlen(ai_fft_0_M01_AXI_AWLEN),
        .S00_AXI_awlock(ai_fft_0_M01_AXI_AWLOCK),
        .S00_AXI_awprot(ai_fft_0_M01_AXI_AWPROT),
        .S00_AXI_awqos(ai_fft_0_M01_AXI_AWQOS),
        .S00_AXI_awready(ai_fft_0_M01_AXI_AWREADY),
        .S00_AXI_awsize(ai_fft_0_M01_AXI_AWSIZE),
        .S00_AXI_awuser(ai_fft_0_M01_AXI_AWUSER),
        .S00_AXI_awvalid(ai_fft_0_M01_AXI_AWVALID),
        .S00_AXI_bid(ai_fft_0_M01_AXI_BID),
        .S00_AXI_bready(ai_fft_0_M01_AXI_BREADY),
        .S00_AXI_bresp(ai_fft_0_M01_AXI_BRESP),
        .S00_AXI_buser(ai_fft_0_M01_AXI_BUSER),
        .S00_AXI_bvalid(ai_fft_0_M01_AXI_BVALID),
        .S00_AXI_rdata(ai_fft_0_M01_AXI_RDATA),
        .S00_AXI_rid(ai_fft_0_M01_AXI_RID),
        .S00_AXI_rlast(ai_fft_0_M01_AXI_RLAST),
        .S00_AXI_rready(ai_fft_0_M01_AXI_RREADY),
        .S00_AXI_rresp(ai_fft_0_M01_AXI_RRESP),
        .S00_AXI_ruser(ai_fft_0_M01_AXI_RUSER),
        .S00_AXI_rvalid(ai_fft_0_M01_AXI_RVALID),
        .S00_AXI_wdata(ai_fft_0_M01_AXI_WDATA),
        .S00_AXI_wlast(ai_fft_0_M01_AXI_WLAST),
        .S00_AXI_wready(ai_fft_0_M01_AXI_WREADY),
        .S00_AXI_wstrb(ai_fft_0_M01_AXI_WSTRB),
        .S00_AXI_wuser(ai_fft_0_M01_AXI_WUSER),
        .S00_AXI_wvalid(ai_fft_0_M01_AXI_WVALID),
        .S01_ACLK(processing_system7_0_FCLK_CLK0),
        .S01_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S01_AXI_araddr(resize_quantize_0_m_axi_out_r_ARADDR),
        .S01_AXI_arburst(resize_quantize_0_m_axi_out_r_ARBURST),
        .S01_AXI_arcache(resize_quantize_0_m_axi_out_r_ARCACHE),
        .S01_AXI_arlen(resize_quantize_0_m_axi_out_r_ARLEN),
        .S01_AXI_arlock(resize_quantize_0_m_axi_out_r_ARLOCK),
        .S01_AXI_arprot(resize_quantize_0_m_axi_out_r_ARPROT),
        .S01_AXI_arqos(resize_quantize_0_m_axi_out_r_ARQOS),
        .S01_AXI_arready(resize_quantize_0_m_axi_out_r_ARREADY),
        .S01_AXI_arregion(resize_quantize_0_m_axi_out_r_ARREGION),
        .S01_AXI_arsize(resize_quantize_0_m_axi_out_r_ARSIZE),
        .S01_AXI_arvalid(resize_quantize_0_m_axi_out_r_ARVALID),
        .S01_AXI_awaddr(resize_quantize_0_m_axi_out_r_AWADDR),
        .S01_AXI_awburst(resize_quantize_0_m_axi_out_r_AWBURST),
        .S01_AXI_awcache(resize_quantize_0_m_axi_out_r_AWCACHE),
        .S01_AXI_awlen(resize_quantize_0_m_axi_out_r_AWLEN),
        .S01_AXI_awlock(resize_quantize_0_m_axi_out_r_AWLOCK),
        .S01_AXI_awprot(resize_quantize_0_m_axi_out_r_AWPROT),
        .S01_AXI_awqos(resize_quantize_0_m_axi_out_r_AWQOS),
        .S01_AXI_awready(resize_quantize_0_m_axi_out_r_AWREADY),
        .S01_AXI_awregion(resize_quantize_0_m_axi_out_r_AWREGION),
        .S01_AXI_awsize(resize_quantize_0_m_axi_out_r_AWSIZE),
        .S01_AXI_awvalid(resize_quantize_0_m_axi_out_r_AWVALID),
        .S01_AXI_bready(resize_quantize_0_m_axi_out_r_BREADY),
        .S01_AXI_bresp(resize_quantize_0_m_axi_out_r_BRESP),
        .S01_AXI_bvalid(resize_quantize_0_m_axi_out_r_BVALID),
        .S01_AXI_rdata(resize_quantize_0_m_axi_out_r_RDATA),
        .S01_AXI_rlast(resize_quantize_0_m_axi_out_r_RLAST),
        .S01_AXI_rready(resize_quantize_0_m_axi_out_r_RREADY),
        .S01_AXI_rresp(resize_quantize_0_m_axi_out_r_RRESP),
        .S01_AXI_rvalid(resize_quantize_0_m_axi_out_r_RVALID),
        .S01_AXI_wdata(resize_quantize_0_m_axi_out_r_WDATA),
        .S01_AXI_wlast(resize_quantize_0_m_axi_out_r_WLAST),
        .S01_AXI_wready(resize_quantize_0_m_axi_out_r_WREADY),
        .S01_AXI_wstrb(resize_quantize_0_m_axi_out_r_WSTRB),
        .S01_AXI_wvalid(resize_quantize_0_m_axi_out_r_WVALID));
  design_1_axi_interconnect_1_1 axi_interconnect_3
       (.ACLK(processing_system7_0_FCLK_CLK0),
        .ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_ACLK(processing_system7_0_FCLK_CLK0),
        .M00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_AXI_araddr(axi_interconnect_3_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_interconnect_3_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_interconnect_3_M00_AXI_ARCACHE),
        .M00_AXI_arid(axi_interconnect_3_M00_AXI_ARID),
        .M00_AXI_arlen(axi_interconnect_3_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_interconnect_3_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_interconnect_3_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_interconnect_3_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_interconnect_3_M00_AXI_ARREADY),
        .M00_AXI_arsize(axi_interconnect_3_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(axi_interconnect_3_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_3_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_interconnect_3_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_interconnect_3_M00_AXI_AWCACHE),
        .M00_AXI_awid(axi_interconnect_3_M00_AXI_AWID),
        .M00_AXI_awlen(axi_interconnect_3_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_interconnect_3_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_interconnect_3_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_interconnect_3_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_interconnect_3_M00_AXI_AWREADY),
        .M00_AXI_awsize(axi_interconnect_3_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(axi_interconnect_3_M00_AXI_AWVALID),
        .M00_AXI_bid(axi_interconnect_3_M00_AXI_BID),
        .M00_AXI_bready(axi_interconnect_3_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_3_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_3_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_3_M00_AXI_RDATA),
        .M00_AXI_rid(axi_interconnect_3_M00_AXI_RID),
        .M00_AXI_rlast(axi_interconnect_3_M00_AXI_RLAST),
        .M00_AXI_rready(axi_interconnect_3_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_3_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_3_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_3_M00_AXI_WDATA),
        .M00_AXI_wid(axi_interconnect_3_M00_AXI_WID),
        .M00_AXI_wlast(axi_interconnect_3_M00_AXI_WLAST),
        .M00_AXI_wready(axi_interconnect_3_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_3_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_3_M00_AXI_WVALID),
        .S00_ACLK(processing_system7_0_FCLK_CLK0),
        .S00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S00_AXI_araddr(ai_fft_0_M02_AXI_ARADDR),
        .S00_AXI_arburst(ai_fft_0_M02_AXI_ARBURST),
        .S00_AXI_arcache(ai_fft_0_M02_AXI_ARCACHE),
        .S00_AXI_arid(ai_fft_0_M02_AXI_ARID),
        .S00_AXI_arlen(ai_fft_0_M02_AXI_ARLEN),
        .S00_AXI_arlock(ai_fft_0_M02_AXI_ARLOCK),
        .S00_AXI_arprot(ai_fft_0_M02_AXI_ARPROT),
        .S00_AXI_arqos(ai_fft_0_M02_AXI_ARQOS),
        .S00_AXI_arready(ai_fft_0_M02_AXI_ARREADY),
        .S00_AXI_arsize(ai_fft_0_M02_AXI_ARSIZE),
        .S00_AXI_aruser(ai_fft_0_M02_AXI_ARUSER),
        .S00_AXI_arvalid(ai_fft_0_M02_AXI_ARVALID),
        .S00_AXI_awaddr(ai_fft_0_M02_AXI_AWADDR),
        .S00_AXI_awburst(ai_fft_0_M02_AXI_AWBURST),
        .S00_AXI_awcache(ai_fft_0_M02_AXI_AWCACHE),
        .S00_AXI_awid(ai_fft_0_M02_AXI_AWID),
        .S00_AXI_awlen(ai_fft_0_M02_AXI_AWLEN),
        .S00_AXI_awlock(ai_fft_0_M02_AXI_AWLOCK),
        .S00_AXI_awprot(ai_fft_0_M02_AXI_AWPROT),
        .S00_AXI_awqos(ai_fft_0_M02_AXI_AWQOS),
        .S00_AXI_awready(ai_fft_0_M02_AXI_AWREADY),
        .S00_AXI_awsize(ai_fft_0_M02_AXI_AWSIZE),
        .S00_AXI_awuser(ai_fft_0_M02_AXI_AWUSER),
        .S00_AXI_awvalid(ai_fft_0_M02_AXI_AWVALID),
        .S00_AXI_bid(ai_fft_0_M02_AXI_BID),
        .S00_AXI_bready(ai_fft_0_M02_AXI_BREADY),
        .S00_AXI_bresp(ai_fft_0_M02_AXI_BRESP),
        .S00_AXI_bvalid(ai_fft_0_M02_AXI_BVALID),
        .S00_AXI_rdata(ai_fft_0_M02_AXI_RDATA),
        .S00_AXI_rid(ai_fft_0_M02_AXI_RID),
        .S00_AXI_rlast(ai_fft_0_M02_AXI_RLAST),
        .S00_AXI_rready(ai_fft_0_M02_AXI_RREADY),
        .S00_AXI_rresp(ai_fft_0_M02_AXI_RRESP),
        .S00_AXI_ruser(ai_fft_0_M02_AXI_RUSER),
        .S00_AXI_rvalid(ai_fft_0_M02_AXI_RVALID),
        .S00_AXI_wdata(ai_fft_0_M02_AXI_WDATA),
        .S00_AXI_wlast(ai_fft_0_M02_AXI_WLAST),
        .S00_AXI_wready(ai_fft_0_M02_AXI_WREADY),
        .S00_AXI_wstrb(ai_fft_0_M02_AXI_WSTRB),
        .S00_AXI_wuser(ai_fft_0_M02_AXI_WUSER),
        .S00_AXI_wvalid(ai_fft_0_M02_AXI_WVALID));
  design_1_axi_interconnect_1_2 axi_interconnect_4
       (.ACLK(processing_system7_0_FCLK_CLK0),
        .ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_ACLK(processing_system7_0_FCLK_CLK0),
        .M00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .M00_AXI_araddr(axi_interconnect_4_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_interconnect_4_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_interconnect_4_M00_AXI_ARCACHE),
        .M00_AXI_arid(axi_interconnect_4_M00_AXI_ARID),
        .M00_AXI_arlen(axi_interconnect_4_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_interconnect_4_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_interconnect_4_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_interconnect_4_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_interconnect_4_M00_AXI_ARREADY),
        .M00_AXI_arsize(axi_interconnect_4_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(axi_interconnect_4_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_4_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_interconnect_4_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_interconnect_4_M00_AXI_AWCACHE),
        .M00_AXI_awid(axi_interconnect_4_M00_AXI_AWID),
        .M00_AXI_awlen(axi_interconnect_4_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_interconnect_4_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_interconnect_4_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_interconnect_4_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_interconnect_4_M00_AXI_AWREADY),
        .M00_AXI_awsize(axi_interconnect_4_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(axi_interconnect_4_M00_AXI_AWVALID),
        .M00_AXI_bid(axi_interconnect_4_M00_AXI_BID),
        .M00_AXI_bready(axi_interconnect_4_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_4_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_4_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_4_M00_AXI_RDATA),
        .M00_AXI_rid(axi_interconnect_4_M00_AXI_RID),
        .M00_AXI_rlast(axi_interconnect_4_M00_AXI_RLAST),
        .M00_AXI_rready(axi_interconnect_4_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_4_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_4_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_4_M00_AXI_WDATA),
        .M00_AXI_wid(axi_interconnect_4_M00_AXI_WID),
        .M00_AXI_wlast(axi_interconnect_4_M00_AXI_WLAST),
        .M00_AXI_wready(axi_interconnect_4_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_4_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_4_M00_AXI_WVALID),
        .S00_ACLK(processing_system7_0_FCLK_CLK0),
        .S00_ARESETN(rst_ps7_0_200M_peripheral_aresetn),
        .S00_AXI_araddr(ai_fft_0_M03_AXI_ARADDR),
        .S00_AXI_arburst(ai_fft_0_M03_AXI_ARBURST),
        .S00_AXI_arcache(ai_fft_0_M03_AXI_ARCACHE),
        .S00_AXI_arid(ai_fft_0_M03_AXI_ARID),
        .S00_AXI_arlen(ai_fft_0_M03_AXI_ARLEN),
        .S00_AXI_arlock(ai_fft_0_M03_AXI_ARLOCK),
        .S00_AXI_arprot(ai_fft_0_M03_AXI_ARPROT),
        .S00_AXI_arqos(ai_fft_0_M03_AXI_ARQOS),
        .S00_AXI_arready(ai_fft_0_M03_AXI_ARREADY),
        .S00_AXI_arsize(ai_fft_0_M03_AXI_ARSIZE),
        .S00_AXI_aruser(ai_fft_0_M03_AXI_ARUSER),
        .S00_AXI_arvalid(ai_fft_0_M03_AXI_ARVALID),
        .S00_AXI_awaddr(ai_fft_0_M03_AXI_AWADDR),
        .S00_AXI_awburst(ai_fft_0_M03_AXI_AWBURST),
        .S00_AXI_awcache(ai_fft_0_M03_AXI_AWCACHE),
        .S00_AXI_awid(ai_fft_0_M03_AXI_AWID),
        .S00_AXI_awlen(ai_fft_0_M03_AXI_AWLEN),
        .S00_AXI_awlock(ai_fft_0_M03_AXI_AWLOCK),
        .S00_AXI_awprot(ai_fft_0_M03_AXI_AWPROT),
        .S00_AXI_awqos(ai_fft_0_M03_AXI_AWQOS),
        .S00_AXI_awready(ai_fft_0_M03_AXI_AWREADY),
        .S00_AXI_awsize(ai_fft_0_M03_AXI_AWSIZE),
        .S00_AXI_awuser(ai_fft_0_M03_AXI_AWUSER),
        .S00_AXI_awvalid(ai_fft_0_M03_AXI_AWVALID),
        .S00_AXI_bid(ai_fft_0_M03_AXI_BID),
        .S00_AXI_bready(ai_fft_0_M03_AXI_BREADY),
        .S00_AXI_bresp(ai_fft_0_M03_AXI_BRESP),
        .S00_AXI_bvalid(ai_fft_0_M03_AXI_BVALID),
        .S00_AXI_rdata(ai_fft_0_M03_AXI_RDATA),
        .S00_AXI_rid(ai_fft_0_M03_AXI_RID),
        .S00_AXI_rlast(ai_fft_0_M03_AXI_RLAST),
        .S00_AXI_rready(ai_fft_0_M03_AXI_RREADY),
        .S00_AXI_rresp(ai_fft_0_M03_AXI_RRESP),
        .S00_AXI_ruser(ai_fft_0_M03_AXI_RUSER),
        .S00_AXI_rvalid(ai_fft_0_M03_AXI_RVALID),
        .S00_AXI_wdata(ai_fft_0_M03_AXI_WDATA),
        .S00_AXI_wlast(ai_fft_0_M03_AXI_WLAST),
        .S00_AXI_wready(ai_fft_0_M03_AXI_WREADY),
        .S00_AXI_wstrb(ai_fft_0_M03_AXI_WSTRB),
        .S00_AXI_wuser(ai_fft_0_M03_AXI_WUSER),
        .S00_AXI_wvalid(ai_fft_0_M03_AXI_WVALID));
  design_1_processing_system7_0_0 processing_system7_0
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .FCLK_CLK0(processing_system7_0_FCLK_CLK0),
        .FCLK_RESET0_N(processing_system7_0_FCLK_RESET0_N),
        .IRQ_F2P(1'b0),
        .MIO(FIXED_IO_mio[53:0]),
        .M_AXI_GP0_ACLK(processing_system7_0_FCLK_CLK0),
        .M_AXI_GP0_ARADDR(processing_system7_0_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_ARBURST(processing_system7_0_M_AXI_GP0_ARBURST),
        .M_AXI_GP0_ARCACHE(processing_system7_0_M_AXI_GP0_ARCACHE),
        .M_AXI_GP0_ARID(processing_system7_0_M_AXI_GP0_ARID),
        .M_AXI_GP0_ARLEN(processing_system7_0_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_ARLOCK(processing_system7_0_M_AXI_GP0_ARLOCK),
        .M_AXI_GP0_ARPROT(processing_system7_0_M_AXI_GP0_ARPROT),
        .M_AXI_GP0_ARQOS(processing_system7_0_M_AXI_GP0_ARQOS),
        .M_AXI_GP0_ARREADY(processing_system7_0_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_ARSIZE(processing_system7_0_M_AXI_GP0_ARSIZE),
        .M_AXI_GP0_ARVALID(processing_system7_0_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_AWADDR(processing_system7_0_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_AWBURST(processing_system7_0_M_AXI_GP0_AWBURST),
        .M_AXI_GP0_AWCACHE(processing_system7_0_M_AXI_GP0_AWCACHE),
        .M_AXI_GP0_AWID(processing_system7_0_M_AXI_GP0_AWID),
        .M_AXI_GP0_AWLEN(processing_system7_0_M_AXI_GP0_AWLEN),
        .M_AXI_GP0_AWLOCK(processing_system7_0_M_AXI_GP0_AWLOCK),
        .M_AXI_GP0_AWPROT(processing_system7_0_M_AXI_GP0_AWPROT),
        .M_AXI_GP0_AWQOS(processing_system7_0_M_AXI_GP0_AWQOS),
        .M_AXI_GP0_AWREADY(processing_system7_0_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_AWSIZE(processing_system7_0_M_AXI_GP0_AWSIZE),
        .M_AXI_GP0_AWVALID(processing_system7_0_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_BID(processing_system7_0_M_AXI_GP0_BID),
        .M_AXI_GP0_BREADY(processing_system7_0_M_AXI_GP0_BREADY),
        .M_AXI_GP0_BRESP(processing_system7_0_M_AXI_GP0_BRESP),
        .M_AXI_GP0_BVALID(processing_system7_0_M_AXI_GP0_BVALID),
        .M_AXI_GP0_RDATA(processing_system7_0_M_AXI_GP0_RDATA),
        .M_AXI_GP0_RID(processing_system7_0_M_AXI_GP0_RID),
        .M_AXI_GP0_RLAST(processing_system7_0_M_AXI_GP0_RLAST),
        .M_AXI_GP0_RREADY(processing_system7_0_M_AXI_GP0_RREADY),
        .M_AXI_GP0_RRESP(processing_system7_0_M_AXI_GP0_RRESP),
        .M_AXI_GP0_RVALID(processing_system7_0_M_AXI_GP0_RVALID),
        .M_AXI_GP0_WDATA(processing_system7_0_M_AXI_GP0_WDATA),
        .M_AXI_GP0_WID(processing_system7_0_M_AXI_GP0_WID),
        .M_AXI_GP0_WLAST(processing_system7_0_M_AXI_GP0_WLAST),
        .M_AXI_GP0_WREADY(processing_system7_0_M_AXI_GP0_WREADY),
        .M_AXI_GP0_WSTRB(processing_system7_0_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_WVALID(processing_system7_0_M_AXI_GP0_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .S_AXI_HP0_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP0_ARADDR(axi_interconnect_1_M00_AXI_ARADDR),
        .S_AXI_HP0_ARBURST(axi_interconnect_1_M00_AXI_ARBURST),
        .S_AXI_HP0_ARCACHE(axi_interconnect_1_M00_AXI_ARCACHE),
        .S_AXI_HP0_ARID({1'b0,1'b0,1'b0,axi_interconnect_1_M00_AXI_ARID}),
        .S_AXI_HP0_ARLEN(axi_interconnect_1_M00_AXI_ARLEN),
        .S_AXI_HP0_ARLOCK(axi_interconnect_1_M00_AXI_ARLOCK),
        .S_AXI_HP0_ARPROT(axi_interconnect_1_M00_AXI_ARPROT),
        .S_AXI_HP0_ARQOS(axi_interconnect_1_M00_AXI_ARQOS),
        .S_AXI_HP0_ARREADY(axi_interconnect_1_M00_AXI_ARREADY),
        .S_AXI_HP0_ARSIZE(axi_interconnect_1_M00_AXI_ARSIZE),
        .S_AXI_HP0_ARVALID(axi_interconnect_1_M00_AXI_ARVALID),
        .S_AXI_HP0_AWADDR(axi_interconnect_1_M00_AXI_AWADDR),
        .S_AXI_HP0_AWBURST(axi_interconnect_1_M00_AXI_AWBURST),
        .S_AXI_HP0_AWCACHE(axi_interconnect_1_M00_AXI_AWCACHE),
        .S_AXI_HP0_AWID({1'b0,1'b0,1'b0,axi_interconnect_1_M00_AXI_AWID}),
        .S_AXI_HP0_AWLEN(axi_interconnect_1_M00_AXI_AWLEN),
        .S_AXI_HP0_AWLOCK(axi_interconnect_1_M00_AXI_AWLOCK),
        .S_AXI_HP0_AWPROT(axi_interconnect_1_M00_AXI_AWPROT),
        .S_AXI_HP0_AWQOS(axi_interconnect_1_M00_AXI_AWQOS),
        .S_AXI_HP0_AWREADY(axi_interconnect_1_M00_AXI_AWREADY),
        .S_AXI_HP0_AWSIZE(axi_interconnect_1_M00_AXI_AWSIZE),
        .S_AXI_HP0_AWVALID(axi_interconnect_1_M00_AXI_AWVALID),
        .S_AXI_HP0_BID(axi_interconnect_1_M00_AXI_BID),
        .S_AXI_HP0_BREADY(axi_interconnect_1_M00_AXI_BREADY),
        .S_AXI_HP0_BRESP(axi_interconnect_1_M00_AXI_BRESP),
        .S_AXI_HP0_BVALID(axi_interconnect_1_M00_AXI_BVALID),
        .S_AXI_HP0_RDATA(axi_interconnect_1_M00_AXI_RDATA),
        .S_AXI_HP0_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP0_RID(axi_interconnect_1_M00_AXI_RID),
        .S_AXI_HP0_RLAST(axi_interconnect_1_M00_AXI_RLAST),
        .S_AXI_HP0_RREADY(axi_interconnect_1_M00_AXI_RREADY),
        .S_AXI_HP0_RRESP(axi_interconnect_1_M00_AXI_RRESP),
        .S_AXI_HP0_RVALID(axi_interconnect_1_M00_AXI_RVALID),
        .S_AXI_HP0_WDATA(axi_interconnect_1_M00_AXI_WDATA),
        .S_AXI_HP0_WID({1'b0,1'b0,1'b0,axi_interconnect_1_M00_AXI_WID}),
        .S_AXI_HP0_WLAST(axi_interconnect_1_M00_AXI_WLAST),
        .S_AXI_HP0_WREADY(axi_interconnect_1_M00_AXI_WREADY),
        .S_AXI_HP0_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP0_WSTRB(axi_interconnect_1_M00_AXI_WSTRB),
        .S_AXI_HP0_WVALID(axi_interconnect_1_M00_AXI_WVALID),
        .S_AXI_HP1_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP1_ARADDR(axi_interconnect_2_M00_AXI_ARADDR),
        .S_AXI_HP1_ARBURST(axi_interconnect_2_M00_AXI_ARBURST),
        .S_AXI_HP1_ARCACHE(axi_interconnect_2_M00_AXI_ARCACHE),
        .S_AXI_HP1_ARID({1'b0,1'b0,1'b0,axi_interconnect_2_M00_AXI_ARID}),
        .S_AXI_HP1_ARLEN(axi_interconnect_2_M00_AXI_ARLEN),
        .S_AXI_HP1_ARLOCK(axi_interconnect_2_M00_AXI_ARLOCK),
        .S_AXI_HP1_ARPROT(axi_interconnect_2_M00_AXI_ARPROT),
        .S_AXI_HP1_ARQOS(axi_interconnect_2_M00_AXI_ARQOS),
        .S_AXI_HP1_ARREADY(axi_interconnect_2_M00_AXI_ARREADY),
        .S_AXI_HP1_ARSIZE(axi_interconnect_2_M00_AXI_ARSIZE),
        .S_AXI_HP1_ARVALID(axi_interconnect_2_M00_AXI_ARVALID),
        .S_AXI_HP1_AWADDR(axi_interconnect_2_M00_AXI_AWADDR),
        .S_AXI_HP1_AWBURST(axi_interconnect_2_M00_AXI_AWBURST),
        .S_AXI_HP1_AWCACHE(axi_interconnect_2_M00_AXI_AWCACHE),
        .S_AXI_HP1_AWID({1'b0,1'b0,1'b0,axi_interconnect_2_M00_AXI_AWID}),
        .S_AXI_HP1_AWLEN(axi_interconnect_2_M00_AXI_AWLEN),
        .S_AXI_HP1_AWLOCK(axi_interconnect_2_M00_AXI_AWLOCK),
        .S_AXI_HP1_AWPROT(axi_interconnect_2_M00_AXI_AWPROT),
        .S_AXI_HP1_AWQOS(axi_interconnect_2_M00_AXI_AWQOS),
        .S_AXI_HP1_AWREADY(axi_interconnect_2_M00_AXI_AWREADY),
        .S_AXI_HP1_AWSIZE(axi_interconnect_2_M00_AXI_AWSIZE),
        .S_AXI_HP1_AWVALID(axi_interconnect_2_M00_AXI_AWVALID),
        .S_AXI_HP1_BID(axi_interconnect_2_M00_AXI_BID),
        .S_AXI_HP1_BREADY(axi_interconnect_2_M00_AXI_BREADY),
        .S_AXI_HP1_BRESP(axi_interconnect_2_M00_AXI_BRESP),
        .S_AXI_HP1_BVALID(axi_interconnect_2_M00_AXI_BVALID),
        .S_AXI_HP1_RDATA(axi_interconnect_2_M00_AXI_RDATA),
        .S_AXI_HP1_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP1_RID(axi_interconnect_2_M00_AXI_RID),
        .S_AXI_HP1_RLAST(axi_interconnect_2_M00_AXI_RLAST),
        .S_AXI_HP1_RREADY(axi_interconnect_2_M00_AXI_RREADY),
        .S_AXI_HP1_RRESP(axi_interconnect_2_M00_AXI_RRESP),
        .S_AXI_HP1_RVALID(axi_interconnect_2_M00_AXI_RVALID),
        .S_AXI_HP1_WDATA(axi_interconnect_2_M00_AXI_WDATA),
        .S_AXI_HP1_WID({1'b0,1'b0,1'b0,axi_interconnect_2_M00_AXI_WID}),
        .S_AXI_HP1_WLAST(axi_interconnect_2_M00_AXI_WLAST),
        .S_AXI_HP1_WREADY(axi_interconnect_2_M00_AXI_WREADY),
        .S_AXI_HP1_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP1_WSTRB(axi_interconnect_2_M00_AXI_WSTRB),
        .S_AXI_HP1_WVALID(axi_interconnect_2_M00_AXI_WVALID),
        .S_AXI_HP2_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP2_ARADDR(axi_interconnect_3_M00_AXI_ARADDR),
        .S_AXI_HP2_ARBURST(axi_interconnect_3_M00_AXI_ARBURST),
        .S_AXI_HP2_ARCACHE(axi_interconnect_3_M00_AXI_ARCACHE),
        .S_AXI_HP2_ARID({1'b0,1'b0,1'b0,1'b0,axi_interconnect_3_M00_AXI_ARID}),
        .S_AXI_HP2_ARLEN(axi_interconnect_3_M00_AXI_ARLEN),
        .S_AXI_HP2_ARLOCK(axi_interconnect_3_M00_AXI_ARLOCK),
        .S_AXI_HP2_ARPROT(axi_interconnect_3_M00_AXI_ARPROT),
        .S_AXI_HP2_ARQOS(axi_interconnect_3_M00_AXI_ARQOS),
        .S_AXI_HP2_ARREADY(axi_interconnect_3_M00_AXI_ARREADY),
        .S_AXI_HP2_ARSIZE(axi_interconnect_3_M00_AXI_ARSIZE),
        .S_AXI_HP2_ARVALID(axi_interconnect_3_M00_AXI_ARVALID),
        .S_AXI_HP2_AWADDR(axi_interconnect_3_M00_AXI_AWADDR),
        .S_AXI_HP2_AWBURST(axi_interconnect_3_M00_AXI_AWBURST),
        .S_AXI_HP2_AWCACHE(axi_interconnect_3_M00_AXI_AWCACHE),
        .S_AXI_HP2_AWID({1'b0,1'b0,1'b0,1'b0,axi_interconnect_3_M00_AXI_AWID}),
        .S_AXI_HP2_AWLEN(axi_interconnect_3_M00_AXI_AWLEN),
        .S_AXI_HP2_AWLOCK(axi_interconnect_3_M00_AXI_AWLOCK),
        .S_AXI_HP2_AWPROT(axi_interconnect_3_M00_AXI_AWPROT),
        .S_AXI_HP2_AWQOS(axi_interconnect_3_M00_AXI_AWQOS),
        .S_AXI_HP2_AWREADY(axi_interconnect_3_M00_AXI_AWREADY),
        .S_AXI_HP2_AWSIZE(axi_interconnect_3_M00_AXI_AWSIZE),
        .S_AXI_HP2_AWVALID(axi_interconnect_3_M00_AXI_AWVALID),
        .S_AXI_HP2_BID(axi_interconnect_3_M00_AXI_BID),
        .S_AXI_HP2_BREADY(axi_interconnect_3_M00_AXI_BREADY),
        .S_AXI_HP2_BRESP(axi_interconnect_3_M00_AXI_BRESP),
        .S_AXI_HP2_BVALID(axi_interconnect_3_M00_AXI_BVALID),
        .S_AXI_HP2_RDATA(axi_interconnect_3_M00_AXI_RDATA),
        .S_AXI_HP2_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP2_RID(axi_interconnect_3_M00_AXI_RID),
        .S_AXI_HP2_RLAST(axi_interconnect_3_M00_AXI_RLAST),
        .S_AXI_HP2_RREADY(axi_interconnect_3_M00_AXI_RREADY),
        .S_AXI_HP2_RRESP(axi_interconnect_3_M00_AXI_RRESP),
        .S_AXI_HP2_RVALID(axi_interconnect_3_M00_AXI_RVALID),
        .S_AXI_HP2_WDATA(axi_interconnect_3_M00_AXI_WDATA),
        .S_AXI_HP2_WID({1'b0,1'b0,1'b0,1'b0,axi_interconnect_3_M00_AXI_WID}),
        .S_AXI_HP2_WLAST(axi_interconnect_3_M00_AXI_WLAST),
        .S_AXI_HP2_WREADY(axi_interconnect_3_M00_AXI_WREADY),
        .S_AXI_HP2_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP2_WSTRB(axi_interconnect_3_M00_AXI_WSTRB),
        .S_AXI_HP2_WVALID(axi_interconnect_3_M00_AXI_WVALID),
        .S_AXI_HP3_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP3_ARADDR(axi_interconnect_4_M00_AXI_ARADDR),
        .S_AXI_HP3_ARBURST(axi_interconnect_4_M00_AXI_ARBURST),
        .S_AXI_HP3_ARCACHE(axi_interconnect_4_M00_AXI_ARCACHE),
        .S_AXI_HP3_ARID({1'b0,1'b0,1'b0,1'b0,axi_interconnect_4_M00_AXI_ARID}),
        .S_AXI_HP3_ARLEN(axi_interconnect_4_M00_AXI_ARLEN),
        .S_AXI_HP3_ARLOCK(axi_interconnect_4_M00_AXI_ARLOCK),
        .S_AXI_HP3_ARPROT(axi_interconnect_4_M00_AXI_ARPROT),
        .S_AXI_HP3_ARQOS(axi_interconnect_4_M00_AXI_ARQOS),
        .S_AXI_HP3_ARREADY(axi_interconnect_4_M00_AXI_ARREADY),
        .S_AXI_HP3_ARSIZE(axi_interconnect_4_M00_AXI_ARSIZE),
        .S_AXI_HP3_ARVALID(axi_interconnect_4_M00_AXI_ARVALID),
        .S_AXI_HP3_AWADDR(axi_interconnect_4_M00_AXI_AWADDR),
        .S_AXI_HP3_AWBURST(axi_interconnect_4_M00_AXI_AWBURST),
        .S_AXI_HP3_AWCACHE(axi_interconnect_4_M00_AXI_AWCACHE),
        .S_AXI_HP3_AWID({1'b0,1'b0,1'b0,1'b0,axi_interconnect_4_M00_AXI_AWID}),
        .S_AXI_HP3_AWLEN(axi_interconnect_4_M00_AXI_AWLEN),
        .S_AXI_HP3_AWLOCK(axi_interconnect_4_M00_AXI_AWLOCK),
        .S_AXI_HP3_AWPROT(axi_interconnect_4_M00_AXI_AWPROT),
        .S_AXI_HP3_AWQOS(axi_interconnect_4_M00_AXI_AWQOS),
        .S_AXI_HP3_AWREADY(axi_interconnect_4_M00_AXI_AWREADY),
        .S_AXI_HP3_AWSIZE(axi_interconnect_4_M00_AXI_AWSIZE),
        .S_AXI_HP3_AWVALID(axi_interconnect_4_M00_AXI_AWVALID),
        .S_AXI_HP3_BID(axi_interconnect_4_M00_AXI_BID),
        .S_AXI_HP3_BREADY(axi_interconnect_4_M00_AXI_BREADY),
        .S_AXI_HP3_BRESP(axi_interconnect_4_M00_AXI_BRESP),
        .S_AXI_HP3_BVALID(axi_interconnect_4_M00_AXI_BVALID),
        .S_AXI_HP3_RDATA(axi_interconnect_4_M00_AXI_RDATA),
        .S_AXI_HP3_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP3_RID(axi_interconnect_4_M00_AXI_RID),
        .S_AXI_HP3_RLAST(axi_interconnect_4_M00_AXI_RLAST),
        .S_AXI_HP3_RREADY(axi_interconnect_4_M00_AXI_RREADY),
        .S_AXI_HP3_RRESP(axi_interconnect_4_M00_AXI_RRESP),
        .S_AXI_HP3_RVALID(axi_interconnect_4_M00_AXI_RVALID),
        .S_AXI_HP3_WDATA(axi_interconnect_4_M00_AXI_WDATA),
        .S_AXI_HP3_WID({1'b0,1'b0,1'b0,1'b0,axi_interconnect_4_M00_AXI_WID}),
        .S_AXI_HP3_WLAST(axi_interconnect_4_M00_AXI_WLAST),
        .S_AXI_HP3_WREADY(axi_interconnect_4_M00_AXI_WREADY),
        .S_AXI_HP3_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP3_WSTRB(axi_interconnect_4_M00_AXI_WSTRB),
        .S_AXI_HP3_WVALID(axi_interconnect_4_M00_AXI_WVALID),
        .USB0_VBUS_PWRFAULT(1'b0));
  design_1_resize_quantize_0_0 resize_quantize_0
       (.ap_clk(processing_system7_0_FCLK_CLK0),
        .ap_rst_n(rst_ps7_0_200M_peripheral_aresetn),
        .m_axi_in_r_ARADDR(resize_quantize_0_m_axi_in_r_ARADDR),
        .m_axi_in_r_ARBURST(resize_quantize_0_m_axi_in_r_ARBURST),
        .m_axi_in_r_ARCACHE(resize_quantize_0_m_axi_in_r_ARCACHE),
        .m_axi_in_r_ARLEN(resize_quantize_0_m_axi_in_r_ARLEN),
        .m_axi_in_r_ARLOCK(resize_quantize_0_m_axi_in_r_ARLOCK),
        .m_axi_in_r_ARPROT(resize_quantize_0_m_axi_in_r_ARPROT),
        .m_axi_in_r_ARQOS(resize_quantize_0_m_axi_in_r_ARQOS),
        .m_axi_in_r_ARREADY(resize_quantize_0_m_axi_in_r_ARREADY),
        .m_axi_in_r_ARREGION(resize_quantize_0_m_axi_in_r_ARREGION),
        .m_axi_in_r_ARSIZE(resize_quantize_0_m_axi_in_r_ARSIZE),
        .m_axi_in_r_ARVALID(resize_quantize_0_m_axi_in_r_ARVALID),
        .m_axi_in_r_AWADDR(resize_quantize_0_m_axi_in_r_AWADDR),
        .m_axi_in_r_AWBURST(resize_quantize_0_m_axi_in_r_AWBURST),
        .m_axi_in_r_AWCACHE(resize_quantize_0_m_axi_in_r_AWCACHE),
        .m_axi_in_r_AWLEN(resize_quantize_0_m_axi_in_r_AWLEN),
        .m_axi_in_r_AWLOCK(resize_quantize_0_m_axi_in_r_AWLOCK),
        .m_axi_in_r_AWPROT(resize_quantize_0_m_axi_in_r_AWPROT),
        .m_axi_in_r_AWQOS(resize_quantize_0_m_axi_in_r_AWQOS),
        .m_axi_in_r_AWREADY(resize_quantize_0_m_axi_in_r_AWREADY),
        .m_axi_in_r_AWREGION(resize_quantize_0_m_axi_in_r_AWREGION),
        .m_axi_in_r_AWSIZE(resize_quantize_0_m_axi_in_r_AWSIZE),
        .m_axi_in_r_AWVALID(resize_quantize_0_m_axi_in_r_AWVALID),
        .m_axi_in_r_BREADY(resize_quantize_0_m_axi_in_r_BREADY),
        .m_axi_in_r_BRESP(resize_quantize_0_m_axi_in_r_BRESP),
        .m_axi_in_r_BVALID(resize_quantize_0_m_axi_in_r_BVALID),
        .m_axi_in_r_RDATA(resize_quantize_0_m_axi_in_r_RDATA),
        .m_axi_in_r_RLAST(resize_quantize_0_m_axi_in_r_RLAST),
        .m_axi_in_r_RREADY(resize_quantize_0_m_axi_in_r_RREADY),
        .m_axi_in_r_RRESP(resize_quantize_0_m_axi_in_r_RRESP),
        .m_axi_in_r_RVALID(resize_quantize_0_m_axi_in_r_RVALID),
        .m_axi_in_r_WDATA(resize_quantize_0_m_axi_in_r_WDATA),
        .m_axi_in_r_WLAST(resize_quantize_0_m_axi_in_r_WLAST),
        .m_axi_in_r_WREADY(resize_quantize_0_m_axi_in_r_WREADY),
        .m_axi_in_r_WSTRB(resize_quantize_0_m_axi_in_r_WSTRB),
        .m_axi_in_r_WVALID(resize_quantize_0_m_axi_in_r_WVALID),
        .m_axi_out_r_ARADDR(resize_quantize_0_m_axi_out_r_ARADDR),
        .m_axi_out_r_ARBURST(resize_quantize_0_m_axi_out_r_ARBURST),
        .m_axi_out_r_ARCACHE(resize_quantize_0_m_axi_out_r_ARCACHE),
        .m_axi_out_r_ARLEN(resize_quantize_0_m_axi_out_r_ARLEN),
        .m_axi_out_r_ARLOCK(resize_quantize_0_m_axi_out_r_ARLOCK),
        .m_axi_out_r_ARPROT(resize_quantize_0_m_axi_out_r_ARPROT),
        .m_axi_out_r_ARQOS(resize_quantize_0_m_axi_out_r_ARQOS),
        .m_axi_out_r_ARREADY(resize_quantize_0_m_axi_out_r_ARREADY),
        .m_axi_out_r_ARREGION(resize_quantize_0_m_axi_out_r_ARREGION),
        .m_axi_out_r_ARSIZE(resize_quantize_0_m_axi_out_r_ARSIZE),
        .m_axi_out_r_ARVALID(resize_quantize_0_m_axi_out_r_ARVALID),
        .m_axi_out_r_AWADDR(resize_quantize_0_m_axi_out_r_AWADDR),
        .m_axi_out_r_AWBURST(resize_quantize_0_m_axi_out_r_AWBURST),
        .m_axi_out_r_AWCACHE(resize_quantize_0_m_axi_out_r_AWCACHE),
        .m_axi_out_r_AWLEN(resize_quantize_0_m_axi_out_r_AWLEN),
        .m_axi_out_r_AWLOCK(resize_quantize_0_m_axi_out_r_AWLOCK),
        .m_axi_out_r_AWPROT(resize_quantize_0_m_axi_out_r_AWPROT),
        .m_axi_out_r_AWQOS(resize_quantize_0_m_axi_out_r_AWQOS),
        .m_axi_out_r_AWREADY(resize_quantize_0_m_axi_out_r_AWREADY),
        .m_axi_out_r_AWREGION(resize_quantize_0_m_axi_out_r_AWREGION),
        .m_axi_out_r_AWSIZE(resize_quantize_0_m_axi_out_r_AWSIZE),
        .m_axi_out_r_AWVALID(resize_quantize_0_m_axi_out_r_AWVALID),
        .m_axi_out_r_BREADY(resize_quantize_0_m_axi_out_r_BREADY),
        .m_axi_out_r_BRESP(resize_quantize_0_m_axi_out_r_BRESP),
        .m_axi_out_r_BVALID(resize_quantize_0_m_axi_out_r_BVALID),
        .m_axi_out_r_RDATA(resize_quantize_0_m_axi_out_r_RDATA),
        .m_axi_out_r_RLAST(resize_quantize_0_m_axi_out_r_RLAST),
        .m_axi_out_r_RREADY(resize_quantize_0_m_axi_out_r_RREADY),
        .m_axi_out_r_RRESP(resize_quantize_0_m_axi_out_r_RRESP),
        .m_axi_out_r_RVALID(resize_quantize_0_m_axi_out_r_RVALID),
        .m_axi_out_r_WDATA(resize_quantize_0_m_axi_out_r_WDATA),
        .m_axi_out_r_WLAST(resize_quantize_0_m_axi_out_r_WLAST),
        .m_axi_out_r_WREADY(resize_quantize_0_m_axi_out_r_WREADY),
        .m_axi_out_r_WSTRB(resize_quantize_0_m_axi_out_r_WSTRB),
        .m_axi_out_r_WVALID(resize_quantize_0_m_axi_out_r_WVALID),
        .s_axi_control_ARADDR(axi_interconnect_0_M01_AXI_ARADDR[6:0]),
        .s_axi_control_ARREADY(axi_interconnect_0_M01_AXI_ARREADY),
        .s_axi_control_ARVALID(axi_interconnect_0_M01_AXI_ARVALID),
        .s_axi_control_AWADDR(axi_interconnect_0_M01_AXI_AWADDR[6:0]),
        .s_axi_control_AWREADY(axi_interconnect_0_M01_AXI_AWREADY),
        .s_axi_control_AWVALID(axi_interconnect_0_M01_AXI_AWVALID),
        .s_axi_control_BREADY(axi_interconnect_0_M01_AXI_BREADY),
        .s_axi_control_BRESP(axi_interconnect_0_M01_AXI_BRESP),
        .s_axi_control_BVALID(axi_interconnect_0_M01_AXI_BVALID),
        .s_axi_control_RDATA(axi_interconnect_0_M01_AXI_RDATA),
        .s_axi_control_RREADY(axi_interconnect_0_M01_AXI_RREADY),
        .s_axi_control_RRESP(axi_interconnect_0_M01_AXI_RRESP),
        .s_axi_control_RVALID(axi_interconnect_0_M01_AXI_RVALID),
        .s_axi_control_WDATA(axi_interconnect_0_M01_AXI_WDATA),
        .s_axi_control_WREADY(axi_interconnect_0_M01_AXI_WREADY),
        .s_axi_control_WSTRB(axi_interconnect_0_M01_AXI_WSTRB),
        .s_axi_control_WVALID(axi_interconnect_0_M01_AXI_WVALID));
  design_1_rst_ps7_0_200M_0 rst_ps7_0_200M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(processing_system7_0_FCLK_RESET0_N),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_ps7_0_200M_peripheral_aresetn),
        .slowest_sync_clk(processing_system7_0_FCLK_CLK0));
endmodule

module design_1_axi_interconnect_0_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    M01_ACLK,
    M01_ARESETN,
    M01_AXI_araddr,
    M01_AXI_arready,
    M01_AXI_arvalid,
    M01_AXI_awaddr,
    M01_AXI_awready,
    M01_AXI_awvalid,
    M01_AXI_bready,
    M01_AXI_bresp,
    M01_AXI_bvalid,
    M01_AXI_rdata,
    M01_AXI_rready,
    M01_AXI_rresp,
    M01_AXI_rvalid,
    M01_AXI_wdata,
    M01_AXI_wready,
    M01_AXI_wstrb,
    M01_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wid,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input M01_ACLK;
  input M01_ARESETN;
  output [31:0]M01_AXI_araddr;
  input M01_AXI_arready;
  output M01_AXI_arvalid;
  output [31:0]M01_AXI_awaddr;
  input M01_AXI_awready;
  output M01_AXI_awvalid;
  output M01_AXI_bready;
  input [1:0]M01_AXI_bresp;
  input M01_AXI_bvalid;
  input [31:0]M01_AXI_rdata;
  output M01_AXI_rready;
  input [1:0]M01_AXI_rresp;
  input M01_AXI_rvalid;
  output [31:0]M01_AXI_wdata;
  input M01_AXI_wready;
  output [3:0]M01_AXI_wstrb;
  output M01_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [11:0]S00_AXI_arid;
  input [3:0]S00_AXI_arlen;
  input [1:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [11:0]S00_AXI_awid;
  input [3:0]S00_AXI_awlen;
  input [1:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [11:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [11:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input [11:0]S00_AXI_wid;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;

  wire axi_interconnect_0_ACLK_net;
  wire axi_interconnect_0_ARESETN_net;
  wire [31:0]axi_interconnect_0_to_s00_couplers_ARADDR;
  wire [1:0]axi_interconnect_0_to_s00_couplers_ARBURST;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARCACHE;
  wire [11:0]axi_interconnect_0_to_s00_couplers_ARID;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARLEN;
  wire [1:0]axi_interconnect_0_to_s00_couplers_ARLOCK;
  wire [2:0]axi_interconnect_0_to_s00_couplers_ARPROT;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARQOS;
  wire axi_interconnect_0_to_s00_couplers_ARREADY;
  wire [2:0]axi_interconnect_0_to_s00_couplers_ARSIZE;
  wire axi_interconnect_0_to_s00_couplers_ARVALID;
  wire [31:0]axi_interconnect_0_to_s00_couplers_AWADDR;
  wire [1:0]axi_interconnect_0_to_s00_couplers_AWBURST;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWCACHE;
  wire [11:0]axi_interconnect_0_to_s00_couplers_AWID;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWLEN;
  wire [1:0]axi_interconnect_0_to_s00_couplers_AWLOCK;
  wire [2:0]axi_interconnect_0_to_s00_couplers_AWPROT;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWQOS;
  wire axi_interconnect_0_to_s00_couplers_AWREADY;
  wire [2:0]axi_interconnect_0_to_s00_couplers_AWSIZE;
  wire axi_interconnect_0_to_s00_couplers_AWVALID;
  wire [11:0]axi_interconnect_0_to_s00_couplers_BID;
  wire axi_interconnect_0_to_s00_couplers_BREADY;
  wire [1:0]axi_interconnect_0_to_s00_couplers_BRESP;
  wire axi_interconnect_0_to_s00_couplers_BVALID;
  wire [31:0]axi_interconnect_0_to_s00_couplers_RDATA;
  wire [11:0]axi_interconnect_0_to_s00_couplers_RID;
  wire axi_interconnect_0_to_s00_couplers_RLAST;
  wire axi_interconnect_0_to_s00_couplers_RREADY;
  wire [1:0]axi_interconnect_0_to_s00_couplers_RRESP;
  wire axi_interconnect_0_to_s00_couplers_RVALID;
  wire [31:0]axi_interconnect_0_to_s00_couplers_WDATA;
  wire [11:0]axi_interconnect_0_to_s00_couplers_WID;
  wire axi_interconnect_0_to_s00_couplers_WLAST;
  wire axi_interconnect_0_to_s00_couplers_WREADY;
  wire [3:0]axi_interconnect_0_to_s00_couplers_WSTRB;
  wire axi_interconnect_0_to_s00_couplers_WVALID;
  wire [31:0]m00_couplers_to_axi_interconnect_0_ARADDR;
  wire [2:0]m00_couplers_to_axi_interconnect_0_ARPROT;
  wire m00_couplers_to_axi_interconnect_0_ARREADY;
  wire m00_couplers_to_axi_interconnect_0_ARVALID;
  wire [31:0]m00_couplers_to_axi_interconnect_0_AWADDR;
  wire [2:0]m00_couplers_to_axi_interconnect_0_AWPROT;
  wire m00_couplers_to_axi_interconnect_0_AWREADY;
  wire m00_couplers_to_axi_interconnect_0_AWVALID;
  wire m00_couplers_to_axi_interconnect_0_BREADY;
  wire [1:0]m00_couplers_to_axi_interconnect_0_BRESP;
  wire m00_couplers_to_axi_interconnect_0_BVALID;
  wire [31:0]m00_couplers_to_axi_interconnect_0_RDATA;
  wire m00_couplers_to_axi_interconnect_0_RREADY;
  wire [1:0]m00_couplers_to_axi_interconnect_0_RRESP;
  wire m00_couplers_to_axi_interconnect_0_RVALID;
  wire [31:0]m00_couplers_to_axi_interconnect_0_WDATA;
  wire m00_couplers_to_axi_interconnect_0_WREADY;
  wire [3:0]m00_couplers_to_axi_interconnect_0_WSTRB;
  wire m00_couplers_to_axi_interconnect_0_WVALID;
  wire [31:0]m01_couplers_to_axi_interconnect_0_ARADDR;
  wire m01_couplers_to_axi_interconnect_0_ARREADY;
  wire m01_couplers_to_axi_interconnect_0_ARVALID;
  wire [31:0]m01_couplers_to_axi_interconnect_0_AWADDR;
  wire m01_couplers_to_axi_interconnect_0_AWREADY;
  wire m01_couplers_to_axi_interconnect_0_AWVALID;
  wire m01_couplers_to_axi_interconnect_0_BREADY;
  wire [1:0]m01_couplers_to_axi_interconnect_0_BRESP;
  wire m01_couplers_to_axi_interconnect_0_BVALID;
  wire [31:0]m01_couplers_to_axi_interconnect_0_RDATA;
  wire m01_couplers_to_axi_interconnect_0_RREADY;
  wire [1:0]m01_couplers_to_axi_interconnect_0_RRESP;
  wire m01_couplers_to_axi_interconnect_0_RVALID;
  wire [31:0]m01_couplers_to_axi_interconnect_0_WDATA;
  wire m01_couplers_to_axi_interconnect_0_WREADY;
  wire [3:0]m01_couplers_to_axi_interconnect_0_WSTRB;
  wire m01_couplers_to_axi_interconnect_0_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire s00_couplers_to_xbar_AWVALID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [31:0]s00_couplers_to_xbar_RDATA;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [31:0]s00_couplers_to_xbar_WDATA;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [3:0]s00_couplers_to_xbar_WSTRB;
  wire s00_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire xbar_to_m00_couplers_ARREADY;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire xbar_to_m00_couplers_AWREADY;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [31:0]xbar_to_m00_couplers_RDATA;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire xbar_to_m00_couplers_RVALID;
  wire [31:0]xbar_to_m00_couplers_WDATA;
  wire xbar_to_m00_couplers_WREADY;
  wire [3:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WVALID;
  wire [63:32]xbar_to_m01_couplers_ARADDR;
  wire xbar_to_m01_couplers_ARREADY;
  wire [1:1]xbar_to_m01_couplers_ARVALID;
  wire [63:32]xbar_to_m01_couplers_AWADDR;
  wire xbar_to_m01_couplers_AWREADY;
  wire [1:1]xbar_to_m01_couplers_AWVALID;
  wire [1:1]xbar_to_m01_couplers_BREADY;
  wire [1:0]xbar_to_m01_couplers_BRESP;
  wire xbar_to_m01_couplers_BVALID;
  wire [31:0]xbar_to_m01_couplers_RDATA;
  wire [1:1]xbar_to_m01_couplers_RREADY;
  wire [1:0]xbar_to_m01_couplers_RRESP;
  wire xbar_to_m01_couplers_RVALID;
  wire [63:32]xbar_to_m01_couplers_WDATA;
  wire xbar_to_m01_couplers_WREADY;
  wire [7:4]xbar_to_m01_couplers_WSTRB;
  wire [1:1]xbar_to_m01_couplers_WVALID;

  assign M00_AXI_araddr[31:0] = m00_couplers_to_axi_interconnect_0_ARADDR;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_interconnect_0_ARPROT;
  assign M00_AXI_arvalid = m00_couplers_to_axi_interconnect_0_ARVALID;
  assign M00_AXI_awaddr[31:0] = m00_couplers_to_axi_interconnect_0_AWADDR;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_interconnect_0_AWPROT;
  assign M00_AXI_awvalid = m00_couplers_to_axi_interconnect_0_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_axi_interconnect_0_BREADY;
  assign M00_AXI_rready = m00_couplers_to_axi_interconnect_0_RREADY;
  assign M00_AXI_wdata[31:0] = m00_couplers_to_axi_interconnect_0_WDATA;
  assign M00_AXI_wstrb[3:0] = m00_couplers_to_axi_interconnect_0_WSTRB;
  assign M00_AXI_wvalid = m00_couplers_to_axi_interconnect_0_WVALID;
  assign M01_AXI_araddr[31:0] = m01_couplers_to_axi_interconnect_0_ARADDR;
  assign M01_AXI_arvalid = m01_couplers_to_axi_interconnect_0_ARVALID;
  assign M01_AXI_awaddr[31:0] = m01_couplers_to_axi_interconnect_0_AWADDR;
  assign M01_AXI_awvalid = m01_couplers_to_axi_interconnect_0_AWVALID;
  assign M01_AXI_bready = m01_couplers_to_axi_interconnect_0_BREADY;
  assign M01_AXI_rready = m01_couplers_to_axi_interconnect_0_RREADY;
  assign M01_AXI_wdata[31:0] = m01_couplers_to_axi_interconnect_0_WDATA;
  assign M01_AXI_wstrb[3:0] = m01_couplers_to_axi_interconnect_0_WSTRB;
  assign M01_AXI_wvalid = m01_couplers_to_axi_interconnect_0_WVALID;
  assign S00_AXI_arready = axi_interconnect_0_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_0_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[11:0] = axi_interconnect_0_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_interconnect_0_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = axi_interconnect_0_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = axi_interconnect_0_to_s00_couplers_RDATA;
  assign S00_AXI_rid[11:0] = axi_interconnect_0_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_interconnect_0_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_0_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = axi_interconnect_0_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_0_to_s00_couplers_WREADY;
  assign axi_interconnect_0_ACLK_net = ACLK;
  assign axi_interconnect_0_ARESETN_net = ARESETN;
  assign axi_interconnect_0_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_interconnect_0_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_0_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARID = S00_AXI_arid[11:0];
  assign axi_interconnect_0_to_s00_couplers_ARLEN = S00_AXI_arlen[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARLOCK = S00_AXI_arlock[1:0];
  assign axi_interconnect_0_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_0_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_0_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_0_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_interconnect_0_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_0_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWID = S00_AXI_awid[11:0];
  assign axi_interconnect_0_to_s00_couplers_AWLEN = S00_AXI_awlen[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWLOCK = S00_AXI_awlock[1:0];
  assign axi_interconnect_0_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_0_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_0_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_0_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_0_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_0_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign axi_interconnect_0_to_s00_couplers_WID = S00_AXI_wid[11:0];
  assign axi_interconnect_0_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_0_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign axi_interconnect_0_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign m00_couplers_to_axi_interconnect_0_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_axi_interconnect_0_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_axi_interconnect_0_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_interconnect_0_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_axi_interconnect_0_RDATA = M00_AXI_rdata[31:0];
  assign m00_couplers_to_axi_interconnect_0_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_interconnect_0_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_axi_interconnect_0_WREADY = M00_AXI_wready;
  assign m01_couplers_to_axi_interconnect_0_ARREADY = M01_AXI_arready;
  assign m01_couplers_to_axi_interconnect_0_AWREADY = M01_AXI_awready;
  assign m01_couplers_to_axi_interconnect_0_BRESP = M01_AXI_bresp[1:0];
  assign m01_couplers_to_axi_interconnect_0_BVALID = M01_AXI_bvalid;
  assign m01_couplers_to_axi_interconnect_0_RDATA = M01_AXI_rdata[31:0];
  assign m01_couplers_to_axi_interconnect_0_RRESP = M01_AXI_rresp[1:0];
  assign m01_couplers_to_axi_interconnect_0_RVALID = M01_AXI_rvalid;
  assign m01_couplers_to_axi_interconnect_0_WREADY = M01_AXI_wready;
  m00_couplers_imp_1CA5Z32 m00_couplers
       (.M_ACLK(axi_interconnect_0_ACLK_net),
        .M_ARESETN(axi_interconnect_0_ARESETN_net),
        .M_AXI_araddr(m00_couplers_to_axi_interconnect_0_ARADDR),
        .M_AXI_arprot(m00_couplers_to_axi_interconnect_0_ARPROT),
        .M_AXI_arready(m00_couplers_to_axi_interconnect_0_ARREADY),
        .M_AXI_arvalid(m00_couplers_to_axi_interconnect_0_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_interconnect_0_AWADDR),
        .M_AXI_awprot(m00_couplers_to_axi_interconnect_0_AWPROT),
        .M_AXI_awready(m00_couplers_to_axi_interconnect_0_AWREADY),
        .M_AXI_awvalid(m00_couplers_to_axi_interconnect_0_AWVALID),
        .M_AXI_bready(m00_couplers_to_axi_interconnect_0_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_interconnect_0_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_interconnect_0_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_interconnect_0_RDATA),
        .M_AXI_rready(m00_couplers_to_axi_interconnect_0_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_interconnect_0_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_interconnect_0_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_interconnect_0_WDATA),
        .M_AXI_wready(m00_couplers_to_axi_interconnect_0_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_interconnect_0_WSTRB),
        .M_AXI_wvalid(m00_couplers_to_axi_interconnect_0_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
  m01_couplers_imp_I4GRPB m01_couplers
       (.M_ACLK(axi_interconnect_0_ACLK_net),
        .M_ARESETN(axi_interconnect_0_ARESETN_net),
        .M_AXI_araddr(m01_couplers_to_axi_interconnect_0_ARADDR),
        .M_AXI_arready(m01_couplers_to_axi_interconnect_0_ARREADY),
        .M_AXI_arvalid(m01_couplers_to_axi_interconnect_0_ARVALID),
        .M_AXI_awaddr(m01_couplers_to_axi_interconnect_0_AWADDR),
        .M_AXI_awready(m01_couplers_to_axi_interconnect_0_AWREADY),
        .M_AXI_awvalid(m01_couplers_to_axi_interconnect_0_AWVALID),
        .M_AXI_bready(m01_couplers_to_axi_interconnect_0_BREADY),
        .M_AXI_bresp(m01_couplers_to_axi_interconnect_0_BRESP),
        .M_AXI_bvalid(m01_couplers_to_axi_interconnect_0_BVALID),
        .M_AXI_rdata(m01_couplers_to_axi_interconnect_0_RDATA),
        .M_AXI_rready(m01_couplers_to_axi_interconnect_0_RREADY),
        .M_AXI_rresp(m01_couplers_to_axi_interconnect_0_RRESP),
        .M_AXI_rvalid(m01_couplers_to_axi_interconnect_0_RVALID),
        .M_AXI_wdata(m01_couplers_to_axi_interconnect_0_WDATA),
        .M_AXI_wready(m01_couplers_to_axi_interconnect_0_WREADY),
        .M_AXI_wstrb(m01_couplers_to_axi_interconnect_0_WSTRB),
        .M_AXI_wvalid(m01_couplers_to_axi_interconnect_0_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m01_couplers_ARADDR),
        .S_AXI_arready(xbar_to_m01_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m01_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m01_couplers_AWADDR),
        .S_AXI_awready(xbar_to_m01_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m01_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m01_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m01_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m01_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m01_couplers_RDATA),
        .S_AXI_rready(xbar_to_m01_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m01_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m01_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m01_couplers_WDATA),
        .S_AXI_wready(xbar_to_m01_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m01_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m01_couplers_WVALID));
  s00_couplers_imp_O7FAN0 s00_couplers
       (.M_ACLK(axi_interconnect_0_ACLK_net),
        .M_ARESETN(axi_interconnect_0_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(axi_interconnect_0_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_0_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_0_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_interconnect_0_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_interconnect_0_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_0_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_0_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_0_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_0_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_0_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(axi_interconnect_0_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_0_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_0_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_0_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_interconnect_0_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_interconnect_0_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_0_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_0_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_0_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_0_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_0_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(axi_interconnect_0_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_interconnect_0_to_s00_couplers_BID),
        .S_AXI_bready(axi_interconnect_0_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_0_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_0_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_0_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_interconnect_0_to_s00_couplers_RID),
        .S_AXI_rlast(axi_interconnect_0_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_0_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_0_to_s00_couplers_RRESP),
        .S_AXI_rvalid(axi_interconnect_0_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_0_to_s00_couplers_WDATA),
        .S_AXI_wid(axi_interconnect_0_to_s00_couplers_WID),
        .S_AXI_wlast(axi_interconnect_0_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_0_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_0_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(axi_interconnect_0_to_s00_couplers_WVALID));
  design_1_xbar_0 xbar
       (.aclk(axi_interconnect_0_ACLK_net),
        .aresetn(axi_interconnect_0_ARESETN_net),
        .m_axi_araddr({xbar_to_m01_couplers_ARADDR,xbar_to_m00_couplers_ARADDR}),
        .m_axi_arprot(xbar_to_m00_couplers_ARPROT),
        .m_axi_arready({xbar_to_m01_couplers_ARREADY,xbar_to_m00_couplers_ARREADY}),
        .m_axi_arvalid({xbar_to_m01_couplers_ARVALID,xbar_to_m00_couplers_ARVALID}),
        .m_axi_awaddr({xbar_to_m01_couplers_AWADDR,xbar_to_m00_couplers_AWADDR}),
        .m_axi_awprot(xbar_to_m00_couplers_AWPROT),
        .m_axi_awready({xbar_to_m01_couplers_AWREADY,xbar_to_m00_couplers_AWREADY}),
        .m_axi_awvalid({xbar_to_m01_couplers_AWVALID,xbar_to_m00_couplers_AWVALID}),
        .m_axi_bready({xbar_to_m01_couplers_BREADY,xbar_to_m00_couplers_BREADY}),
        .m_axi_bresp({xbar_to_m01_couplers_BRESP,xbar_to_m00_couplers_BRESP}),
        .m_axi_bvalid({xbar_to_m01_couplers_BVALID,xbar_to_m00_couplers_BVALID}),
        .m_axi_rdata({xbar_to_m01_couplers_RDATA,xbar_to_m00_couplers_RDATA}),
        .m_axi_rready({xbar_to_m01_couplers_RREADY,xbar_to_m00_couplers_RREADY}),
        .m_axi_rresp({xbar_to_m01_couplers_RRESP,xbar_to_m00_couplers_RRESP}),
        .m_axi_rvalid({xbar_to_m01_couplers_RVALID,xbar_to_m00_couplers_RVALID}),
        .m_axi_wdata({xbar_to_m01_couplers_WDATA,xbar_to_m00_couplers_WDATA}),
        .m_axi_wready({xbar_to_m01_couplers_WREADY,xbar_to_m00_couplers_WREADY}),
        .m_axi_wstrb({xbar_to_m01_couplers_WSTRB,xbar_to_m00_couplers_WSTRB}),
        .m_axi_wvalid({xbar_to_m01_couplers_WVALID,xbar_to_m00_couplers_WVALID}),
        .s_axi_araddr(s00_couplers_to_xbar_ARADDR),
        .s_axi_arprot(s00_couplers_to_xbar_ARPROT),
        .s_axi_arready(s00_couplers_to_xbar_ARREADY),
        .s_axi_arvalid(s00_couplers_to_xbar_ARVALID),
        .s_axi_awaddr(s00_couplers_to_xbar_AWADDR),
        .s_axi_awprot(s00_couplers_to_xbar_AWPROT),
        .s_axi_awready(s00_couplers_to_xbar_AWREADY),
        .s_axi_awvalid(s00_couplers_to_xbar_AWVALID),
        .s_axi_bready(s00_couplers_to_xbar_BREADY),
        .s_axi_bresp(s00_couplers_to_xbar_BRESP),
        .s_axi_bvalid(s00_couplers_to_xbar_BVALID),
        .s_axi_rdata(s00_couplers_to_xbar_RDATA),
        .s_axi_rready(s00_couplers_to_xbar_RREADY),
        .s_axi_rresp(s00_couplers_to_xbar_RRESP),
        .s_axi_rvalid(s00_couplers_to_xbar_RVALID),
        .s_axi_wdata(s00_couplers_to_xbar_WDATA),
        .s_axi_wready(s00_couplers_to_xbar_WREADY),
        .s_axi_wstrb(s00_couplers_to_xbar_WSTRB),
        .s_axi_wvalid(s00_couplers_to_xbar_WVALID));
endmodule

module design_1_axi_interconnect_0_1
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_aruser,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awuser,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wid,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wuser,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_aruser,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awuser,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_buser,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_ruser,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wuser,
    S00_AXI_wvalid,
    S01_ACLK,
    S01_ARESETN,
    S01_AXI_araddr,
    S01_AXI_arburst,
    S01_AXI_arcache,
    S01_AXI_arlen,
    S01_AXI_arlock,
    S01_AXI_arprot,
    S01_AXI_arqos,
    S01_AXI_arready,
    S01_AXI_arregion,
    S01_AXI_arsize,
    S01_AXI_arvalid,
    S01_AXI_awaddr,
    S01_AXI_awburst,
    S01_AXI_awcache,
    S01_AXI_awlen,
    S01_AXI_awlock,
    S01_AXI_awprot,
    S01_AXI_awqos,
    S01_AXI_awready,
    S01_AXI_awregion,
    S01_AXI_awsize,
    S01_AXI_awvalid,
    S01_AXI_bready,
    S01_AXI_bresp,
    S01_AXI_bvalid,
    S01_AXI_rdata,
    S01_AXI_rlast,
    S01_AXI_rready,
    S01_AXI_rresp,
    S01_AXI_rvalid,
    S01_AXI_wdata,
    S01_AXI_wlast,
    S01_AXI_wready,
    S01_AXI_wstrb,
    S01_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [2:0]M00_AXI_arid;
  output [3:0]M00_AXI_arlen;
  output [1:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output [0:0]M00_AXI_aruser;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [2:0]M00_AXI_awid;
  output [3:0]M00_AXI_awlen;
  output [1:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output [0:0]M00_AXI_awuser;
  output M00_AXI_awvalid;
  input [5:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [5:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output [2:0]M00_AXI_wid;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wuser;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [1:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input [0:0]S00_AXI_aruser;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [1:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input [0:0]S00_AXI_awuser;
  input S00_AXI_awvalid;
  output [1:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output [0:0]S00_AXI_buser;
  output S00_AXI_bvalid;
  output [63:0]S00_AXI_rdata;
  output [1:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_ruser;
  output S00_AXI_rvalid;
  input [63:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [7:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wuser;
  input S00_AXI_wvalid;
  input S01_ACLK;
  input S01_ARESETN;
  input [31:0]S01_AXI_araddr;
  input [1:0]S01_AXI_arburst;
  input [3:0]S01_AXI_arcache;
  input [7:0]S01_AXI_arlen;
  input [1:0]S01_AXI_arlock;
  input [2:0]S01_AXI_arprot;
  input [3:0]S01_AXI_arqos;
  output S01_AXI_arready;
  input [3:0]S01_AXI_arregion;
  input [2:0]S01_AXI_arsize;
  input S01_AXI_arvalid;
  input [31:0]S01_AXI_awaddr;
  input [1:0]S01_AXI_awburst;
  input [3:0]S01_AXI_awcache;
  input [7:0]S01_AXI_awlen;
  input [1:0]S01_AXI_awlock;
  input [2:0]S01_AXI_awprot;
  input [3:0]S01_AXI_awqos;
  output S01_AXI_awready;
  input [3:0]S01_AXI_awregion;
  input [2:0]S01_AXI_awsize;
  input S01_AXI_awvalid;
  input S01_AXI_bready;
  output [1:0]S01_AXI_bresp;
  output S01_AXI_bvalid;
  output [31:0]S01_AXI_rdata;
  output S01_AXI_rlast;
  input S01_AXI_rready;
  output [1:0]S01_AXI_rresp;
  output S01_AXI_rvalid;
  input [31:0]S01_AXI_wdata;
  input S01_AXI_wlast;
  output S01_AXI_wready;
  input [3:0]S01_AXI_wstrb;
  input S01_AXI_wvalid;

  wire axi_interconnect_1_ACLK_net;
  (* MARK_DEBUG *) wire axi_interconnect_1_ARESETN_net;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_1_to_s00_couplers_ARADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_ARBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s00_couplers_ARCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_ARID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_1_to_s00_couplers_ARLEN;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s00_couplers_ARPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s00_couplers_ARQOS;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_ARREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s00_couplers_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_1_to_s00_couplers_ARUSER;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_ARVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_1_to_s00_couplers_AWADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_AWBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s00_couplers_AWCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_AWID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_1_to_s00_couplers_AWLEN;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s00_couplers_AWPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s00_couplers_AWQOS;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_AWREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s00_couplers_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_1_to_s00_couplers_AWUSER;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_AWVALID;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_BID;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_BREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_BRESP;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_1_to_s00_couplers_BUSER;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_BVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_1_to_s00_couplers_RDATA;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_RID;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_RLAST;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_RREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s00_couplers_RRESP;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_1_to_s00_couplers_RUSER;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_RVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_1_to_s00_couplers_WDATA;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_WLAST;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_WREADY;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_1_to_s00_couplers_WSTRB;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_1_to_s00_couplers_WUSER;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s00_couplers_WVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_1_to_s01_couplers_ARADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s01_couplers_ARBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_ARCACHE;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_1_to_s01_couplers_ARLEN;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s01_couplers_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s01_couplers_ARPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_ARQOS;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_ARREADY;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_ARREGION;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s01_couplers_ARSIZE;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_ARVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_1_to_s01_couplers_AWADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s01_couplers_AWBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_AWCACHE;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_1_to_s01_couplers_AWLEN;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s01_couplers_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s01_couplers_AWPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_AWQOS;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_AWREADY;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_AWREGION;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_1_to_s01_couplers_AWSIZE;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_AWVALID;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_BREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s01_couplers_BRESP;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_BVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_1_to_s01_couplers_RDATA;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_RLAST;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_RREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_1_to_s01_couplers_RRESP;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_RVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_1_to_s01_couplers_WDATA;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_WLAST;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_WREADY;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_1_to_s01_couplers_WSTRB;
  (* MARK_DEBUG *) wire axi_interconnect_1_to_s01_couplers_WVALID;
  (* MARK_DEBUG *) wire [31:0]m00_couplers_to_axi_interconnect_1_ARADDR;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_1_ARBURST;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_1_ARCACHE;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_ARID;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_1_ARLEN;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_1_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_ARPROT;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_1_ARQOS;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_ARREADY;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]m00_couplers_to_axi_interconnect_1_ARUSER;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_ARVALID;
  (* MARK_DEBUG *) wire [31:0]m00_couplers_to_axi_interconnect_1_AWADDR;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_1_AWBURST;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_1_AWCACHE;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_AWID;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_1_AWLEN;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_1_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_AWPROT;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_1_AWQOS;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_AWREADY;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]m00_couplers_to_axi_interconnect_1_AWUSER;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_AWVALID;
  (* MARK_DEBUG *) wire [5:0]m00_couplers_to_axi_interconnect_1_BID;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_BREADY;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_1_BRESP;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_BVALID;
  (* MARK_DEBUG *) wire [63:0]m00_couplers_to_axi_interconnect_1_RDATA;
  (* MARK_DEBUG *) wire [5:0]m00_couplers_to_axi_interconnect_1_RID;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_RLAST;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_RREADY;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_1_RRESP;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_RVALID;
  (* MARK_DEBUG *) wire [63:0]m00_couplers_to_axi_interconnect_1_WDATA;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_1_WID;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_WLAST;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_WREADY;
  (* MARK_DEBUG *) wire [7:0]m00_couplers_to_axi_interconnect_1_WSTRB;
  (* MARK_DEBUG *) wire [0:0]m00_couplers_to_axi_interconnect_1_WUSER;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_1_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [1:0]s00_couplers_to_xbar_ARBURST;
  wire [3:0]s00_couplers_to_xbar_ARCACHE;
  wire [1:0]s00_couplers_to_xbar_ARID;
  wire [7:0]s00_couplers_to_xbar_ARLEN;
  wire [0:0]s00_couplers_to_xbar_ARLOCK;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [3:0]s00_couplers_to_xbar_ARQOS;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire [2:0]s00_couplers_to_xbar_ARSIZE;
  wire [0:0]s00_couplers_to_xbar_ARUSER;
  wire s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [1:0]s00_couplers_to_xbar_AWBURST;
  wire [3:0]s00_couplers_to_xbar_AWCACHE;
  wire [1:0]s00_couplers_to_xbar_AWID;
  wire [7:0]s00_couplers_to_xbar_AWLEN;
  wire [0:0]s00_couplers_to_xbar_AWLOCK;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [3:0]s00_couplers_to_xbar_AWQOS;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire [2:0]s00_couplers_to_xbar_AWSIZE;
  wire [0:0]s00_couplers_to_xbar_AWUSER;
  wire s00_couplers_to_xbar_AWVALID;
  wire [2:0]s00_couplers_to_xbar_BID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BUSER;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [63:0]s00_couplers_to_xbar_RDATA;
  wire [2:0]s00_couplers_to_xbar_RID;
  wire [0:0]s00_couplers_to_xbar_RLAST;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RUSER;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [63:0]s00_couplers_to_xbar_WDATA;
  wire s00_couplers_to_xbar_WLAST;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [7:0]s00_couplers_to_xbar_WSTRB;
  wire [0:0]s00_couplers_to_xbar_WUSER;
  wire s00_couplers_to_xbar_WVALID;
  wire [31:0]s01_couplers_to_xbar_ARADDR;
  wire [1:0]s01_couplers_to_xbar_ARBURST;
  wire [3:0]s01_couplers_to_xbar_ARCACHE;
  wire [7:0]s01_couplers_to_xbar_ARLEN;
  wire [0:0]s01_couplers_to_xbar_ARLOCK;
  wire [2:0]s01_couplers_to_xbar_ARPROT;
  wire [3:0]s01_couplers_to_xbar_ARQOS;
  wire [1:1]s01_couplers_to_xbar_ARREADY;
  wire [2:0]s01_couplers_to_xbar_ARSIZE;
  wire s01_couplers_to_xbar_ARVALID;
  wire [31:0]s01_couplers_to_xbar_AWADDR;
  wire [1:0]s01_couplers_to_xbar_AWBURST;
  wire [3:0]s01_couplers_to_xbar_AWCACHE;
  wire [7:0]s01_couplers_to_xbar_AWLEN;
  wire [0:0]s01_couplers_to_xbar_AWLOCK;
  wire [2:0]s01_couplers_to_xbar_AWPROT;
  wire [3:0]s01_couplers_to_xbar_AWQOS;
  wire [1:1]s01_couplers_to_xbar_AWREADY;
  wire [2:0]s01_couplers_to_xbar_AWSIZE;
  wire s01_couplers_to_xbar_AWVALID;
  wire s01_couplers_to_xbar_BREADY;
  wire [3:2]s01_couplers_to_xbar_BRESP;
  wire [1:1]s01_couplers_to_xbar_BVALID;
  wire [127:64]s01_couplers_to_xbar_RDATA;
  wire [1:1]s01_couplers_to_xbar_RLAST;
  wire s01_couplers_to_xbar_RREADY;
  wire [3:2]s01_couplers_to_xbar_RRESP;
  wire [1:1]s01_couplers_to_xbar_RVALID;
  wire [63:0]s01_couplers_to_xbar_WDATA;
  wire s01_couplers_to_xbar_WLAST;
  wire [1:1]s01_couplers_to_xbar_WREADY;
  wire [7:0]s01_couplers_to_xbar_WSTRB;
  wire s01_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [1:0]xbar_to_m00_couplers_ARBURST;
  wire [3:0]xbar_to_m00_couplers_ARCACHE;
  wire [2:0]xbar_to_m00_couplers_ARID;
  wire [7:0]xbar_to_m00_couplers_ARLEN;
  wire [0:0]xbar_to_m00_couplers_ARLOCK;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire [3:0]xbar_to_m00_couplers_ARQOS;
  wire xbar_to_m00_couplers_ARREADY;
  wire [3:0]xbar_to_m00_couplers_ARREGION;
  wire [2:0]xbar_to_m00_couplers_ARSIZE;
  wire [0:0]xbar_to_m00_couplers_ARUSER;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [1:0]xbar_to_m00_couplers_AWBURST;
  wire [3:0]xbar_to_m00_couplers_AWCACHE;
  wire [2:0]xbar_to_m00_couplers_AWID;
  wire [7:0]xbar_to_m00_couplers_AWLEN;
  wire [0:0]xbar_to_m00_couplers_AWLOCK;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire [3:0]xbar_to_m00_couplers_AWQOS;
  wire xbar_to_m00_couplers_AWREADY;
  wire [3:0]xbar_to_m00_couplers_AWREGION;
  wire [2:0]xbar_to_m00_couplers_AWSIZE;
  wire [0:0]xbar_to_m00_couplers_AWUSER;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [2:0]xbar_to_m00_couplers_BID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [63:0]xbar_to_m00_couplers_RDATA;
  wire [2:0]xbar_to_m00_couplers_RID;
  wire xbar_to_m00_couplers_RLAST;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire [0:0]xbar_to_m00_couplers_RUSER;
  wire xbar_to_m00_couplers_RVALID;
  wire [63:0]xbar_to_m00_couplers_WDATA;
  wire [0:0]xbar_to_m00_couplers_WLAST;
  wire xbar_to_m00_couplers_WREADY;
  wire [7:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WUSER;
  wire [0:0]xbar_to_m00_couplers_WVALID;

  assign M00_AXI_araddr[31:0] = m00_couplers_to_axi_interconnect_1_ARADDR;
  assign M00_AXI_arburst[1:0] = m00_couplers_to_axi_interconnect_1_ARBURST;
  assign M00_AXI_arcache[3:0] = m00_couplers_to_axi_interconnect_1_ARCACHE;
  assign M00_AXI_arid[2:0] = m00_couplers_to_axi_interconnect_1_ARID;
  assign M00_AXI_arlen[3:0] = m00_couplers_to_axi_interconnect_1_ARLEN;
  assign M00_AXI_arlock[1:0] = m00_couplers_to_axi_interconnect_1_ARLOCK;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_interconnect_1_ARPROT;
  assign M00_AXI_arqos[3:0] = m00_couplers_to_axi_interconnect_1_ARQOS;
  assign M00_AXI_arsize[2:0] = m00_couplers_to_axi_interconnect_1_ARSIZE;
  assign M00_AXI_aruser[0] = m00_couplers_to_axi_interconnect_1_ARUSER;
  assign M00_AXI_arvalid = m00_couplers_to_axi_interconnect_1_ARVALID;
  assign M00_AXI_awaddr[31:0] = m00_couplers_to_axi_interconnect_1_AWADDR;
  assign M00_AXI_awburst[1:0] = m00_couplers_to_axi_interconnect_1_AWBURST;
  assign M00_AXI_awcache[3:0] = m00_couplers_to_axi_interconnect_1_AWCACHE;
  assign M00_AXI_awid[2:0] = m00_couplers_to_axi_interconnect_1_AWID;
  assign M00_AXI_awlen[3:0] = m00_couplers_to_axi_interconnect_1_AWLEN;
  assign M00_AXI_awlock[1:0] = m00_couplers_to_axi_interconnect_1_AWLOCK;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_interconnect_1_AWPROT;
  assign M00_AXI_awqos[3:0] = m00_couplers_to_axi_interconnect_1_AWQOS;
  assign M00_AXI_awsize[2:0] = m00_couplers_to_axi_interconnect_1_AWSIZE;
  assign M00_AXI_awuser[0] = m00_couplers_to_axi_interconnect_1_AWUSER;
  assign M00_AXI_awvalid = m00_couplers_to_axi_interconnect_1_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_axi_interconnect_1_BREADY;
  assign M00_AXI_rready = m00_couplers_to_axi_interconnect_1_RREADY;
  assign M00_AXI_wdata[63:0] = m00_couplers_to_axi_interconnect_1_WDATA;
  assign M00_AXI_wid[2:0] = m00_couplers_to_axi_interconnect_1_WID;
  assign M00_AXI_wlast = m00_couplers_to_axi_interconnect_1_WLAST;
  assign M00_AXI_wstrb[7:0] = m00_couplers_to_axi_interconnect_1_WSTRB;
  assign M00_AXI_wuser[0] = m00_couplers_to_axi_interconnect_1_WUSER;
  assign M00_AXI_wvalid = m00_couplers_to_axi_interconnect_1_WVALID;
  assign S00_AXI_arready = axi_interconnect_1_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_1_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[1:0] = axi_interconnect_1_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_interconnect_1_to_s00_couplers_BRESP;
  assign S00_AXI_buser[0] = axi_interconnect_1_to_s00_couplers_BUSER;
  assign S00_AXI_bvalid = axi_interconnect_1_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[63:0] = axi_interconnect_1_to_s00_couplers_RDATA;
  assign S00_AXI_rid[1:0] = axi_interconnect_1_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_interconnect_1_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_1_to_s00_couplers_RRESP;
  assign S00_AXI_ruser[0] = axi_interconnect_1_to_s00_couplers_RUSER;
  assign S00_AXI_rvalid = axi_interconnect_1_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_1_to_s00_couplers_WREADY;
  assign S01_AXI_arready = axi_interconnect_1_to_s01_couplers_ARREADY;
  assign S01_AXI_awready = axi_interconnect_1_to_s01_couplers_AWREADY;
  assign S01_AXI_bresp[1:0] = axi_interconnect_1_to_s01_couplers_BRESP;
  assign S01_AXI_bvalid = axi_interconnect_1_to_s01_couplers_BVALID;
  assign S01_AXI_rdata[31:0] = axi_interconnect_1_to_s01_couplers_RDATA;
  assign S01_AXI_rlast = axi_interconnect_1_to_s01_couplers_RLAST;
  assign S01_AXI_rresp[1:0] = axi_interconnect_1_to_s01_couplers_RRESP;
  assign S01_AXI_rvalid = axi_interconnect_1_to_s01_couplers_RVALID;
  assign S01_AXI_wready = axi_interconnect_1_to_s01_couplers_WREADY;
  assign axi_interconnect_1_ACLK_net = ACLK;
  assign axi_interconnect_1_ARESETN_net = ARESETN;
  assign axi_interconnect_1_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_interconnect_1_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_1_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_1_to_s00_couplers_ARID = S00_AXI_arid[1:0];
  assign axi_interconnect_1_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign axi_interconnect_1_to_s00_couplers_ARLOCK = S00_AXI_arlock;
  assign axi_interconnect_1_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_1_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_interconnect_1_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_1_to_s00_couplers_ARUSER = S00_AXI_aruser[0];
  assign axi_interconnect_1_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_1_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_interconnect_1_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_1_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_1_to_s00_couplers_AWID = S00_AXI_awid[1:0];
  assign axi_interconnect_1_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign axi_interconnect_1_to_s00_couplers_AWLOCK = S00_AXI_awlock;
  assign axi_interconnect_1_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_1_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_interconnect_1_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_1_to_s00_couplers_AWUSER = S00_AXI_awuser[0];
  assign axi_interconnect_1_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_1_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_1_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_1_to_s00_couplers_WDATA = S00_AXI_wdata[63:0];
  assign axi_interconnect_1_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_1_to_s00_couplers_WSTRB = S00_AXI_wstrb[7:0];
  assign axi_interconnect_1_to_s00_couplers_WUSER = S00_AXI_wuser[0];
  assign axi_interconnect_1_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign axi_interconnect_1_to_s01_couplers_ARADDR = S01_AXI_araddr[31:0];
  assign axi_interconnect_1_to_s01_couplers_ARBURST = S01_AXI_arburst[1:0];
  assign axi_interconnect_1_to_s01_couplers_ARCACHE = S01_AXI_arcache[3:0];
  assign axi_interconnect_1_to_s01_couplers_ARLEN = S01_AXI_arlen[7:0];
  assign axi_interconnect_1_to_s01_couplers_ARLOCK = S01_AXI_arlock[1:0];
  assign axi_interconnect_1_to_s01_couplers_ARPROT = S01_AXI_arprot[2:0];
  assign axi_interconnect_1_to_s01_couplers_ARQOS = S01_AXI_arqos[3:0];
  assign axi_interconnect_1_to_s01_couplers_ARREGION = S01_AXI_arregion[3:0];
  assign axi_interconnect_1_to_s01_couplers_ARSIZE = S01_AXI_arsize[2:0];
  assign axi_interconnect_1_to_s01_couplers_ARVALID = S01_AXI_arvalid;
  assign axi_interconnect_1_to_s01_couplers_AWADDR = S01_AXI_awaddr[31:0];
  assign axi_interconnect_1_to_s01_couplers_AWBURST = S01_AXI_awburst[1:0];
  assign axi_interconnect_1_to_s01_couplers_AWCACHE = S01_AXI_awcache[3:0];
  assign axi_interconnect_1_to_s01_couplers_AWLEN = S01_AXI_awlen[7:0];
  assign axi_interconnect_1_to_s01_couplers_AWLOCK = S01_AXI_awlock[1:0];
  assign axi_interconnect_1_to_s01_couplers_AWPROT = S01_AXI_awprot[2:0];
  assign axi_interconnect_1_to_s01_couplers_AWQOS = S01_AXI_awqos[3:0];
  assign axi_interconnect_1_to_s01_couplers_AWREGION = S01_AXI_awregion[3:0];
  assign axi_interconnect_1_to_s01_couplers_AWSIZE = S01_AXI_awsize[2:0];
  assign axi_interconnect_1_to_s01_couplers_AWVALID = S01_AXI_awvalid;
  assign axi_interconnect_1_to_s01_couplers_BREADY = S01_AXI_bready;
  assign axi_interconnect_1_to_s01_couplers_RREADY = S01_AXI_rready;
  assign axi_interconnect_1_to_s01_couplers_WDATA = S01_AXI_wdata[31:0];
  assign axi_interconnect_1_to_s01_couplers_WLAST = S01_AXI_wlast;
  assign axi_interconnect_1_to_s01_couplers_WSTRB = S01_AXI_wstrb[3:0];
  assign axi_interconnect_1_to_s01_couplers_WVALID = S01_AXI_wvalid;
  assign m00_couplers_to_axi_interconnect_1_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_axi_interconnect_1_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_axi_interconnect_1_BID = M00_AXI_bid[5:0];
  assign m00_couplers_to_axi_interconnect_1_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_interconnect_1_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_axi_interconnect_1_RDATA = M00_AXI_rdata[63:0];
  assign m00_couplers_to_axi_interconnect_1_RID = M00_AXI_rid[5:0];
  assign m00_couplers_to_axi_interconnect_1_RLAST = M00_AXI_rlast;
  assign m00_couplers_to_axi_interconnect_1_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_interconnect_1_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_axi_interconnect_1_WREADY = M00_AXI_wready;
  m00_couplers_imp_1FDLJBY m00_couplers
       (.M_ACLK(axi_interconnect_1_ACLK_net),
        .M_ARESETN(axi_interconnect_1_ARESETN_net),
        .M_AXI_araddr(m00_couplers_to_axi_interconnect_1_ARADDR),
        .M_AXI_arburst(m00_couplers_to_axi_interconnect_1_ARBURST),
        .M_AXI_arcache(m00_couplers_to_axi_interconnect_1_ARCACHE),
        .M_AXI_arid(m00_couplers_to_axi_interconnect_1_ARID),
        .M_AXI_arlen(m00_couplers_to_axi_interconnect_1_ARLEN),
        .M_AXI_arlock(m00_couplers_to_axi_interconnect_1_ARLOCK),
        .M_AXI_arprot(m00_couplers_to_axi_interconnect_1_ARPROT),
        .M_AXI_arqos(m00_couplers_to_axi_interconnect_1_ARQOS),
        .M_AXI_arready(m00_couplers_to_axi_interconnect_1_ARREADY),
        .M_AXI_arsize(m00_couplers_to_axi_interconnect_1_ARSIZE),
        .M_AXI_aruser(m00_couplers_to_axi_interconnect_1_ARUSER),
        .M_AXI_arvalid(m00_couplers_to_axi_interconnect_1_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_interconnect_1_AWADDR),
        .M_AXI_awburst(m00_couplers_to_axi_interconnect_1_AWBURST),
        .M_AXI_awcache(m00_couplers_to_axi_interconnect_1_AWCACHE),
        .M_AXI_awid(m00_couplers_to_axi_interconnect_1_AWID),
        .M_AXI_awlen(m00_couplers_to_axi_interconnect_1_AWLEN),
        .M_AXI_awlock(m00_couplers_to_axi_interconnect_1_AWLOCK),
        .M_AXI_awprot(m00_couplers_to_axi_interconnect_1_AWPROT),
        .M_AXI_awqos(m00_couplers_to_axi_interconnect_1_AWQOS),
        .M_AXI_awready(m00_couplers_to_axi_interconnect_1_AWREADY),
        .M_AXI_awsize(m00_couplers_to_axi_interconnect_1_AWSIZE),
        .M_AXI_awuser(m00_couplers_to_axi_interconnect_1_AWUSER),
        .M_AXI_awvalid(m00_couplers_to_axi_interconnect_1_AWVALID),
        .M_AXI_bid(m00_couplers_to_axi_interconnect_1_BID),
        .M_AXI_bready(m00_couplers_to_axi_interconnect_1_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_interconnect_1_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_interconnect_1_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_interconnect_1_RDATA),
        .M_AXI_rid(m00_couplers_to_axi_interconnect_1_RID),
        .M_AXI_rlast(m00_couplers_to_axi_interconnect_1_RLAST),
        .M_AXI_rready(m00_couplers_to_axi_interconnect_1_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_interconnect_1_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_interconnect_1_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_interconnect_1_WDATA),
        .M_AXI_wid(m00_couplers_to_axi_interconnect_1_WID),
        .M_AXI_wlast(m00_couplers_to_axi_interconnect_1_WLAST),
        .M_AXI_wready(m00_couplers_to_axi_interconnect_1_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_interconnect_1_WSTRB),
        .M_AXI_wuser(m00_couplers_to_axi_interconnect_1_WUSER),
        .M_AXI_wvalid(m00_couplers_to_axi_interconnect_1_WVALID),
        .S_ACLK(axi_interconnect_1_ACLK_net),
        .S_ARESETN(axi_interconnect_1_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arburst(xbar_to_m00_couplers_ARBURST),
        .S_AXI_arcache(xbar_to_m00_couplers_ARCACHE),
        .S_AXI_arid(xbar_to_m00_couplers_ARID),
        .S_AXI_arlen(xbar_to_m00_couplers_ARLEN),
        .S_AXI_arlock(xbar_to_m00_couplers_ARLOCK),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arqos(xbar_to_m00_couplers_ARQOS),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arregion(xbar_to_m00_couplers_ARREGION),
        .S_AXI_arsize(xbar_to_m00_couplers_ARSIZE),
        .S_AXI_aruser(xbar_to_m00_couplers_ARUSER),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awburst(xbar_to_m00_couplers_AWBURST),
        .S_AXI_awcache(xbar_to_m00_couplers_AWCACHE),
        .S_AXI_awid(xbar_to_m00_couplers_AWID),
        .S_AXI_awlen(xbar_to_m00_couplers_AWLEN),
        .S_AXI_awlock(xbar_to_m00_couplers_AWLOCK),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awqos(xbar_to_m00_couplers_AWQOS),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awregion(xbar_to_m00_couplers_AWREGION),
        .S_AXI_awsize(xbar_to_m00_couplers_AWSIZE),
        .S_AXI_awuser(xbar_to_m00_couplers_AWUSER),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bid(xbar_to_m00_couplers_BID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rid(xbar_to_m00_couplers_RID),
        .S_AXI_rlast(xbar_to_m00_couplers_RLAST),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_ruser(xbar_to_m00_couplers_RUSER),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wlast(xbar_to_m00_couplers_WLAST),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wuser(xbar_to_m00_couplers_WUSER),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
  design_1_m00_pchk_0 m00_pchk
       (.aclk(axi_interconnect_1_ACLK_net),
        .aresetn(axi_interconnect_1_ARESETN_net),
        .pc_axi_araddr(m00_couplers_to_axi_interconnect_1_ARADDR),
        .pc_axi_arburst(m00_couplers_to_axi_interconnect_1_ARBURST),
        .pc_axi_arcache(m00_couplers_to_axi_interconnect_1_ARCACHE),
        .pc_axi_arid(m00_couplers_to_axi_interconnect_1_ARID),
        .pc_axi_arlen(m00_couplers_to_axi_interconnect_1_ARLEN),
        .pc_axi_arlock(m00_couplers_to_axi_interconnect_1_ARLOCK),
        .pc_axi_arprot(m00_couplers_to_axi_interconnect_1_ARPROT),
        .pc_axi_arqos(m00_couplers_to_axi_interconnect_1_ARQOS),
        .pc_axi_arready(m00_couplers_to_axi_interconnect_1_ARREADY),
        .pc_axi_arsize(m00_couplers_to_axi_interconnect_1_ARSIZE),
        .pc_axi_aruser(m00_couplers_to_axi_interconnect_1_ARUSER),
        .pc_axi_arvalid(m00_couplers_to_axi_interconnect_1_ARVALID),
        .pc_axi_awaddr(m00_couplers_to_axi_interconnect_1_AWADDR),
        .pc_axi_awburst(m00_couplers_to_axi_interconnect_1_AWBURST),
        .pc_axi_awcache(m00_couplers_to_axi_interconnect_1_AWCACHE),
        .pc_axi_awid(m00_couplers_to_axi_interconnect_1_AWID),
        .pc_axi_awlen(m00_couplers_to_axi_interconnect_1_AWLEN),
        .pc_axi_awlock(m00_couplers_to_axi_interconnect_1_AWLOCK),
        .pc_axi_awprot(m00_couplers_to_axi_interconnect_1_AWPROT),
        .pc_axi_awqos(m00_couplers_to_axi_interconnect_1_AWQOS),
        .pc_axi_awready(m00_couplers_to_axi_interconnect_1_AWREADY),
        .pc_axi_awsize(m00_couplers_to_axi_interconnect_1_AWSIZE),
        .pc_axi_awuser(m00_couplers_to_axi_interconnect_1_AWUSER),
        .pc_axi_awvalid(m00_couplers_to_axi_interconnect_1_AWVALID),
        .pc_axi_bid(m00_couplers_to_axi_interconnect_1_BID[2:0]),
        .pc_axi_bready(m00_couplers_to_axi_interconnect_1_BREADY),
        .pc_axi_bresp(m00_couplers_to_axi_interconnect_1_BRESP),
        .pc_axi_bvalid(m00_couplers_to_axi_interconnect_1_BVALID),
        .pc_axi_rdata(m00_couplers_to_axi_interconnect_1_RDATA),
        .pc_axi_rid(m00_couplers_to_axi_interconnect_1_RID[2:0]),
        .pc_axi_rlast(m00_couplers_to_axi_interconnect_1_RLAST),
        .pc_axi_rready(m00_couplers_to_axi_interconnect_1_RREADY),
        .pc_axi_rresp(m00_couplers_to_axi_interconnect_1_RRESP),
        .pc_axi_ruser(1'b0),
        .pc_axi_rvalid(m00_couplers_to_axi_interconnect_1_RVALID),
        .pc_axi_wdata(m00_couplers_to_axi_interconnect_1_WDATA),
        .pc_axi_wid(m00_couplers_to_axi_interconnect_1_WID),
        .pc_axi_wlast(m00_couplers_to_axi_interconnect_1_WLAST),
        .pc_axi_wready(m00_couplers_to_axi_interconnect_1_WREADY),
        .pc_axi_wstrb(m00_couplers_to_axi_interconnect_1_WSTRB),
        .pc_axi_wuser(m00_couplers_to_axi_interconnect_1_WUSER),
        .pc_axi_wvalid(m00_couplers_to_axi_interconnect_1_WVALID));
  s00_couplers_imp_HS4N6K s00_couplers
       (.M_ACLK(axi_interconnect_1_ACLK_net),
        .M_ARESETN(axi_interconnect_1_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s00_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s00_couplers_to_xbar_ARCACHE),
        .M_AXI_arid(s00_couplers_to_xbar_ARID),
        .M_AXI_arlen(s00_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s00_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s00_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s00_couplers_to_xbar_ARSIZE),
        .M_AXI_aruser(s00_couplers_to_xbar_ARUSER),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s00_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s00_couplers_to_xbar_AWCACHE),
        .M_AXI_awid(s00_couplers_to_xbar_AWID),
        .M_AXI_awlen(s00_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s00_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s00_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s00_couplers_to_xbar_AWSIZE),
        .M_AXI_awuser(s00_couplers_to_xbar_AWUSER),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bid(s00_couplers_to_xbar_BID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_buser(s00_couplers_to_xbar_BUSER),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rid(s00_couplers_to_xbar_RID),
        .M_AXI_rlast(s00_couplers_to_xbar_RLAST),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_ruser(s00_couplers_to_xbar_RUSER),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s00_couplers_to_xbar_WLAST),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wuser(s00_couplers_to_xbar_WUSER),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(axi_interconnect_1_ACLK_net),
        .S_ARESETN(axi_interconnect_1_ARESETN_net),
        .S_AXI_araddr(axi_interconnect_1_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_1_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_1_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_interconnect_1_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_interconnect_1_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_1_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_1_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_1_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_1_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_1_to_s00_couplers_ARSIZE),
        .S_AXI_aruser(axi_interconnect_1_to_s00_couplers_ARUSER),
        .S_AXI_arvalid(axi_interconnect_1_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_1_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_1_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_1_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_interconnect_1_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_interconnect_1_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_1_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_1_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_1_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_1_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_1_to_s00_couplers_AWSIZE),
        .S_AXI_awuser(axi_interconnect_1_to_s00_couplers_AWUSER),
        .S_AXI_awvalid(axi_interconnect_1_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_interconnect_1_to_s00_couplers_BID),
        .S_AXI_bready(axi_interconnect_1_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_1_to_s00_couplers_BRESP),
        .S_AXI_buser(axi_interconnect_1_to_s00_couplers_BUSER),
        .S_AXI_bvalid(axi_interconnect_1_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_1_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_interconnect_1_to_s00_couplers_RID),
        .S_AXI_rlast(axi_interconnect_1_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_1_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_1_to_s00_couplers_RRESP),
        .S_AXI_ruser(axi_interconnect_1_to_s00_couplers_RUSER),
        .S_AXI_rvalid(axi_interconnect_1_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_1_to_s00_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_1_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_1_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_1_to_s00_couplers_WSTRB),
        .S_AXI_wuser(axi_interconnect_1_to_s00_couplers_WUSER),
        .S_AXI_wvalid(axi_interconnect_1_to_s00_couplers_WVALID));
  design_1_s00_pchk_0 s00_pchk
       (.aclk(axi_interconnect_1_ACLK_net),
        .aresetn(axi_interconnect_1_ARESETN_net),
        .pc_axi_araddr(axi_interconnect_1_to_s00_couplers_ARADDR),
        .pc_axi_arburst(axi_interconnect_1_to_s00_couplers_ARBURST),
        .pc_axi_arcache(axi_interconnect_1_to_s00_couplers_ARCACHE),
        .pc_axi_arid(axi_interconnect_1_to_s00_couplers_ARID),
        .pc_axi_arlen(axi_interconnect_1_to_s00_couplers_ARLEN),
        .pc_axi_arlock(axi_interconnect_1_to_s00_couplers_ARLOCK),
        .pc_axi_arprot(axi_interconnect_1_to_s00_couplers_ARPROT),
        .pc_axi_arqos(axi_interconnect_1_to_s00_couplers_ARQOS),
        .pc_axi_arready(axi_interconnect_1_to_s00_couplers_ARREADY),
        .pc_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_arsize(axi_interconnect_1_to_s00_couplers_ARSIZE),
        .pc_axi_aruser(axi_interconnect_1_to_s00_couplers_ARUSER),
        .pc_axi_arvalid(axi_interconnect_1_to_s00_couplers_ARVALID),
        .pc_axi_awaddr(axi_interconnect_1_to_s00_couplers_AWADDR),
        .pc_axi_awburst(axi_interconnect_1_to_s00_couplers_AWBURST),
        .pc_axi_awcache(axi_interconnect_1_to_s00_couplers_AWCACHE),
        .pc_axi_awid(axi_interconnect_1_to_s00_couplers_AWID),
        .pc_axi_awlen(axi_interconnect_1_to_s00_couplers_AWLEN),
        .pc_axi_awlock(axi_interconnect_1_to_s00_couplers_AWLOCK),
        .pc_axi_awprot(axi_interconnect_1_to_s00_couplers_AWPROT),
        .pc_axi_awqos(axi_interconnect_1_to_s00_couplers_AWQOS),
        .pc_axi_awready(axi_interconnect_1_to_s00_couplers_AWREADY),
        .pc_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_awsize(axi_interconnect_1_to_s00_couplers_AWSIZE),
        .pc_axi_awuser(axi_interconnect_1_to_s00_couplers_AWUSER),
        .pc_axi_awvalid(axi_interconnect_1_to_s00_couplers_AWVALID),
        .pc_axi_bid(axi_interconnect_1_to_s00_couplers_BID),
        .pc_axi_bready(axi_interconnect_1_to_s00_couplers_BREADY),
        .pc_axi_bresp(axi_interconnect_1_to_s00_couplers_BRESP),
        .pc_axi_buser(axi_interconnect_1_to_s00_couplers_BUSER),
        .pc_axi_bvalid(axi_interconnect_1_to_s00_couplers_BVALID),
        .pc_axi_rdata(axi_interconnect_1_to_s00_couplers_RDATA),
        .pc_axi_rid(axi_interconnect_1_to_s00_couplers_RID),
        .pc_axi_rlast(axi_interconnect_1_to_s00_couplers_RLAST),
        .pc_axi_rready(axi_interconnect_1_to_s00_couplers_RREADY),
        .pc_axi_rresp(axi_interconnect_1_to_s00_couplers_RRESP),
        .pc_axi_ruser(axi_interconnect_1_to_s00_couplers_RUSER),
        .pc_axi_rvalid(axi_interconnect_1_to_s00_couplers_RVALID),
        .pc_axi_wdata(axi_interconnect_1_to_s00_couplers_WDATA),
        .pc_axi_wlast(axi_interconnect_1_to_s00_couplers_WLAST),
        .pc_axi_wready(axi_interconnect_1_to_s00_couplers_WREADY),
        .pc_axi_wstrb(axi_interconnect_1_to_s00_couplers_WSTRB),
        .pc_axi_wuser(axi_interconnect_1_to_s00_couplers_WUSER),
        .pc_axi_wvalid(axi_interconnect_1_to_s00_couplers_WVALID));
  s01_couplers_imp_1CMTC59 s01_couplers
       (.M_ACLK(axi_interconnect_1_ACLK_net),
        .M_ARESETN(axi_interconnect_1_ARESETN_net),
        .M_AXI_araddr(s01_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s01_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s01_couplers_to_xbar_ARCACHE),
        .M_AXI_arlen(s01_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s01_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s01_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s01_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s01_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s01_couplers_to_xbar_ARSIZE),
        .M_AXI_arvalid(s01_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s01_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s01_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s01_couplers_to_xbar_AWCACHE),
        .M_AXI_awlen(s01_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s01_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s01_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s01_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s01_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s01_couplers_to_xbar_AWSIZE),
        .M_AXI_awvalid(s01_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s01_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s01_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s01_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s01_couplers_to_xbar_RDATA),
        .M_AXI_rlast(s01_couplers_to_xbar_RLAST),
        .M_AXI_rready(s01_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s01_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s01_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s01_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s01_couplers_to_xbar_WLAST),
        .M_AXI_wready(s01_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s01_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s01_couplers_to_xbar_WVALID),
        .S_ACLK(axi_interconnect_1_ACLK_net),
        .S_ARESETN(axi_interconnect_1_ARESETN_net),
        .S_AXI_araddr(axi_interconnect_1_to_s01_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_1_to_s01_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_1_to_s01_couplers_ARCACHE),
        .S_AXI_arlen(axi_interconnect_1_to_s01_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_1_to_s01_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_1_to_s01_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_1_to_s01_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_1_to_s01_couplers_ARREADY),
        .S_AXI_arregion(axi_interconnect_1_to_s01_couplers_ARREGION),
        .S_AXI_arsize(axi_interconnect_1_to_s01_couplers_ARSIZE),
        .S_AXI_arvalid(axi_interconnect_1_to_s01_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_1_to_s01_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_1_to_s01_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_1_to_s01_couplers_AWCACHE),
        .S_AXI_awlen(axi_interconnect_1_to_s01_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_1_to_s01_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_1_to_s01_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_1_to_s01_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_1_to_s01_couplers_AWREADY),
        .S_AXI_awregion(axi_interconnect_1_to_s01_couplers_AWREGION),
        .S_AXI_awsize(axi_interconnect_1_to_s01_couplers_AWSIZE),
        .S_AXI_awvalid(axi_interconnect_1_to_s01_couplers_AWVALID),
        .S_AXI_bready(axi_interconnect_1_to_s01_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_1_to_s01_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_1_to_s01_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_1_to_s01_couplers_RDATA),
        .S_AXI_rlast(axi_interconnect_1_to_s01_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_1_to_s01_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_1_to_s01_couplers_RRESP),
        .S_AXI_rvalid(axi_interconnect_1_to_s01_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_1_to_s01_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_1_to_s01_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_1_to_s01_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_1_to_s01_couplers_WSTRB),
        .S_AXI_wvalid(axi_interconnect_1_to_s01_couplers_WVALID));
  design_1_s01_pchk_0 s01_pchk
       (.aclk(axi_interconnect_1_ACLK_net),
        .aresetn(axi_interconnect_1_ARESETN_net),
        .pc_axi_araddr(axi_interconnect_1_to_s01_couplers_ARADDR),
        .pc_axi_arburst(axi_interconnect_1_to_s01_couplers_ARBURST),
        .pc_axi_arcache(axi_interconnect_1_to_s01_couplers_ARCACHE),
        .pc_axi_arlen(axi_interconnect_1_to_s01_couplers_ARLEN),
        .pc_axi_arlock(axi_interconnect_1_to_s01_couplers_ARLOCK[0]),
        .pc_axi_arprot(axi_interconnect_1_to_s01_couplers_ARPROT),
        .pc_axi_arqos(axi_interconnect_1_to_s01_couplers_ARQOS),
        .pc_axi_arready(axi_interconnect_1_to_s01_couplers_ARREADY),
        .pc_axi_arregion(axi_interconnect_1_to_s01_couplers_ARREGION),
        .pc_axi_arsize(axi_interconnect_1_to_s01_couplers_ARSIZE),
        .pc_axi_arvalid(axi_interconnect_1_to_s01_couplers_ARVALID),
        .pc_axi_awaddr(axi_interconnect_1_to_s01_couplers_AWADDR),
        .pc_axi_awburst(axi_interconnect_1_to_s01_couplers_AWBURST),
        .pc_axi_awcache(axi_interconnect_1_to_s01_couplers_AWCACHE),
        .pc_axi_awlen(axi_interconnect_1_to_s01_couplers_AWLEN),
        .pc_axi_awlock(axi_interconnect_1_to_s01_couplers_AWLOCK[0]),
        .pc_axi_awprot(axi_interconnect_1_to_s01_couplers_AWPROT),
        .pc_axi_awqos(axi_interconnect_1_to_s01_couplers_AWQOS),
        .pc_axi_awready(axi_interconnect_1_to_s01_couplers_AWREADY),
        .pc_axi_awregion(axi_interconnect_1_to_s01_couplers_AWREGION),
        .pc_axi_awsize(axi_interconnect_1_to_s01_couplers_AWSIZE),
        .pc_axi_awvalid(axi_interconnect_1_to_s01_couplers_AWVALID),
        .pc_axi_bready(axi_interconnect_1_to_s01_couplers_BREADY),
        .pc_axi_bresp(axi_interconnect_1_to_s01_couplers_BRESP),
        .pc_axi_bvalid(axi_interconnect_1_to_s01_couplers_BVALID),
        .pc_axi_rdata(axi_interconnect_1_to_s01_couplers_RDATA),
        .pc_axi_rlast(axi_interconnect_1_to_s01_couplers_RLAST),
        .pc_axi_rready(axi_interconnect_1_to_s01_couplers_RREADY),
        .pc_axi_rresp(axi_interconnect_1_to_s01_couplers_RRESP),
        .pc_axi_rvalid(axi_interconnect_1_to_s01_couplers_RVALID),
        .pc_axi_wdata(axi_interconnect_1_to_s01_couplers_WDATA),
        .pc_axi_wlast(axi_interconnect_1_to_s01_couplers_WLAST),
        .pc_axi_wready(axi_interconnect_1_to_s01_couplers_WREADY),
        .pc_axi_wstrb(axi_interconnect_1_to_s01_couplers_WSTRB),
        .pc_axi_wvalid(axi_interconnect_1_to_s01_couplers_WVALID));
  design_1_xbar_1 xbar
       (.aclk(axi_interconnect_1_ACLK_net),
        .aresetn(axi_interconnect_1_ARESETN_net),
        .m_axi_araddr(xbar_to_m00_couplers_ARADDR),
        .m_axi_arburst(xbar_to_m00_couplers_ARBURST),
        .m_axi_arcache(xbar_to_m00_couplers_ARCACHE),
        .m_axi_arid(xbar_to_m00_couplers_ARID),
        .m_axi_arlen(xbar_to_m00_couplers_ARLEN),
        .m_axi_arlock(xbar_to_m00_couplers_ARLOCK),
        .m_axi_arprot(xbar_to_m00_couplers_ARPROT),
        .m_axi_arqos(xbar_to_m00_couplers_ARQOS),
        .m_axi_arready(xbar_to_m00_couplers_ARREADY),
        .m_axi_arregion(xbar_to_m00_couplers_ARREGION),
        .m_axi_arsize(xbar_to_m00_couplers_ARSIZE),
        .m_axi_aruser(xbar_to_m00_couplers_ARUSER),
        .m_axi_arvalid(xbar_to_m00_couplers_ARVALID),
        .m_axi_awaddr(xbar_to_m00_couplers_AWADDR),
        .m_axi_awburst(xbar_to_m00_couplers_AWBURST),
        .m_axi_awcache(xbar_to_m00_couplers_AWCACHE),
        .m_axi_awid(xbar_to_m00_couplers_AWID),
        .m_axi_awlen(xbar_to_m00_couplers_AWLEN),
        .m_axi_awlock(xbar_to_m00_couplers_AWLOCK),
        .m_axi_awprot(xbar_to_m00_couplers_AWPROT),
        .m_axi_awqos(xbar_to_m00_couplers_AWQOS),
        .m_axi_awready(xbar_to_m00_couplers_AWREADY),
        .m_axi_awregion(xbar_to_m00_couplers_AWREGION),
        .m_axi_awsize(xbar_to_m00_couplers_AWSIZE),
        .m_axi_awuser(xbar_to_m00_couplers_AWUSER),
        .m_axi_awvalid(xbar_to_m00_couplers_AWVALID),
        .m_axi_bid(xbar_to_m00_couplers_BID),
        .m_axi_bready(xbar_to_m00_couplers_BREADY),
        .m_axi_bresp(xbar_to_m00_couplers_BRESP),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(xbar_to_m00_couplers_BVALID),
        .m_axi_rdata(xbar_to_m00_couplers_RDATA),
        .m_axi_rid(xbar_to_m00_couplers_RID),
        .m_axi_rlast(xbar_to_m00_couplers_RLAST),
        .m_axi_rready(xbar_to_m00_couplers_RREADY),
        .m_axi_rresp(xbar_to_m00_couplers_RRESP),
        .m_axi_ruser(xbar_to_m00_couplers_RUSER),
        .m_axi_rvalid(xbar_to_m00_couplers_RVALID),
        .m_axi_wdata(xbar_to_m00_couplers_WDATA),
        .m_axi_wlast(xbar_to_m00_couplers_WLAST),
        .m_axi_wready(xbar_to_m00_couplers_WREADY),
        .m_axi_wstrb(xbar_to_m00_couplers_WSTRB),
        .m_axi_wuser(xbar_to_m00_couplers_WUSER),
        .m_axi_wvalid(xbar_to_m00_couplers_WVALID),
        .s_axi_araddr({s01_couplers_to_xbar_ARADDR,s00_couplers_to_xbar_ARADDR}),
        .s_axi_arburst({s01_couplers_to_xbar_ARBURST,s00_couplers_to_xbar_ARBURST}),
        .s_axi_arcache({s01_couplers_to_xbar_ARCACHE,s00_couplers_to_xbar_ARCACHE}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0,s00_couplers_to_xbar_ARID}),
        .s_axi_arlen({s01_couplers_to_xbar_ARLEN,s00_couplers_to_xbar_ARLEN}),
        .s_axi_arlock({s01_couplers_to_xbar_ARLOCK,s00_couplers_to_xbar_ARLOCK}),
        .s_axi_arprot({s01_couplers_to_xbar_ARPROT,s00_couplers_to_xbar_ARPROT}),
        .s_axi_arqos({s01_couplers_to_xbar_ARQOS,s00_couplers_to_xbar_ARQOS}),
        .s_axi_arready({s01_couplers_to_xbar_ARREADY,s00_couplers_to_xbar_ARREADY}),
        .s_axi_arsize({s01_couplers_to_xbar_ARSIZE,s00_couplers_to_xbar_ARSIZE}),
        .s_axi_aruser({1'b0,s00_couplers_to_xbar_ARUSER}),
        .s_axi_arvalid({s01_couplers_to_xbar_ARVALID,s00_couplers_to_xbar_ARVALID}),
        .s_axi_awaddr({s01_couplers_to_xbar_AWADDR,s00_couplers_to_xbar_AWADDR}),
        .s_axi_awburst({s01_couplers_to_xbar_AWBURST,s00_couplers_to_xbar_AWBURST}),
        .s_axi_awcache({s01_couplers_to_xbar_AWCACHE,s00_couplers_to_xbar_AWCACHE}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0,s00_couplers_to_xbar_AWID}),
        .s_axi_awlen({s01_couplers_to_xbar_AWLEN,s00_couplers_to_xbar_AWLEN}),
        .s_axi_awlock({s01_couplers_to_xbar_AWLOCK,s00_couplers_to_xbar_AWLOCK}),
        .s_axi_awprot({s01_couplers_to_xbar_AWPROT,s00_couplers_to_xbar_AWPROT}),
        .s_axi_awqos({s01_couplers_to_xbar_AWQOS,s00_couplers_to_xbar_AWQOS}),
        .s_axi_awready({s01_couplers_to_xbar_AWREADY,s00_couplers_to_xbar_AWREADY}),
        .s_axi_awsize({s01_couplers_to_xbar_AWSIZE,s00_couplers_to_xbar_AWSIZE}),
        .s_axi_awuser({1'b0,s00_couplers_to_xbar_AWUSER}),
        .s_axi_awvalid({s01_couplers_to_xbar_AWVALID,s00_couplers_to_xbar_AWVALID}),
        .s_axi_bid(s00_couplers_to_xbar_BID),
        .s_axi_bready({s01_couplers_to_xbar_BREADY,s00_couplers_to_xbar_BREADY}),
        .s_axi_bresp({s01_couplers_to_xbar_BRESP,s00_couplers_to_xbar_BRESP}),
        .s_axi_buser(s00_couplers_to_xbar_BUSER),
        .s_axi_bvalid({s01_couplers_to_xbar_BVALID,s00_couplers_to_xbar_BVALID}),
        .s_axi_rdata({s01_couplers_to_xbar_RDATA,s00_couplers_to_xbar_RDATA}),
        .s_axi_rid(s00_couplers_to_xbar_RID),
        .s_axi_rlast({s01_couplers_to_xbar_RLAST,s00_couplers_to_xbar_RLAST}),
        .s_axi_rready({s01_couplers_to_xbar_RREADY,s00_couplers_to_xbar_RREADY}),
        .s_axi_rresp({s01_couplers_to_xbar_RRESP,s00_couplers_to_xbar_RRESP}),
        .s_axi_ruser(s00_couplers_to_xbar_RUSER),
        .s_axi_rvalid({s01_couplers_to_xbar_RVALID,s00_couplers_to_xbar_RVALID}),
        .s_axi_wdata({s01_couplers_to_xbar_WDATA,s00_couplers_to_xbar_WDATA}),
        .s_axi_wlast({s01_couplers_to_xbar_WLAST,s00_couplers_to_xbar_WLAST}),
        .s_axi_wready({s01_couplers_to_xbar_WREADY,s00_couplers_to_xbar_WREADY}),
        .s_axi_wstrb({s01_couplers_to_xbar_WSTRB,s00_couplers_to_xbar_WSTRB}),
        .s_axi_wuser({1'b0,s00_couplers_to_xbar_WUSER}),
        .s_axi_wvalid({s01_couplers_to_xbar_WVALID,s00_couplers_to_xbar_WVALID}));
endmodule

module design_1_axi_interconnect_1_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_aruser,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awuser,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wid,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wuser,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_aruser,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awuser,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_buser,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_ruser,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wuser,
    S00_AXI_wvalid,
    S01_ACLK,
    S01_ARESETN,
    S01_AXI_araddr,
    S01_AXI_arburst,
    S01_AXI_arcache,
    S01_AXI_arlen,
    S01_AXI_arlock,
    S01_AXI_arprot,
    S01_AXI_arqos,
    S01_AXI_arready,
    S01_AXI_arregion,
    S01_AXI_arsize,
    S01_AXI_arvalid,
    S01_AXI_awaddr,
    S01_AXI_awburst,
    S01_AXI_awcache,
    S01_AXI_awlen,
    S01_AXI_awlock,
    S01_AXI_awprot,
    S01_AXI_awqos,
    S01_AXI_awready,
    S01_AXI_awregion,
    S01_AXI_awsize,
    S01_AXI_awvalid,
    S01_AXI_bready,
    S01_AXI_bresp,
    S01_AXI_bvalid,
    S01_AXI_rdata,
    S01_AXI_rlast,
    S01_AXI_rready,
    S01_AXI_rresp,
    S01_AXI_rvalid,
    S01_AXI_wdata,
    S01_AXI_wlast,
    S01_AXI_wready,
    S01_AXI_wstrb,
    S01_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [2:0]M00_AXI_arid;
  output [3:0]M00_AXI_arlen;
  output [1:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output [0:0]M00_AXI_aruser;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [2:0]M00_AXI_awid;
  output [3:0]M00_AXI_awlen;
  output [1:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output [0:0]M00_AXI_awuser;
  output M00_AXI_awvalid;
  input [5:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [5:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output [2:0]M00_AXI_wid;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wuser;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [1:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input [0:0]S00_AXI_aruser;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [1:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input [0:0]S00_AXI_awuser;
  input S00_AXI_awvalid;
  output [1:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output [0:0]S00_AXI_buser;
  output S00_AXI_bvalid;
  output [63:0]S00_AXI_rdata;
  output [1:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_ruser;
  output S00_AXI_rvalid;
  input [63:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [7:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wuser;
  input S00_AXI_wvalid;
  input S01_ACLK;
  input S01_ARESETN;
  input [31:0]S01_AXI_araddr;
  input [1:0]S01_AXI_arburst;
  input [3:0]S01_AXI_arcache;
  input [7:0]S01_AXI_arlen;
  input [1:0]S01_AXI_arlock;
  input [2:0]S01_AXI_arprot;
  input [3:0]S01_AXI_arqos;
  output S01_AXI_arready;
  input [3:0]S01_AXI_arregion;
  input [2:0]S01_AXI_arsize;
  input S01_AXI_arvalid;
  input [31:0]S01_AXI_awaddr;
  input [1:0]S01_AXI_awburst;
  input [3:0]S01_AXI_awcache;
  input [7:0]S01_AXI_awlen;
  input [1:0]S01_AXI_awlock;
  input [2:0]S01_AXI_awprot;
  input [3:0]S01_AXI_awqos;
  output S01_AXI_awready;
  input [3:0]S01_AXI_awregion;
  input [2:0]S01_AXI_awsize;
  input S01_AXI_awvalid;
  input S01_AXI_bready;
  output [1:0]S01_AXI_bresp;
  output S01_AXI_bvalid;
  output [31:0]S01_AXI_rdata;
  output S01_AXI_rlast;
  input S01_AXI_rready;
  output [1:0]S01_AXI_rresp;
  output S01_AXI_rvalid;
  input [31:0]S01_AXI_wdata;
  input S01_AXI_wlast;
  output S01_AXI_wready;
  input [3:0]S01_AXI_wstrb;
  input S01_AXI_wvalid;

  wire axi_interconnect_2_ACLK_net;
  (* MARK_DEBUG *) wire axi_interconnect_2_ARESETN_net;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_2_to_s00_couplers_ARADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_ARBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s00_couplers_ARCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_ARID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_2_to_s00_couplers_ARLEN;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s00_couplers_ARPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s00_couplers_ARQOS;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_ARREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s00_couplers_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_2_to_s00_couplers_ARUSER;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_ARVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_2_to_s00_couplers_AWADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_AWBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s00_couplers_AWCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_AWID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_2_to_s00_couplers_AWLEN;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s00_couplers_AWPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s00_couplers_AWQOS;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_AWREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s00_couplers_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_2_to_s00_couplers_AWUSER;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_AWVALID;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_BID;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_BREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_BRESP;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_2_to_s00_couplers_BUSER;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_BVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_2_to_s00_couplers_RDATA;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_RID;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_RLAST;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_RREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s00_couplers_RRESP;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_2_to_s00_couplers_RUSER;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_RVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_2_to_s00_couplers_WDATA;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_WLAST;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_WREADY;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_2_to_s00_couplers_WSTRB;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_2_to_s00_couplers_WUSER;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s00_couplers_WVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_2_to_s01_couplers_ARADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s01_couplers_ARBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_ARCACHE;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_2_to_s01_couplers_ARLEN;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s01_couplers_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s01_couplers_ARPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_ARQOS;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_ARREADY;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_ARREGION;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s01_couplers_ARSIZE;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_ARVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_2_to_s01_couplers_AWADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s01_couplers_AWBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_AWCACHE;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_2_to_s01_couplers_AWLEN;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s01_couplers_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s01_couplers_AWPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_AWQOS;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_AWREADY;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_AWREGION;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_2_to_s01_couplers_AWSIZE;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_AWVALID;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_BREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s01_couplers_BRESP;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_BVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_2_to_s01_couplers_RDATA;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_RLAST;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_RREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_2_to_s01_couplers_RRESP;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_RVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_2_to_s01_couplers_WDATA;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_WLAST;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_WREADY;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_2_to_s01_couplers_WSTRB;
  (* MARK_DEBUG *) wire axi_interconnect_2_to_s01_couplers_WVALID;
  (* MARK_DEBUG *) wire [31:0]m00_couplers_to_axi_interconnect_2_ARADDR;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_2_ARBURST;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_2_ARCACHE;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_ARID;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_2_ARLEN;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_2_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_ARPROT;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_2_ARQOS;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_ARREADY;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]m00_couplers_to_axi_interconnect_2_ARUSER;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_ARVALID;
  (* MARK_DEBUG *) wire [31:0]m00_couplers_to_axi_interconnect_2_AWADDR;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_2_AWBURST;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_2_AWCACHE;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_AWID;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_2_AWLEN;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_2_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_AWPROT;
  (* MARK_DEBUG *) wire [3:0]m00_couplers_to_axi_interconnect_2_AWQOS;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_AWREADY;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]m00_couplers_to_axi_interconnect_2_AWUSER;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_AWVALID;
  (* MARK_DEBUG *) wire [5:0]m00_couplers_to_axi_interconnect_2_BID;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_BREADY;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_2_BRESP;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_BVALID;
  (* MARK_DEBUG *) wire [63:0]m00_couplers_to_axi_interconnect_2_RDATA;
  (* MARK_DEBUG *) wire [5:0]m00_couplers_to_axi_interconnect_2_RID;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_RLAST;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_RREADY;
  (* MARK_DEBUG *) wire [1:0]m00_couplers_to_axi_interconnect_2_RRESP;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_RVALID;
  (* MARK_DEBUG *) wire [63:0]m00_couplers_to_axi_interconnect_2_WDATA;
  (* MARK_DEBUG *) wire [2:0]m00_couplers_to_axi_interconnect_2_WID;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_WLAST;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_WREADY;
  (* MARK_DEBUG *) wire [7:0]m00_couplers_to_axi_interconnect_2_WSTRB;
  (* MARK_DEBUG *) wire [0:0]m00_couplers_to_axi_interconnect_2_WUSER;
  (* MARK_DEBUG *) wire m00_couplers_to_axi_interconnect_2_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [1:0]s00_couplers_to_xbar_ARBURST;
  wire [3:0]s00_couplers_to_xbar_ARCACHE;
  wire [1:0]s00_couplers_to_xbar_ARID;
  wire [7:0]s00_couplers_to_xbar_ARLEN;
  wire [0:0]s00_couplers_to_xbar_ARLOCK;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [3:0]s00_couplers_to_xbar_ARQOS;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire [2:0]s00_couplers_to_xbar_ARSIZE;
  wire [0:0]s00_couplers_to_xbar_ARUSER;
  wire s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [1:0]s00_couplers_to_xbar_AWBURST;
  wire [3:0]s00_couplers_to_xbar_AWCACHE;
  wire [1:0]s00_couplers_to_xbar_AWID;
  wire [7:0]s00_couplers_to_xbar_AWLEN;
  wire [0:0]s00_couplers_to_xbar_AWLOCK;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [3:0]s00_couplers_to_xbar_AWQOS;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire [2:0]s00_couplers_to_xbar_AWSIZE;
  wire [0:0]s00_couplers_to_xbar_AWUSER;
  wire s00_couplers_to_xbar_AWVALID;
  wire [2:0]s00_couplers_to_xbar_BID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BUSER;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [63:0]s00_couplers_to_xbar_RDATA;
  wire [2:0]s00_couplers_to_xbar_RID;
  wire [0:0]s00_couplers_to_xbar_RLAST;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RUSER;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [63:0]s00_couplers_to_xbar_WDATA;
  wire s00_couplers_to_xbar_WLAST;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [7:0]s00_couplers_to_xbar_WSTRB;
  wire [0:0]s00_couplers_to_xbar_WUSER;
  wire s00_couplers_to_xbar_WVALID;
  wire [31:0]s01_couplers_to_xbar_ARADDR;
  wire [1:0]s01_couplers_to_xbar_ARBURST;
  wire [3:0]s01_couplers_to_xbar_ARCACHE;
  wire [7:0]s01_couplers_to_xbar_ARLEN;
  wire [0:0]s01_couplers_to_xbar_ARLOCK;
  wire [2:0]s01_couplers_to_xbar_ARPROT;
  wire [3:0]s01_couplers_to_xbar_ARQOS;
  wire [1:1]s01_couplers_to_xbar_ARREADY;
  wire [2:0]s01_couplers_to_xbar_ARSIZE;
  wire s01_couplers_to_xbar_ARVALID;
  wire [31:0]s01_couplers_to_xbar_AWADDR;
  wire [1:0]s01_couplers_to_xbar_AWBURST;
  wire [3:0]s01_couplers_to_xbar_AWCACHE;
  wire [7:0]s01_couplers_to_xbar_AWLEN;
  wire [0:0]s01_couplers_to_xbar_AWLOCK;
  wire [2:0]s01_couplers_to_xbar_AWPROT;
  wire [3:0]s01_couplers_to_xbar_AWQOS;
  wire [1:1]s01_couplers_to_xbar_AWREADY;
  wire [2:0]s01_couplers_to_xbar_AWSIZE;
  wire s01_couplers_to_xbar_AWVALID;
  wire s01_couplers_to_xbar_BREADY;
  wire [3:2]s01_couplers_to_xbar_BRESP;
  wire [1:1]s01_couplers_to_xbar_BVALID;
  wire [127:64]s01_couplers_to_xbar_RDATA;
  wire [1:1]s01_couplers_to_xbar_RLAST;
  wire s01_couplers_to_xbar_RREADY;
  wire [3:2]s01_couplers_to_xbar_RRESP;
  wire [1:1]s01_couplers_to_xbar_RVALID;
  wire [63:0]s01_couplers_to_xbar_WDATA;
  wire s01_couplers_to_xbar_WLAST;
  wire [1:1]s01_couplers_to_xbar_WREADY;
  wire [7:0]s01_couplers_to_xbar_WSTRB;
  wire s01_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [1:0]xbar_to_m00_couplers_ARBURST;
  wire [3:0]xbar_to_m00_couplers_ARCACHE;
  wire [2:0]xbar_to_m00_couplers_ARID;
  wire [7:0]xbar_to_m00_couplers_ARLEN;
  wire [0:0]xbar_to_m00_couplers_ARLOCK;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire [3:0]xbar_to_m00_couplers_ARQOS;
  wire xbar_to_m00_couplers_ARREADY;
  wire [3:0]xbar_to_m00_couplers_ARREGION;
  wire [2:0]xbar_to_m00_couplers_ARSIZE;
  wire [0:0]xbar_to_m00_couplers_ARUSER;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [1:0]xbar_to_m00_couplers_AWBURST;
  wire [3:0]xbar_to_m00_couplers_AWCACHE;
  wire [2:0]xbar_to_m00_couplers_AWID;
  wire [7:0]xbar_to_m00_couplers_AWLEN;
  wire [0:0]xbar_to_m00_couplers_AWLOCK;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire [3:0]xbar_to_m00_couplers_AWQOS;
  wire xbar_to_m00_couplers_AWREADY;
  wire [3:0]xbar_to_m00_couplers_AWREGION;
  wire [2:0]xbar_to_m00_couplers_AWSIZE;
  wire [0:0]xbar_to_m00_couplers_AWUSER;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [2:0]xbar_to_m00_couplers_BID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [63:0]xbar_to_m00_couplers_RDATA;
  wire [2:0]xbar_to_m00_couplers_RID;
  wire xbar_to_m00_couplers_RLAST;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire [0:0]xbar_to_m00_couplers_RUSER;
  wire xbar_to_m00_couplers_RVALID;
  wire [63:0]xbar_to_m00_couplers_WDATA;
  wire [0:0]xbar_to_m00_couplers_WLAST;
  wire xbar_to_m00_couplers_WREADY;
  wire [7:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WUSER;
  wire [0:0]xbar_to_m00_couplers_WVALID;

  assign M00_AXI_araddr[31:0] = m00_couplers_to_axi_interconnect_2_ARADDR;
  assign M00_AXI_arburst[1:0] = m00_couplers_to_axi_interconnect_2_ARBURST;
  assign M00_AXI_arcache[3:0] = m00_couplers_to_axi_interconnect_2_ARCACHE;
  assign M00_AXI_arid[2:0] = m00_couplers_to_axi_interconnect_2_ARID;
  assign M00_AXI_arlen[3:0] = m00_couplers_to_axi_interconnect_2_ARLEN;
  assign M00_AXI_arlock[1:0] = m00_couplers_to_axi_interconnect_2_ARLOCK;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_interconnect_2_ARPROT;
  assign M00_AXI_arqos[3:0] = m00_couplers_to_axi_interconnect_2_ARQOS;
  assign M00_AXI_arsize[2:0] = m00_couplers_to_axi_interconnect_2_ARSIZE;
  assign M00_AXI_aruser[0] = m00_couplers_to_axi_interconnect_2_ARUSER;
  assign M00_AXI_arvalid = m00_couplers_to_axi_interconnect_2_ARVALID;
  assign M00_AXI_awaddr[31:0] = m00_couplers_to_axi_interconnect_2_AWADDR;
  assign M00_AXI_awburst[1:0] = m00_couplers_to_axi_interconnect_2_AWBURST;
  assign M00_AXI_awcache[3:0] = m00_couplers_to_axi_interconnect_2_AWCACHE;
  assign M00_AXI_awid[2:0] = m00_couplers_to_axi_interconnect_2_AWID;
  assign M00_AXI_awlen[3:0] = m00_couplers_to_axi_interconnect_2_AWLEN;
  assign M00_AXI_awlock[1:0] = m00_couplers_to_axi_interconnect_2_AWLOCK;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_interconnect_2_AWPROT;
  assign M00_AXI_awqos[3:0] = m00_couplers_to_axi_interconnect_2_AWQOS;
  assign M00_AXI_awsize[2:0] = m00_couplers_to_axi_interconnect_2_AWSIZE;
  assign M00_AXI_awuser[0] = m00_couplers_to_axi_interconnect_2_AWUSER;
  assign M00_AXI_awvalid = m00_couplers_to_axi_interconnect_2_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_axi_interconnect_2_BREADY;
  assign M00_AXI_rready = m00_couplers_to_axi_interconnect_2_RREADY;
  assign M00_AXI_wdata[63:0] = m00_couplers_to_axi_interconnect_2_WDATA;
  assign M00_AXI_wid[2:0] = m00_couplers_to_axi_interconnect_2_WID;
  assign M00_AXI_wlast = m00_couplers_to_axi_interconnect_2_WLAST;
  assign M00_AXI_wstrb[7:0] = m00_couplers_to_axi_interconnect_2_WSTRB;
  assign M00_AXI_wuser[0] = m00_couplers_to_axi_interconnect_2_WUSER;
  assign M00_AXI_wvalid = m00_couplers_to_axi_interconnect_2_WVALID;
  assign S00_AXI_arready = axi_interconnect_2_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_2_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[1:0] = axi_interconnect_2_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_interconnect_2_to_s00_couplers_BRESP;
  assign S00_AXI_buser[0] = axi_interconnect_2_to_s00_couplers_BUSER;
  assign S00_AXI_bvalid = axi_interconnect_2_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[63:0] = axi_interconnect_2_to_s00_couplers_RDATA;
  assign S00_AXI_rid[1:0] = axi_interconnect_2_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_interconnect_2_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_2_to_s00_couplers_RRESP;
  assign S00_AXI_ruser[0] = axi_interconnect_2_to_s00_couplers_RUSER;
  assign S00_AXI_rvalid = axi_interconnect_2_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_2_to_s00_couplers_WREADY;
  assign S01_AXI_arready = axi_interconnect_2_to_s01_couplers_ARREADY;
  assign S01_AXI_awready = axi_interconnect_2_to_s01_couplers_AWREADY;
  assign S01_AXI_bresp[1:0] = axi_interconnect_2_to_s01_couplers_BRESP;
  assign S01_AXI_bvalid = axi_interconnect_2_to_s01_couplers_BVALID;
  assign S01_AXI_rdata[31:0] = axi_interconnect_2_to_s01_couplers_RDATA;
  assign S01_AXI_rlast = axi_interconnect_2_to_s01_couplers_RLAST;
  assign S01_AXI_rresp[1:0] = axi_interconnect_2_to_s01_couplers_RRESP;
  assign S01_AXI_rvalid = axi_interconnect_2_to_s01_couplers_RVALID;
  assign S01_AXI_wready = axi_interconnect_2_to_s01_couplers_WREADY;
  assign axi_interconnect_2_ACLK_net = ACLK;
  assign axi_interconnect_2_ARESETN_net = ARESETN;
  assign axi_interconnect_2_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_interconnect_2_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_2_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_2_to_s00_couplers_ARID = S00_AXI_arid[1:0];
  assign axi_interconnect_2_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign axi_interconnect_2_to_s00_couplers_ARLOCK = S00_AXI_arlock;
  assign axi_interconnect_2_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_2_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_interconnect_2_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_2_to_s00_couplers_ARUSER = S00_AXI_aruser[0];
  assign axi_interconnect_2_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_2_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_interconnect_2_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_2_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_2_to_s00_couplers_AWID = S00_AXI_awid[1:0];
  assign axi_interconnect_2_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign axi_interconnect_2_to_s00_couplers_AWLOCK = S00_AXI_awlock;
  assign axi_interconnect_2_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_2_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_interconnect_2_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_2_to_s00_couplers_AWUSER = S00_AXI_awuser[0];
  assign axi_interconnect_2_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_2_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_2_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_2_to_s00_couplers_WDATA = S00_AXI_wdata[63:0];
  assign axi_interconnect_2_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_2_to_s00_couplers_WSTRB = S00_AXI_wstrb[7:0];
  assign axi_interconnect_2_to_s00_couplers_WUSER = S00_AXI_wuser[0];
  assign axi_interconnect_2_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign axi_interconnect_2_to_s01_couplers_ARADDR = S01_AXI_araddr[31:0];
  assign axi_interconnect_2_to_s01_couplers_ARBURST = S01_AXI_arburst[1:0];
  assign axi_interconnect_2_to_s01_couplers_ARCACHE = S01_AXI_arcache[3:0];
  assign axi_interconnect_2_to_s01_couplers_ARLEN = S01_AXI_arlen[7:0];
  assign axi_interconnect_2_to_s01_couplers_ARLOCK = S01_AXI_arlock[1:0];
  assign axi_interconnect_2_to_s01_couplers_ARPROT = S01_AXI_arprot[2:0];
  assign axi_interconnect_2_to_s01_couplers_ARQOS = S01_AXI_arqos[3:0];
  assign axi_interconnect_2_to_s01_couplers_ARREGION = S01_AXI_arregion[3:0];
  assign axi_interconnect_2_to_s01_couplers_ARSIZE = S01_AXI_arsize[2:0];
  assign axi_interconnect_2_to_s01_couplers_ARVALID = S01_AXI_arvalid;
  assign axi_interconnect_2_to_s01_couplers_AWADDR = S01_AXI_awaddr[31:0];
  assign axi_interconnect_2_to_s01_couplers_AWBURST = S01_AXI_awburst[1:0];
  assign axi_interconnect_2_to_s01_couplers_AWCACHE = S01_AXI_awcache[3:0];
  assign axi_interconnect_2_to_s01_couplers_AWLEN = S01_AXI_awlen[7:0];
  assign axi_interconnect_2_to_s01_couplers_AWLOCK = S01_AXI_awlock[1:0];
  assign axi_interconnect_2_to_s01_couplers_AWPROT = S01_AXI_awprot[2:0];
  assign axi_interconnect_2_to_s01_couplers_AWQOS = S01_AXI_awqos[3:0];
  assign axi_interconnect_2_to_s01_couplers_AWREGION = S01_AXI_awregion[3:0];
  assign axi_interconnect_2_to_s01_couplers_AWSIZE = S01_AXI_awsize[2:0];
  assign axi_interconnect_2_to_s01_couplers_AWVALID = S01_AXI_awvalid;
  assign axi_interconnect_2_to_s01_couplers_BREADY = S01_AXI_bready;
  assign axi_interconnect_2_to_s01_couplers_RREADY = S01_AXI_rready;
  assign axi_interconnect_2_to_s01_couplers_WDATA = S01_AXI_wdata[31:0];
  assign axi_interconnect_2_to_s01_couplers_WLAST = S01_AXI_wlast;
  assign axi_interconnect_2_to_s01_couplers_WSTRB = S01_AXI_wstrb[3:0];
  assign axi_interconnect_2_to_s01_couplers_WVALID = S01_AXI_wvalid;
  assign m00_couplers_to_axi_interconnect_2_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_axi_interconnect_2_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_axi_interconnect_2_BID = M00_AXI_bid[5:0];
  assign m00_couplers_to_axi_interconnect_2_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_interconnect_2_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_axi_interconnect_2_RDATA = M00_AXI_rdata[63:0];
  assign m00_couplers_to_axi_interconnect_2_RID = M00_AXI_rid[5:0];
  assign m00_couplers_to_axi_interconnect_2_RLAST = M00_AXI_rlast;
  assign m00_couplers_to_axi_interconnect_2_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_interconnect_2_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_axi_interconnect_2_WREADY = M00_AXI_wready;
  m00_couplers_imp_ZLTC2M m00_couplers
       (.M_ACLK(axi_interconnect_2_ACLK_net),
        .M_ARESETN(axi_interconnect_2_ARESETN_net),
        .M_AXI_araddr(m00_couplers_to_axi_interconnect_2_ARADDR),
        .M_AXI_arburst(m00_couplers_to_axi_interconnect_2_ARBURST),
        .M_AXI_arcache(m00_couplers_to_axi_interconnect_2_ARCACHE),
        .M_AXI_arid(m00_couplers_to_axi_interconnect_2_ARID),
        .M_AXI_arlen(m00_couplers_to_axi_interconnect_2_ARLEN),
        .M_AXI_arlock(m00_couplers_to_axi_interconnect_2_ARLOCK),
        .M_AXI_arprot(m00_couplers_to_axi_interconnect_2_ARPROT),
        .M_AXI_arqos(m00_couplers_to_axi_interconnect_2_ARQOS),
        .M_AXI_arready(m00_couplers_to_axi_interconnect_2_ARREADY),
        .M_AXI_arsize(m00_couplers_to_axi_interconnect_2_ARSIZE),
        .M_AXI_aruser(m00_couplers_to_axi_interconnect_2_ARUSER),
        .M_AXI_arvalid(m00_couplers_to_axi_interconnect_2_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_interconnect_2_AWADDR),
        .M_AXI_awburst(m00_couplers_to_axi_interconnect_2_AWBURST),
        .M_AXI_awcache(m00_couplers_to_axi_interconnect_2_AWCACHE),
        .M_AXI_awid(m00_couplers_to_axi_interconnect_2_AWID),
        .M_AXI_awlen(m00_couplers_to_axi_interconnect_2_AWLEN),
        .M_AXI_awlock(m00_couplers_to_axi_interconnect_2_AWLOCK),
        .M_AXI_awprot(m00_couplers_to_axi_interconnect_2_AWPROT),
        .M_AXI_awqos(m00_couplers_to_axi_interconnect_2_AWQOS),
        .M_AXI_awready(m00_couplers_to_axi_interconnect_2_AWREADY),
        .M_AXI_awsize(m00_couplers_to_axi_interconnect_2_AWSIZE),
        .M_AXI_awuser(m00_couplers_to_axi_interconnect_2_AWUSER),
        .M_AXI_awvalid(m00_couplers_to_axi_interconnect_2_AWVALID),
        .M_AXI_bid(m00_couplers_to_axi_interconnect_2_BID),
        .M_AXI_bready(m00_couplers_to_axi_interconnect_2_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_interconnect_2_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_interconnect_2_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_interconnect_2_RDATA),
        .M_AXI_rid(m00_couplers_to_axi_interconnect_2_RID),
        .M_AXI_rlast(m00_couplers_to_axi_interconnect_2_RLAST),
        .M_AXI_rready(m00_couplers_to_axi_interconnect_2_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_interconnect_2_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_interconnect_2_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_interconnect_2_WDATA),
        .M_AXI_wid(m00_couplers_to_axi_interconnect_2_WID),
        .M_AXI_wlast(m00_couplers_to_axi_interconnect_2_WLAST),
        .M_AXI_wready(m00_couplers_to_axi_interconnect_2_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_interconnect_2_WSTRB),
        .M_AXI_wuser(m00_couplers_to_axi_interconnect_2_WUSER),
        .M_AXI_wvalid(m00_couplers_to_axi_interconnect_2_WVALID),
        .S_ACLK(axi_interconnect_2_ACLK_net),
        .S_ARESETN(axi_interconnect_2_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arburst(xbar_to_m00_couplers_ARBURST),
        .S_AXI_arcache(xbar_to_m00_couplers_ARCACHE),
        .S_AXI_arid(xbar_to_m00_couplers_ARID),
        .S_AXI_arlen(xbar_to_m00_couplers_ARLEN),
        .S_AXI_arlock(xbar_to_m00_couplers_ARLOCK),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arqos(xbar_to_m00_couplers_ARQOS),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arregion(xbar_to_m00_couplers_ARREGION),
        .S_AXI_arsize(xbar_to_m00_couplers_ARSIZE),
        .S_AXI_aruser(xbar_to_m00_couplers_ARUSER),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awburst(xbar_to_m00_couplers_AWBURST),
        .S_AXI_awcache(xbar_to_m00_couplers_AWCACHE),
        .S_AXI_awid(xbar_to_m00_couplers_AWID),
        .S_AXI_awlen(xbar_to_m00_couplers_AWLEN),
        .S_AXI_awlock(xbar_to_m00_couplers_AWLOCK),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awqos(xbar_to_m00_couplers_AWQOS),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awregion(xbar_to_m00_couplers_AWREGION),
        .S_AXI_awsize(xbar_to_m00_couplers_AWSIZE),
        .S_AXI_awuser(xbar_to_m00_couplers_AWUSER),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bid(xbar_to_m00_couplers_BID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rid(xbar_to_m00_couplers_RID),
        .S_AXI_rlast(xbar_to_m00_couplers_RLAST),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_ruser(xbar_to_m00_couplers_RUSER),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wlast(xbar_to_m00_couplers_WLAST),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wuser(xbar_to_m00_couplers_WUSER),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
  design_1_m00_pchk_1 m00_pchk
       (.aclk(axi_interconnect_2_ACLK_net),
        .aresetn(axi_interconnect_2_ARESETN_net),
        .pc_axi_araddr(m00_couplers_to_axi_interconnect_2_ARADDR),
        .pc_axi_arburst(m00_couplers_to_axi_interconnect_2_ARBURST),
        .pc_axi_arcache(m00_couplers_to_axi_interconnect_2_ARCACHE),
        .pc_axi_arid(m00_couplers_to_axi_interconnect_2_ARID),
        .pc_axi_arlen(m00_couplers_to_axi_interconnect_2_ARLEN),
        .pc_axi_arlock(m00_couplers_to_axi_interconnect_2_ARLOCK),
        .pc_axi_arprot(m00_couplers_to_axi_interconnect_2_ARPROT),
        .pc_axi_arqos(m00_couplers_to_axi_interconnect_2_ARQOS),
        .pc_axi_arready(m00_couplers_to_axi_interconnect_2_ARREADY),
        .pc_axi_arsize(m00_couplers_to_axi_interconnect_2_ARSIZE),
        .pc_axi_aruser(m00_couplers_to_axi_interconnect_2_ARUSER),
        .pc_axi_arvalid(m00_couplers_to_axi_interconnect_2_ARVALID),
        .pc_axi_awaddr(m00_couplers_to_axi_interconnect_2_AWADDR),
        .pc_axi_awburst(m00_couplers_to_axi_interconnect_2_AWBURST),
        .pc_axi_awcache(m00_couplers_to_axi_interconnect_2_AWCACHE),
        .pc_axi_awid(m00_couplers_to_axi_interconnect_2_AWID),
        .pc_axi_awlen(m00_couplers_to_axi_interconnect_2_AWLEN),
        .pc_axi_awlock(m00_couplers_to_axi_interconnect_2_AWLOCK),
        .pc_axi_awprot(m00_couplers_to_axi_interconnect_2_AWPROT),
        .pc_axi_awqos(m00_couplers_to_axi_interconnect_2_AWQOS),
        .pc_axi_awready(m00_couplers_to_axi_interconnect_2_AWREADY),
        .pc_axi_awsize(m00_couplers_to_axi_interconnect_2_AWSIZE),
        .pc_axi_awuser(m00_couplers_to_axi_interconnect_2_AWUSER),
        .pc_axi_awvalid(m00_couplers_to_axi_interconnect_2_AWVALID),
        .pc_axi_bid(m00_couplers_to_axi_interconnect_2_BID[2:0]),
        .pc_axi_bready(m00_couplers_to_axi_interconnect_2_BREADY),
        .pc_axi_bresp(m00_couplers_to_axi_interconnect_2_BRESP),
        .pc_axi_bvalid(m00_couplers_to_axi_interconnect_2_BVALID),
        .pc_axi_rdata(m00_couplers_to_axi_interconnect_2_RDATA),
        .pc_axi_rid(m00_couplers_to_axi_interconnect_2_RID[2:0]),
        .pc_axi_rlast(m00_couplers_to_axi_interconnect_2_RLAST),
        .pc_axi_rready(m00_couplers_to_axi_interconnect_2_RREADY),
        .pc_axi_rresp(m00_couplers_to_axi_interconnect_2_RRESP),
        .pc_axi_ruser(1'b0),
        .pc_axi_rvalid(m00_couplers_to_axi_interconnect_2_RVALID),
        .pc_axi_wdata(m00_couplers_to_axi_interconnect_2_WDATA),
        .pc_axi_wid(m00_couplers_to_axi_interconnect_2_WID),
        .pc_axi_wlast(m00_couplers_to_axi_interconnect_2_WLAST),
        .pc_axi_wready(m00_couplers_to_axi_interconnect_2_WREADY),
        .pc_axi_wstrb(m00_couplers_to_axi_interconnect_2_WSTRB),
        .pc_axi_wuser(m00_couplers_to_axi_interconnect_2_WUSER),
        .pc_axi_wvalid(m00_couplers_to_axi_interconnect_2_WVALID));
  s00_couplers_imp_XOWISC s00_couplers
       (.M_ACLK(axi_interconnect_2_ACLK_net),
        .M_ARESETN(axi_interconnect_2_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s00_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s00_couplers_to_xbar_ARCACHE),
        .M_AXI_arid(s00_couplers_to_xbar_ARID),
        .M_AXI_arlen(s00_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s00_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s00_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s00_couplers_to_xbar_ARSIZE),
        .M_AXI_aruser(s00_couplers_to_xbar_ARUSER),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s00_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s00_couplers_to_xbar_AWCACHE),
        .M_AXI_awid(s00_couplers_to_xbar_AWID),
        .M_AXI_awlen(s00_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s00_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s00_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s00_couplers_to_xbar_AWSIZE),
        .M_AXI_awuser(s00_couplers_to_xbar_AWUSER),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bid(s00_couplers_to_xbar_BID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_buser(s00_couplers_to_xbar_BUSER),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rid(s00_couplers_to_xbar_RID),
        .M_AXI_rlast(s00_couplers_to_xbar_RLAST),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_ruser(s00_couplers_to_xbar_RUSER),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s00_couplers_to_xbar_WLAST),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wuser(s00_couplers_to_xbar_WUSER),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(axi_interconnect_2_ACLK_net),
        .S_ARESETN(axi_interconnect_2_ARESETN_net),
        .S_AXI_araddr(axi_interconnect_2_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_2_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_2_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_interconnect_2_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_interconnect_2_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_2_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_2_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_2_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_2_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_2_to_s00_couplers_ARSIZE),
        .S_AXI_aruser(axi_interconnect_2_to_s00_couplers_ARUSER),
        .S_AXI_arvalid(axi_interconnect_2_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_2_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_2_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_2_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_interconnect_2_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_interconnect_2_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_2_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_2_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_2_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_2_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_2_to_s00_couplers_AWSIZE),
        .S_AXI_awuser(axi_interconnect_2_to_s00_couplers_AWUSER),
        .S_AXI_awvalid(axi_interconnect_2_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_interconnect_2_to_s00_couplers_BID),
        .S_AXI_bready(axi_interconnect_2_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_2_to_s00_couplers_BRESP),
        .S_AXI_buser(axi_interconnect_2_to_s00_couplers_BUSER),
        .S_AXI_bvalid(axi_interconnect_2_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_2_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_interconnect_2_to_s00_couplers_RID),
        .S_AXI_rlast(axi_interconnect_2_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_2_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_2_to_s00_couplers_RRESP),
        .S_AXI_ruser(axi_interconnect_2_to_s00_couplers_RUSER),
        .S_AXI_rvalid(axi_interconnect_2_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_2_to_s00_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_2_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_2_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_2_to_s00_couplers_WSTRB),
        .S_AXI_wuser(axi_interconnect_2_to_s00_couplers_WUSER),
        .S_AXI_wvalid(axi_interconnect_2_to_s00_couplers_WVALID));
  design_1_s00_pchk_1 s00_pchk
       (.aclk(axi_interconnect_2_ACLK_net),
        .aresetn(axi_interconnect_2_ARESETN_net),
        .pc_axi_araddr(axi_interconnect_2_to_s00_couplers_ARADDR),
        .pc_axi_arburst(axi_interconnect_2_to_s00_couplers_ARBURST),
        .pc_axi_arcache(axi_interconnect_2_to_s00_couplers_ARCACHE),
        .pc_axi_arid(axi_interconnect_2_to_s00_couplers_ARID),
        .pc_axi_arlen(axi_interconnect_2_to_s00_couplers_ARLEN),
        .pc_axi_arlock(axi_interconnect_2_to_s00_couplers_ARLOCK),
        .pc_axi_arprot(axi_interconnect_2_to_s00_couplers_ARPROT),
        .pc_axi_arqos(axi_interconnect_2_to_s00_couplers_ARQOS),
        .pc_axi_arready(axi_interconnect_2_to_s00_couplers_ARREADY),
        .pc_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_arsize(axi_interconnect_2_to_s00_couplers_ARSIZE),
        .pc_axi_aruser(axi_interconnect_2_to_s00_couplers_ARUSER),
        .pc_axi_arvalid(axi_interconnect_2_to_s00_couplers_ARVALID),
        .pc_axi_awaddr(axi_interconnect_2_to_s00_couplers_AWADDR),
        .pc_axi_awburst(axi_interconnect_2_to_s00_couplers_AWBURST),
        .pc_axi_awcache(axi_interconnect_2_to_s00_couplers_AWCACHE),
        .pc_axi_awid(axi_interconnect_2_to_s00_couplers_AWID),
        .pc_axi_awlen(axi_interconnect_2_to_s00_couplers_AWLEN),
        .pc_axi_awlock(axi_interconnect_2_to_s00_couplers_AWLOCK),
        .pc_axi_awprot(axi_interconnect_2_to_s00_couplers_AWPROT),
        .pc_axi_awqos(axi_interconnect_2_to_s00_couplers_AWQOS),
        .pc_axi_awready(axi_interconnect_2_to_s00_couplers_AWREADY),
        .pc_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_awsize(axi_interconnect_2_to_s00_couplers_AWSIZE),
        .pc_axi_awuser(axi_interconnect_2_to_s00_couplers_AWUSER),
        .pc_axi_awvalid(axi_interconnect_2_to_s00_couplers_AWVALID),
        .pc_axi_bid(axi_interconnect_2_to_s00_couplers_BID),
        .pc_axi_bready(axi_interconnect_2_to_s00_couplers_BREADY),
        .pc_axi_bresp(axi_interconnect_2_to_s00_couplers_BRESP),
        .pc_axi_buser(axi_interconnect_2_to_s00_couplers_BUSER),
        .pc_axi_bvalid(axi_interconnect_2_to_s00_couplers_BVALID),
        .pc_axi_rdata(axi_interconnect_2_to_s00_couplers_RDATA),
        .pc_axi_rid(axi_interconnect_2_to_s00_couplers_RID),
        .pc_axi_rlast(axi_interconnect_2_to_s00_couplers_RLAST),
        .pc_axi_rready(axi_interconnect_2_to_s00_couplers_RREADY),
        .pc_axi_rresp(axi_interconnect_2_to_s00_couplers_RRESP),
        .pc_axi_ruser(axi_interconnect_2_to_s00_couplers_RUSER),
        .pc_axi_rvalid(axi_interconnect_2_to_s00_couplers_RVALID),
        .pc_axi_wdata(axi_interconnect_2_to_s00_couplers_WDATA),
        .pc_axi_wlast(axi_interconnect_2_to_s00_couplers_WLAST),
        .pc_axi_wready(axi_interconnect_2_to_s00_couplers_WREADY),
        .pc_axi_wstrb(axi_interconnect_2_to_s00_couplers_WSTRB),
        .pc_axi_wuser(axi_interconnect_2_to_s00_couplers_WUSER),
        .pc_axi_wvalid(axi_interconnect_2_to_s00_couplers_WVALID));
  s01_couplers_imp_15OSRGD s01_couplers
       (.M_ACLK(axi_interconnect_2_ACLK_net),
        .M_ARESETN(axi_interconnect_2_ARESETN_net),
        .M_AXI_araddr(s01_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s01_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s01_couplers_to_xbar_ARCACHE),
        .M_AXI_arlen(s01_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s01_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s01_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s01_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s01_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s01_couplers_to_xbar_ARSIZE),
        .M_AXI_arvalid(s01_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s01_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s01_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s01_couplers_to_xbar_AWCACHE),
        .M_AXI_awlen(s01_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s01_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s01_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s01_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s01_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s01_couplers_to_xbar_AWSIZE),
        .M_AXI_awvalid(s01_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s01_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s01_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s01_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s01_couplers_to_xbar_RDATA),
        .M_AXI_rlast(s01_couplers_to_xbar_RLAST),
        .M_AXI_rready(s01_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s01_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s01_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s01_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s01_couplers_to_xbar_WLAST),
        .M_AXI_wready(s01_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s01_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s01_couplers_to_xbar_WVALID),
        .S_ACLK(axi_interconnect_2_ACLK_net),
        .S_ARESETN(axi_interconnect_2_ARESETN_net),
        .S_AXI_araddr(axi_interconnect_2_to_s01_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_2_to_s01_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_2_to_s01_couplers_ARCACHE),
        .S_AXI_arlen(axi_interconnect_2_to_s01_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_2_to_s01_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_2_to_s01_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_2_to_s01_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_2_to_s01_couplers_ARREADY),
        .S_AXI_arregion(axi_interconnect_2_to_s01_couplers_ARREGION),
        .S_AXI_arsize(axi_interconnect_2_to_s01_couplers_ARSIZE),
        .S_AXI_arvalid(axi_interconnect_2_to_s01_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_2_to_s01_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_2_to_s01_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_2_to_s01_couplers_AWCACHE),
        .S_AXI_awlen(axi_interconnect_2_to_s01_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_2_to_s01_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_2_to_s01_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_2_to_s01_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_2_to_s01_couplers_AWREADY),
        .S_AXI_awregion(axi_interconnect_2_to_s01_couplers_AWREGION),
        .S_AXI_awsize(axi_interconnect_2_to_s01_couplers_AWSIZE),
        .S_AXI_awvalid(axi_interconnect_2_to_s01_couplers_AWVALID),
        .S_AXI_bready(axi_interconnect_2_to_s01_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_2_to_s01_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_2_to_s01_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_2_to_s01_couplers_RDATA),
        .S_AXI_rlast(axi_interconnect_2_to_s01_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_2_to_s01_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_2_to_s01_couplers_RRESP),
        .S_AXI_rvalid(axi_interconnect_2_to_s01_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_2_to_s01_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_2_to_s01_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_2_to_s01_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_2_to_s01_couplers_WSTRB),
        .S_AXI_wvalid(axi_interconnect_2_to_s01_couplers_WVALID));
  design_1_s01_pchk_1 s01_pchk
       (.aclk(axi_interconnect_2_ACLK_net),
        .aresetn(axi_interconnect_2_ARESETN_net),
        .pc_axi_araddr(axi_interconnect_2_to_s01_couplers_ARADDR),
        .pc_axi_arburst(axi_interconnect_2_to_s01_couplers_ARBURST),
        .pc_axi_arcache(axi_interconnect_2_to_s01_couplers_ARCACHE),
        .pc_axi_arlen(axi_interconnect_2_to_s01_couplers_ARLEN),
        .pc_axi_arlock(axi_interconnect_2_to_s01_couplers_ARLOCK[0]),
        .pc_axi_arprot(axi_interconnect_2_to_s01_couplers_ARPROT),
        .pc_axi_arqos(axi_interconnect_2_to_s01_couplers_ARQOS),
        .pc_axi_arready(axi_interconnect_2_to_s01_couplers_ARREADY),
        .pc_axi_arregion(axi_interconnect_2_to_s01_couplers_ARREGION),
        .pc_axi_arsize(axi_interconnect_2_to_s01_couplers_ARSIZE),
        .pc_axi_arvalid(axi_interconnect_2_to_s01_couplers_ARVALID),
        .pc_axi_awaddr(axi_interconnect_2_to_s01_couplers_AWADDR),
        .pc_axi_awburst(axi_interconnect_2_to_s01_couplers_AWBURST),
        .pc_axi_awcache(axi_interconnect_2_to_s01_couplers_AWCACHE),
        .pc_axi_awlen(axi_interconnect_2_to_s01_couplers_AWLEN),
        .pc_axi_awlock(axi_interconnect_2_to_s01_couplers_AWLOCK[0]),
        .pc_axi_awprot(axi_interconnect_2_to_s01_couplers_AWPROT),
        .pc_axi_awqos(axi_interconnect_2_to_s01_couplers_AWQOS),
        .pc_axi_awready(axi_interconnect_2_to_s01_couplers_AWREADY),
        .pc_axi_awregion(axi_interconnect_2_to_s01_couplers_AWREGION),
        .pc_axi_awsize(axi_interconnect_2_to_s01_couplers_AWSIZE),
        .pc_axi_awvalid(axi_interconnect_2_to_s01_couplers_AWVALID),
        .pc_axi_bready(axi_interconnect_2_to_s01_couplers_BREADY),
        .pc_axi_bresp(axi_interconnect_2_to_s01_couplers_BRESP),
        .pc_axi_bvalid(axi_interconnect_2_to_s01_couplers_BVALID),
        .pc_axi_rdata(axi_interconnect_2_to_s01_couplers_RDATA),
        .pc_axi_rlast(axi_interconnect_2_to_s01_couplers_RLAST),
        .pc_axi_rready(axi_interconnect_2_to_s01_couplers_RREADY),
        .pc_axi_rresp(axi_interconnect_2_to_s01_couplers_RRESP),
        .pc_axi_rvalid(axi_interconnect_2_to_s01_couplers_RVALID),
        .pc_axi_wdata(axi_interconnect_2_to_s01_couplers_WDATA),
        .pc_axi_wlast(axi_interconnect_2_to_s01_couplers_WLAST),
        .pc_axi_wready(axi_interconnect_2_to_s01_couplers_WREADY),
        .pc_axi_wstrb(axi_interconnect_2_to_s01_couplers_WSTRB),
        .pc_axi_wvalid(axi_interconnect_2_to_s01_couplers_WVALID));
  design_1_xbar_2 xbar
       (.aclk(axi_interconnect_2_ACLK_net),
        .aresetn(axi_interconnect_2_ARESETN_net),
        .m_axi_araddr(xbar_to_m00_couplers_ARADDR),
        .m_axi_arburst(xbar_to_m00_couplers_ARBURST),
        .m_axi_arcache(xbar_to_m00_couplers_ARCACHE),
        .m_axi_arid(xbar_to_m00_couplers_ARID),
        .m_axi_arlen(xbar_to_m00_couplers_ARLEN),
        .m_axi_arlock(xbar_to_m00_couplers_ARLOCK),
        .m_axi_arprot(xbar_to_m00_couplers_ARPROT),
        .m_axi_arqos(xbar_to_m00_couplers_ARQOS),
        .m_axi_arready(xbar_to_m00_couplers_ARREADY),
        .m_axi_arregion(xbar_to_m00_couplers_ARREGION),
        .m_axi_arsize(xbar_to_m00_couplers_ARSIZE),
        .m_axi_aruser(xbar_to_m00_couplers_ARUSER),
        .m_axi_arvalid(xbar_to_m00_couplers_ARVALID),
        .m_axi_awaddr(xbar_to_m00_couplers_AWADDR),
        .m_axi_awburst(xbar_to_m00_couplers_AWBURST),
        .m_axi_awcache(xbar_to_m00_couplers_AWCACHE),
        .m_axi_awid(xbar_to_m00_couplers_AWID),
        .m_axi_awlen(xbar_to_m00_couplers_AWLEN),
        .m_axi_awlock(xbar_to_m00_couplers_AWLOCK),
        .m_axi_awprot(xbar_to_m00_couplers_AWPROT),
        .m_axi_awqos(xbar_to_m00_couplers_AWQOS),
        .m_axi_awready(xbar_to_m00_couplers_AWREADY),
        .m_axi_awregion(xbar_to_m00_couplers_AWREGION),
        .m_axi_awsize(xbar_to_m00_couplers_AWSIZE),
        .m_axi_awuser(xbar_to_m00_couplers_AWUSER),
        .m_axi_awvalid(xbar_to_m00_couplers_AWVALID),
        .m_axi_bid(xbar_to_m00_couplers_BID),
        .m_axi_bready(xbar_to_m00_couplers_BREADY),
        .m_axi_bresp(xbar_to_m00_couplers_BRESP),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(xbar_to_m00_couplers_BVALID),
        .m_axi_rdata(xbar_to_m00_couplers_RDATA),
        .m_axi_rid(xbar_to_m00_couplers_RID),
        .m_axi_rlast(xbar_to_m00_couplers_RLAST),
        .m_axi_rready(xbar_to_m00_couplers_RREADY),
        .m_axi_rresp(xbar_to_m00_couplers_RRESP),
        .m_axi_ruser(xbar_to_m00_couplers_RUSER),
        .m_axi_rvalid(xbar_to_m00_couplers_RVALID),
        .m_axi_wdata(xbar_to_m00_couplers_WDATA),
        .m_axi_wlast(xbar_to_m00_couplers_WLAST),
        .m_axi_wready(xbar_to_m00_couplers_WREADY),
        .m_axi_wstrb(xbar_to_m00_couplers_WSTRB),
        .m_axi_wuser(xbar_to_m00_couplers_WUSER),
        .m_axi_wvalid(xbar_to_m00_couplers_WVALID),
        .s_axi_araddr({s01_couplers_to_xbar_ARADDR,s00_couplers_to_xbar_ARADDR}),
        .s_axi_arburst({s01_couplers_to_xbar_ARBURST,s00_couplers_to_xbar_ARBURST}),
        .s_axi_arcache({s01_couplers_to_xbar_ARCACHE,s00_couplers_to_xbar_ARCACHE}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0,s00_couplers_to_xbar_ARID}),
        .s_axi_arlen({s01_couplers_to_xbar_ARLEN,s00_couplers_to_xbar_ARLEN}),
        .s_axi_arlock({s01_couplers_to_xbar_ARLOCK,s00_couplers_to_xbar_ARLOCK}),
        .s_axi_arprot({s01_couplers_to_xbar_ARPROT,s00_couplers_to_xbar_ARPROT}),
        .s_axi_arqos({s01_couplers_to_xbar_ARQOS,s00_couplers_to_xbar_ARQOS}),
        .s_axi_arready({s01_couplers_to_xbar_ARREADY,s00_couplers_to_xbar_ARREADY}),
        .s_axi_arsize({s01_couplers_to_xbar_ARSIZE,s00_couplers_to_xbar_ARSIZE}),
        .s_axi_aruser({1'b0,s00_couplers_to_xbar_ARUSER}),
        .s_axi_arvalid({s01_couplers_to_xbar_ARVALID,s00_couplers_to_xbar_ARVALID}),
        .s_axi_awaddr({s01_couplers_to_xbar_AWADDR,s00_couplers_to_xbar_AWADDR}),
        .s_axi_awburst({s01_couplers_to_xbar_AWBURST,s00_couplers_to_xbar_AWBURST}),
        .s_axi_awcache({s01_couplers_to_xbar_AWCACHE,s00_couplers_to_xbar_AWCACHE}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0,s00_couplers_to_xbar_AWID}),
        .s_axi_awlen({s01_couplers_to_xbar_AWLEN,s00_couplers_to_xbar_AWLEN}),
        .s_axi_awlock({s01_couplers_to_xbar_AWLOCK,s00_couplers_to_xbar_AWLOCK}),
        .s_axi_awprot({s01_couplers_to_xbar_AWPROT,s00_couplers_to_xbar_AWPROT}),
        .s_axi_awqos({s01_couplers_to_xbar_AWQOS,s00_couplers_to_xbar_AWQOS}),
        .s_axi_awready({s01_couplers_to_xbar_AWREADY,s00_couplers_to_xbar_AWREADY}),
        .s_axi_awsize({s01_couplers_to_xbar_AWSIZE,s00_couplers_to_xbar_AWSIZE}),
        .s_axi_awuser({1'b0,s00_couplers_to_xbar_AWUSER}),
        .s_axi_awvalid({s01_couplers_to_xbar_AWVALID,s00_couplers_to_xbar_AWVALID}),
        .s_axi_bid(s00_couplers_to_xbar_BID),
        .s_axi_bready({s01_couplers_to_xbar_BREADY,s00_couplers_to_xbar_BREADY}),
        .s_axi_bresp({s01_couplers_to_xbar_BRESP,s00_couplers_to_xbar_BRESP}),
        .s_axi_buser(s00_couplers_to_xbar_BUSER),
        .s_axi_bvalid({s01_couplers_to_xbar_BVALID,s00_couplers_to_xbar_BVALID}),
        .s_axi_rdata({s01_couplers_to_xbar_RDATA,s00_couplers_to_xbar_RDATA}),
        .s_axi_rid(s00_couplers_to_xbar_RID),
        .s_axi_rlast({s01_couplers_to_xbar_RLAST,s00_couplers_to_xbar_RLAST}),
        .s_axi_rready({s01_couplers_to_xbar_RREADY,s00_couplers_to_xbar_RREADY}),
        .s_axi_rresp({s01_couplers_to_xbar_RRESP,s00_couplers_to_xbar_RRESP}),
        .s_axi_ruser(s00_couplers_to_xbar_RUSER),
        .s_axi_rvalid({s01_couplers_to_xbar_RVALID,s00_couplers_to_xbar_RVALID}),
        .s_axi_wdata({s01_couplers_to_xbar_WDATA,s00_couplers_to_xbar_WDATA}),
        .s_axi_wlast({s01_couplers_to_xbar_WLAST,s00_couplers_to_xbar_WLAST}),
        .s_axi_wready({s01_couplers_to_xbar_WREADY,s00_couplers_to_xbar_WREADY}),
        .s_axi_wstrb({s01_couplers_to_xbar_WSTRB,s00_couplers_to_xbar_WSTRB}),
        .s_axi_wuser({1'b0,s00_couplers_to_xbar_WUSER}),
        .s_axi_wvalid({s01_couplers_to_xbar_WVALID,s00_couplers_to_xbar_WVALID}));
endmodule

module design_1_axi_interconnect_1_1
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_aruser,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awuser,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wid,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wuser,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_aruser,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awuser,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_ruser,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wuser,
    S00_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [1:0]M00_AXI_arid;
  output [3:0]M00_AXI_arlen;
  output [1:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output [0:0]M00_AXI_aruser;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [1:0]M00_AXI_awid;
  output [3:0]M00_AXI_awlen;
  output [1:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output [0:0]M00_AXI_awuser;
  output M00_AXI_awvalid;
  input [5:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [5:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output [1:0]M00_AXI_wid;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wuser;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [1:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input [0:0]S00_AXI_aruser;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [1:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input [0:0]S00_AXI_awuser;
  input S00_AXI_awvalid;
  output [1:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [63:0]S00_AXI_rdata;
  output [1:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_ruser;
  output S00_AXI_rvalid;
  input [63:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [7:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wuser;
  input S00_AXI_wvalid;

  wire S00_ACLK_1;
  (* MARK_DEBUG *) wire S00_ARESETN_1;
  wire axi_interconnect_3_ACLK_net;
  (* MARK_DEBUG *) wire axi_interconnect_3_ARESETN_net;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_3_to_s00_couplers_ARADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_ARBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_3_to_s00_couplers_ARCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_ARID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_3_to_s00_couplers_ARLEN;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_3_to_s00_couplers_ARPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_3_to_s00_couplers_ARQOS;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_ARREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_3_to_s00_couplers_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_3_to_s00_couplers_ARUSER;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_ARVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_3_to_s00_couplers_AWADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_AWBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_3_to_s00_couplers_AWCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_AWID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_3_to_s00_couplers_AWLEN;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_3_to_s00_couplers_AWPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_3_to_s00_couplers_AWQOS;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_AWREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_3_to_s00_couplers_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_3_to_s00_couplers_AWUSER;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_AWVALID;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_BID;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_BREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_BRESP;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_BVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_3_to_s00_couplers_RDATA;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_RID;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_RLAST;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_RREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_3_to_s00_couplers_RRESP;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_3_to_s00_couplers_RUSER;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_RVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_3_to_s00_couplers_WDATA;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_WLAST;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_WREADY;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_3_to_s00_couplers_WSTRB;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_3_to_s00_couplers_WUSER;
  (* MARK_DEBUG *) wire axi_interconnect_3_to_s00_couplers_WVALID;
  (* MARK_DEBUG *) wire [31:0]s00_couplers_to_axi_interconnect_3_ARADDR;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_ARBURST;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_3_ARCACHE;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_ARID;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_3_ARLEN;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_3_ARPROT;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_3_ARQOS;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_ARREADY;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_3_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]s00_couplers_to_axi_interconnect_3_ARUSER;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_ARVALID;
  (* MARK_DEBUG *) wire [31:0]s00_couplers_to_axi_interconnect_3_AWADDR;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_AWBURST;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_3_AWCACHE;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_AWID;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_3_AWLEN;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_3_AWPROT;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_3_AWQOS;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_AWREADY;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_3_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]s00_couplers_to_axi_interconnect_3_AWUSER;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_AWVALID;
  (* MARK_DEBUG *) wire [5:0]s00_couplers_to_axi_interconnect_3_BID;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_BREADY;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_BRESP;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_BVALID;
  (* MARK_DEBUG *) wire [63:0]s00_couplers_to_axi_interconnect_3_RDATA;
  (* MARK_DEBUG *) wire [5:0]s00_couplers_to_axi_interconnect_3_RID;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_RLAST;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_RREADY;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_RRESP;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_RVALID;
  (* MARK_DEBUG *) wire [63:0]s00_couplers_to_axi_interconnect_3_WDATA;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_3_WID;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_WLAST;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_WREADY;
  (* MARK_DEBUG *) wire [7:0]s00_couplers_to_axi_interconnect_3_WSTRB;
  (* MARK_DEBUG *) wire [0:0]s00_couplers_to_axi_interconnect_3_WUSER;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_3_WVALID;

  assign M00_AXI_araddr[31:0] = s00_couplers_to_axi_interconnect_3_ARADDR;
  assign M00_AXI_arburst[1:0] = s00_couplers_to_axi_interconnect_3_ARBURST;
  assign M00_AXI_arcache[3:0] = s00_couplers_to_axi_interconnect_3_ARCACHE;
  assign M00_AXI_arid[1:0] = s00_couplers_to_axi_interconnect_3_ARID;
  assign M00_AXI_arlen[3:0] = s00_couplers_to_axi_interconnect_3_ARLEN;
  assign M00_AXI_arlock[1:0] = s00_couplers_to_axi_interconnect_3_ARLOCK;
  assign M00_AXI_arprot[2:0] = s00_couplers_to_axi_interconnect_3_ARPROT;
  assign M00_AXI_arqos[3:0] = s00_couplers_to_axi_interconnect_3_ARQOS;
  assign M00_AXI_arsize[2:0] = s00_couplers_to_axi_interconnect_3_ARSIZE;
  assign M00_AXI_aruser[0] = s00_couplers_to_axi_interconnect_3_ARUSER;
  assign M00_AXI_arvalid = s00_couplers_to_axi_interconnect_3_ARVALID;
  assign M00_AXI_awaddr[31:0] = s00_couplers_to_axi_interconnect_3_AWADDR;
  assign M00_AXI_awburst[1:0] = s00_couplers_to_axi_interconnect_3_AWBURST;
  assign M00_AXI_awcache[3:0] = s00_couplers_to_axi_interconnect_3_AWCACHE;
  assign M00_AXI_awid[1:0] = s00_couplers_to_axi_interconnect_3_AWID;
  assign M00_AXI_awlen[3:0] = s00_couplers_to_axi_interconnect_3_AWLEN;
  assign M00_AXI_awlock[1:0] = s00_couplers_to_axi_interconnect_3_AWLOCK;
  assign M00_AXI_awprot[2:0] = s00_couplers_to_axi_interconnect_3_AWPROT;
  assign M00_AXI_awqos[3:0] = s00_couplers_to_axi_interconnect_3_AWQOS;
  assign M00_AXI_awsize[2:0] = s00_couplers_to_axi_interconnect_3_AWSIZE;
  assign M00_AXI_awuser[0] = s00_couplers_to_axi_interconnect_3_AWUSER;
  assign M00_AXI_awvalid = s00_couplers_to_axi_interconnect_3_AWVALID;
  assign M00_AXI_bready = s00_couplers_to_axi_interconnect_3_BREADY;
  assign M00_AXI_rready = s00_couplers_to_axi_interconnect_3_RREADY;
  assign M00_AXI_wdata[63:0] = s00_couplers_to_axi_interconnect_3_WDATA;
  assign M00_AXI_wid[1:0] = s00_couplers_to_axi_interconnect_3_WID;
  assign M00_AXI_wlast = s00_couplers_to_axi_interconnect_3_WLAST;
  assign M00_AXI_wstrb[7:0] = s00_couplers_to_axi_interconnect_3_WSTRB;
  assign M00_AXI_wuser[0] = s00_couplers_to_axi_interconnect_3_WUSER;
  assign M00_AXI_wvalid = s00_couplers_to_axi_interconnect_3_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN;
  assign S00_AXI_arready = axi_interconnect_3_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_3_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[1:0] = axi_interconnect_3_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_interconnect_3_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = axi_interconnect_3_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[63:0] = axi_interconnect_3_to_s00_couplers_RDATA;
  assign S00_AXI_rid[1:0] = axi_interconnect_3_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_interconnect_3_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_3_to_s00_couplers_RRESP;
  assign S00_AXI_ruser[0] = axi_interconnect_3_to_s00_couplers_RUSER;
  assign S00_AXI_rvalid = axi_interconnect_3_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_3_to_s00_couplers_WREADY;
  assign axi_interconnect_3_ACLK_net = M00_ACLK;
  assign axi_interconnect_3_ARESETN_net = M00_ARESETN;
  assign axi_interconnect_3_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_interconnect_3_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_3_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_3_to_s00_couplers_ARID = S00_AXI_arid[1:0];
  assign axi_interconnect_3_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign axi_interconnect_3_to_s00_couplers_ARLOCK = S00_AXI_arlock;
  assign axi_interconnect_3_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_3_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_interconnect_3_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_3_to_s00_couplers_ARUSER = S00_AXI_aruser[0];
  assign axi_interconnect_3_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_3_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_interconnect_3_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_3_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_3_to_s00_couplers_AWID = S00_AXI_awid[1:0];
  assign axi_interconnect_3_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign axi_interconnect_3_to_s00_couplers_AWLOCK = S00_AXI_awlock;
  assign axi_interconnect_3_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_3_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_interconnect_3_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_3_to_s00_couplers_AWUSER = S00_AXI_awuser[0];
  assign axi_interconnect_3_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_3_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_3_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_3_to_s00_couplers_WDATA = S00_AXI_wdata[63:0];
  assign axi_interconnect_3_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_3_to_s00_couplers_WSTRB = S00_AXI_wstrb[7:0];
  assign axi_interconnect_3_to_s00_couplers_WUSER = S00_AXI_wuser[0];
  assign axi_interconnect_3_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign s00_couplers_to_axi_interconnect_3_ARREADY = M00_AXI_arready;
  assign s00_couplers_to_axi_interconnect_3_AWREADY = M00_AXI_awready;
  assign s00_couplers_to_axi_interconnect_3_BID = M00_AXI_bid[5:0];
  assign s00_couplers_to_axi_interconnect_3_BRESP = M00_AXI_bresp[1:0];
  assign s00_couplers_to_axi_interconnect_3_BVALID = M00_AXI_bvalid;
  assign s00_couplers_to_axi_interconnect_3_RDATA = M00_AXI_rdata[63:0];
  assign s00_couplers_to_axi_interconnect_3_RID = M00_AXI_rid[5:0];
  assign s00_couplers_to_axi_interconnect_3_RLAST = M00_AXI_rlast;
  assign s00_couplers_to_axi_interconnect_3_RRESP = M00_AXI_rresp[1:0];
  assign s00_couplers_to_axi_interconnect_3_RVALID = M00_AXI_rvalid;
  assign s00_couplers_to_axi_interconnect_3_WREADY = M00_AXI_wready;
  design_1_m00_pchk_2 m00_pchk
       (.aclk(axi_interconnect_3_ACLK_net),
        .aresetn(axi_interconnect_3_ARESETN_net),
        .pc_axi_araddr(s00_couplers_to_axi_interconnect_3_ARADDR),
        .pc_axi_arburst(s00_couplers_to_axi_interconnect_3_ARBURST),
        .pc_axi_arcache(s00_couplers_to_axi_interconnect_3_ARCACHE),
        .pc_axi_arid(s00_couplers_to_axi_interconnect_3_ARID),
        .pc_axi_arlen(s00_couplers_to_axi_interconnect_3_ARLEN),
        .pc_axi_arlock(s00_couplers_to_axi_interconnect_3_ARLOCK),
        .pc_axi_arprot(s00_couplers_to_axi_interconnect_3_ARPROT),
        .pc_axi_arqos(s00_couplers_to_axi_interconnect_3_ARQOS),
        .pc_axi_arready(s00_couplers_to_axi_interconnect_3_ARREADY),
        .pc_axi_arsize(s00_couplers_to_axi_interconnect_3_ARSIZE),
        .pc_axi_aruser(s00_couplers_to_axi_interconnect_3_ARUSER),
        .pc_axi_arvalid(s00_couplers_to_axi_interconnect_3_ARVALID),
        .pc_axi_awaddr(s00_couplers_to_axi_interconnect_3_AWADDR),
        .pc_axi_awburst(s00_couplers_to_axi_interconnect_3_AWBURST),
        .pc_axi_awcache(s00_couplers_to_axi_interconnect_3_AWCACHE),
        .pc_axi_awid(s00_couplers_to_axi_interconnect_3_AWID),
        .pc_axi_awlen(s00_couplers_to_axi_interconnect_3_AWLEN),
        .pc_axi_awlock(s00_couplers_to_axi_interconnect_3_AWLOCK),
        .pc_axi_awprot(s00_couplers_to_axi_interconnect_3_AWPROT),
        .pc_axi_awqos(s00_couplers_to_axi_interconnect_3_AWQOS),
        .pc_axi_awready(s00_couplers_to_axi_interconnect_3_AWREADY),
        .pc_axi_awsize(s00_couplers_to_axi_interconnect_3_AWSIZE),
        .pc_axi_awuser(s00_couplers_to_axi_interconnect_3_AWUSER),
        .pc_axi_awvalid(s00_couplers_to_axi_interconnect_3_AWVALID),
        .pc_axi_bid(s00_couplers_to_axi_interconnect_3_BID[1:0]),
        .pc_axi_bready(s00_couplers_to_axi_interconnect_3_BREADY),
        .pc_axi_bresp(s00_couplers_to_axi_interconnect_3_BRESP),
        .pc_axi_bvalid(s00_couplers_to_axi_interconnect_3_BVALID),
        .pc_axi_rdata(s00_couplers_to_axi_interconnect_3_RDATA),
        .pc_axi_rid(s00_couplers_to_axi_interconnect_3_RID[1:0]),
        .pc_axi_rlast(s00_couplers_to_axi_interconnect_3_RLAST),
        .pc_axi_rready(s00_couplers_to_axi_interconnect_3_RREADY),
        .pc_axi_rresp(s00_couplers_to_axi_interconnect_3_RRESP),
        .pc_axi_ruser(1'b0),
        .pc_axi_rvalid(s00_couplers_to_axi_interconnect_3_RVALID),
        .pc_axi_wdata(s00_couplers_to_axi_interconnect_3_WDATA),
        .pc_axi_wid(s00_couplers_to_axi_interconnect_3_WID),
        .pc_axi_wlast(s00_couplers_to_axi_interconnect_3_WLAST),
        .pc_axi_wready(s00_couplers_to_axi_interconnect_3_WREADY),
        .pc_axi_wstrb(s00_couplers_to_axi_interconnect_3_WSTRB),
        .pc_axi_wuser(s00_couplers_to_axi_interconnect_3_WUSER),
        .pc_axi_wvalid(s00_couplers_to_axi_interconnect_3_WVALID));
  s00_couplers_imp_ULGAU4 s00_couplers
       (.M_ACLK(axi_interconnect_3_ACLK_net),
        .M_ARESETN(axi_interconnect_3_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_axi_interconnect_3_ARADDR),
        .M_AXI_arburst(s00_couplers_to_axi_interconnect_3_ARBURST),
        .M_AXI_arcache(s00_couplers_to_axi_interconnect_3_ARCACHE),
        .M_AXI_arid(s00_couplers_to_axi_interconnect_3_ARID),
        .M_AXI_arlen(s00_couplers_to_axi_interconnect_3_ARLEN),
        .M_AXI_arlock(s00_couplers_to_axi_interconnect_3_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_axi_interconnect_3_ARPROT),
        .M_AXI_arqos(s00_couplers_to_axi_interconnect_3_ARQOS),
        .M_AXI_arready(s00_couplers_to_axi_interconnect_3_ARREADY),
        .M_AXI_arsize(s00_couplers_to_axi_interconnect_3_ARSIZE),
        .M_AXI_aruser(s00_couplers_to_axi_interconnect_3_ARUSER),
        .M_AXI_arvalid(s00_couplers_to_axi_interconnect_3_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_axi_interconnect_3_AWADDR),
        .M_AXI_awburst(s00_couplers_to_axi_interconnect_3_AWBURST),
        .M_AXI_awcache(s00_couplers_to_axi_interconnect_3_AWCACHE),
        .M_AXI_awid(s00_couplers_to_axi_interconnect_3_AWID),
        .M_AXI_awlen(s00_couplers_to_axi_interconnect_3_AWLEN),
        .M_AXI_awlock(s00_couplers_to_axi_interconnect_3_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_axi_interconnect_3_AWPROT),
        .M_AXI_awqos(s00_couplers_to_axi_interconnect_3_AWQOS),
        .M_AXI_awready(s00_couplers_to_axi_interconnect_3_AWREADY),
        .M_AXI_awsize(s00_couplers_to_axi_interconnect_3_AWSIZE),
        .M_AXI_awuser(s00_couplers_to_axi_interconnect_3_AWUSER),
        .M_AXI_awvalid(s00_couplers_to_axi_interconnect_3_AWVALID),
        .M_AXI_bid(s00_couplers_to_axi_interconnect_3_BID),
        .M_AXI_bready(s00_couplers_to_axi_interconnect_3_BREADY),
        .M_AXI_bresp(s00_couplers_to_axi_interconnect_3_BRESP),
        .M_AXI_bvalid(s00_couplers_to_axi_interconnect_3_BVALID),
        .M_AXI_rdata(s00_couplers_to_axi_interconnect_3_RDATA),
        .M_AXI_rid(s00_couplers_to_axi_interconnect_3_RID),
        .M_AXI_rlast(s00_couplers_to_axi_interconnect_3_RLAST),
        .M_AXI_rready(s00_couplers_to_axi_interconnect_3_RREADY),
        .M_AXI_rresp(s00_couplers_to_axi_interconnect_3_RRESP),
        .M_AXI_rvalid(s00_couplers_to_axi_interconnect_3_RVALID),
        .M_AXI_wdata(s00_couplers_to_axi_interconnect_3_WDATA),
        .M_AXI_wid(s00_couplers_to_axi_interconnect_3_WID),
        .M_AXI_wlast(s00_couplers_to_axi_interconnect_3_WLAST),
        .M_AXI_wready(s00_couplers_to_axi_interconnect_3_WREADY),
        .M_AXI_wstrb(s00_couplers_to_axi_interconnect_3_WSTRB),
        .M_AXI_wuser(s00_couplers_to_axi_interconnect_3_WUSER),
        .M_AXI_wvalid(s00_couplers_to_axi_interconnect_3_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(axi_interconnect_3_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_3_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_3_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_interconnect_3_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_interconnect_3_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_3_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_3_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_3_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_3_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_3_to_s00_couplers_ARSIZE),
        .S_AXI_aruser(axi_interconnect_3_to_s00_couplers_ARUSER),
        .S_AXI_arvalid(axi_interconnect_3_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_3_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_3_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_3_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_interconnect_3_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_interconnect_3_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_3_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_3_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_3_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_3_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_3_to_s00_couplers_AWSIZE),
        .S_AXI_awuser(axi_interconnect_3_to_s00_couplers_AWUSER),
        .S_AXI_awvalid(axi_interconnect_3_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_interconnect_3_to_s00_couplers_BID),
        .S_AXI_bready(axi_interconnect_3_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_3_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_3_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_3_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_interconnect_3_to_s00_couplers_RID),
        .S_AXI_rlast(axi_interconnect_3_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_3_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_3_to_s00_couplers_RRESP),
        .S_AXI_ruser(axi_interconnect_3_to_s00_couplers_RUSER),
        .S_AXI_rvalid(axi_interconnect_3_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_3_to_s00_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_3_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_3_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_3_to_s00_couplers_WSTRB),
        .S_AXI_wuser(axi_interconnect_3_to_s00_couplers_WUSER),
        .S_AXI_wvalid(axi_interconnect_3_to_s00_couplers_WVALID));
  design_1_s00_pchk_2 s00_pchk
       (.aclk(S00_ACLK_1),
        .aresetn(S00_ARESETN_1),
        .pc_axi_araddr(axi_interconnect_3_to_s00_couplers_ARADDR),
        .pc_axi_arburst(axi_interconnect_3_to_s00_couplers_ARBURST),
        .pc_axi_arcache(axi_interconnect_3_to_s00_couplers_ARCACHE),
        .pc_axi_arid(axi_interconnect_3_to_s00_couplers_ARID),
        .pc_axi_arlen(axi_interconnect_3_to_s00_couplers_ARLEN),
        .pc_axi_arlock(axi_interconnect_3_to_s00_couplers_ARLOCK),
        .pc_axi_arprot(axi_interconnect_3_to_s00_couplers_ARPROT),
        .pc_axi_arqos(axi_interconnect_3_to_s00_couplers_ARQOS),
        .pc_axi_arready(axi_interconnect_3_to_s00_couplers_ARREADY),
        .pc_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_arsize(axi_interconnect_3_to_s00_couplers_ARSIZE),
        .pc_axi_aruser(axi_interconnect_3_to_s00_couplers_ARUSER),
        .pc_axi_arvalid(axi_interconnect_3_to_s00_couplers_ARVALID),
        .pc_axi_awaddr(axi_interconnect_3_to_s00_couplers_AWADDR),
        .pc_axi_awburst(axi_interconnect_3_to_s00_couplers_AWBURST),
        .pc_axi_awcache(axi_interconnect_3_to_s00_couplers_AWCACHE),
        .pc_axi_awid(axi_interconnect_3_to_s00_couplers_AWID),
        .pc_axi_awlen(axi_interconnect_3_to_s00_couplers_AWLEN),
        .pc_axi_awlock(axi_interconnect_3_to_s00_couplers_AWLOCK),
        .pc_axi_awprot(axi_interconnect_3_to_s00_couplers_AWPROT),
        .pc_axi_awqos(axi_interconnect_3_to_s00_couplers_AWQOS),
        .pc_axi_awready(axi_interconnect_3_to_s00_couplers_AWREADY),
        .pc_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_awsize(axi_interconnect_3_to_s00_couplers_AWSIZE),
        .pc_axi_awuser(axi_interconnect_3_to_s00_couplers_AWUSER),
        .pc_axi_awvalid(axi_interconnect_3_to_s00_couplers_AWVALID),
        .pc_axi_bid(axi_interconnect_3_to_s00_couplers_BID),
        .pc_axi_bready(axi_interconnect_3_to_s00_couplers_BREADY),
        .pc_axi_bresp(axi_interconnect_3_to_s00_couplers_BRESP),
        .pc_axi_buser(1'b0),
        .pc_axi_bvalid(axi_interconnect_3_to_s00_couplers_BVALID),
        .pc_axi_rdata(axi_interconnect_3_to_s00_couplers_RDATA),
        .pc_axi_rid(axi_interconnect_3_to_s00_couplers_RID),
        .pc_axi_rlast(axi_interconnect_3_to_s00_couplers_RLAST),
        .pc_axi_rready(axi_interconnect_3_to_s00_couplers_RREADY),
        .pc_axi_rresp(axi_interconnect_3_to_s00_couplers_RRESP),
        .pc_axi_ruser(axi_interconnect_3_to_s00_couplers_RUSER),
        .pc_axi_rvalid(axi_interconnect_3_to_s00_couplers_RVALID),
        .pc_axi_wdata(axi_interconnect_3_to_s00_couplers_WDATA),
        .pc_axi_wlast(axi_interconnect_3_to_s00_couplers_WLAST),
        .pc_axi_wready(axi_interconnect_3_to_s00_couplers_WREADY),
        .pc_axi_wstrb(axi_interconnect_3_to_s00_couplers_WSTRB),
        .pc_axi_wuser(axi_interconnect_3_to_s00_couplers_WUSER),
        .pc_axi_wvalid(axi_interconnect_3_to_s00_couplers_WVALID));
endmodule

module design_1_axi_interconnect_1_2
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_aruser,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awuser,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wid,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wuser,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_aruser,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awuser,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_ruser,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wuser,
    S00_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [1:0]M00_AXI_arid;
  output [3:0]M00_AXI_arlen;
  output [1:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output [0:0]M00_AXI_aruser;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [1:0]M00_AXI_awid;
  output [3:0]M00_AXI_awlen;
  output [1:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output [0:0]M00_AXI_awuser;
  output M00_AXI_awvalid;
  input [5:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [5:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output [1:0]M00_AXI_wid;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wuser;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [1:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input [0:0]S00_AXI_aruser;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [1:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input [0:0]S00_AXI_awuser;
  input S00_AXI_awvalid;
  output [1:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [63:0]S00_AXI_rdata;
  output [1:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_ruser;
  output S00_AXI_rvalid;
  input [63:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [7:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wuser;
  input S00_AXI_wvalid;

  wire S00_ACLK_1;
  (* MARK_DEBUG *) wire S00_ARESETN_1;
  wire axi_interconnect_4_ACLK_net;
  (* MARK_DEBUG *) wire axi_interconnect_4_ARESETN_net;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_4_to_s00_couplers_ARADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_ARBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_4_to_s00_couplers_ARCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_ARID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_4_to_s00_couplers_ARLEN;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_4_to_s00_couplers_ARPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_4_to_s00_couplers_ARQOS;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_ARREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_4_to_s00_couplers_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_4_to_s00_couplers_ARUSER;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_ARVALID;
  (* MARK_DEBUG *) wire [31:0]axi_interconnect_4_to_s00_couplers_AWADDR;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_AWBURST;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_4_to_s00_couplers_AWCACHE;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_AWID;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_4_to_s00_couplers_AWLEN;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_4_to_s00_couplers_AWPROT;
  (* MARK_DEBUG *) wire [3:0]axi_interconnect_4_to_s00_couplers_AWQOS;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_AWREADY;
  (* MARK_DEBUG *) wire [2:0]axi_interconnect_4_to_s00_couplers_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_4_to_s00_couplers_AWUSER;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_AWVALID;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_BID;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_BREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_BRESP;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_BVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_4_to_s00_couplers_RDATA;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_RID;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_RLAST;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_RREADY;
  (* MARK_DEBUG *) wire [1:0]axi_interconnect_4_to_s00_couplers_RRESP;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_4_to_s00_couplers_RUSER;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_RVALID;
  (* MARK_DEBUG *) wire [63:0]axi_interconnect_4_to_s00_couplers_WDATA;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_WLAST;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_WREADY;
  (* MARK_DEBUG *) wire [7:0]axi_interconnect_4_to_s00_couplers_WSTRB;
  (* MARK_DEBUG *) wire [0:0]axi_interconnect_4_to_s00_couplers_WUSER;
  (* MARK_DEBUG *) wire axi_interconnect_4_to_s00_couplers_WVALID;
  (* MARK_DEBUG *) wire [31:0]s00_couplers_to_axi_interconnect_4_ARADDR;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_ARBURST;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_4_ARCACHE;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_ARID;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_4_ARLEN;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_ARLOCK;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_4_ARPROT;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_4_ARQOS;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_ARREADY;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_4_ARSIZE;
  (* MARK_DEBUG *) wire [0:0]s00_couplers_to_axi_interconnect_4_ARUSER;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_ARVALID;
  (* MARK_DEBUG *) wire [31:0]s00_couplers_to_axi_interconnect_4_AWADDR;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_AWBURST;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_4_AWCACHE;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_AWID;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_4_AWLEN;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_AWLOCK;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_4_AWPROT;
  (* MARK_DEBUG *) wire [3:0]s00_couplers_to_axi_interconnect_4_AWQOS;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_AWREADY;
  (* MARK_DEBUG *) wire [2:0]s00_couplers_to_axi_interconnect_4_AWSIZE;
  (* MARK_DEBUG *) wire [0:0]s00_couplers_to_axi_interconnect_4_AWUSER;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_AWVALID;
  (* MARK_DEBUG *) wire [5:0]s00_couplers_to_axi_interconnect_4_BID;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_BREADY;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_BRESP;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_BVALID;
  (* MARK_DEBUG *) wire [63:0]s00_couplers_to_axi_interconnect_4_RDATA;
  (* MARK_DEBUG *) wire [5:0]s00_couplers_to_axi_interconnect_4_RID;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_RLAST;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_RREADY;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_RRESP;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_RVALID;
  (* MARK_DEBUG *) wire [63:0]s00_couplers_to_axi_interconnect_4_WDATA;
  (* MARK_DEBUG *) wire [1:0]s00_couplers_to_axi_interconnect_4_WID;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_WLAST;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_WREADY;
  (* MARK_DEBUG *) wire [7:0]s00_couplers_to_axi_interconnect_4_WSTRB;
  (* MARK_DEBUG *) wire [0:0]s00_couplers_to_axi_interconnect_4_WUSER;
  (* MARK_DEBUG *) wire s00_couplers_to_axi_interconnect_4_WVALID;

  assign M00_AXI_araddr[31:0] = s00_couplers_to_axi_interconnect_4_ARADDR;
  assign M00_AXI_arburst[1:0] = s00_couplers_to_axi_interconnect_4_ARBURST;
  assign M00_AXI_arcache[3:0] = s00_couplers_to_axi_interconnect_4_ARCACHE;
  assign M00_AXI_arid[1:0] = s00_couplers_to_axi_interconnect_4_ARID;
  assign M00_AXI_arlen[3:0] = s00_couplers_to_axi_interconnect_4_ARLEN;
  assign M00_AXI_arlock[1:0] = s00_couplers_to_axi_interconnect_4_ARLOCK;
  assign M00_AXI_arprot[2:0] = s00_couplers_to_axi_interconnect_4_ARPROT;
  assign M00_AXI_arqos[3:0] = s00_couplers_to_axi_interconnect_4_ARQOS;
  assign M00_AXI_arsize[2:0] = s00_couplers_to_axi_interconnect_4_ARSIZE;
  assign M00_AXI_aruser[0] = s00_couplers_to_axi_interconnect_4_ARUSER;
  assign M00_AXI_arvalid = s00_couplers_to_axi_interconnect_4_ARVALID;
  assign M00_AXI_awaddr[31:0] = s00_couplers_to_axi_interconnect_4_AWADDR;
  assign M00_AXI_awburst[1:0] = s00_couplers_to_axi_interconnect_4_AWBURST;
  assign M00_AXI_awcache[3:0] = s00_couplers_to_axi_interconnect_4_AWCACHE;
  assign M00_AXI_awid[1:0] = s00_couplers_to_axi_interconnect_4_AWID;
  assign M00_AXI_awlen[3:0] = s00_couplers_to_axi_interconnect_4_AWLEN;
  assign M00_AXI_awlock[1:0] = s00_couplers_to_axi_interconnect_4_AWLOCK;
  assign M00_AXI_awprot[2:0] = s00_couplers_to_axi_interconnect_4_AWPROT;
  assign M00_AXI_awqos[3:0] = s00_couplers_to_axi_interconnect_4_AWQOS;
  assign M00_AXI_awsize[2:0] = s00_couplers_to_axi_interconnect_4_AWSIZE;
  assign M00_AXI_awuser[0] = s00_couplers_to_axi_interconnect_4_AWUSER;
  assign M00_AXI_awvalid = s00_couplers_to_axi_interconnect_4_AWVALID;
  assign M00_AXI_bready = s00_couplers_to_axi_interconnect_4_BREADY;
  assign M00_AXI_rready = s00_couplers_to_axi_interconnect_4_RREADY;
  assign M00_AXI_wdata[63:0] = s00_couplers_to_axi_interconnect_4_WDATA;
  assign M00_AXI_wid[1:0] = s00_couplers_to_axi_interconnect_4_WID;
  assign M00_AXI_wlast = s00_couplers_to_axi_interconnect_4_WLAST;
  assign M00_AXI_wstrb[7:0] = s00_couplers_to_axi_interconnect_4_WSTRB;
  assign M00_AXI_wuser[0] = s00_couplers_to_axi_interconnect_4_WUSER;
  assign M00_AXI_wvalid = s00_couplers_to_axi_interconnect_4_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN;
  assign S00_AXI_arready = axi_interconnect_4_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_4_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[1:0] = axi_interconnect_4_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_interconnect_4_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = axi_interconnect_4_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[63:0] = axi_interconnect_4_to_s00_couplers_RDATA;
  assign S00_AXI_rid[1:0] = axi_interconnect_4_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_interconnect_4_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_4_to_s00_couplers_RRESP;
  assign S00_AXI_ruser[0] = axi_interconnect_4_to_s00_couplers_RUSER;
  assign S00_AXI_rvalid = axi_interconnect_4_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_4_to_s00_couplers_WREADY;
  assign axi_interconnect_4_ACLK_net = M00_ACLK;
  assign axi_interconnect_4_ARESETN_net = M00_ARESETN;
  assign axi_interconnect_4_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_interconnect_4_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_4_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_4_to_s00_couplers_ARID = S00_AXI_arid[1:0];
  assign axi_interconnect_4_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign axi_interconnect_4_to_s00_couplers_ARLOCK = S00_AXI_arlock;
  assign axi_interconnect_4_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_4_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_interconnect_4_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_4_to_s00_couplers_ARUSER = S00_AXI_aruser[0];
  assign axi_interconnect_4_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_4_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_interconnect_4_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_4_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_4_to_s00_couplers_AWID = S00_AXI_awid[1:0];
  assign axi_interconnect_4_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign axi_interconnect_4_to_s00_couplers_AWLOCK = S00_AXI_awlock;
  assign axi_interconnect_4_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_4_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_interconnect_4_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_4_to_s00_couplers_AWUSER = S00_AXI_awuser[0];
  assign axi_interconnect_4_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_4_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_4_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_4_to_s00_couplers_WDATA = S00_AXI_wdata[63:0];
  assign axi_interconnect_4_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_4_to_s00_couplers_WSTRB = S00_AXI_wstrb[7:0];
  assign axi_interconnect_4_to_s00_couplers_WUSER = S00_AXI_wuser[0];
  assign axi_interconnect_4_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign s00_couplers_to_axi_interconnect_4_ARREADY = M00_AXI_arready;
  assign s00_couplers_to_axi_interconnect_4_AWREADY = M00_AXI_awready;
  assign s00_couplers_to_axi_interconnect_4_BID = M00_AXI_bid[5:0];
  assign s00_couplers_to_axi_interconnect_4_BRESP = M00_AXI_bresp[1:0];
  assign s00_couplers_to_axi_interconnect_4_BVALID = M00_AXI_bvalid;
  assign s00_couplers_to_axi_interconnect_4_RDATA = M00_AXI_rdata[63:0];
  assign s00_couplers_to_axi_interconnect_4_RID = M00_AXI_rid[5:0];
  assign s00_couplers_to_axi_interconnect_4_RLAST = M00_AXI_rlast;
  assign s00_couplers_to_axi_interconnect_4_RRESP = M00_AXI_rresp[1:0];
  assign s00_couplers_to_axi_interconnect_4_RVALID = M00_AXI_rvalid;
  assign s00_couplers_to_axi_interconnect_4_WREADY = M00_AXI_wready;
  design_1_m00_pchk_3 m00_pchk
       (.aclk(axi_interconnect_4_ACLK_net),
        .aresetn(axi_interconnect_4_ARESETN_net),
        .pc_axi_araddr(s00_couplers_to_axi_interconnect_4_ARADDR),
        .pc_axi_arburst(s00_couplers_to_axi_interconnect_4_ARBURST),
        .pc_axi_arcache(s00_couplers_to_axi_interconnect_4_ARCACHE),
        .pc_axi_arid(s00_couplers_to_axi_interconnect_4_ARID),
        .pc_axi_arlen(s00_couplers_to_axi_interconnect_4_ARLEN),
        .pc_axi_arlock(s00_couplers_to_axi_interconnect_4_ARLOCK),
        .pc_axi_arprot(s00_couplers_to_axi_interconnect_4_ARPROT),
        .pc_axi_arqos(s00_couplers_to_axi_interconnect_4_ARQOS),
        .pc_axi_arready(s00_couplers_to_axi_interconnect_4_ARREADY),
        .pc_axi_arsize(s00_couplers_to_axi_interconnect_4_ARSIZE),
        .pc_axi_aruser(s00_couplers_to_axi_interconnect_4_ARUSER),
        .pc_axi_arvalid(s00_couplers_to_axi_interconnect_4_ARVALID),
        .pc_axi_awaddr(s00_couplers_to_axi_interconnect_4_AWADDR),
        .pc_axi_awburst(s00_couplers_to_axi_interconnect_4_AWBURST),
        .pc_axi_awcache(s00_couplers_to_axi_interconnect_4_AWCACHE),
        .pc_axi_awid(s00_couplers_to_axi_interconnect_4_AWID),
        .pc_axi_awlen(s00_couplers_to_axi_interconnect_4_AWLEN),
        .pc_axi_awlock(s00_couplers_to_axi_interconnect_4_AWLOCK),
        .pc_axi_awprot(s00_couplers_to_axi_interconnect_4_AWPROT),
        .pc_axi_awqos(s00_couplers_to_axi_interconnect_4_AWQOS),
        .pc_axi_awready(s00_couplers_to_axi_interconnect_4_AWREADY),
        .pc_axi_awsize(s00_couplers_to_axi_interconnect_4_AWSIZE),
        .pc_axi_awuser(s00_couplers_to_axi_interconnect_4_AWUSER),
        .pc_axi_awvalid(s00_couplers_to_axi_interconnect_4_AWVALID),
        .pc_axi_bid(s00_couplers_to_axi_interconnect_4_BID[1:0]),
        .pc_axi_bready(s00_couplers_to_axi_interconnect_4_BREADY),
        .pc_axi_bresp(s00_couplers_to_axi_interconnect_4_BRESP),
        .pc_axi_bvalid(s00_couplers_to_axi_interconnect_4_BVALID),
        .pc_axi_rdata(s00_couplers_to_axi_interconnect_4_RDATA),
        .pc_axi_rid(s00_couplers_to_axi_interconnect_4_RID[1:0]),
        .pc_axi_rlast(s00_couplers_to_axi_interconnect_4_RLAST),
        .pc_axi_rready(s00_couplers_to_axi_interconnect_4_RREADY),
        .pc_axi_rresp(s00_couplers_to_axi_interconnect_4_RRESP),
        .pc_axi_ruser(1'b0),
        .pc_axi_rvalid(s00_couplers_to_axi_interconnect_4_RVALID),
        .pc_axi_wdata(s00_couplers_to_axi_interconnect_4_WDATA),
        .pc_axi_wid(s00_couplers_to_axi_interconnect_4_WID),
        .pc_axi_wlast(s00_couplers_to_axi_interconnect_4_WLAST),
        .pc_axi_wready(s00_couplers_to_axi_interconnect_4_WREADY),
        .pc_axi_wstrb(s00_couplers_to_axi_interconnect_4_WSTRB),
        .pc_axi_wuser(s00_couplers_to_axi_interconnect_4_WUSER),
        .pc_axi_wvalid(s00_couplers_to_axi_interconnect_4_WVALID));
  s00_couplers_imp_37YZ6K s00_couplers
       (.M_ACLK(axi_interconnect_4_ACLK_net),
        .M_ARESETN(axi_interconnect_4_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_axi_interconnect_4_ARADDR),
        .M_AXI_arburst(s00_couplers_to_axi_interconnect_4_ARBURST),
        .M_AXI_arcache(s00_couplers_to_axi_interconnect_4_ARCACHE),
        .M_AXI_arid(s00_couplers_to_axi_interconnect_4_ARID),
        .M_AXI_arlen(s00_couplers_to_axi_interconnect_4_ARLEN),
        .M_AXI_arlock(s00_couplers_to_axi_interconnect_4_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_axi_interconnect_4_ARPROT),
        .M_AXI_arqos(s00_couplers_to_axi_interconnect_4_ARQOS),
        .M_AXI_arready(s00_couplers_to_axi_interconnect_4_ARREADY),
        .M_AXI_arsize(s00_couplers_to_axi_interconnect_4_ARSIZE),
        .M_AXI_aruser(s00_couplers_to_axi_interconnect_4_ARUSER),
        .M_AXI_arvalid(s00_couplers_to_axi_interconnect_4_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_axi_interconnect_4_AWADDR),
        .M_AXI_awburst(s00_couplers_to_axi_interconnect_4_AWBURST),
        .M_AXI_awcache(s00_couplers_to_axi_interconnect_4_AWCACHE),
        .M_AXI_awid(s00_couplers_to_axi_interconnect_4_AWID),
        .M_AXI_awlen(s00_couplers_to_axi_interconnect_4_AWLEN),
        .M_AXI_awlock(s00_couplers_to_axi_interconnect_4_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_axi_interconnect_4_AWPROT),
        .M_AXI_awqos(s00_couplers_to_axi_interconnect_4_AWQOS),
        .M_AXI_awready(s00_couplers_to_axi_interconnect_4_AWREADY),
        .M_AXI_awsize(s00_couplers_to_axi_interconnect_4_AWSIZE),
        .M_AXI_awuser(s00_couplers_to_axi_interconnect_4_AWUSER),
        .M_AXI_awvalid(s00_couplers_to_axi_interconnect_4_AWVALID),
        .M_AXI_bid(s00_couplers_to_axi_interconnect_4_BID),
        .M_AXI_bready(s00_couplers_to_axi_interconnect_4_BREADY),
        .M_AXI_bresp(s00_couplers_to_axi_interconnect_4_BRESP),
        .M_AXI_bvalid(s00_couplers_to_axi_interconnect_4_BVALID),
        .M_AXI_rdata(s00_couplers_to_axi_interconnect_4_RDATA),
        .M_AXI_rid(s00_couplers_to_axi_interconnect_4_RID),
        .M_AXI_rlast(s00_couplers_to_axi_interconnect_4_RLAST),
        .M_AXI_rready(s00_couplers_to_axi_interconnect_4_RREADY),
        .M_AXI_rresp(s00_couplers_to_axi_interconnect_4_RRESP),
        .M_AXI_rvalid(s00_couplers_to_axi_interconnect_4_RVALID),
        .M_AXI_wdata(s00_couplers_to_axi_interconnect_4_WDATA),
        .M_AXI_wid(s00_couplers_to_axi_interconnect_4_WID),
        .M_AXI_wlast(s00_couplers_to_axi_interconnect_4_WLAST),
        .M_AXI_wready(s00_couplers_to_axi_interconnect_4_WREADY),
        .M_AXI_wstrb(s00_couplers_to_axi_interconnect_4_WSTRB),
        .M_AXI_wuser(s00_couplers_to_axi_interconnect_4_WUSER),
        .M_AXI_wvalid(s00_couplers_to_axi_interconnect_4_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(axi_interconnect_4_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_4_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_4_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_interconnect_4_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_interconnect_4_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_4_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_4_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_4_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_4_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_4_to_s00_couplers_ARSIZE),
        .S_AXI_aruser(axi_interconnect_4_to_s00_couplers_ARUSER),
        .S_AXI_arvalid(axi_interconnect_4_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_4_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_4_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_4_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_interconnect_4_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_interconnect_4_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_4_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_4_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_4_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_4_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_4_to_s00_couplers_AWSIZE),
        .S_AXI_awuser(axi_interconnect_4_to_s00_couplers_AWUSER),
        .S_AXI_awvalid(axi_interconnect_4_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_interconnect_4_to_s00_couplers_BID),
        .S_AXI_bready(axi_interconnect_4_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_4_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_4_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_4_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_interconnect_4_to_s00_couplers_RID),
        .S_AXI_rlast(axi_interconnect_4_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_4_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_4_to_s00_couplers_RRESP),
        .S_AXI_ruser(axi_interconnect_4_to_s00_couplers_RUSER),
        .S_AXI_rvalid(axi_interconnect_4_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_4_to_s00_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_4_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_4_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_4_to_s00_couplers_WSTRB),
        .S_AXI_wuser(axi_interconnect_4_to_s00_couplers_WUSER),
        .S_AXI_wvalid(axi_interconnect_4_to_s00_couplers_WVALID));
  design_1_s00_pchk_3 s00_pchk
       (.aclk(S00_ACLK_1),
        .aresetn(S00_ARESETN_1),
        .pc_axi_araddr(axi_interconnect_4_to_s00_couplers_ARADDR),
        .pc_axi_arburst(axi_interconnect_4_to_s00_couplers_ARBURST),
        .pc_axi_arcache(axi_interconnect_4_to_s00_couplers_ARCACHE),
        .pc_axi_arid(axi_interconnect_4_to_s00_couplers_ARID),
        .pc_axi_arlen(axi_interconnect_4_to_s00_couplers_ARLEN),
        .pc_axi_arlock(axi_interconnect_4_to_s00_couplers_ARLOCK),
        .pc_axi_arprot(axi_interconnect_4_to_s00_couplers_ARPROT),
        .pc_axi_arqos(axi_interconnect_4_to_s00_couplers_ARQOS),
        .pc_axi_arready(axi_interconnect_4_to_s00_couplers_ARREADY),
        .pc_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_arsize(axi_interconnect_4_to_s00_couplers_ARSIZE),
        .pc_axi_aruser(axi_interconnect_4_to_s00_couplers_ARUSER),
        .pc_axi_arvalid(axi_interconnect_4_to_s00_couplers_ARVALID),
        .pc_axi_awaddr(axi_interconnect_4_to_s00_couplers_AWADDR),
        .pc_axi_awburst(axi_interconnect_4_to_s00_couplers_AWBURST),
        .pc_axi_awcache(axi_interconnect_4_to_s00_couplers_AWCACHE),
        .pc_axi_awid(axi_interconnect_4_to_s00_couplers_AWID),
        .pc_axi_awlen(axi_interconnect_4_to_s00_couplers_AWLEN),
        .pc_axi_awlock(axi_interconnect_4_to_s00_couplers_AWLOCK),
        .pc_axi_awprot(axi_interconnect_4_to_s00_couplers_AWPROT),
        .pc_axi_awqos(axi_interconnect_4_to_s00_couplers_AWQOS),
        .pc_axi_awready(axi_interconnect_4_to_s00_couplers_AWREADY),
        .pc_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .pc_axi_awsize(axi_interconnect_4_to_s00_couplers_AWSIZE),
        .pc_axi_awuser(axi_interconnect_4_to_s00_couplers_AWUSER),
        .pc_axi_awvalid(axi_interconnect_4_to_s00_couplers_AWVALID),
        .pc_axi_bid(axi_interconnect_4_to_s00_couplers_BID),
        .pc_axi_bready(axi_interconnect_4_to_s00_couplers_BREADY),
        .pc_axi_bresp(axi_interconnect_4_to_s00_couplers_BRESP),
        .pc_axi_buser(1'b0),
        .pc_axi_bvalid(axi_interconnect_4_to_s00_couplers_BVALID),
        .pc_axi_rdata(axi_interconnect_4_to_s00_couplers_RDATA),
        .pc_axi_rid(axi_interconnect_4_to_s00_couplers_RID),
        .pc_axi_rlast(axi_interconnect_4_to_s00_couplers_RLAST),
        .pc_axi_rready(axi_interconnect_4_to_s00_couplers_RREADY),
        .pc_axi_rresp(axi_interconnect_4_to_s00_couplers_RRESP),
        .pc_axi_ruser(axi_interconnect_4_to_s00_couplers_RUSER),
        .pc_axi_rvalid(axi_interconnect_4_to_s00_couplers_RVALID),
        .pc_axi_wdata(axi_interconnect_4_to_s00_couplers_WDATA),
        .pc_axi_wlast(axi_interconnect_4_to_s00_couplers_WLAST),
        .pc_axi_wready(axi_interconnect_4_to_s00_couplers_WREADY),
        .pc_axi_wstrb(axi_interconnect_4_to_s00_couplers_WSTRB),
        .pc_axi_wuser(axi_interconnect_4_to_s00_couplers_WUSER),
        .pc_axi_wvalid(axi_interconnect_4_to_s00_couplers_WVALID));
endmodule

module m00_couplers_imp_1CA5Z32
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]m00_couplers_to_m00_couplers_ARADDR;
  wire [2:0]m00_couplers_to_m00_couplers_ARPROT;
  wire m00_couplers_to_m00_couplers_ARREADY;
  wire m00_couplers_to_m00_couplers_ARVALID;
  wire [31:0]m00_couplers_to_m00_couplers_AWADDR;
  wire [2:0]m00_couplers_to_m00_couplers_AWPROT;
  wire m00_couplers_to_m00_couplers_AWREADY;
  wire m00_couplers_to_m00_couplers_AWVALID;
  wire m00_couplers_to_m00_couplers_BREADY;
  wire [1:0]m00_couplers_to_m00_couplers_BRESP;
  wire m00_couplers_to_m00_couplers_BVALID;
  wire [31:0]m00_couplers_to_m00_couplers_RDATA;
  wire m00_couplers_to_m00_couplers_RREADY;
  wire [1:0]m00_couplers_to_m00_couplers_RRESP;
  wire m00_couplers_to_m00_couplers_RVALID;
  wire [31:0]m00_couplers_to_m00_couplers_WDATA;
  wire m00_couplers_to_m00_couplers_WREADY;
  wire [3:0]m00_couplers_to_m00_couplers_WSTRB;
  wire m00_couplers_to_m00_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m00_couplers_to_m00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m00_couplers_to_m00_couplers_ARPROT;
  assign M_AXI_arvalid = m00_couplers_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m00_couplers_to_m00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m00_couplers_to_m00_couplers_AWPROT;
  assign M_AXI_awvalid = m00_couplers_to_m00_couplers_AWVALID;
  assign M_AXI_bready = m00_couplers_to_m00_couplers_BREADY;
  assign M_AXI_rready = m00_couplers_to_m00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m00_couplers_to_m00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m00_couplers_to_m00_couplers_WSTRB;
  assign M_AXI_wvalid = m00_couplers_to_m00_couplers_WVALID;
  assign S_AXI_arready = m00_couplers_to_m00_couplers_ARREADY;
  assign S_AXI_awready = m00_couplers_to_m00_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m00_couplers_to_m00_couplers_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_m00_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m00_couplers_to_m00_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m00_couplers_to_m00_couplers_RRESP;
  assign S_AXI_rvalid = m00_couplers_to_m00_couplers_RVALID;
  assign S_AXI_wready = m00_couplers_to_m00_couplers_WREADY;
  assign m00_couplers_to_m00_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_m00_couplers_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_m00_couplers_ARREADY = M_AXI_arready;
  assign m00_couplers_to_m00_couplers_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_m00_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_m00_couplers_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_m00_couplers_AWREADY = M_AXI_awready;
  assign m00_couplers_to_m00_couplers_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_m00_couplers_BREADY = S_AXI_bready;
  assign m00_couplers_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_couplers_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign m00_couplers_to_m00_couplers_RDATA = M_AXI_rdata[31:0];
  assign m00_couplers_to_m00_couplers_RREADY = S_AXI_rready;
  assign m00_couplers_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_couplers_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign m00_couplers_to_m00_couplers_WDATA = S_AXI_wdata[31:0];
  assign m00_couplers_to_m00_couplers_WREADY = M_AXI_wready;
  assign m00_couplers_to_m00_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m00_couplers_to_m00_couplers_WVALID = S_AXI_wvalid;
endmodule

module m00_couplers_imp_1FDLJBY
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wuser,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [2:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output [0:0]M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [2:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output [0:0]M_AXI_awuser;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [2:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output [0:0]M_AXI_wuser;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [2:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [2:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [2:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [2:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_pc_to_m00_couplers_ARADDR;
  wire [1:0]auto_pc_to_m00_couplers_ARBURST;
  wire [3:0]auto_pc_to_m00_couplers_ARCACHE;
  wire [2:0]auto_pc_to_m00_couplers_ARID;
  wire [3:0]auto_pc_to_m00_couplers_ARLEN;
  wire [1:0]auto_pc_to_m00_couplers_ARLOCK;
  wire [2:0]auto_pc_to_m00_couplers_ARPROT;
  wire [3:0]auto_pc_to_m00_couplers_ARQOS;
  wire auto_pc_to_m00_couplers_ARREADY;
  wire [2:0]auto_pc_to_m00_couplers_ARSIZE;
  wire [0:0]auto_pc_to_m00_couplers_ARUSER;
  wire auto_pc_to_m00_couplers_ARVALID;
  wire [31:0]auto_pc_to_m00_couplers_AWADDR;
  wire [1:0]auto_pc_to_m00_couplers_AWBURST;
  wire [3:0]auto_pc_to_m00_couplers_AWCACHE;
  wire [2:0]auto_pc_to_m00_couplers_AWID;
  wire [3:0]auto_pc_to_m00_couplers_AWLEN;
  wire [1:0]auto_pc_to_m00_couplers_AWLOCK;
  wire [2:0]auto_pc_to_m00_couplers_AWPROT;
  wire [3:0]auto_pc_to_m00_couplers_AWQOS;
  wire auto_pc_to_m00_couplers_AWREADY;
  wire [2:0]auto_pc_to_m00_couplers_AWSIZE;
  wire [0:0]auto_pc_to_m00_couplers_AWUSER;
  wire auto_pc_to_m00_couplers_AWVALID;
  wire [5:0]auto_pc_to_m00_couplers_BID;
  wire auto_pc_to_m00_couplers_BREADY;
  wire [1:0]auto_pc_to_m00_couplers_BRESP;
  wire auto_pc_to_m00_couplers_BVALID;
  wire [63:0]auto_pc_to_m00_couplers_RDATA;
  wire [5:0]auto_pc_to_m00_couplers_RID;
  wire auto_pc_to_m00_couplers_RLAST;
  wire auto_pc_to_m00_couplers_RREADY;
  wire [1:0]auto_pc_to_m00_couplers_RRESP;
  wire auto_pc_to_m00_couplers_RVALID;
  wire [63:0]auto_pc_to_m00_couplers_WDATA;
  wire [2:0]auto_pc_to_m00_couplers_WID;
  wire auto_pc_to_m00_couplers_WLAST;
  wire auto_pc_to_m00_couplers_WREADY;
  wire [7:0]auto_pc_to_m00_couplers_WSTRB;
  wire [0:0]auto_pc_to_m00_couplers_WUSER;
  wire auto_pc_to_m00_couplers_WVALID;
  wire [31:0]m00_couplers_to_auto_pc_ARADDR;
  wire [1:0]m00_couplers_to_auto_pc_ARBURST;
  wire [3:0]m00_couplers_to_auto_pc_ARCACHE;
  wire [2:0]m00_couplers_to_auto_pc_ARID;
  wire [7:0]m00_couplers_to_auto_pc_ARLEN;
  wire [0:0]m00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]m00_couplers_to_auto_pc_ARPROT;
  wire [3:0]m00_couplers_to_auto_pc_ARQOS;
  wire m00_couplers_to_auto_pc_ARREADY;
  wire [3:0]m00_couplers_to_auto_pc_ARREGION;
  wire [2:0]m00_couplers_to_auto_pc_ARSIZE;
  wire [0:0]m00_couplers_to_auto_pc_ARUSER;
  wire m00_couplers_to_auto_pc_ARVALID;
  wire [31:0]m00_couplers_to_auto_pc_AWADDR;
  wire [1:0]m00_couplers_to_auto_pc_AWBURST;
  wire [3:0]m00_couplers_to_auto_pc_AWCACHE;
  wire [2:0]m00_couplers_to_auto_pc_AWID;
  wire [7:0]m00_couplers_to_auto_pc_AWLEN;
  wire [0:0]m00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]m00_couplers_to_auto_pc_AWPROT;
  wire [3:0]m00_couplers_to_auto_pc_AWQOS;
  wire m00_couplers_to_auto_pc_AWREADY;
  wire [3:0]m00_couplers_to_auto_pc_AWREGION;
  wire [2:0]m00_couplers_to_auto_pc_AWSIZE;
  wire [0:0]m00_couplers_to_auto_pc_AWUSER;
  wire m00_couplers_to_auto_pc_AWVALID;
  wire [2:0]m00_couplers_to_auto_pc_BID;
  wire m00_couplers_to_auto_pc_BREADY;
  wire [1:0]m00_couplers_to_auto_pc_BRESP;
  wire m00_couplers_to_auto_pc_BVALID;
  wire [63:0]m00_couplers_to_auto_pc_RDATA;
  wire [2:0]m00_couplers_to_auto_pc_RID;
  wire m00_couplers_to_auto_pc_RLAST;
  wire m00_couplers_to_auto_pc_RREADY;
  wire [1:0]m00_couplers_to_auto_pc_RRESP;
  wire [0:0]m00_couplers_to_auto_pc_RUSER;
  wire m00_couplers_to_auto_pc_RVALID;
  wire [63:0]m00_couplers_to_auto_pc_WDATA;
  wire m00_couplers_to_auto_pc_WLAST;
  wire m00_couplers_to_auto_pc_WREADY;
  wire [7:0]m00_couplers_to_auto_pc_WSTRB;
  wire [0:0]m00_couplers_to_auto_pc_WUSER;
  wire m00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_m00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_pc_to_m00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_pc_to_m00_couplers_ARCACHE;
  assign M_AXI_arid[2:0] = auto_pc_to_m00_couplers_ARID;
  assign M_AXI_arlen[3:0] = auto_pc_to_m00_couplers_ARLEN;
  assign M_AXI_arlock[1:0] = auto_pc_to_m00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_pc_to_m00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_pc_to_m00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_pc_to_m00_couplers_ARSIZE;
  assign M_AXI_aruser[0] = auto_pc_to_m00_couplers_ARUSER;
  assign M_AXI_arvalid = auto_pc_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_m00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_pc_to_m00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_pc_to_m00_couplers_AWCACHE;
  assign M_AXI_awid[2:0] = auto_pc_to_m00_couplers_AWID;
  assign M_AXI_awlen[3:0] = auto_pc_to_m00_couplers_AWLEN;
  assign M_AXI_awlock[1:0] = auto_pc_to_m00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_pc_to_m00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_pc_to_m00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_pc_to_m00_couplers_AWSIZE;
  assign M_AXI_awuser[0] = auto_pc_to_m00_couplers_AWUSER;
  assign M_AXI_awvalid = auto_pc_to_m00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_m00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_m00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_pc_to_m00_couplers_WDATA;
  assign M_AXI_wid[2:0] = auto_pc_to_m00_couplers_WID;
  assign M_AXI_wlast = auto_pc_to_m00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_pc_to_m00_couplers_WSTRB;
  assign M_AXI_wuser[0] = auto_pc_to_m00_couplers_WUSER;
  assign M_AXI_wvalid = auto_pc_to_m00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = m00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = m00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[2:0] = m00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = m00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[63:0] = m00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[2:0] = m00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = m00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = m00_couplers_to_auto_pc_RRESP;
  assign S_AXI_ruser[0] = m00_couplers_to_auto_pc_RUSER;
  assign S_AXI_rvalid = m00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = m00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_m00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_m00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_m00_couplers_BID = M_AXI_bid[5:0];
  assign auto_pc_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_m00_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_pc_to_m00_couplers_RID = M_AXI_rid[5:0];
  assign auto_pc_to_m00_couplers_RLAST = M_AXI_rlast;
  assign auto_pc_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_m00_couplers_WREADY = M_AXI_wready;
  assign m00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign m00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign m00_couplers_to_auto_pc_ARID = S_AXI_arid[2:0];
  assign m00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign m00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[0];
  assign m00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign m00_couplers_to_auto_pc_ARREGION = S_AXI_arregion[3:0];
  assign m00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign m00_couplers_to_auto_pc_ARUSER = S_AXI_aruser[0];
  assign m00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign m00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign m00_couplers_to_auto_pc_AWID = S_AXI_awid[2:0];
  assign m00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign m00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[0];
  assign m00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign m00_couplers_to_auto_pc_AWREGION = S_AXI_awregion[3:0];
  assign m00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign m00_couplers_to_auto_pc_AWUSER = S_AXI_awuser[0];
  assign m00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign m00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign m00_couplers_to_auto_pc_WDATA = S_AXI_wdata[63:0];
  assign m00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign m00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[7:0];
  assign m00_couplers_to_auto_pc_WUSER = S_AXI_wuser[0];
  assign m00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  design_1_auto_pc_1 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_m00_couplers_ARADDR),
        .m_axi_arburst(auto_pc_to_m00_couplers_ARBURST),
        .m_axi_arcache(auto_pc_to_m00_couplers_ARCACHE),
        .m_axi_arid(auto_pc_to_m00_couplers_ARID),
        .m_axi_arlen(auto_pc_to_m00_couplers_ARLEN),
        .m_axi_arlock(auto_pc_to_m00_couplers_ARLOCK),
        .m_axi_arprot(auto_pc_to_m00_couplers_ARPROT),
        .m_axi_arqos(auto_pc_to_m00_couplers_ARQOS),
        .m_axi_arready(auto_pc_to_m00_couplers_ARREADY),
        .m_axi_arsize(auto_pc_to_m00_couplers_ARSIZE),
        .m_axi_aruser(auto_pc_to_m00_couplers_ARUSER),
        .m_axi_arvalid(auto_pc_to_m00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_m00_couplers_AWADDR),
        .m_axi_awburst(auto_pc_to_m00_couplers_AWBURST),
        .m_axi_awcache(auto_pc_to_m00_couplers_AWCACHE),
        .m_axi_awid(auto_pc_to_m00_couplers_AWID),
        .m_axi_awlen(auto_pc_to_m00_couplers_AWLEN),
        .m_axi_awlock(auto_pc_to_m00_couplers_AWLOCK),
        .m_axi_awprot(auto_pc_to_m00_couplers_AWPROT),
        .m_axi_awqos(auto_pc_to_m00_couplers_AWQOS),
        .m_axi_awready(auto_pc_to_m00_couplers_AWREADY),
        .m_axi_awsize(auto_pc_to_m00_couplers_AWSIZE),
        .m_axi_awuser(auto_pc_to_m00_couplers_AWUSER),
        .m_axi_awvalid(auto_pc_to_m00_couplers_AWVALID),
        .m_axi_bid(auto_pc_to_m00_couplers_BID[2:0]),
        .m_axi_bready(auto_pc_to_m00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_m00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_m00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_m00_couplers_RDATA),
        .m_axi_rid(auto_pc_to_m00_couplers_RID[2:0]),
        .m_axi_rlast(auto_pc_to_m00_couplers_RLAST),
        .m_axi_rready(auto_pc_to_m00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_m00_couplers_RRESP),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(auto_pc_to_m00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_m00_couplers_WDATA),
        .m_axi_wid(auto_pc_to_m00_couplers_WID),
        .m_axi_wlast(auto_pc_to_m00_couplers_WLAST),
        .m_axi_wready(auto_pc_to_m00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_m00_couplers_WSTRB),
        .m_axi_wuser(auto_pc_to_m00_couplers_WUSER),
        .m_axi_wvalid(auto_pc_to_m00_couplers_WVALID),
        .s_axi_araddr(m00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(m00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(m00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(m00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(m00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(m00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(m00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(m00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(m00_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion(m00_couplers_to_auto_pc_ARREGION),
        .s_axi_arsize(m00_couplers_to_auto_pc_ARSIZE),
        .s_axi_aruser(m00_couplers_to_auto_pc_ARUSER),
        .s_axi_arvalid(m00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(m00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(m00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(m00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(m00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(m00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(m00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(m00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(m00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(m00_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion(m00_couplers_to_auto_pc_AWREGION),
        .s_axi_awsize(m00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awuser(m00_couplers_to_auto_pc_AWUSER),
        .s_axi_awvalid(m00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(m00_couplers_to_auto_pc_BID),
        .s_axi_bready(m00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(m00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(m00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(m00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(m00_couplers_to_auto_pc_RID),
        .s_axi_rlast(m00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(m00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(m00_couplers_to_auto_pc_RRESP),
        .s_axi_ruser(m00_couplers_to_auto_pc_RUSER),
        .s_axi_rvalid(m00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(m00_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(m00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(m00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(m00_couplers_to_auto_pc_WSTRB),
        .s_axi_wuser(m00_couplers_to_auto_pc_WUSER),
        .s_axi_wvalid(m00_couplers_to_auto_pc_WVALID));
endmodule

module m00_couplers_imp_ZLTC2M
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wuser,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [2:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output [0:0]M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [2:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output [0:0]M_AXI_awuser;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [2:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output [0:0]M_AXI_wuser;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [2:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [2:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [2:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [2:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_pc_to_m00_couplers_ARADDR;
  wire [1:0]auto_pc_to_m00_couplers_ARBURST;
  wire [3:0]auto_pc_to_m00_couplers_ARCACHE;
  wire [2:0]auto_pc_to_m00_couplers_ARID;
  wire [3:0]auto_pc_to_m00_couplers_ARLEN;
  wire [1:0]auto_pc_to_m00_couplers_ARLOCK;
  wire [2:0]auto_pc_to_m00_couplers_ARPROT;
  wire [3:0]auto_pc_to_m00_couplers_ARQOS;
  wire auto_pc_to_m00_couplers_ARREADY;
  wire [2:0]auto_pc_to_m00_couplers_ARSIZE;
  wire [0:0]auto_pc_to_m00_couplers_ARUSER;
  wire auto_pc_to_m00_couplers_ARVALID;
  wire [31:0]auto_pc_to_m00_couplers_AWADDR;
  wire [1:0]auto_pc_to_m00_couplers_AWBURST;
  wire [3:0]auto_pc_to_m00_couplers_AWCACHE;
  wire [2:0]auto_pc_to_m00_couplers_AWID;
  wire [3:0]auto_pc_to_m00_couplers_AWLEN;
  wire [1:0]auto_pc_to_m00_couplers_AWLOCK;
  wire [2:0]auto_pc_to_m00_couplers_AWPROT;
  wire [3:0]auto_pc_to_m00_couplers_AWQOS;
  wire auto_pc_to_m00_couplers_AWREADY;
  wire [2:0]auto_pc_to_m00_couplers_AWSIZE;
  wire [0:0]auto_pc_to_m00_couplers_AWUSER;
  wire auto_pc_to_m00_couplers_AWVALID;
  wire [5:0]auto_pc_to_m00_couplers_BID;
  wire auto_pc_to_m00_couplers_BREADY;
  wire [1:0]auto_pc_to_m00_couplers_BRESP;
  wire auto_pc_to_m00_couplers_BVALID;
  wire [63:0]auto_pc_to_m00_couplers_RDATA;
  wire [5:0]auto_pc_to_m00_couplers_RID;
  wire auto_pc_to_m00_couplers_RLAST;
  wire auto_pc_to_m00_couplers_RREADY;
  wire [1:0]auto_pc_to_m00_couplers_RRESP;
  wire auto_pc_to_m00_couplers_RVALID;
  wire [63:0]auto_pc_to_m00_couplers_WDATA;
  wire [2:0]auto_pc_to_m00_couplers_WID;
  wire auto_pc_to_m00_couplers_WLAST;
  wire auto_pc_to_m00_couplers_WREADY;
  wire [7:0]auto_pc_to_m00_couplers_WSTRB;
  wire [0:0]auto_pc_to_m00_couplers_WUSER;
  wire auto_pc_to_m00_couplers_WVALID;
  wire [31:0]m00_couplers_to_auto_pc_ARADDR;
  wire [1:0]m00_couplers_to_auto_pc_ARBURST;
  wire [3:0]m00_couplers_to_auto_pc_ARCACHE;
  wire [2:0]m00_couplers_to_auto_pc_ARID;
  wire [7:0]m00_couplers_to_auto_pc_ARLEN;
  wire [0:0]m00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]m00_couplers_to_auto_pc_ARPROT;
  wire [3:0]m00_couplers_to_auto_pc_ARQOS;
  wire m00_couplers_to_auto_pc_ARREADY;
  wire [3:0]m00_couplers_to_auto_pc_ARREGION;
  wire [2:0]m00_couplers_to_auto_pc_ARSIZE;
  wire [0:0]m00_couplers_to_auto_pc_ARUSER;
  wire m00_couplers_to_auto_pc_ARVALID;
  wire [31:0]m00_couplers_to_auto_pc_AWADDR;
  wire [1:0]m00_couplers_to_auto_pc_AWBURST;
  wire [3:0]m00_couplers_to_auto_pc_AWCACHE;
  wire [2:0]m00_couplers_to_auto_pc_AWID;
  wire [7:0]m00_couplers_to_auto_pc_AWLEN;
  wire [0:0]m00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]m00_couplers_to_auto_pc_AWPROT;
  wire [3:0]m00_couplers_to_auto_pc_AWQOS;
  wire m00_couplers_to_auto_pc_AWREADY;
  wire [3:0]m00_couplers_to_auto_pc_AWREGION;
  wire [2:0]m00_couplers_to_auto_pc_AWSIZE;
  wire [0:0]m00_couplers_to_auto_pc_AWUSER;
  wire m00_couplers_to_auto_pc_AWVALID;
  wire [2:0]m00_couplers_to_auto_pc_BID;
  wire m00_couplers_to_auto_pc_BREADY;
  wire [1:0]m00_couplers_to_auto_pc_BRESP;
  wire m00_couplers_to_auto_pc_BVALID;
  wire [63:0]m00_couplers_to_auto_pc_RDATA;
  wire [2:0]m00_couplers_to_auto_pc_RID;
  wire m00_couplers_to_auto_pc_RLAST;
  wire m00_couplers_to_auto_pc_RREADY;
  wire [1:0]m00_couplers_to_auto_pc_RRESP;
  wire [0:0]m00_couplers_to_auto_pc_RUSER;
  wire m00_couplers_to_auto_pc_RVALID;
  wire [63:0]m00_couplers_to_auto_pc_WDATA;
  wire m00_couplers_to_auto_pc_WLAST;
  wire m00_couplers_to_auto_pc_WREADY;
  wire [7:0]m00_couplers_to_auto_pc_WSTRB;
  wire [0:0]m00_couplers_to_auto_pc_WUSER;
  wire m00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_m00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_pc_to_m00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_pc_to_m00_couplers_ARCACHE;
  assign M_AXI_arid[2:0] = auto_pc_to_m00_couplers_ARID;
  assign M_AXI_arlen[3:0] = auto_pc_to_m00_couplers_ARLEN;
  assign M_AXI_arlock[1:0] = auto_pc_to_m00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_pc_to_m00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_pc_to_m00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_pc_to_m00_couplers_ARSIZE;
  assign M_AXI_aruser[0] = auto_pc_to_m00_couplers_ARUSER;
  assign M_AXI_arvalid = auto_pc_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_m00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_pc_to_m00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_pc_to_m00_couplers_AWCACHE;
  assign M_AXI_awid[2:0] = auto_pc_to_m00_couplers_AWID;
  assign M_AXI_awlen[3:0] = auto_pc_to_m00_couplers_AWLEN;
  assign M_AXI_awlock[1:0] = auto_pc_to_m00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_pc_to_m00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_pc_to_m00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_pc_to_m00_couplers_AWSIZE;
  assign M_AXI_awuser[0] = auto_pc_to_m00_couplers_AWUSER;
  assign M_AXI_awvalid = auto_pc_to_m00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_m00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_m00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_pc_to_m00_couplers_WDATA;
  assign M_AXI_wid[2:0] = auto_pc_to_m00_couplers_WID;
  assign M_AXI_wlast = auto_pc_to_m00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_pc_to_m00_couplers_WSTRB;
  assign M_AXI_wuser[0] = auto_pc_to_m00_couplers_WUSER;
  assign M_AXI_wvalid = auto_pc_to_m00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = m00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = m00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[2:0] = m00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = m00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[63:0] = m00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[2:0] = m00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = m00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = m00_couplers_to_auto_pc_RRESP;
  assign S_AXI_ruser[0] = m00_couplers_to_auto_pc_RUSER;
  assign S_AXI_rvalid = m00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = m00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_m00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_m00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_m00_couplers_BID = M_AXI_bid[5:0];
  assign auto_pc_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_m00_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_pc_to_m00_couplers_RID = M_AXI_rid[5:0];
  assign auto_pc_to_m00_couplers_RLAST = M_AXI_rlast;
  assign auto_pc_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_m00_couplers_WREADY = M_AXI_wready;
  assign m00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign m00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign m00_couplers_to_auto_pc_ARID = S_AXI_arid[2:0];
  assign m00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign m00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[0];
  assign m00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign m00_couplers_to_auto_pc_ARREGION = S_AXI_arregion[3:0];
  assign m00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign m00_couplers_to_auto_pc_ARUSER = S_AXI_aruser[0];
  assign m00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign m00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign m00_couplers_to_auto_pc_AWID = S_AXI_awid[2:0];
  assign m00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign m00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[0];
  assign m00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign m00_couplers_to_auto_pc_AWREGION = S_AXI_awregion[3:0];
  assign m00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign m00_couplers_to_auto_pc_AWUSER = S_AXI_awuser[0];
  assign m00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign m00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign m00_couplers_to_auto_pc_WDATA = S_AXI_wdata[63:0];
  assign m00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign m00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[7:0];
  assign m00_couplers_to_auto_pc_WUSER = S_AXI_wuser[0];
  assign m00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  design_1_auto_pc_2 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_m00_couplers_ARADDR),
        .m_axi_arburst(auto_pc_to_m00_couplers_ARBURST),
        .m_axi_arcache(auto_pc_to_m00_couplers_ARCACHE),
        .m_axi_arid(auto_pc_to_m00_couplers_ARID),
        .m_axi_arlen(auto_pc_to_m00_couplers_ARLEN),
        .m_axi_arlock(auto_pc_to_m00_couplers_ARLOCK),
        .m_axi_arprot(auto_pc_to_m00_couplers_ARPROT),
        .m_axi_arqos(auto_pc_to_m00_couplers_ARQOS),
        .m_axi_arready(auto_pc_to_m00_couplers_ARREADY),
        .m_axi_arsize(auto_pc_to_m00_couplers_ARSIZE),
        .m_axi_aruser(auto_pc_to_m00_couplers_ARUSER),
        .m_axi_arvalid(auto_pc_to_m00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_m00_couplers_AWADDR),
        .m_axi_awburst(auto_pc_to_m00_couplers_AWBURST),
        .m_axi_awcache(auto_pc_to_m00_couplers_AWCACHE),
        .m_axi_awid(auto_pc_to_m00_couplers_AWID),
        .m_axi_awlen(auto_pc_to_m00_couplers_AWLEN),
        .m_axi_awlock(auto_pc_to_m00_couplers_AWLOCK),
        .m_axi_awprot(auto_pc_to_m00_couplers_AWPROT),
        .m_axi_awqos(auto_pc_to_m00_couplers_AWQOS),
        .m_axi_awready(auto_pc_to_m00_couplers_AWREADY),
        .m_axi_awsize(auto_pc_to_m00_couplers_AWSIZE),
        .m_axi_awuser(auto_pc_to_m00_couplers_AWUSER),
        .m_axi_awvalid(auto_pc_to_m00_couplers_AWVALID),
        .m_axi_bid(auto_pc_to_m00_couplers_BID[2:0]),
        .m_axi_bready(auto_pc_to_m00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_m00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_m00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_m00_couplers_RDATA),
        .m_axi_rid(auto_pc_to_m00_couplers_RID[2:0]),
        .m_axi_rlast(auto_pc_to_m00_couplers_RLAST),
        .m_axi_rready(auto_pc_to_m00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_m00_couplers_RRESP),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(auto_pc_to_m00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_m00_couplers_WDATA),
        .m_axi_wid(auto_pc_to_m00_couplers_WID),
        .m_axi_wlast(auto_pc_to_m00_couplers_WLAST),
        .m_axi_wready(auto_pc_to_m00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_m00_couplers_WSTRB),
        .m_axi_wuser(auto_pc_to_m00_couplers_WUSER),
        .m_axi_wvalid(auto_pc_to_m00_couplers_WVALID),
        .s_axi_araddr(m00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(m00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(m00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(m00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(m00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(m00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(m00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(m00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(m00_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion(m00_couplers_to_auto_pc_ARREGION),
        .s_axi_arsize(m00_couplers_to_auto_pc_ARSIZE),
        .s_axi_aruser(m00_couplers_to_auto_pc_ARUSER),
        .s_axi_arvalid(m00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(m00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(m00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(m00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(m00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(m00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(m00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(m00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(m00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(m00_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion(m00_couplers_to_auto_pc_AWREGION),
        .s_axi_awsize(m00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awuser(m00_couplers_to_auto_pc_AWUSER),
        .s_axi_awvalid(m00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(m00_couplers_to_auto_pc_BID),
        .s_axi_bready(m00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(m00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(m00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(m00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(m00_couplers_to_auto_pc_RID),
        .s_axi_rlast(m00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(m00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(m00_couplers_to_auto_pc_RRESP),
        .s_axi_ruser(m00_couplers_to_auto_pc_RUSER),
        .s_axi_rvalid(m00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(m00_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(m00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(m00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(m00_couplers_to_auto_pc_WSTRB),
        .s_axi_wuser(m00_couplers_to_auto_pc_WUSER),
        .s_axi_wvalid(m00_couplers_to_auto_pc_WVALID));
endmodule

module m01_couplers_imp_I4GRPB
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]m01_couplers_to_m01_couplers_ARADDR;
  wire m01_couplers_to_m01_couplers_ARREADY;
  wire m01_couplers_to_m01_couplers_ARVALID;
  wire [31:0]m01_couplers_to_m01_couplers_AWADDR;
  wire m01_couplers_to_m01_couplers_AWREADY;
  wire m01_couplers_to_m01_couplers_AWVALID;
  wire m01_couplers_to_m01_couplers_BREADY;
  wire [1:0]m01_couplers_to_m01_couplers_BRESP;
  wire m01_couplers_to_m01_couplers_BVALID;
  wire [31:0]m01_couplers_to_m01_couplers_RDATA;
  wire m01_couplers_to_m01_couplers_RREADY;
  wire [1:0]m01_couplers_to_m01_couplers_RRESP;
  wire m01_couplers_to_m01_couplers_RVALID;
  wire [31:0]m01_couplers_to_m01_couplers_WDATA;
  wire m01_couplers_to_m01_couplers_WREADY;
  wire [3:0]m01_couplers_to_m01_couplers_WSTRB;
  wire m01_couplers_to_m01_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m01_couplers_to_m01_couplers_ARADDR;
  assign M_AXI_arvalid = m01_couplers_to_m01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m01_couplers_to_m01_couplers_AWADDR;
  assign M_AXI_awvalid = m01_couplers_to_m01_couplers_AWVALID;
  assign M_AXI_bready = m01_couplers_to_m01_couplers_BREADY;
  assign M_AXI_rready = m01_couplers_to_m01_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m01_couplers_to_m01_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m01_couplers_to_m01_couplers_WSTRB;
  assign M_AXI_wvalid = m01_couplers_to_m01_couplers_WVALID;
  assign S_AXI_arready = m01_couplers_to_m01_couplers_ARREADY;
  assign S_AXI_awready = m01_couplers_to_m01_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m01_couplers_to_m01_couplers_BRESP;
  assign S_AXI_bvalid = m01_couplers_to_m01_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m01_couplers_to_m01_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m01_couplers_to_m01_couplers_RRESP;
  assign S_AXI_rvalid = m01_couplers_to_m01_couplers_RVALID;
  assign S_AXI_wready = m01_couplers_to_m01_couplers_WREADY;
  assign m01_couplers_to_m01_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m01_couplers_to_m01_couplers_ARREADY = M_AXI_arready;
  assign m01_couplers_to_m01_couplers_ARVALID = S_AXI_arvalid;
  assign m01_couplers_to_m01_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m01_couplers_to_m01_couplers_AWREADY = M_AXI_awready;
  assign m01_couplers_to_m01_couplers_AWVALID = S_AXI_awvalid;
  assign m01_couplers_to_m01_couplers_BREADY = S_AXI_bready;
  assign m01_couplers_to_m01_couplers_BRESP = M_AXI_bresp[1:0];
  assign m01_couplers_to_m01_couplers_BVALID = M_AXI_bvalid;
  assign m01_couplers_to_m01_couplers_RDATA = M_AXI_rdata[31:0];
  assign m01_couplers_to_m01_couplers_RREADY = S_AXI_rready;
  assign m01_couplers_to_m01_couplers_RRESP = M_AXI_rresp[1:0];
  assign m01_couplers_to_m01_couplers_RVALID = M_AXI_rvalid;
  assign m01_couplers_to_m01_couplers_WDATA = S_AXI_wdata[31:0];
  assign m01_couplers_to_m01_couplers_WREADY = M_AXI_wready;
  assign m01_couplers_to_m01_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m01_couplers_to_m01_couplers_WVALID = S_AXI_wvalid;
endmodule

module s00_couplers_imp_37YZ6K
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wuser,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [1:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output [0:0]M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [1:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output [0:0]M_AXI_awuser;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [1:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output [0:0]M_AXI_wuser;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [1:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [1:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [1:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [1:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [1:0]auto_pc_to_s00_couplers_ARBURST;
  wire [3:0]auto_pc_to_s00_couplers_ARCACHE;
  wire [1:0]auto_pc_to_s00_couplers_ARID;
  wire [3:0]auto_pc_to_s00_couplers_ARLEN;
  wire [1:0]auto_pc_to_s00_couplers_ARLOCK;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire [3:0]auto_pc_to_s00_couplers_ARQOS;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire [2:0]auto_pc_to_s00_couplers_ARSIZE;
  wire [0:0]auto_pc_to_s00_couplers_ARUSER;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [1:0]auto_pc_to_s00_couplers_AWBURST;
  wire [3:0]auto_pc_to_s00_couplers_AWCACHE;
  wire [1:0]auto_pc_to_s00_couplers_AWID;
  wire [3:0]auto_pc_to_s00_couplers_AWLEN;
  wire [1:0]auto_pc_to_s00_couplers_AWLOCK;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire [3:0]auto_pc_to_s00_couplers_AWQOS;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire [2:0]auto_pc_to_s00_couplers_AWSIZE;
  wire [0:0]auto_pc_to_s00_couplers_AWUSER;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire [5:0]auto_pc_to_s00_couplers_BID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [63:0]auto_pc_to_s00_couplers_RDATA;
  wire [5:0]auto_pc_to_s00_couplers_RID;
  wire auto_pc_to_s00_couplers_RLAST;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [63:0]auto_pc_to_s00_couplers_WDATA;
  wire [1:0]auto_pc_to_s00_couplers_WID;
  wire auto_pc_to_s00_couplers_WLAST;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [7:0]auto_pc_to_s00_couplers_WSTRB;
  wire [0:0]auto_pc_to_s00_couplers_WUSER;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [1:0]s00_couplers_to_auto_pc_ARID;
  wire [7:0]s00_couplers_to_auto_pc_ARLEN;
  wire s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire [0:0]s00_couplers_to_auto_pc_ARUSER;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [1:0]s00_couplers_to_auto_pc_AWID;
  wire [7:0]s00_couplers_to_auto_pc_AWLEN;
  wire s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire [0:0]s00_couplers_to_auto_pc_AWUSER;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [1:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [63:0]s00_couplers_to_auto_pc_RDATA;
  wire [1:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire [0:0]s00_couplers_to_auto_pc_RUSER;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [63:0]s00_couplers_to_auto_pc_WDATA;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [7:0]s00_couplers_to_auto_pc_WSTRB;
  wire [0:0]s00_couplers_to_auto_pc_WUSER;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_pc_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_pc_to_s00_couplers_ARCACHE;
  assign M_AXI_arid[1:0] = auto_pc_to_s00_couplers_ARID;
  assign M_AXI_arlen[3:0] = auto_pc_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[1:0] = auto_pc_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_pc_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_pc_to_s00_couplers_ARSIZE;
  assign M_AXI_aruser[0] = auto_pc_to_s00_couplers_ARUSER;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_pc_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_pc_to_s00_couplers_AWCACHE;
  assign M_AXI_awid[1:0] = auto_pc_to_s00_couplers_AWID;
  assign M_AXI_awlen[3:0] = auto_pc_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[1:0] = auto_pc_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_pc_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_pc_to_s00_couplers_AWSIZE;
  assign M_AXI_awuser[0] = auto_pc_to_s00_couplers_AWUSER;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wid[1:0] = auto_pc_to_s00_couplers_WID;
  assign M_AXI_wlast = auto_pc_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wuser[0] = auto_pc_to_s00_couplers_WUSER;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[1:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[63:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[1:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_ruser[0] = s00_couplers_to_auto_pc_RUSER;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BID = M_AXI_bid[5:0];
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_pc_to_s00_couplers_RID = M_AXI_rid[5:0];
  assign auto_pc_to_s00_couplers_RLAST = M_AXI_rlast;
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[1:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock;
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARUSER = S_AXI_aruser[0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[1:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock;
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWUSER = S_AXI_awuser[0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[63:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[7:0];
  assign s00_couplers_to_auto_pc_WUSER = S_AXI_wuser[0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  design_1_auto_pc_4 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arburst(auto_pc_to_s00_couplers_ARBURST),
        .m_axi_arcache(auto_pc_to_s00_couplers_ARCACHE),
        .m_axi_arid(auto_pc_to_s00_couplers_ARID),
        .m_axi_arlen(auto_pc_to_s00_couplers_ARLEN),
        .m_axi_arlock(auto_pc_to_s00_couplers_ARLOCK),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arqos(auto_pc_to_s00_couplers_ARQOS),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arsize(auto_pc_to_s00_couplers_ARSIZE),
        .m_axi_aruser(auto_pc_to_s00_couplers_ARUSER),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awburst(auto_pc_to_s00_couplers_AWBURST),
        .m_axi_awcache(auto_pc_to_s00_couplers_AWCACHE),
        .m_axi_awid(auto_pc_to_s00_couplers_AWID),
        .m_axi_awlen(auto_pc_to_s00_couplers_AWLEN),
        .m_axi_awlock(auto_pc_to_s00_couplers_AWLOCK),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awqos(auto_pc_to_s00_couplers_AWQOS),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awsize(auto_pc_to_s00_couplers_AWSIZE),
        .m_axi_awuser(auto_pc_to_s00_couplers_AWUSER),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bid(auto_pc_to_s00_couplers_BID[1:0]),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rid(auto_pc_to_s00_couplers_RID[1:0]),
        .m_axi_rlast(auto_pc_to_s00_couplers_RLAST),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wid(auto_pc_to_s00_couplers_WID),
        .m_axi_wlast(auto_pc_to_s00_couplers_WLAST),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wuser(auto_pc_to_s00_couplers_WUSER),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_aruser(s00_couplers_to_auto_pc_ARUSER),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awuser(s00_couplers_to_auto_pc_AWUSER),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_ruser(s00_couplers_to_auto_pc_RUSER),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wuser(s00_couplers_to_auto_pc_WUSER),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

module s00_couplers_imp_HS4N6K
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_buser,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_ruser,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wuser,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_buser,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [1:0]M_AXI_arid;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output [0:0]M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [1:0]M_AXI_awid;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output [0:0]M_AXI_awuser;
  output M_AXI_awvalid;
  input [2:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_buser;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [2:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_ruser;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output [0:0]M_AXI_wuser;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [1:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [1:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [1:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_buser;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [1:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire [31:0]s00_couplers_to_s00_data_fifo_ARADDR;
  wire [1:0]s00_couplers_to_s00_data_fifo_ARBURST;
  wire [3:0]s00_couplers_to_s00_data_fifo_ARCACHE;
  wire [1:0]s00_couplers_to_s00_data_fifo_ARID;
  wire [7:0]s00_couplers_to_s00_data_fifo_ARLEN;
  wire s00_couplers_to_s00_data_fifo_ARLOCK;
  wire [2:0]s00_couplers_to_s00_data_fifo_ARPROT;
  wire [3:0]s00_couplers_to_s00_data_fifo_ARQOS;
  wire s00_couplers_to_s00_data_fifo_ARREADY;
  wire [2:0]s00_couplers_to_s00_data_fifo_ARSIZE;
  wire [0:0]s00_couplers_to_s00_data_fifo_ARUSER;
  wire s00_couplers_to_s00_data_fifo_ARVALID;
  wire [31:0]s00_couplers_to_s00_data_fifo_AWADDR;
  wire [1:0]s00_couplers_to_s00_data_fifo_AWBURST;
  wire [3:0]s00_couplers_to_s00_data_fifo_AWCACHE;
  wire [1:0]s00_couplers_to_s00_data_fifo_AWID;
  wire [7:0]s00_couplers_to_s00_data_fifo_AWLEN;
  wire s00_couplers_to_s00_data_fifo_AWLOCK;
  wire [2:0]s00_couplers_to_s00_data_fifo_AWPROT;
  wire [3:0]s00_couplers_to_s00_data_fifo_AWQOS;
  wire s00_couplers_to_s00_data_fifo_AWREADY;
  wire [2:0]s00_couplers_to_s00_data_fifo_AWSIZE;
  wire [0:0]s00_couplers_to_s00_data_fifo_AWUSER;
  wire s00_couplers_to_s00_data_fifo_AWVALID;
  wire [1:0]s00_couplers_to_s00_data_fifo_BID;
  wire s00_couplers_to_s00_data_fifo_BREADY;
  wire [1:0]s00_couplers_to_s00_data_fifo_BRESP;
  wire [0:0]s00_couplers_to_s00_data_fifo_BUSER;
  wire s00_couplers_to_s00_data_fifo_BVALID;
  wire [63:0]s00_couplers_to_s00_data_fifo_RDATA;
  wire [1:0]s00_couplers_to_s00_data_fifo_RID;
  wire s00_couplers_to_s00_data_fifo_RLAST;
  wire s00_couplers_to_s00_data_fifo_RREADY;
  wire [1:0]s00_couplers_to_s00_data_fifo_RRESP;
  wire [0:0]s00_couplers_to_s00_data_fifo_RUSER;
  wire s00_couplers_to_s00_data_fifo_RVALID;
  wire [63:0]s00_couplers_to_s00_data_fifo_WDATA;
  wire s00_couplers_to_s00_data_fifo_WLAST;
  wire s00_couplers_to_s00_data_fifo_WREADY;
  wire [7:0]s00_couplers_to_s00_data_fifo_WSTRB;
  wire [0:0]s00_couplers_to_s00_data_fifo_WUSER;
  wire s00_couplers_to_s00_data_fifo_WVALID;
  wire [31:0]s00_data_fifo_to_s00_couplers_ARADDR;
  wire [1:0]s00_data_fifo_to_s00_couplers_ARBURST;
  wire [3:0]s00_data_fifo_to_s00_couplers_ARCACHE;
  wire [1:0]s00_data_fifo_to_s00_couplers_ARID;
  wire [7:0]s00_data_fifo_to_s00_couplers_ARLEN;
  wire [0:0]s00_data_fifo_to_s00_couplers_ARLOCK;
  wire [2:0]s00_data_fifo_to_s00_couplers_ARPROT;
  wire [3:0]s00_data_fifo_to_s00_couplers_ARQOS;
  wire s00_data_fifo_to_s00_couplers_ARREADY;
  wire [2:0]s00_data_fifo_to_s00_couplers_ARSIZE;
  wire [0:0]s00_data_fifo_to_s00_couplers_ARUSER;
  wire s00_data_fifo_to_s00_couplers_ARVALID;
  wire [31:0]s00_data_fifo_to_s00_couplers_AWADDR;
  wire [1:0]s00_data_fifo_to_s00_couplers_AWBURST;
  wire [3:0]s00_data_fifo_to_s00_couplers_AWCACHE;
  wire [1:0]s00_data_fifo_to_s00_couplers_AWID;
  wire [7:0]s00_data_fifo_to_s00_couplers_AWLEN;
  wire [0:0]s00_data_fifo_to_s00_couplers_AWLOCK;
  wire [2:0]s00_data_fifo_to_s00_couplers_AWPROT;
  wire [3:0]s00_data_fifo_to_s00_couplers_AWQOS;
  wire s00_data_fifo_to_s00_couplers_AWREADY;
  wire [2:0]s00_data_fifo_to_s00_couplers_AWSIZE;
  wire [0:0]s00_data_fifo_to_s00_couplers_AWUSER;
  wire s00_data_fifo_to_s00_couplers_AWVALID;
  wire [2:0]s00_data_fifo_to_s00_couplers_BID;
  wire s00_data_fifo_to_s00_couplers_BREADY;
  wire [1:0]s00_data_fifo_to_s00_couplers_BRESP;
  wire [0:0]s00_data_fifo_to_s00_couplers_BUSER;
  wire s00_data_fifo_to_s00_couplers_BVALID;
  wire [63:0]s00_data_fifo_to_s00_couplers_RDATA;
  wire [2:0]s00_data_fifo_to_s00_couplers_RID;
  wire s00_data_fifo_to_s00_couplers_RLAST;
  wire s00_data_fifo_to_s00_couplers_RREADY;
  wire [1:0]s00_data_fifo_to_s00_couplers_RRESP;
  wire [0:0]s00_data_fifo_to_s00_couplers_RUSER;
  wire s00_data_fifo_to_s00_couplers_RVALID;
  wire [63:0]s00_data_fifo_to_s00_couplers_WDATA;
  wire s00_data_fifo_to_s00_couplers_WLAST;
  wire s00_data_fifo_to_s00_couplers_WREADY;
  wire [7:0]s00_data_fifo_to_s00_couplers_WSTRB;
  wire [0:0]s00_data_fifo_to_s00_couplers_WUSER;
  wire s00_data_fifo_to_s00_couplers_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[31:0] = s00_data_fifo_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = s00_data_fifo_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = s00_data_fifo_to_s00_couplers_ARCACHE;
  assign M_AXI_arid[1:0] = s00_data_fifo_to_s00_couplers_ARID;
  assign M_AXI_arlen[7:0] = s00_data_fifo_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[0] = s00_data_fifo_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = s00_data_fifo_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = s00_data_fifo_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = s00_data_fifo_to_s00_couplers_ARSIZE;
  assign M_AXI_aruser[0] = s00_data_fifo_to_s00_couplers_ARUSER;
  assign M_AXI_arvalid = s00_data_fifo_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s00_data_fifo_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = s00_data_fifo_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = s00_data_fifo_to_s00_couplers_AWCACHE;
  assign M_AXI_awid[1:0] = s00_data_fifo_to_s00_couplers_AWID;
  assign M_AXI_awlen[7:0] = s00_data_fifo_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[0] = s00_data_fifo_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = s00_data_fifo_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = s00_data_fifo_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = s00_data_fifo_to_s00_couplers_AWSIZE;
  assign M_AXI_awuser[0] = s00_data_fifo_to_s00_couplers_AWUSER;
  assign M_AXI_awvalid = s00_data_fifo_to_s00_couplers_AWVALID;
  assign M_AXI_bready = s00_data_fifo_to_s00_couplers_BREADY;
  assign M_AXI_rready = s00_data_fifo_to_s00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = s00_data_fifo_to_s00_couplers_WDATA;
  assign M_AXI_wlast = s00_data_fifo_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = s00_data_fifo_to_s00_couplers_WSTRB;
  assign M_AXI_wuser[0] = s00_data_fifo_to_s00_couplers_WUSER;
  assign M_AXI_wvalid = s00_data_fifo_to_s00_couplers_WVALID;
  assign S_AXI_arready = s00_couplers_to_s00_data_fifo_ARREADY;
  assign S_AXI_awready = s00_couplers_to_s00_data_fifo_AWREADY;
  assign S_AXI_bid[1:0] = s00_couplers_to_s00_data_fifo_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_s00_data_fifo_BRESP;
  assign S_AXI_buser[0] = s00_couplers_to_s00_data_fifo_BUSER;
  assign S_AXI_bvalid = s00_couplers_to_s00_data_fifo_BVALID;
  assign S_AXI_rdata[63:0] = s00_couplers_to_s00_data_fifo_RDATA;
  assign S_AXI_rid[1:0] = s00_couplers_to_s00_data_fifo_RID;
  assign S_AXI_rlast = s00_couplers_to_s00_data_fifo_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_s00_data_fifo_RRESP;
  assign S_AXI_ruser[0] = s00_couplers_to_s00_data_fifo_RUSER;
  assign S_AXI_rvalid = s00_couplers_to_s00_data_fifo_RVALID;
  assign S_AXI_wready = s00_couplers_to_s00_data_fifo_WREADY;
  assign s00_couplers_to_s00_data_fifo_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_s00_data_fifo_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_s00_data_fifo_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_s00_data_fifo_ARID = S_AXI_arid[1:0];
  assign s00_couplers_to_s00_data_fifo_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_s00_data_fifo_ARLOCK = S_AXI_arlock;
  assign s00_couplers_to_s00_data_fifo_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_s00_data_fifo_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_s00_data_fifo_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_s00_data_fifo_ARUSER = S_AXI_aruser[0];
  assign s00_couplers_to_s00_data_fifo_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_s00_data_fifo_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_s00_data_fifo_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_s00_data_fifo_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_s00_data_fifo_AWID = S_AXI_awid[1:0];
  assign s00_couplers_to_s00_data_fifo_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_s00_data_fifo_AWLOCK = S_AXI_awlock;
  assign s00_couplers_to_s00_data_fifo_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_s00_data_fifo_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_s00_data_fifo_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_s00_data_fifo_AWUSER = S_AXI_awuser[0];
  assign s00_couplers_to_s00_data_fifo_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_s00_data_fifo_BREADY = S_AXI_bready;
  assign s00_couplers_to_s00_data_fifo_RREADY = S_AXI_rready;
  assign s00_couplers_to_s00_data_fifo_WDATA = S_AXI_wdata[63:0];
  assign s00_couplers_to_s00_data_fifo_WLAST = S_AXI_wlast;
  assign s00_couplers_to_s00_data_fifo_WSTRB = S_AXI_wstrb[7:0];
  assign s00_couplers_to_s00_data_fifo_WUSER = S_AXI_wuser[0];
  assign s00_couplers_to_s00_data_fifo_WVALID = S_AXI_wvalid;
  assign s00_data_fifo_to_s00_couplers_ARREADY = M_AXI_arready;
  assign s00_data_fifo_to_s00_couplers_AWREADY = M_AXI_awready;
  assign s00_data_fifo_to_s00_couplers_BID = M_AXI_bid[2:0];
  assign s00_data_fifo_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign s00_data_fifo_to_s00_couplers_BUSER = M_AXI_buser[0];
  assign s00_data_fifo_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign s00_data_fifo_to_s00_couplers_RDATA = M_AXI_rdata[63:0];
  assign s00_data_fifo_to_s00_couplers_RID = M_AXI_rid[2:0];
  assign s00_data_fifo_to_s00_couplers_RLAST = M_AXI_rlast;
  assign s00_data_fifo_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign s00_data_fifo_to_s00_couplers_RUSER = M_AXI_ruser[0];
  assign s00_data_fifo_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign s00_data_fifo_to_s00_couplers_WREADY = M_AXI_wready;
  design_1_s00_data_fifo_0 s00_data_fifo
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(s00_data_fifo_to_s00_couplers_ARADDR),
        .m_axi_arburst(s00_data_fifo_to_s00_couplers_ARBURST),
        .m_axi_arcache(s00_data_fifo_to_s00_couplers_ARCACHE),
        .m_axi_arid(s00_data_fifo_to_s00_couplers_ARID),
        .m_axi_arlen(s00_data_fifo_to_s00_couplers_ARLEN),
        .m_axi_arlock(s00_data_fifo_to_s00_couplers_ARLOCK),
        .m_axi_arprot(s00_data_fifo_to_s00_couplers_ARPROT),
        .m_axi_arqos(s00_data_fifo_to_s00_couplers_ARQOS),
        .m_axi_arready(s00_data_fifo_to_s00_couplers_ARREADY),
        .m_axi_arsize(s00_data_fifo_to_s00_couplers_ARSIZE),
        .m_axi_aruser(s00_data_fifo_to_s00_couplers_ARUSER),
        .m_axi_arvalid(s00_data_fifo_to_s00_couplers_ARVALID),
        .m_axi_awaddr(s00_data_fifo_to_s00_couplers_AWADDR),
        .m_axi_awburst(s00_data_fifo_to_s00_couplers_AWBURST),
        .m_axi_awcache(s00_data_fifo_to_s00_couplers_AWCACHE),
        .m_axi_awid(s00_data_fifo_to_s00_couplers_AWID),
        .m_axi_awlen(s00_data_fifo_to_s00_couplers_AWLEN),
        .m_axi_awlock(s00_data_fifo_to_s00_couplers_AWLOCK),
        .m_axi_awprot(s00_data_fifo_to_s00_couplers_AWPROT),
        .m_axi_awqos(s00_data_fifo_to_s00_couplers_AWQOS),
        .m_axi_awready(s00_data_fifo_to_s00_couplers_AWREADY),
        .m_axi_awsize(s00_data_fifo_to_s00_couplers_AWSIZE),
        .m_axi_awuser(s00_data_fifo_to_s00_couplers_AWUSER),
        .m_axi_awvalid(s00_data_fifo_to_s00_couplers_AWVALID),
        .m_axi_bid(s00_data_fifo_to_s00_couplers_BID[1:0]),
        .m_axi_bready(s00_data_fifo_to_s00_couplers_BREADY),
        .m_axi_bresp(s00_data_fifo_to_s00_couplers_BRESP),
        .m_axi_buser(s00_data_fifo_to_s00_couplers_BUSER),
        .m_axi_bvalid(s00_data_fifo_to_s00_couplers_BVALID),
        .m_axi_rdata(s00_data_fifo_to_s00_couplers_RDATA),
        .m_axi_rid(s00_data_fifo_to_s00_couplers_RID[1:0]),
        .m_axi_rlast(s00_data_fifo_to_s00_couplers_RLAST),
        .m_axi_rready(s00_data_fifo_to_s00_couplers_RREADY),
        .m_axi_rresp(s00_data_fifo_to_s00_couplers_RRESP),
        .m_axi_ruser(s00_data_fifo_to_s00_couplers_RUSER),
        .m_axi_rvalid(s00_data_fifo_to_s00_couplers_RVALID),
        .m_axi_wdata(s00_data_fifo_to_s00_couplers_WDATA),
        .m_axi_wlast(s00_data_fifo_to_s00_couplers_WLAST),
        .m_axi_wready(s00_data_fifo_to_s00_couplers_WREADY),
        .m_axi_wstrb(s00_data_fifo_to_s00_couplers_WSTRB),
        .m_axi_wuser(s00_data_fifo_to_s00_couplers_WUSER),
        .m_axi_wvalid(s00_data_fifo_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_s00_data_fifo_ARADDR),
        .s_axi_arburst(s00_couplers_to_s00_data_fifo_ARBURST),
        .s_axi_arcache(s00_couplers_to_s00_data_fifo_ARCACHE),
        .s_axi_arid(s00_couplers_to_s00_data_fifo_ARID),
        .s_axi_arlen(s00_couplers_to_s00_data_fifo_ARLEN),
        .s_axi_arlock(s00_couplers_to_s00_data_fifo_ARLOCK),
        .s_axi_arprot(s00_couplers_to_s00_data_fifo_ARPROT),
        .s_axi_arqos(s00_couplers_to_s00_data_fifo_ARQOS),
        .s_axi_arready(s00_couplers_to_s00_data_fifo_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(s00_couplers_to_s00_data_fifo_ARSIZE),
        .s_axi_aruser(s00_couplers_to_s00_data_fifo_ARUSER),
        .s_axi_arvalid(s00_couplers_to_s00_data_fifo_ARVALID),
        .s_axi_awaddr(s00_couplers_to_s00_data_fifo_AWADDR),
        .s_axi_awburst(s00_couplers_to_s00_data_fifo_AWBURST),
        .s_axi_awcache(s00_couplers_to_s00_data_fifo_AWCACHE),
        .s_axi_awid(s00_couplers_to_s00_data_fifo_AWID),
        .s_axi_awlen(s00_couplers_to_s00_data_fifo_AWLEN),
        .s_axi_awlock(s00_couplers_to_s00_data_fifo_AWLOCK),
        .s_axi_awprot(s00_couplers_to_s00_data_fifo_AWPROT),
        .s_axi_awqos(s00_couplers_to_s00_data_fifo_AWQOS),
        .s_axi_awready(s00_couplers_to_s00_data_fifo_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(s00_couplers_to_s00_data_fifo_AWSIZE),
        .s_axi_awuser(s00_couplers_to_s00_data_fifo_AWUSER),
        .s_axi_awvalid(s00_couplers_to_s00_data_fifo_AWVALID),
        .s_axi_bid(s00_couplers_to_s00_data_fifo_BID),
        .s_axi_bready(s00_couplers_to_s00_data_fifo_BREADY),
        .s_axi_bresp(s00_couplers_to_s00_data_fifo_BRESP),
        .s_axi_buser(s00_couplers_to_s00_data_fifo_BUSER),
        .s_axi_bvalid(s00_couplers_to_s00_data_fifo_BVALID),
        .s_axi_rdata(s00_couplers_to_s00_data_fifo_RDATA),
        .s_axi_rid(s00_couplers_to_s00_data_fifo_RID),
        .s_axi_rlast(s00_couplers_to_s00_data_fifo_RLAST),
        .s_axi_rready(s00_couplers_to_s00_data_fifo_RREADY),
        .s_axi_rresp(s00_couplers_to_s00_data_fifo_RRESP),
        .s_axi_ruser(s00_couplers_to_s00_data_fifo_RUSER),
        .s_axi_rvalid(s00_couplers_to_s00_data_fifo_RVALID),
        .s_axi_wdata(s00_couplers_to_s00_data_fifo_WDATA),
        .s_axi_wlast(s00_couplers_to_s00_data_fifo_WLAST),
        .s_axi_wready(s00_couplers_to_s00_data_fifo_WREADY),
        .s_axi_wstrb(s00_couplers_to_s00_data_fifo_WSTRB),
        .s_axi_wuser(s00_couplers_to_s00_data_fifo_WUSER),
        .s_axi_wvalid(s00_couplers_to_s00_data_fifo_WVALID));
endmodule

module s00_couplers_imp_O7FAN0
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wid,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [11:0]S_AXI_arid;
  input [3:0]S_AXI_arlen;
  input [1:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [11:0]S_AXI_awid;
  input [3:0]S_AXI_awlen;
  input [1:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [11:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output [11:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input [11:0]S_AXI_wid;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [31:0]auto_pc_to_s00_couplers_RDATA;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [31:0]auto_pc_to_s00_couplers_WDATA;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [3:0]auto_pc_to_s00_couplers_WSTRB;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [11:0]s00_couplers_to_auto_pc_ARID;
  wire [3:0]s00_couplers_to_auto_pc_ARLEN;
  wire [1:0]s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [11:0]s00_couplers_to_auto_pc_AWID;
  wire [3:0]s00_couplers_to_auto_pc_AWLEN;
  wire [1:0]s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [11:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [31:0]s00_couplers_to_auto_pc_RDATA;
  wire [11:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [31:0]s00_couplers_to_auto_pc_WDATA;
  wire [11:0]s00_couplers_to_auto_pc_WID;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [3:0]s00_couplers_to_auto_pc_WSTRB;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[11:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[11:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[11:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[3:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[1:0];
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[11:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[3:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[1:0];
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_auto_pc_WID = S_AXI_wid[11:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  design_1_auto_pc_0 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wid(s00_couplers_to_auto_pc_WID),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

module s00_couplers_imp_ULGAU4
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wuser,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [1:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output [0:0]M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [1:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output [0:0]M_AXI_awuser;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [1:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output [0:0]M_AXI_wuser;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [1:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [1:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [1:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [1:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [1:0]auto_pc_to_s00_couplers_ARBURST;
  wire [3:0]auto_pc_to_s00_couplers_ARCACHE;
  wire [1:0]auto_pc_to_s00_couplers_ARID;
  wire [3:0]auto_pc_to_s00_couplers_ARLEN;
  wire [1:0]auto_pc_to_s00_couplers_ARLOCK;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire [3:0]auto_pc_to_s00_couplers_ARQOS;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire [2:0]auto_pc_to_s00_couplers_ARSIZE;
  wire [0:0]auto_pc_to_s00_couplers_ARUSER;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [1:0]auto_pc_to_s00_couplers_AWBURST;
  wire [3:0]auto_pc_to_s00_couplers_AWCACHE;
  wire [1:0]auto_pc_to_s00_couplers_AWID;
  wire [3:0]auto_pc_to_s00_couplers_AWLEN;
  wire [1:0]auto_pc_to_s00_couplers_AWLOCK;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire [3:0]auto_pc_to_s00_couplers_AWQOS;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire [2:0]auto_pc_to_s00_couplers_AWSIZE;
  wire [0:0]auto_pc_to_s00_couplers_AWUSER;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire [5:0]auto_pc_to_s00_couplers_BID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [63:0]auto_pc_to_s00_couplers_RDATA;
  wire [5:0]auto_pc_to_s00_couplers_RID;
  wire auto_pc_to_s00_couplers_RLAST;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [63:0]auto_pc_to_s00_couplers_WDATA;
  wire [1:0]auto_pc_to_s00_couplers_WID;
  wire auto_pc_to_s00_couplers_WLAST;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [7:0]auto_pc_to_s00_couplers_WSTRB;
  wire [0:0]auto_pc_to_s00_couplers_WUSER;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [1:0]s00_couplers_to_auto_pc_ARID;
  wire [7:0]s00_couplers_to_auto_pc_ARLEN;
  wire s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire [0:0]s00_couplers_to_auto_pc_ARUSER;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [1:0]s00_couplers_to_auto_pc_AWID;
  wire [7:0]s00_couplers_to_auto_pc_AWLEN;
  wire s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire [0:0]s00_couplers_to_auto_pc_AWUSER;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [1:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [63:0]s00_couplers_to_auto_pc_RDATA;
  wire [1:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire [0:0]s00_couplers_to_auto_pc_RUSER;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [63:0]s00_couplers_to_auto_pc_WDATA;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [7:0]s00_couplers_to_auto_pc_WSTRB;
  wire [0:0]s00_couplers_to_auto_pc_WUSER;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_pc_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_pc_to_s00_couplers_ARCACHE;
  assign M_AXI_arid[1:0] = auto_pc_to_s00_couplers_ARID;
  assign M_AXI_arlen[3:0] = auto_pc_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[1:0] = auto_pc_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_pc_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_pc_to_s00_couplers_ARSIZE;
  assign M_AXI_aruser[0] = auto_pc_to_s00_couplers_ARUSER;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_pc_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_pc_to_s00_couplers_AWCACHE;
  assign M_AXI_awid[1:0] = auto_pc_to_s00_couplers_AWID;
  assign M_AXI_awlen[3:0] = auto_pc_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[1:0] = auto_pc_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_pc_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_pc_to_s00_couplers_AWSIZE;
  assign M_AXI_awuser[0] = auto_pc_to_s00_couplers_AWUSER;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wid[1:0] = auto_pc_to_s00_couplers_WID;
  assign M_AXI_wlast = auto_pc_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wuser[0] = auto_pc_to_s00_couplers_WUSER;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[1:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[63:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[1:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_ruser[0] = s00_couplers_to_auto_pc_RUSER;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BID = M_AXI_bid[5:0];
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_pc_to_s00_couplers_RID = M_AXI_rid[5:0];
  assign auto_pc_to_s00_couplers_RLAST = M_AXI_rlast;
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[1:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock;
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARUSER = S_AXI_aruser[0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[1:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock;
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWUSER = S_AXI_awuser[0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[63:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[7:0];
  assign s00_couplers_to_auto_pc_WUSER = S_AXI_wuser[0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
  design_1_auto_pc_3 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arburst(auto_pc_to_s00_couplers_ARBURST),
        .m_axi_arcache(auto_pc_to_s00_couplers_ARCACHE),
        .m_axi_arid(auto_pc_to_s00_couplers_ARID),
        .m_axi_arlen(auto_pc_to_s00_couplers_ARLEN),
        .m_axi_arlock(auto_pc_to_s00_couplers_ARLOCK),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arqos(auto_pc_to_s00_couplers_ARQOS),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arsize(auto_pc_to_s00_couplers_ARSIZE),
        .m_axi_aruser(auto_pc_to_s00_couplers_ARUSER),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awburst(auto_pc_to_s00_couplers_AWBURST),
        .m_axi_awcache(auto_pc_to_s00_couplers_AWCACHE),
        .m_axi_awid(auto_pc_to_s00_couplers_AWID),
        .m_axi_awlen(auto_pc_to_s00_couplers_AWLEN),
        .m_axi_awlock(auto_pc_to_s00_couplers_AWLOCK),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awqos(auto_pc_to_s00_couplers_AWQOS),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awsize(auto_pc_to_s00_couplers_AWSIZE),
        .m_axi_awuser(auto_pc_to_s00_couplers_AWUSER),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bid(auto_pc_to_s00_couplers_BID[1:0]),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rid(auto_pc_to_s00_couplers_RID[1:0]),
        .m_axi_rlast(auto_pc_to_s00_couplers_RLAST),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wid(auto_pc_to_s00_couplers_WID),
        .m_axi_wlast(auto_pc_to_s00_couplers_WLAST),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wuser(auto_pc_to_s00_couplers_WUSER),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_aruser(s00_couplers_to_auto_pc_ARUSER),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awuser(s00_couplers_to_auto_pc_AWUSER),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_ruser(s00_couplers_to_auto_pc_RUSER),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wuser(s00_couplers_to_auto_pc_WUSER),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

module s00_couplers_imp_XOWISC
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_buser,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_ruser,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wuser,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_buser,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [1:0]M_AXI_arid;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output [0:0]M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [1:0]M_AXI_awid;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output [0:0]M_AXI_awuser;
  output M_AXI_awvalid;
  input [2:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_buser;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [2:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_ruser;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output [0:0]M_AXI_wuser;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [1:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [1:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [1:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_buser;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [1:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire [31:0]s00_couplers_to_s00_data_fifo_ARADDR;
  wire [1:0]s00_couplers_to_s00_data_fifo_ARBURST;
  wire [3:0]s00_couplers_to_s00_data_fifo_ARCACHE;
  wire [1:0]s00_couplers_to_s00_data_fifo_ARID;
  wire [7:0]s00_couplers_to_s00_data_fifo_ARLEN;
  wire s00_couplers_to_s00_data_fifo_ARLOCK;
  wire [2:0]s00_couplers_to_s00_data_fifo_ARPROT;
  wire [3:0]s00_couplers_to_s00_data_fifo_ARQOS;
  wire s00_couplers_to_s00_data_fifo_ARREADY;
  wire [2:0]s00_couplers_to_s00_data_fifo_ARSIZE;
  wire [0:0]s00_couplers_to_s00_data_fifo_ARUSER;
  wire s00_couplers_to_s00_data_fifo_ARVALID;
  wire [31:0]s00_couplers_to_s00_data_fifo_AWADDR;
  wire [1:0]s00_couplers_to_s00_data_fifo_AWBURST;
  wire [3:0]s00_couplers_to_s00_data_fifo_AWCACHE;
  wire [1:0]s00_couplers_to_s00_data_fifo_AWID;
  wire [7:0]s00_couplers_to_s00_data_fifo_AWLEN;
  wire s00_couplers_to_s00_data_fifo_AWLOCK;
  wire [2:0]s00_couplers_to_s00_data_fifo_AWPROT;
  wire [3:0]s00_couplers_to_s00_data_fifo_AWQOS;
  wire s00_couplers_to_s00_data_fifo_AWREADY;
  wire [2:0]s00_couplers_to_s00_data_fifo_AWSIZE;
  wire [0:0]s00_couplers_to_s00_data_fifo_AWUSER;
  wire s00_couplers_to_s00_data_fifo_AWVALID;
  wire [1:0]s00_couplers_to_s00_data_fifo_BID;
  wire s00_couplers_to_s00_data_fifo_BREADY;
  wire [1:0]s00_couplers_to_s00_data_fifo_BRESP;
  wire [0:0]s00_couplers_to_s00_data_fifo_BUSER;
  wire s00_couplers_to_s00_data_fifo_BVALID;
  wire [63:0]s00_couplers_to_s00_data_fifo_RDATA;
  wire [1:0]s00_couplers_to_s00_data_fifo_RID;
  wire s00_couplers_to_s00_data_fifo_RLAST;
  wire s00_couplers_to_s00_data_fifo_RREADY;
  wire [1:0]s00_couplers_to_s00_data_fifo_RRESP;
  wire [0:0]s00_couplers_to_s00_data_fifo_RUSER;
  wire s00_couplers_to_s00_data_fifo_RVALID;
  wire [63:0]s00_couplers_to_s00_data_fifo_WDATA;
  wire s00_couplers_to_s00_data_fifo_WLAST;
  wire s00_couplers_to_s00_data_fifo_WREADY;
  wire [7:0]s00_couplers_to_s00_data_fifo_WSTRB;
  wire [0:0]s00_couplers_to_s00_data_fifo_WUSER;
  wire s00_couplers_to_s00_data_fifo_WVALID;
  wire [31:0]s00_data_fifo_to_s00_couplers_ARADDR;
  wire [1:0]s00_data_fifo_to_s00_couplers_ARBURST;
  wire [3:0]s00_data_fifo_to_s00_couplers_ARCACHE;
  wire [1:0]s00_data_fifo_to_s00_couplers_ARID;
  wire [7:0]s00_data_fifo_to_s00_couplers_ARLEN;
  wire [0:0]s00_data_fifo_to_s00_couplers_ARLOCK;
  wire [2:0]s00_data_fifo_to_s00_couplers_ARPROT;
  wire [3:0]s00_data_fifo_to_s00_couplers_ARQOS;
  wire s00_data_fifo_to_s00_couplers_ARREADY;
  wire [2:0]s00_data_fifo_to_s00_couplers_ARSIZE;
  wire [0:0]s00_data_fifo_to_s00_couplers_ARUSER;
  wire s00_data_fifo_to_s00_couplers_ARVALID;
  wire [31:0]s00_data_fifo_to_s00_couplers_AWADDR;
  wire [1:0]s00_data_fifo_to_s00_couplers_AWBURST;
  wire [3:0]s00_data_fifo_to_s00_couplers_AWCACHE;
  wire [1:0]s00_data_fifo_to_s00_couplers_AWID;
  wire [7:0]s00_data_fifo_to_s00_couplers_AWLEN;
  wire [0:0]s00_data_fifo_to_s00_couplers_AWLOCK;
  wire [2:0]s00_data_fifo_to_s00_couplers_AWPROT;
  wire [3:0]s00_data_fifo_to_s00_couplers_AWQOS;
  wire s00_data_fifo_to_s00_couplers_AWREADY;
  wire [2:0]s00_data_fifo_to_s00_couplers_AWSIZE;
  wire [0:0]s00_data_fifo_to_s00_couplers_AWUSER;
  wire s00_data_fifo_to_s00_couplers_AWVALID;
  wire [2:0]s00_data_fifo_to_s00_couplers_BID;
  wire s00_data_fifo_to_s00_couplers_BREADY;
  wire [1:0]s00_data_fifo_to_s00_couplers_BRESP;
  wire [0:0]s00_data_fifo_to_s00_couplers_BUSER;
  wire s00_data_fifo_to_s00_couplers_BVALID;
  wire [63:0]s00_data_fifo_to_s00_couplers_RDATA;
  wire [2:0]s00_data_fifo_to_s00_couplers_RID;
  wire s00_data_fifo_to_s00_couplers_RLAST;
  wire s00_data_fifo_to_s00_couplers_RREADY;
  wire [1:0]s00_data_fifo_to_s00_couplers_RRESP;
  wire [0:0]s00_data_fifo_to_s00_couplers_RUSER;
  wire s00_data_fifo_to_s00_couplers_RVALID;
  wire [63:0]s00_data_fifo_to_s00_couplers_WDATA;
  wire s00_data_fifo_to_s00_couplers_WLAST;
  wire s00_data_fifo_to_s00_couplers_WREADY;
  wire [7:0]s00_data_fifo_to_s00_couplers_WSTRB;
  wire [0:0]s00_data_fifo_to_s00_couplers_WUSER;
  wire s00_data_fifo_to_s00_couplers_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[31:0] = s00_data_fifo_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = s00_data_fifo_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = s00_data_fifo_to_s00_couplers_ARCACHE;
  assign M_AXI_arid[1:0] = s00_data_fifo_to_s00_couplers_ARID;
  assign M_AXI_arlen[7:0] = s00_data_fifo_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[0] = s00_data_fifo_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = s00_data_fifo_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = s00_data_fifo_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = s00_data_fifo_to_s00_couplers_ARSIZE;
  assign M_AXI_aruser[0] = s00_data_fifo_to_s00_couplers_ARUSER;
  assign M_AXI_arvalid = s00_data_fifo_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = s00_data_fifo_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = s00_data_fifo_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = s00_data_fifo_to_s00_couplers_AWCACHE;
  assign M_AXI_awid[1:0] = s00_data_fifo_to_s00_couplers_AWID;
  assign M_AXI_awlen[7:0] = s00_data_fifo_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[0] = s00_data_fifo_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = s00_data_fifo_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = s00_data_fifo_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = s00_data_fifo_to_s00_couplers_AWSIZE;
  assign M_AXI_awuser[0] = s00_data_fifo_to_s00_couplers_AWUSER;
  assign M_AXI_awvalid = s00_data_fifo_to_s00_couplers_AWVALID;
  assign M_AXI_bready = s00_data_fifo_to_s00_couplers_BREADY;
  assign M_AXI_rready = s00_data_fifo_to_s00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = s00_data_fifo_to_s00_couplers_WDATA;
  assign M_AXI_wlast = s00_data_fifo_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = s00_data_fifo_to_s00_couplers_WSTRB;
  assign M_AXI_wuser[0] = s00_data_fifo_to_s00_couplers_WUSER;
  assign M_AXI_wvalid = s00_data_fifo_to_s00_couplers_WVALID;
  assign S_AXI_arready = s00_couplers_to_s00_data_fifo_ARREADY;
  assign S_AXI_awready = s00_couplers_to_s00_data_fifo_AWREADY;
  assign S_AXI_bid[1:0] = s00_couplers_to_s00_data_fifo_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_s00_data_fifo_BRESP;
  assign S_AXI_buser[0] = s00_couplers_to_s00_data_fifo_BUSER;
  assign S_AXI_bvalid = s00_couplers_to_s00_data_fifo_BVALID;
  assign S_AXI_rdata[63:0] = s00_couplers_to_s00_data_fifo_RDATA;
  assign S_AXI_rid[1:0] = s00_couplers_to_s00_data_fifo_RID;
  assign S_AXI_rlast = s00_couplers_to_s00_data_fifo_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_s00_data_fifo_RRESP;
  assign S_AXI_ruser[0] = s00_couplers_to_s00_data_fifo_RUSER;
  assign S_AXI_rvalid = s00_couplers_to_s00_data_fifo_RVALID;
  assign S_AXI_wready = s00_couplers_to_s00_data_fifo_WREADY;
  assign s00_couplers_to_s00_data_fifo_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_s00_data_fifo_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_s00_data_fifo_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_s00_data_fifo_ARID = S_AXI_arid[1:0];
  assign s00_couplers_to_s00_data_fifo_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_s00_data_fifo_ARLOCK = S_AXI_arlock;
  assign s00_couplers_to_s00_data_fifo_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_s00_data_fifo_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_s00_data_fifo_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_s00_data_fifo_ARUSER = S_AXI_aruser[0];
  assign s00_couplers_to_s00_data_fifo_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_s00_data_fifo_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_s00_data_fifo_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_s00_data_fifo_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_s00_data_fifo_AWID = S_AXI_awid[1:0];
  assign s00_couplers_to_s00_data_fifo_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_s00_data_fifo_AWLOCK = S_AXI_awlock;
  assign s00_couplers_to_s00_data_fifo_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_s00_data_fifo_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_s00_data_fifo_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_s00_data_fifo_AWUSER = S_AXI_awuser[0];
  assign s00_couplers_to_s00_data_fifo_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_s00_data_fifo_BREADY = S_AXI_bready;
  assign s00_couplers_to_s00_data_fifo_RREADY = S_AXI_rready;
  assign s00_couplers_to_s00_data_fifo_WDATA = S_AXI_wdata[63:0];
  assign s00_couplers_to_s00_data_fifo_WLAST = S_AXI_wlast;
  assign s00_couplers_to_s00_data_fifo_WSTRB = S_AXI_wstrb[7:0];
  assign s00_couplers_to_s00_data_fifo_WUSER = S_AXI_wuser[0];
  assign s00_couplers_to_s00_data_fifo_WVALID = S_AXI_wvalid;
  assign s00_data_fifo_to_s00_couplers_ARREADY = M_AXI_arready;
  assign s00_data_fifo_to_s00_couplers_AWREADY = M_AXI_awready;
  assign s00_data_fifo_to_s00_couplers_BID = M_AXI_bid[2:0];
  assign s00_data_fifo_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign s00_data_fifo_to_s00_couplers_BUSER = M_AXI_buser[0];
  assign s00_data_fifo_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign s00_data_fifo_to_s00_couplers_RDATA = M_AXI_rdata[63:0];
  assign s00_data_fifo_to_s00_couplers_RID = M_AXI_rid[2:0];
  assign s00_data_fifo_to_s00_couplers_RLAST = M_AXI_rlast;
  assign s00_data_fifo_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign s00_data_fifo_to_s00_couplers_RUSER = M_AXI_ruser[0];
  assign s00_data_fifo_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign s00_data_fifo_to_s00_couplers_WREADY = M_AXI_wready;
  design_1_s00_data_fifo_1 s00_data_fifo
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(s00_data_fifo_to_s00_couplers_ARADDR),
        .m_axi_arburst(s00_data_fifo_to_s00_couplers_ARBURST),
        .m_axi_arcache(s00_data_fifo_to_s00_couplers_ARCACHE),
        .m_axi_arid(s00_data_fifo_to_s00_couplers_ARID),
        .m_axi_arlen(s00_data_fifo_to_s00_couplers_ARLEN),
        .m_axi_arlock(s00_data_fifo_to_s00_couplers_ARLOCK),
        .m_axi_arprot(s00_data_fifo_to_s00_couplers_ARPROT),
        .m_axi_arqos(s00_data_fifo_to_s00_couplers_ARQOS),
        .m_axi_arready(s00_data_fifo_to_s00_couplers_ARREADY),
        .m_axi_arsize(s00_data_fifo_to_s00_couplers_ARSIZE),
        .m_axi_aruser(s00_data_fifo_to_s00_couplers_ARUSER),
        .m_axi_arvalid(s00_data_fifo_to_s00_couplers_ARVALID),
        .m_axi_awaddr(s00_data_fifo_to_s00_couplers_AWADDR),
        .m_axi_awburst(s00_data_fifo_to_s00_couplers_AWBURST),
        .m_axi_awcache(s00_data_fifo_to_s00_couplers_AWCACHE),
        .m_axi_awid(s00_data_fifo_to_s00_couplers_AWID),
        .m_axi_awlen(s00_data_fifo_to_s00_couplers_AWLEN),
        .m_axi_awlock(s00_data_fifo_to_s00_couplers_AWLOCK),
        .m_axi_awprot(s00_data_fifo_to_s00_couplers_AWPROT),
        .m_axi_awqos(s00_data_fifo_to_s00_couplers_AWQOS),
        .m_axi_awready(s00_data_fifo_to_s00_couplers_AWREADY),
        .m_axi_awsize(s00_data_fifo_to_s00_couplers_AWSIZE),
        .m_axi_awuser(s00_data_fifo_to_s00_couplers_AWUSER),
        .m_axi_awvalid(s00_data_fifo_to_s00_couplers_AWVALID),
        .m_axi_bid(s00_data_fifo_to_s00_couplers_BID[1:0]),
        .m_axi_bready(s00_data_fifo_to_s00_couplers_BREADY),
        .m_axi_bresp(s00_data_fifo_to_s00_couplers_BRESP),
        .m_axi_buser(s00_data_fifo_to_s00_couplers_BUSER),
        .m_axi_bvalid(s00_data_fifo_to_s00_couplers_BVALID),
        .m_axi_rdata(s00_data_fifo_to_s00_couplers_RDATA),
        .m_axi_rid(s00_data_fifo_to_s00_couplers_RID[1:0]),
        .m_axi_rlast(s00_data_fifo_to_s00_couplers_RLAST),
        .m_axi_rready(s00_data_fifo_to_s00_couplers_RREADY),
        .m_axi_rresp(s00_data_fifo_to_s00_couplers_RRESP),
        .m_axi_ruser(s00_data_fifo_to_s00_couplers_RUSER),
        .m_axi_rvalid(s00_data_fifo_to_s00_couplers_RVALID),
        .m_axi_wdata(s00_data_fifo_to_s00_couplers_WDATA),
        .m_axi_wlast(s00_data_fifo_to_s00_couplers_WLAST),
        .m_axi_wready(s00_data_fifo_to_s00_couplers_WREADY),
        .m_axi_wstrb(s00_data_fifo_to_s00_couplers_WSTRB),
        .m_axi_wuser(s00_data_fifo_to_s00_couplers_WUSER),
        .m_axi_wvalid(s00_data_fifo_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_s00_data_fifo_ARADDR),
        .s_axi_arburst(s00_couplers_to_s00_data_fifo_ARBURST),
        .s_axi_arcache(s00_couplers_to_s00_data_fifo_ARCACHE),
        .s_axi_arid(s00_couplers_to_s00_data_fifo_ARID),
        .s_axi_arlen(s00_couplers_to_s00_data_fifo_ARLEN),
        .s_axi_arlock(s00_couplers_to_s00_data_fifo_ARLOCK),
        .s_axi_arprot(s00_couplers_to_s00_data_fifo_ARPROT),
        .s_axi_arqos(s00_couplers_to_s00_data_fifo_ARQOS),
        .s_axi_arready(s00_couplers_to_s00_data_fifo_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(s00_couplers_to_s00_data_fifo_ARSIZE),
        .s_axi_aruser(s00_couplers_to_s00_data_fifo_ARUSER),
        .s_axi_arvalid(s00_couplers_to_s00_data_fifo_ARVALID),
        .s_axi_awaddr(s00_couplers_to_s00_data_fifo_AWADDR),
        .s_axi_awburst(s00_couplers_to_s00_data_fifo_AWBURST),
        .s_axi_awcache(s00_couplers_to_s00_data_fifo_AWCACHE),
        .s_axi_awid(s00_couplers_to_s00_data_fifo_AWID),
        .s_axi_awlen(s00_couplers_to_s00_data_fifo_AWLEN),
        .s_axi_awlock(s00_couplers_to_s00_data_fifo_AWLOCK),
        .s_axi_awprot(s00_couplers_to_s00_data_fifo_AWPROT),
        .s_axi_awqos(s00_couplers_to_s00_data_fifo_AWQOS),
        .s_axi_awready(s00_couplers_to_s00_data_fifo_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(s00_couplers_to_s00_data_fifo_AWSIZE),
        .s_axi_awuser(s00_couplers_to_s00_data_fifo_AWUSER),
        .s_axi_awvalid(s00_couplers_to_s00_data_fifo_AWVALID),
        .s_axi_bid(s00_couplers_to_s00_data_fifo_BID),
        .s_axi_bready(s00_couplers_to_s00_data_fifo_BREADY),
        .s_axi_bresp(s00_couplers_to_s00_data_fifo_BRESP),
        .s_axi_buser(s00_couplers_to_s00_data_fifo_BUSER),
        .s_axi_bvalid(s00_couplers_to_s00_data_fifo_BVALID),
        .s_axi_rdata(s00_couplers_to_s00_data_fifo_RDATA),
        .s_axi_rid(s00_couplers_to_s00_data_fifo_RID),
        .s_axi_rlast(s00_couplers_to_s00_data_fifo_RLAST),
        .s_axi_rready(s00_couplers_to_s00_data_fifo_RREADY),
        .s_axi_rresp(s00_couplers_to_s00_data_fifo_RRESP),
        .s_axi_ruser(s00_couplers_to_s00_data_fifo_RUSER),
        .s_axi_rvalid(s00_couplers_to_s00_data_fifo_RVALID),
        .s_axi_wdata(s00_couplers_to_s00_data_fifo_WDATA),
        .s_axi_wlast(s00_couplers_to_s00_data_fifo_WLAST),
        .s_axi_wready(s00_couplers_to_s00_data_fifo_WREADY),
        .s_axi_wstrb(s00_couplers_to_s00_data_fifo_WSTRB),
        .s_axi_wuser(s00_couplers_to_s00_data_fifo_WUSER),
        .s_axi_wvalid(s00_couplers_to_s00_data_fifo_WVALID));
endmodule

module s01_couplers_imp_15OSRGD
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [7:0]S_AXI_arlen;
  input [1:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [7:0]S_AXI_awlen;
  input [1:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_us_df_to_s01_couplers_ARADDR;
  wire [1:0]auto_us_df_to_s01_couplers_ARBURST;
  wire [3:0]auto_us_df_to_s01_couplers_ARCACHE;
  wire [7:0]auto_us_df_to_s01_couplers_ARLEN;
  wire [0:0]auto_us_df_to_s01_couplers_ARLOCK;
  wire [2:0]auto_us_df_to_s01_couplers_ARPROT;
  wire [3:0]auto_us_df_to_s01_couplers_ARQOS;
  wire auto_us_df_to_s01_couplers_ARREADY;
  wire [2:0]auto_us_df_to_s01_couplers_ARSIZE;
  wire auto_us_df_to_s01_couplers_ARVALID;
  wire [31:0]auto_us_df_to_s01_couplers_AWADDR;
  wire [1:0]auto_us_df_to_s01_couplers_AWBURST;
  wire [3:0]auto_us_df_to_s01_couplers_AWCACHE;
  wire [7:0]auto_us_df_to_s01_couplers_AWLEN;
  wire [0:0]auto_us_df_to_s01_couplers_AWLOCK;
  wire [2:0]auto_us_df_to_s01_couplers_AWPROT;
  wire [3:0]auto_us_df_to_s01_couplers_AWQOS;
  wire auto_us_df_to_s01_couplers_AWREADY;
  wire [2:0]auto_us_df_to_s01_couplers_AWSIZE;
  wire auto_us_df_to_s01_couplers_AWVALID;
  wire auto_us_df_to_s01_couplers_BREADY;
  wire [1:0]auto_us_df_to_s01_couplers_BRESP;
  wire auto_us_df_to_s01_couplers_BVALID;
  wire [63:0]auto_us_df_to_s01_couplers_RDATA;
  wire auto_us_df_to_s01_couplers_RLAST;
  wire auto_us_df_to_s01_couplers_RREADY;
  wire [1:0]auto_us_df_to_s01_couplers_RRESP;
  wire auto_us_df_to_s01_couplers_RVALID;
  wire [63:0]auto_us_df_to_s01_couplers_WDATA;
  wire auto_us_df_to_s01_couplers_WLAST;
  wire auto_us_df_to_s01_couplers_WREADY;
  wire [7:0]auto_us_df_to_s01_couplers_WSTRB;
  wire auto_us_df_to_s01_couplers_WVALID;
  wire [31:0]s01_couplers_to_auto_us_df_ARADDR;
  wire [1:0]s01_couplers_to_auto_us_df_ARBURST;
  wire [3:0]s01_couplers_to_auto_us_df_ARCACHE;
  wire [7:0]s01_couplers_to_auto_us_df_ARLEN;
  wire [1:0]s01_couplers_to_auto_us_df_ARLOCK;
  wire [2:0]s01_couplers_to_auto_us_df_ARPROT;
  wire [3:0]s01_couplers_to_auto_us_df_ARQOS;
  wire s01_couplers_to_auto_us_df_ARREADY;
  wire [3:0]s01_couplers_to_auto_us_df_ARREGION;
  wire [2:0]s01_couplers_to_auto_us_df_ARSIZE;
  wire s01_couplers_to_auto_us_df_ARVALID;
  wire [31:0]s01_couplers_to_auto_us_df_AWADDR;
  wire [1:0]s01_couplers_to_auto_us_df_AWBURST;
  wire [3:0]s01_couplers_to_auto_us_df_AWCACHE;
  wire [7:0]s01_couplers_to_auto_us_df_AWLEN;
  wire [1:0]s01_couplers_to_auto_us_df_AWLOCK;
  wire [2:0]s01_couplers_to_auto_us_df_AWPROT;
  wire [3:0]s01_couplers_to_auto_us_df_AWQOS;
  wire s01_couplers_to_auto_us_df_AWREADY;
  wire [3:0]s01_couplers_to_auto_us_df_AWREGION;
  wire [2:0]s01_couplers_to_auto_us_df_AWSIZE;
  wire s01_couplers_to_auto_us_df_AWVALID;
  wire s01_couplers_to_auto_us_df_BREADY;
  wire [1:0]s01_couplers_to_auto_us_df_BRESP;
  wire s01_couplers_to_auto_us_df_BVALID;
  wire [31:0]s01_couplers_to_auto_us_df_RDATA;
  wire s01_couplers_to_auto_us_df_RLAST;
  wire s01_couplers_to_auto_us_df_RREADY;
  wire [1:0]s01_couplers_to_auto_us_df_RRESP;
  wire s01_couplers_to_auto_us_df_RVALID;
  wire [31:0]s01_couplers_to_auto_us_df_WDATA;
  wire s01_couplers_to_auto_us_df_WLAST;
  wire s01_couplers_to_auto_us_df_WREADY;
  wire [3:0]s01_couplers_to_auto_us_df_WSTRB;
  wire s01_couplers_to_auto_us_df_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[31:0] = auto_us_df_to_s01_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_us_df_to_s01_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_us_df_to_s01_couplers_ARCACHE;
  assign M_AXI_arlen[7:0] = auto_us_df_to_s01_couplers_ARLEN;
  assign M_AXI_arlock[0] = auto_us_df_to_s01_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_us_df_to_s01_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_us_df_to_s01_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_us_df_to_s01_couplers_ARSIZE;
  assign M_AXI_arvalid = auto_us_df_to_s01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_us_df_to_s01_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_us_df_to_s01_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_us_df_to_s01_couplers_AWCACHE;
  assign M_AXI_awlen[7:0] = auto_us_df_to_s01_couplers_AWLEN;
  assign M_AXI_awlock[0] = auto_us_df_to_s01_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_us_df_to_s01_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_us_df_to_s01_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_us_df_to_s01_couplers_AWSIZE;
  assign M_AXI_awvalid = auto_us_df_to_s01_couplers_AWVALID;
  assign M_AXI_bready = auto_us_df_to_s01_couplers_BREADY;
  assign M_AXI_rready = auto_us_df_to_s01_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_us_df_to_s01_couplers_WDATA;
  assign M_AXI_wlast = auto_us_df_to_s01_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_us_df_to_s01_couplers_WSTRB;
  assign M_AXI_wvalid = auto_us_df_to_s01_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s01_couplers_to_auto_us_df_ARREADY;
  assign S_AXI_awready = s01_couplers_to_auto_us_df_AWREADY;
  assign S_AXI_bresp[1:0] = s01_couplers_to_auto_us_df_BRESP;
  assign S_AXI_bvalid = s01_couplers_to_auto_us_df_BVALID;
  assign S_AXI_rdata[31:0] = s01_couplers_to_auto_us_df_RDATA;
  assign S_AXI_rlast = s01_couplers_to_auto_us_df_RLAST;
  assign S_AXI_rresp[1:0] = s01_couplers_to_auto_us_df_RRESP;
  assign S_AXI_rvalid = s01_couplers_to_auto_us_df_RVALID;
  assign S_AXI_wready = s01_couplers_to_auto_us_df_WREADY;
  assign auto_us_df_to_s01_couplers_ARREADY = M_AXI_arready;
  assign auto_us_df_to_s01_couplers_AWREADY = M_AXI_awready;
  assign auto_us_df_to_s01_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_us_df_to_s01_couplers_BVALID = M_AXI_bvalid;
  assign auto_us_df_to_s01_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_us_df_to_s01_couplers_RLAST = M_AXI_rlast;
  assign auto_us_df_to_s01_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_us_df_to_s01_couplers_RVALID = M_AXI_rvalid;
  assign auto_us_df_to_s01_couplers_WREADY = M_AXI_wready;
  assign s01_couplers_to_auto_us_df_ARADDR = S_AXI_araddr[31:0];
  assign s01_couplers_to_auto_us_df_ARBURST = S_AXI_arburst[1:0];
  assign s01_couplers_to_auto_us_df_ARCACHE = S_AXI_arcache[3:0];
  assign s01_couplers_to_auto_us_df_ARLEN = S_AXI_arlen[7:0];
  assign s01_couplers_to_auto_us_df_ARLOCK = S_AXI_arlock[1:0];
  assign s01_couplers_to_auto_us_df_ARPROT = S_AXI_arprot[2:0];
  assign s01_couplers_to_auto_us_df_ARQOS = S_AXI_arqos[3:0];
  assign s01_couplers_to_auto_us_df_ARREGION = S_AXI_arregion[3:0];
  assign s01_couplers_to_auto_us_df_ARSIZE = S_AXI_arsize[2:0];
  assign s01_couplers_to_auto_us_df_ARVALID = S_AXI_arvalid;
  assign s01_couplers_to_auto_us_df_AWADDR = S_AXI_awaddr[31:0];
  assign s01_couplers_to_auto_us_df_AWBURST = S_AXI_awburst[1:0];
  assign s01_couplers_to_auto_us_df_AWCACHE = S_AXI_awcache[3:0];
  assign s01_couplers_to_auto_us_df_AWLEN = S_AXI_awlen[7:0];
  assign s01_couplers_to_auto_us_df_AWLOCK = S_AXI_awlock[1:0];
  assign s01_couplers_to_auto_us_df_AWPROT = S_AXI_awprot[2:0];
  assign s01_couplers_to_auto_us_df_AWQOS = S_AXI_awqos[3:0];
  assign s01_couplers_to_auto_us_df_AWREGION = S_AXI_awregion[3:0];
  assign s01_couplers_to_auto_us_df_AWSIZE = S_AXI_awsize[2:0];
  assign s01_couplers_to_auto_us_df_AWVALID = S_AXI_awvalid;
  assign s01_couplers_to_auto_us_df_BREADY = S_AXI_bready;
  assign s01_couplers_to_auto_us_df_RREADY = S_AXI_rready;
  assign s01_couplers_to_auto_us_df_WDATA = S_AXI_wdata[31:0];
  assign s01_couplers_to_auto_us_df_WLAST = S_AXI_wlast;
  assign s01_couplers_to_auto_us_df_WSTRB = S_AXI_wstrb[3:0];
  assign s01_couplers_to_auto_us_df_WVALID = S_AXI_wvalid;
  design_1_auto_us_df_1 auto_us_df
       (.m_axi_araddr(auto_us_df_to_s01_couplers_ARADDR),
        .m_axi_arburst(auto_us_df_to_s01_couplers_ARBURST),
        .m_axi_arcache(auto_us_df_to_s01_couplers_ARCACHE),
        .m_axi_arlen(auto_us_df_to_s01_couplers_ARLEN),
        .m_axi_arlock(auto_us_df_to_s01_couplers_ARLOCK),
        .m_axi_arprot(auto_us_df_to_s01_couplers_ARPROT),
        .m_axi_arqos(auto_us_df_to_s01_couplers_ARQOS),
        .m_axi_arready(auto_us_df_to_s01_couplers_ARREADY),
        .m_axi_arsize(auto_us_df_to_s01_couplers_ARSIZE),
        .m_axi_arvalid(auto_us_df_to_s01_couplers_ARVALID),
        .m_axi_awaddr(auto_us_df_to_s01_couplers_AWADDR),
        .m_axi_awburst(auto_us_df_to_s01_couplers_AWBURST),
        .m_axi_awcache(auto_us_df_to_s01_couplers_AWCACHE),
        .m_axi_awlen(auto_us_df_to_s01_couplers_AWLEN),
        .m_axi_awlock(auto_us_df_to_s01_couplers_AWLOCK),
        .m_axi_awprot(auto_us_df_to_s01_couplers_AWPROT),
        .m_axi_awqos(auto_us_df_to_s01_couplers_AWQOS),
        .m_axi_awready(auto_us_df_to_s01_couplers_AWREADY),
        .m_axi_awsize(auto_us_df_to_s01_couplers_AWSIZE),
        .m_axi_awvalid(auto_us_df_to_s01_couplers_AWVALID),
        .m_axi_bready(auto_us_df_to_s01_couplers_BREADY),
        .m_axi_bresp(auto_us_df_to_s01_couplers_BRESP),
        .m_axi_bvalid(auto_us_df_to_s01_couplers_BVALID),
        .m_axi_rdata(auto_us_df_to_s01_couplers_RDATA),
        .m_axi_rlast(auto_us_df_to_s01_couplers_RLAST),
        .m_axi_rready(auto_us_df_to_s01_couplers_RREADY),
        .m_axi_rresp(auto_us_df_to_s01_couplers_RRESP),
        .m_axi_rvalid(auto_us_df_to_s01_couplers_RVALID),
        .m_axi_wdata(auto_us_df_to_s01_couplers_WDATA),
        .m_axi_wlast(auto_us_df_to_s01_couplers_WLAST),
        .m_axi_wready(auto_us_df_to_s01_couplers_WREADY),
        .m_axi_wstrb(auto_us_df_to_s01_couplers_WSTRB),
        .m_axi_wvalid(auto_us_df_to_s01_couplers_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(s01_couplers_to_auto_us_df_ARADDR),
        .s_axi_arburst(s01_couplers_to_auto_us_df_ARBURST),
        .s_axi_arcache(s01_couplers_to_auto_us_df_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arlen(s01_couplers_to_auto_us_df_ARLEN),
        .s_axi_arlock(s01_couplers_to_auto_us_df_ARLOCK[0]),
        .s_axi_arprot(s01_couplers_to_auto_us_df_ARPROT),
        .s_axi_arqos(s01_couplers_to_auto_us_df_ARQOS),
        .s_axi_arready(s01_couplers_to_auto_us_df_ARREADY),
        .s_axi_arregion(s01_couplers_to_auto_us_df_ARREGION),
        .s_axi_arsize(s01_couplers_to_auto_us_df_ARSIZE),
        .s_axi_arvalid(s01_couplers_to_auto_us_df_ARVALID),
        .s_axi_awaddr(s01_couplers_to_auto_us_df_AWADDR),
        .s_axi_awburst(s01_couplers_to_auto_us_df_AWBURST),
        .s_axi_awcache(s01_couplers_to_auto_us_df_AWCACHE),
        .s_axi_awlen(s01_couplers_to_auto_us_df_AWLEN),
        .s_axi_awlock(s01_couplers_to_auto_us_df_AWLOCK[0]),
        .s_axi_awprot(s01_couplers_to_auto_us_df_AWPROT),
        .s_axi_awqos(s01_couplers_to_auto_us_df_AWQOS),
        .s_axi_awready(s01_couplers_to_auto_us_df_AWREADY),
        .s_axi_awregion(s01_couplers_to_auto_us_df_AWREGION),
        .s_axi_awsize(s01_couplers_to_auto_us_df_AWSIZE),
        .s_axi_awvalid(s01_couplers_to_auto_us_df_AWVALID),
        .s_axi_bready(s01_couplers_to_auto_us_df_BREADY),
        .s_axi_bresp(s01_couplers_to_auto_us_df_BRESP),
        .s_axi_bvalid(s01_couplers_to_auto_us_df_BVALID),
        .s_axi_rdata(s01_couplers_to_auto_us_df_RDATA),
        .s_axi_rlast(s01_couplers_to_auto_us_df_RLAST),
        .s_axi_rready(s01_couplers_to_auto_us_df_RREADY),
        .s_axi_rresp(s01_couplers_to_auto_us_df_RRESP),
        .s_axi_rvalid(s01_couplers_to_auto_us_df_RVALID),
        .s_axi_wdata(s01_couplers_to_auto_us_df_WDATA),
        .s_axi_wlast(s01_couplers_to_auto_us_df_WLAST),
        .s_axi_wready(s01_couplers_to_auto_us_df_WREADY),
        .s_axi_wstrb(s01_couplers_to_auto_us_df_WSTRB),
        .s_axi_wvalid(s01_couplers_to_auto_us_df_WVALID));
endmodule

module s01_couplers_imp_1CMTC59
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [7:0]S_AXI_arlen;
  input [1:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [7:0]S_AXI_awlen;
  input [1:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [31:0]auto_us_df_to_s01_couplers_ARADDR;
  wire [1:0]auto_us_df_to_s01_couplers_ARBURST;
  wire [3:0]auto_us_df_to_s01_couplers_ARCACHE;
  wire [7:0]auto_us_df_to_s01_couplers_ARLEN;
  wire [0:0]auto_us_df_to_s01_couplers_ARLOCK;
  wire [2:0]auto_us_df_to_s01_couplers_ARPROT;
  wire [3:0]auto_us_df_to_s01_couplers_ARQOS;
  wire auto_us_df_to_s01_couplers_ARREADY;
  wire [2:0]auto_us_df_to_s01_couplers_ARSIZE;
  wire auto_us_df_to_s01_couplers_ARVALID;
  wire [31:0]auto_us_df_to_s01_couplers_AWADDR;
  wire [1:0]auto_us_df_to_s01_couplers_AWBURST;
  wire [3:0]auto_us_df_to_s01_couplers_AWCACHE;
  wire [7:0]auto_us_df_to_s01_couplers_AWLEN;
  wire [0:0]auto_us_df_to_s01_couplers_AWLOCK;
  wire [2:0]auto_us_df_to_s01_couplers_AWPROT;
  wire [3:0]auto_us_df_to_s01_couplers_AWQOS;
  wire auto_us_df_to_s01_couplers_AWREADY;
  wire [2:0]auto_us_df_to_s01_couplers_AWSIZE;
  wire auto_us_df_to_s01_couplers_AWVALID;
  wire auto_us_df_to_s01_couplers_BREADY;
  wire [1:0]auto_us_df_to_s01_couplers_BRESP;
  wire auto_us_df_to_s01_couplers_BVALID;
  wire [63:0]auto_us_df_to_s01_couplers_RDATA;
  wire auto_us_df_to_s01_couplers_RLAST;
  wire auto_us_df_to_s01_couplers_RREADY;
  wire [1:0]auto_us_df_to_s01_couplers_RRESP;
  wire auto_us_df_to_s01_couplers_RVALID;
  wire [63:0]auto_us_df_to_s01_couplers_WDATA;
  wire auto_us_df_to_s01_couplers_WLAST;
  wire auto_us_df_to_s01_couplers_WREADY;
  wire [7:0]auto_us_df_to_s01_couplers_WSTRB;
  wire auto_us_df_to_s01_couplers_WVALID;
  wire [31:0]s01_couplers_to_auto_us_df_ARADDR;
  wire [1:0]s01_couplers_to_auto_us_df_ARBURST;
  wire [3:0]s01_couplers_to_auto_us_df_ARCACHE;
  wire [7:0]s01_couplers_to_auto_us_df_ARLEN;
  wire [1:0]s01_couplers_to_auto_us_df_ARLOCK;
  wire [2:0]s01_couplers_to_auto_us_df_ARPROT;
  wire [3:0]s01_couplers_to_auto_us_df_ARQOS;
  wire s01_couplers_to_auto_us_df_ARREADY;
  wire [3:0]s01_couplers_to_auto_us_df_ARREGION;
  wire [2:0]s01_couplers_to_auto_us_df_ARSIZE;
  wire s01_couplers_to_auto_us_df_ARVALID;
  wire [31:0]s01_couplers_to_auto_us_df_AWADDR;
  wire [1:0]s01_couplers_to_auto_us_df_AWBURST;
  wire [3:0]s01_couplers_to_auto_us_df_AWCACHE;
  wire [7:0]s01_couplers_to_auto_us_df_AWLEN;
  wire [1:0]s01_couplers_to_auto_us_df_AWLOCK;
  wire [2:0]s01_couplers_to_auto_us_df_AWPROT;
  wire [3:0]s01_couplers_to_auto_us_df_AWQOS;
  wire s01_couplers_to_auto_us_df_AWREADY;
  wire [3:0]s01_couplers_to_auto_us_df_AWREGION;
  wire [2:0]s01_couplers_to_auto_us_df_AWSIZE;
  wire s01_couplers_to_auto_us_df_AWVALID;
  wire s01_couplers_to_auto_us_df_BREADY;
  wire [1:0]s01_couplers_to_auto_us_df_BRESP;
  wire s01_couplers_to_auto_us_df_BVALID;
  wire [31:0]s01_couplers_to_auto_us_df_RDATA;
  wire s01_couplers_to_auto_us_df_RLAST;
  wire s01_couplers_to_auto_us_df_RREADY;
  wire [1:0]s01_couplers_to_auto_us_df_RRESP;
  wire s01_couplers_to_auto_us_df_RVALID;
  wire [31:0]s01_couplers_to_auto_us_df_WDATA;
  wire s01_couplers_to_auto_us_df_WLAST;
  wire s01_couplers_to_auto_us_df_WREADY;
  wire [3:0]s01_couplers_to_auto_us_df_WSTRB;
  wire s01_couplers_to_auto_us_df_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[31:0] = auto_us_df_to_s01_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_us_df_to_s01_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_us_df_to_s01_couplers_ARCACHE;
  assign M_AXI_arlen[7:0] = auto_us_df_to_s01_couplers_ARLEN;
  assign M_AXI_arlock[0] = auto_us_df_to_s01_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_us_df_to_s01_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_us_df_to_s01_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_us_df_to_s01_couplers_ARSIZE;
  assign M_AXI_arvalid = auto_us_df_to_s01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_us_df_to_s01_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_us_df_to_s01_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_us_df_to_s01_couplers_AWCACHE;
  assign M_AXI_awlen[7:0] = auto_us_df_to_s01_couplers_AWLEN;
  assign M_AXI_awlock[0] = auto_us_df_to_s01_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_us_df_to_s01_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_us_df_to_s01_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_us_df_to_s01_couplers_AWSIZE;
  assign M_AXI_awvalid = auto_us_df_to_s01_couplers_AWVALID;
  assign M_AXI_bready = auto_us_df_to_s01_couplers_BREADY;
  assign M_AXI_rready = auto_us_df_to_s01_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_us_df_to_s01_couplers_WDATA;
  assign M_AXI_wlast = auto_us_df_to_s01_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_us_df_to_s01_couplers_WSTRB;
  assign M_AXI_wvalid = auto_us_df_to_s01_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s01_couplers_to_auto_us_df_ARREADY;
  assign S_AXI_awready = s01_couplers_to_auto_us_df_AWREADY;
  assign S_AXI_bresp[1:0] = s01_couplers_to_auto_us_df_BRESP;
  assign S_AXI_bvalid = s01_couplers_to_auto_us_df_BVALID;
  assign S_AXI_rdata[31:0] = s01_couplers_to_auto_us_df_RDATA;
  assign S_AXI_rlast = s01_couplers_to_auto_us_df_RLAST;
  assign S_AXI_rresp[1:0] = s01_couplers_to_auto_us_df_RRESP;
  assign S_AXI_rvalid = s01_couplers_to_auto_us_df_RVALID;
  assign S_AXI_wready = s01_couplers_to_auto_us_df_WREADY;
  assign auto_us_df_to_s01_couplers_ARREADY = M_AXI_arready;
  assign auto_us_df_to_s01_couplers_AWREADY = M_AXI_awready;
  assign auto_us_df_to_s01_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_us_df_to_s01_couplers_BVALID = M_AXI_bvalid;
  assign auto_us_df_to_s01_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_us_df_to_s01_couplers_RLAST = M_AXI_rlast;
  assign auto_us_df_to_s01_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_us_df_to_s01_couplers_RVALID = M_AXI_rvalid;
  assign auto_us_df_to_s01_couplers_WREADY = M_AXI_wready;
  assign s01_couplers_to_auto_us_df_ARADDR = S_AXI_araddr[31:0];
  assign s01_couplers_to_auto_us_df_ARBURST = S_AXI_arburst[1:0];
  assign s01_couplers_to_auto_us_df_ARCACHE = S_AXI_arcache[3:0];
  assign s01_couplers_to_auto_us_df_ARLEN = S_AXI_arlen[7:0];
  assign s01_couplers_to_auto_us_df_ARLOCK = S_AXI_arlock[1:0];
  assign s01_couplers_to_auto_us_df_ARPROT = S_AXI_arprot[2:0];
  assign s01_couplers_to_auto_us_df_ARQOS = S_AXI_arqos[3:0];
  assign s01_couplers_to_auto_us_df_ARREGION = S_AXI_arregion[3:0];
  assign s01_couplers_to_auto_us_df_ARSIZE = S_AXI_arsize[2:0];
  assign s01_couplers_to_auto_us_df_ARVALID = S_AXI_arvalid;
  assign s01_couplers_to_auto_us_df_AWADDR = S_AXI_awaddr[31:0];
  assign s01_couplers_to_auto_us_df_AWBURST = S_AXI_awburst[1:0];
  assign s01_couplers_to_auto_us_df_AWCACHE = S_AXI_awcache[3:0];
  assign s01_couplers_to_auto_us_df_AWLEN = S_AXI_awlen[7:0];
  assign s01_couplers_to_auto_us_df_AWLOCK = S_AXI_awlock[1:0];
  assign s01_couplers_to_auto_us_df_AWPROT = S_AXI_awprot[2:0];
  assign s01_couplers_to_auto_us_df_AWQOS = S_AXI_awqos[3:0];
  assign s01_couplers_to_auto_us_df_AWREGION = S_AXI_awregion[3:0];
  assign s01_couplers_to_auto_us_df_AWSIZE = S_AXI_awsize[2:0];
  assign s01_couplers_to_auto_us_df_AWVALID = S_AXI_awvalid;
  assign s01_couplers_to_auto_us_df_BREADY = S_AXI_bready;
  assign s01_couplers_to_auto_us_df_RREADY = S_AXI_rready;
  assign s01_couplers_to_auto_us_df_WDATA = S_AXI_wdata[31:0];
  assign s01_couplers_to_auto_us_df_WLAST = S_AXI_wlast;
  assign s01_couplers_to_auto_us_df_WSTRB = S_AXI_wstrb[3:0];
  assign s01_couplers_to_auto_us_df_WVALID = S_AXI_wvalid;
  design_1_auto_us_df_0 auto_us_df
       (.m_axi_araddr(auto_us_df_to_s01_couplers_ARADDR),
        .m_axi_arburst(auto_us_df_to_s01_couplers_ARBURST),
        .m_axi_arcache(auto_us_df_to_s01_couplers_ARCACHE),
        .m_axi_arlen(auto_us_df_to_s01_couplers_ARLEN),
        .m_axi_arlock(auto_us_df_to_s01_couplers_ARLOCK),
        .m_axi_arprot(auto_us_df_to_s01_couplers_ARPROT),
        .m_axi_arqos(auto_us_df_to_s01_couplers_ARQOS),
        .m_axi_arready(auto_us_df_to_s01_couplers_ARREADY),
        .m_axi_arsize(auto_us_df_to_s01_couplers_ARSIZE),
        .m_axi_arvalid(auto_us_df_to_s01_couplers_ARVALID),
        .m_axi_awaddr(auto_us_df_to_s01_couplers_AWADDR),
        .m_axi_awburst(auto_us_df_to_s01_couplers_AWBURST),
        .m_axi_awcache(auto_us_df_to_s01_couplers_AWCACHE),
        .m_axi_awlen(auto_us_df_to_s01_couplers_AWLEN),
        .m_axi_awlock(auto_us_df_to_s01_couplers_AWLOCK),
        .m_axi_awprot(auto_us_df_to_s01_couplers_AWPROT),
        .m_axi_awqos(auto_us_df_to_s01_couplers_AWQOS),
        .m_axi_awready(auto_us_df_to_s01_couplers_AWREADY),
        .m_axi_awsize(auto_us_df_to_s01_couplers_AWSIZE),
        .m_axi_awvalid(auto_us_df_to_s01_couplers_AWVALID),
        .m_axi_bready(auto_us_df_to_s01_couplers_BREADY),
        .m_axi_bresp(auto_us_df_to_s01_couplers_BRESP),
        .m_axi_bvalid(auto_us_df_to_s01_couplers_BVALID),
        .m_axi_rdata(auto_us_df_to_s01_couplers_RDATA),
        .m_axi_rlast(auto_us_df_to_s01_couplers_RLAST),
        .m_axi_rready(auto_us_df_to_s01_couplers_RREADY),
        .m_axi_rresp(auto_us_df_to_s01_couplers_RRESP),
        .m_axi_rvalid(auto_us_df_to_s01_couplers_RVALID),
        .m_axi_wdata(auto_us_df_to_s01_couplers_WDATA),
        .m_axi_wlast(auto_us_df_to_s01_couplers_WLAST),
        .m_axi_wready(auto_us_df_to_s01_couplers_WREADY),
        .m_axi_wstrb(auto_us_df_to_s01_couplers_WSTRB),
        .m_axi_wvalid(auto_us_df_to_s01_couplers_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(s01_couplers_to_auto_us_df_ARADDR),
        .s_axi_arburst(s01_couplers_to_auto_us_df_ARBURST),
        .s_axi_arcache(s01_couplers_to_auto_us_df_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arlen(s01_couplers_to_auto_us_df_ARLEN),
        .s_axi_arlock(s01_couplers_to_auto_us_df_ARLOCK[0]),
        .s_axi_arprot(s01_couplers_to_auto_us_df_ARPROT),
        .s_axi_arqos(s01_couplers_to_auto_us_df_ARQOS),
        .s_axi_arready(s01_couplers_to_auto_us_df_ARREADY),
        .s_axi_arregion(s01_couplers_to_auto_us_df_ARREGION),
        .s_axi_arsize(s01_couplers_to_auto_us_df_ARSIZE),
        .s_axi_arvalid(s01_couplers_to_auto_us_df_ARVALID),
        .s_axi_awaddr(s01_couplers_to_auto_us_df_AWADDR),
        .s_axi_awburst(s01_couplers_to_auto_us_df_AWBURST),
        .s_axi_awcache(s01_couplers_to_auto_us_df_AWCACHE),
        .s_axi_awlen(s01_couplers_to_auto_us_df_AWLEN),
        .s_axi_awlock(s01_couplers_to_auto_us_df_AWLOCK[0]),
        .s_axi_awprot(s01_couplers_to_auto_us_df_AWPROT),
        .s_axi_awqos(s01_couplers_to_auto_us_df_AWQOS),
        .s_axi_awready(s01_couplers_to_auto_us_df_AWREADY),
        .s_axi_awregion(s01_couplers_to_auto_us_df_AWREGION),
        .s_axi_awsize(s01_couplers_to_auto_us_df_AWSIZE),
        .s_axi_awvalid(s01_couplers_to_auto_us_df_AWVALID),
        .s_axi_bready(s01_couplers_to_auto_us_df_BREADY),
        .s_axi_bresp(s01_couplers_to_auto_us_df_BRESP),
        .s_axi_bvalid(s01_couplers_to_auto_us_df_BVALID),
        .s_axi_rdata(s01_couplers_to_auto_us_df_RDATA),
        .s_axi_rlast(s01_couplers_to_auto_us_df_RLAST),
        .s_axi_rready(s01_couplers_to_auto_us_df_RREADY),
        .s_axi_rresp(s01_couplers_to_auto_us_df_RRESP),
        .s_axi_rvalid(s01_couplers_to_auto_us_df_RVALID),
        .s_axi_wdata(s01_couplers_to_auto_us_df_WDATA),
        .s_axi_wlast(s01_couplers_to_auto_us_df_WLAST),
        .s_axi_wready(s01_couplers_to_auto_us_df_WREADY),
        .s_axi_wstrb(s01_couplers_to_auto_us_df_WSTRB),
        .s_axi_wvalid(s01_couplers_to_auto_us_df_WVALID));
endmodule
