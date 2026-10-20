
`timescale 1 ns / 1 ps

module ai_acce_instr_encoder #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH = 32,

    parameter DIM_WIDTH = 8,
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2,

    parameter STRIDE_X_WIDTH = 2,
    parameter STRIDE_Y_WIDTH = 2,
    parameter DILATION_X_WIDTH = 2,
    parameter DILATION_Y_WIDTH = 2,
    parameter WIN_R_WIDTH = 4,
    parameter WIN_S_WIDTH = 4,

    //quan
    parameter SCALE_WIDTH = 16,
    parameter SHIFT_WIDTH = 4,
    parameter ZERO_POINT_WIDTH = 16,

    parameter BIAS2_SCALE_WIDTH = 16,
    parameter BIAS2_SHIFT_WIDTH = 4,
    // control

    parameter NUM_WIDTH = 8,
    parameter PADDING_WIDTH = 5,
    parameter AIWIH_WIDTH = 20,  // 最大宽度*高度
    parameter AIW_WIDTH = 11,  //最大宽度
    parameter WICRS_WIDTH = 22,
    parameter WIC_WIDTH = 11,
    parameter AOWOH_WIDTH = 20,
    parameter AOW_WIDTH = 11,

    parameter FFT_STAGE_WIDTH   = 4,
    parameter FFT_SIGNLEN_WIDTH = 16,

    parameter C_M_AXI_ADDR_WIDTH = 32
) (
    // Users to add ports here

    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output wire S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output wire S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output wire S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire S_AXI_RREADY,

    output wire mat_core_start,  //1
    input wire is_mat_core_busy,
    input wire layer_done,
    input wire is_mat_core_ready,
    input wire fft_done,

    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_R_BASE_ADDR,  //32
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_W_BASE_ADDR,  //32

    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_R_BASE_ADDR,  //32
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_W_BASE_ADDR,  //32

    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_R_BASE_ADDR,  //32
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_W_BASE_ADDR,

    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias_axi_R_BASE_ADDR,  //32
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] omap_axi_W_BASE_ADDR,  //32




    output wire       is_fft,                  //1
    output wire       is_int16,                //1
    output wire       relu_enable,             //1
    output wire       use_quan_external,       //1
    output wire       use_bias_external,       //1
    output wire       bias_mode_external,      //1
    output wire       use_bias2_add_external,  //1
    output wire       is_pool,
    output wire       pool_type,
    output wire [1:0] conv_type,



    output wire [PADDING_WIDTH-1:0] padding_external[3:0],  //8*4
    output wire [WIN_R_WIDTH-1:0] total_len_r,  //8
    output wire [WIN_S_WIDTH-1:0] total_len_s,  //8
    output wire [STRIDE_X_WIDTH-1:0] stride_x,  //8
    output wire [STRIDE_Y_WIDTH-1:0] stride_y,  //8
    output wire [DILATION_X_WIDTH-1:0] dilation_x,  //8
    output wire [DILATION_Y_WIDTH-1:0] dilation_y,  //8
    output wire [ZERO_POINT_WIDTH-1:0] zero_point_in,  //16
    output wire [ZERO_POINT_WIDTH-1:0] zero_point_out,  //16
    output wire [SCALE_WIDTH-1:0] scale,  //16
    output wire [SHIFT_WIDTH-1:0] shift,  //8
    output wire [BIAS2_SCALE_WIDTH-1:0] bias2_scale,  //16 //int8情况下 低8位有效，int16情况下16位有效
    output wire [BIAS2_SHIFT_WIDTH-1:0] bias2_shift,  //8

    output wire [NUM_WIDTH-1:0] num_oc,  //8
    output wire [NUM_WIDTH-1:0] num_ic,  //8
    output wire [NUM_WIDTH-1:0] num_rs,  //8
    output wire [NUM_WIDTH-1:0] num_ow,  //8
    output wire [NUM_WIDTH-1:0] num_oh,  //8

    output wire [DIM_WIDTH-1:0] basic_oc,  //8
    output wire [DIM_WIDTH-1:0] basic_ic,  //8
    output wire [DIM_WIDTH-1:0] basic_rs,  //8
    output wire [DIM_WIDTH-1:0] basic_ow,  //8
    output wire [DIM_WIDTH-1:0] basic_oh,  //8

    output wire [DIM_WIDTH-1:0] remain_oc,  //8
    output wire [DIM_WIDTH-1:0] remain_ic,  //8
    output wire [DIM_WIDTH-1:0] remain_rs,  //8
    output wire [DIM_WIDTH-1:0] remain_ow,  //8
    output wire [DIM_WIDTH-1:0] remain_oh,  //8


    output wire [IMAP_DIM_WIDTH-1:0] basic_ow_sx,  //16
    output wire [IMAP_DIM_WIDTH-1:0] basic_oh_sy,  //16
    output wire [IMAP_DIM_WIDTH-1:0] basic_iw,  //16
    output wire [IMAP_DIM_WIDTH-1:0] basic_ih,  //16
    output wire [IMAP_DIM_WIDTH-1:0] remain_iw,  //16
    output wire [IMAP_DIM_WIDTH-1:0] remain_ih,  //16

    output wire [AIWIH_WIDTH-1:0] Aiwih,  //32
    output wire [  AIW_WIDTH-1:0] Aiw,    //32
    output wire [WICRS_WIDTH-1:0] Wicrs,  //32
    output wire [  WIC_WIDTH-1:0] Wic,    //32
    output wire [AOWOH_WIDTH-1:0] Aowoh,  //32
    output wire [  AOW_WIDTH-1:0] Aow,    //32


    output wire fft_config,   //1
    output wire fft_start,    //1
    output wire is_ifft_mode, //1
    output wire [FFT_STAGE_WIDTH-1:0] fft_stage,     //4
    output wire [FFT_SIGNLEN_WIDTH-1:0] fft_sign_len //16




);

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg axi_awready;
    reg axi_wready;
    reg [1 : 0] axi_bresp;
    reg axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [1 : 0] axi_rresp;
    reg axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH / 32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 5;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 50
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg4;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg5;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg6;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg7;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg8;
    (*MAX_FANOUT = 128 *) reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg9;
    // reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg9;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg10;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg11;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg12;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg13;
    (*MAX_FANOUT = 128 *) reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg14;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg15;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg16;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg17;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg18;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg19;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg20;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg21;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg22;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg23;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg24;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg25;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg26;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg27;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg28;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg29;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg30;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg31;

    wire slv_reg_rden;
    wire slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
    integer byte_index;
    reg aw_en;

    // I/O Connections assignments

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;
    // Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    // de-asserted when reset is low.

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                // slave is ready to accept write address when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both 
    // S_AXI_AWVALID and S_AXI_WVALID are valid. 

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awaddr <= 0;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                // Write Address latching 
                axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    // de-asserted when reset is low. 

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_wready <= 1'b0;
        end else begin
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en) begin
                // slave is ready to accept write data when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
                axi_wready <= 1'b1;
            end else begin
                axi_wready <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0  <= 0;
            slv_reg1  <= 0;
            slv_reg2  <= 0;
            slv_reg3  <= 0;
            slv_reg4  <= 0;
            slv_reg5  <= 0;
            slv_reg6  <= 0;
            slv_reg7  <= 0;
            slv_reg8  <= 0;
            slv_reg9  <= 0;
            slv_reg10 <= 0;
            slv_reg11 <= 0;
            slv_reg12 <= 0;
            slv_reg13 <= 0;
            slv_reg14 <= 0;
            slv_reg15 <= 0;
            slv_reg16 <= 0;
            slv_reg17 <= 0;
            slv_reg18 <= 0;
            slv_reg19 <= 0;
            slv_reg20 <= 0;
            slv_reg21 <= 0;
            slv_reg22 <= 0;
            slv_reg23 <= 0;
            slv_reg24 <= 0;
            slv_reg25 <= 0;
            slv_reg26 <= 0;
            slv_reg27 <= 0;
            slv_reg28 <= 0;
            slv_reg29 <= 0;
            slv_reg30 <= 0;
            slv_reg31 <= 0;

        end else begin

            if (slv_reg_wren) begin
                case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                    // 6'h00:
                    // if (S_AXI_WSTRB[0] == 1) begin
                    //     // Respective byte enables are asserted as per write strobes 
                    //     // Slave register 0
                    //     slv_reg0[0] <= S_AXI_WDATA[0];
                    // end
                    6'h01:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 1
                            slv_reg1[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h02:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 2
                            slv_reg2[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h03:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 3
                            slv_reg3[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h04:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 4
                            slv_reg4[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h05:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 5
                            slv_reg5[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h06:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 6
                            slv_reg6[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h07:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 7
                            slv_reg7[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h08:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 8
                            slv_reg8[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h09:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 9
                            slv_reg9[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h0A:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 10
                            slv_reg10[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h0B:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 11
                            slv_reg11[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h0C:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 12
                            slv_reg12[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h0D:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 13
                            slv_reg13[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h0E:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 14
                            slv_reg14[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h0F:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 15
                            slv_reg15[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h10:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 16
                            slv_reg16[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h11:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 17
                            slv_reg17[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h12:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 18
                            slv_reg18[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h13:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 19
                            slv_reg19[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h14:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 20
                            slv_reg20[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h15:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 21
                            slv_reg21[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h16:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 22
                            slv_reg22[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h17:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 23
                            slv_reg23[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h18:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 24
                            slv_reg24[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h19:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 25
                            slv_reg25[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h1A:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 26
                            slv_reg26[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h1B:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 27
                            slv_reg27[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h1C:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 28
                            slv_reg28[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h1D:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 29
                            slv_reg29[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h1E:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 30
                            slv_reg30[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    6'h1F:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            // Respective byte enables are asserted as per write strobes 
                            // Slave register 31
                            slv_reg31[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end

                    default: begin
                        // slv_reg0  <= slv_reg0;
                        slv_reg1  <= slv_reg1;
                        slv_reg2  <= slv_reg2;
                        slv_reg3  <= slv_reg3;
                        slv_reg4  <= slv_reg4;
                        slv_reg5  <= slv_reg5;
                        slv_reg6  <= slv_reg6;
                        slv_reg7  <= slv_reg7;
                        slv_reg8  <= slv_reg8;
                        slv_reg9  <= slv_reg9;
                        slv_reg10 <= slv_reg10;
                        slv_reg11 <= slv_reg11;
                        slv_reg12 <= slv_reg12;
                        slv_reg13 <= slv_reg13;
                        slv_reg14 <= slv_reg14;
                        slv_reg15 <= slv_reg15;
                        slv_reg16 <= slv_reg16;
                        slv_reg17 <= slv_reg17;
                        slv_reg18 <= slv_reg18;
                        slv_reg19 <= slv_reg19;
                        slv_reg20 <= slv_reg20;
                        slv_reg21 <= slv_reg21;
                        slv_reg22 <= slv_reg22;
                        slv_reg23 <= slv_reg23;
                        slv_reg24 <= slv_reg24;
                        slv_reg25 <= slv_reg25;
                        slv_reg26 <= slv_reg26;
                        slv_reg27 <= slv_reg27;
                        slv_reg28 <= slv_reg28;
                        slv_reg29 <= slv_reg29;
                        slv_reg30 <= slv_reg30;
                        slv_reg31 <= slv_reg31;

                    end
                endcase
            end
        end
    end

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave 
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    // This marks the acceptance of address and indicates the status of 
    // write transaction.

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_bvalid <= 0;
            axi_bresp  <= 2'b0;
        end else begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
                // indicates a valid write response is available
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0;  // 'OKAY' response 
            end                   // work error responses in future
	      else
	        begin
                if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
                    axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is 
    // de-asserted when reset (active low) is asserted. 
    // The read address is also latched when S_AXI_ARVALID is 
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin
                // indicates that the slave has acceped the valid read address
                axi_arready <= 1'b1;
                // Read address latching
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    // data are available on the axi_rdata bus at this instance. The 
    // assertion of axi_rvalid marks the validity of read data on the 
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    // is deasserted on reset (active low). axi_rresp and axi_rdata are 
    // cleared to zero on reset (active low).  
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end else begin
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
                // Valid read data is available at the read data bus
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;  // 'OKAY' response
            end else if (axi_rvalid && S_AXI_RREADY) begin
                // Read data is accepted by the master
                axi_rvalid <= 1'b0;
            end
        end
    end

    (* mark_debug = "false"*) reg mat_core_enable;

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*) begin
        // Address decoding for reading registers
        case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            6'h00:
            reg_data_out <= {
                {28{1'b0}}, fft_done, is_mat_core_ready, is_mat_core_busy, mat_core_enable
            };
            6'h01: reg_data_out <= slv_reg1;
            6'h02: reg_data_out <= slv_reg2;
            6'h03: reg_data_out <= slv_reg3;
            6'h04: reg_data_out <= slv_reg4;
            6'h05: reg_data_out <= slv_reg5;
            6'h06: reg_data_out <= slv_reg6;
            6'h07: reg_data_out <= slv_reg7;
            6'h08: reg_data_out <= slv_reg8;
            6'h09: reg_data_out <= slv_reg9;
            6'h0A: reg_data_out <= slv_reg10;
            6'h0B: reg_data_out <= slv_reg11;
            6'h0C: reg_data_out <= slv_reg12;
            6'h0D: reg_data_out <= slv_reg13;
            6'h0E: reg_data_out <= slv_reg14;
            6'h0F: reg_data_out <= slv_reg15;
            6'h10: reg_data_out <= slv_reg16;
            6'h11: reg_data_out <= slv_reg17;
            6'h12: reg_data_out <= slv_reg18;
            6'h13: reg_data_out <= slv_reg19;
            6'h14: reg_data_out <= slv_reg20;
            6'h15: reg_data_out <= slv_reg21;
            6'h16: reg_data_out <= slv_reg22;
            6'h17: reg_data_out <= slv_reg23;
            6'h18: reg_data_out <= slv_reg24;
            6'h19: reg_data_out <= slv_reg25;
            6'h1A: reg_data_out <= slv_reg26;
            6'h1B: reg_data_out <= slv_reg27;
            6'h1C: reg_data_out <= slv_reg28;
            6'h1D: reg_data_out <= slv_reg29;
            6'h1E: reg_data_out <= slv_reg30;
            6'h1F: reg_data_out <= slv_reg31;

            default: reg_data_out <= 0;
        endcase
    end

    // Output register or memory read data
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rdata <= 0;
        end else begin
            // When there is a valid read address (S_AXI_ARVALID) with 
            // acceptance of read address by the slave (axi_arready), 
            // output the read dada 
            if (slv_reg_rden) begin
                axi_rdata <= reg_data_out;  // register read data
            end
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            mat_core_enable <= 0;
        end else begin
            if (layer_done) begin
                mat_core_enable <= 0;
            end else if(slv_reg_wren && axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]==6'h00 && S_AXI_WSTRB[0] == 1&&S_AXI_WDATA[0]) begin
                mat_core_enable <= 1'b1;
            end

        end
    end


    reg mat_core_enable_ff;
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            mat_core_enable_ff <= 0;
        end else begin
            mat_core_enable_ff <= mat_core_enable;
        end
    end




    assign mat_core_start = (~is_fft) & (~mat_core_enable_ff & mat_core_enable);  //上升沿


    // slv_reg0[31:2]; reserve


    assign imap_axi_R_BASE_ADDR = slv_reg1[31:0];  //32
    assign imap_axi_W_BASE_ADDR = slv_reg2[31:0];  //32

    assign weight_axi_R_BASE_ADDR = slv_reg3[31:0];  //32
    assign weight_axi_W_BASE_ADD = slv_reg4[31:0];  //32

    assign bias2_axi_R_BASE_ADDR = slv_reg5[31:0];  //32
    assign bias2_axi_W_BASE_ADDR = slv_reg6[31:0];  //32

    assign bias_axi_R_BASE_ADDR = slv_reg7[31:0];  //32
    assign omap_axi_W_BASE_ADDR = slv_reg8[31:0];  //32


    assign is_fft = slv_reg9[0];  //1
    assign is_int16 = slv_reg9[1];  //1
    assign relu_enable = slv_reg9[2];  //1
    assign use_quan_external = slv_reg9[3];  //1
    assign use_bias_external = slv_reg9[4];  //1
    assign bias_mode_external = slv_reg9[5];  //1
    assign use_bias2_add_external = slv_reg9[6];  //1
    assign is_pool = slv_reg9[7];
    assign pool_type = slv_reg9[8];
    assign conv_type = slv_reg9[10:9];

    // slv_reg5[31:7]; reserve


    // padding_external = {Top_padding, Bottom_padding, Left_padding, Right_padding};
    assign padding_external[0] = slv_reg10[PADDING_WIDTH-1:0];  //8*4 
    assign padding_external[1] = slv_reg10[PADDING_WIDTH-1+8:8];
    assign padding_external[2] = slv_reg10[PADDING_WIDTH-1+16:16];
    assign padding_external[3] = slv_reg10[PADDING_WIDTH-1+24:24];

    assign total_len_r = slv_reg11[WIN_R_WIDTH-1:0];  //8
    assign total_len_s = slv_reg11[WIN_S_WIDTH-1+8:8];  //8
    assign stride_x = slv_reg11[STRIDE_X_WIDTH-1+16:16];  //8
    assign stride_y = slv_reg11[STRIDE_Y_WIDTH-1+24:24];  //8

    assign dilation_x = slv_reg12[DILATION_X_WIDTH-1:0];  //8
    assign dilation_y = slv_reg12[DILATION_Y_WIDTH-1+8:8];  //8

    assign zero_point_in = slv_reg13[ZERO_POINT_WIDTH-1:0];  //16
    assign zero_point_out = slv_reg13[ZERO_POINT_WIDTH-1+16:16];  //16

    assign scale = slv_reg14[SCALE_WIDTH-1:0];  //16
    assign shift = slv_reg14[SHIFT_WIDTH-1+16:16];  //8

    assign bias2_scale = slv_reg15[BIAS2_SCALE_WIDTH-1:0];  //16
    assign bias2_shift = slv_reg15[BIAS2_SHIFT_WIDTH-1+16:16];  //8

    assign num_oc = slv_reg16[NUM_WIDTH-1:0];  //8
    assign num_ic = slv_reg16[NUM_WIDTH-1+8:8];  //8
    assign num_rs = slv_reg16[NUM_WIDTH-1+16:16];  //8
    assign num_ow = slv_reg16[NUM_WIDTH-1+24:24];  //8

    assign num_oh = slv_reg17[NUM_WIDTH-1:0];  //8
    assign basic_oc = slv_reg17[DIM_WIDTH-1+8:8];  //8
    assign basic_ic = slv_reg17[DIM_WIDTH-1+16:16];  //8
    assign basic_rs = slv_reg17[DIM_WIDTH-1+24:24];  //8

    assign basic_ow = slv_reg18[DIM_WIDTH-1:0];  //8
    assign basic_oh = slv_reg18[DIM_WIDTH-1+8:8];  //8
    assign remain_oc = slv_reg18[DIM_WIDTH-1+16:16];  //8
    assign remain_ic = slv_reg18[DIM_WIDTH-1+24:24];  //8

    assign remain_rs = slv_reg19[DIM_WIDTH-1:0];  //8
    assign remain_ow = slv_reg19[DIM_WIDTH-1+8:8];  //8
    assign remain_oh = slv_reg19[DIM_WIDTH-1+16:16];  //8


    assign basic_iw = slv_reg20[IMAP_DIM_WIDTH-1:0];  //16
    assign basic_ih = slv_reg20[IMAP_DIM_WIDTH-1+16:16];  //16

    assign basic_ow_sx = slv_reg21[IMAP_DIM_WIDTH-1:0];  //16
    assign basic_oh_sy = slv_reg21[IMAP_DIM_WIDTH-1+16:16];  //16

    assign remain_iw = slv_reg22[IMAP_DIM_WIDTH-1:0];  //16
    assign remain_ih = slv_reg22[IMAP_DIM_WIDTH-1+16:16];  //16


    assign Aiwih = slv_reg23[AIWIH_WIDTH-1:0];  //32
    assign Aiw = slv_reg24[AIW_WIDTH-1:0];  //32
    assign Wicrs = slv_reg25[WICRS_WIDTH-1:0];  //32
    assign Wic = slv_reg26[WIC_WIDTH-1:0];  //32
    assign Aowoh = slv_reg27[AOWOH_WIDTH-1:0];  //32
    assign Aow = slv_reg28[AOW_WIDTH-1:0];  //32

    reg is_int16_reg;
    reg is_fft_reg;
    always @(posedge S_AXI_ACLK) begin
        if (~S_AXI_ARESETN) begin
            is_int16_reg <= 0;
            is_fft_reg   <= 0;
        end else begin
            is_int16_reg <= is_int16;
            is_fft_reg   <= is_fft;
        end
    end

    assign fft_config = slv_reg29[0];  //1
    assign fft_start = (is_fft_reg & is_int16_reg) & slv_reg29[1];  //1
    assign is_ifft_mode = slv_reg29[11];  //1
    assign fft_stage = slv_reg29[12+:FFT_STAGE_WIDTH];  //4
    assign fft_sign_len = slv_reg29[31-:FFT_SIGNLEN_WIDTH];  //16

endmodule
