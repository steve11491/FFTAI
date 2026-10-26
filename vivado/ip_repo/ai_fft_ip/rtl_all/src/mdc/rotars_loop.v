module rotars_loop#(
    parameter DATA_WIDTH = 16,   //FFT data width
    parameter PE_DELAY = 4
)(
    input fft_clk,
    input fft_rstn,
    input fft_ena,
    input [3:0] fft_stage,

    input  signed [DATA_WIDTH-1:0] rotar_i_real,
    input  signed [DATA_WIDTH-1:0] rotar_i_imag,

    output signed [DATA_WIDTH-1:0] rotar_1_real,
    output signed [DATA_WIDTH-1:0] rotar_1_imag,
    output signed [DATA_WIDTH-1:0] rotar_2_real,
    output signed [DATA_WIDTH-1:0] rotar_2_imag,
    output signed [DATA_WIDTH-1:0] rotar_3_real,
    output signed [DATA_WIDTH-1:0] rotar_3_imag,
    output signed [DATA_WIDTH-1:0] rotar_4_real,
    output signed [DATA_WIDTH-1:0] rotar_4_imag
);

//delay loops from write buff to read buff(already -1 loop)
localparam STAGE_1_WRDIFF = 0;
localparam STAGE_2_WRDIFF = 1+1*(PE_DELAY-1);
localparam STAGE_3_WRDIFF = 1+2+2*(PE_DELAY-1)-1;
localparam STAGE_4_WRDIFF = 1+2+4+3*(PE_DELAY-1)-1-3;
//delay loops for write buff to avoid write read complex
localparam STAGE_1_BUFF_LOOP = 0;
localparam STAGE_2_BUFF_LOOP = STAGE_2_WRDIFF - 1; //if > 1  must loop delay
localparam STAGE_3_BUFF_LOOP = STAGE_3_WRDIFF - 2;
localparam STAGE_4_BUFF_LOOP = STAGE_4_WRDIFF - 4;

//cnt
reg [2:0] fft_cnt; //depends on stages
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        fft_cnt <= 3'b0;
    end
    else if(fft_ena)begin
        if(fft_cnt==(fft_stage-1))begin
            fft_cnt <= 3'b0;
        end
        else begin
            fft_cnt <= fft_cnt + 1;
        end
    end
    else begin
        fft_cnt <= 3'b0;
    end
end

//rotar buff
reg write_buff[3:0];
wire read_buff_0;
reg [STAGE_2_WRDIFF-1:0]read_buff_1;
reg [STAGE_3_WRDIFF-1:0]read_buff_2;
reg [STAGE_4_WRDIFF-1:0]read_buff_3;
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        write_buff[0]<=1'b0;
        write_buff[1]<=1'b0;
        write_buff[2]<=1'b0;
        write_buff[3]<=1'b0;
    end
    else if((fft_cnt[2:0]==3'b000)&fft_ena)begin
        write_buff[0]<=~write_buff[0];
    end
    else if (fft_cnt[2:0]==3'b001) begin
        write_buff[1]<=~write_buff[1];
    end
    else if (fft_cnt[2:0]==3'b011) begin
        write_buff[2]<=~write_buff[2];
    end
    else if (fft_cnt[2:0]==3'b111) begin
        write_buff[3]<=~write_buff[3];
    end
end

assign read_buff_0 = ~write_buff[0];
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        read_buff_1<={STAGE_2_WRDIFF{1'b0}};
        read_buff_2<={STAGE_3_WRDIFF{1'b0}};
        read_buff_3<={STAGE_4_WRDIFF{1'b0}};
    end
    else begin
        read_buff_1<={read_buff_1[STAGE_2_WRDIFF-2:0],~write_buff[1]};
        read_buff_2<={read_buff_2[STAGE_3_WRDIFF-2:0],~write_buff[2]};
        read_buff_3<={read_buff_3[STAGE_4_WRDIFF-2:0],~write_buff[3]};
    end
end



reg [DATA_WIDTH-1:0] rotar_1_0[1:0];
reg [DATA_WIDTH-1:0] rotar_1_1[1:0];

reg [DATA_WIDTH-1:0] rotar_2_0[1:0];
reg [DATA_WIDTH-1:0] rotar_2_1[1:0];

reg [DATA_WIDTH-1:0] rotar_3_0_0[1:0];
reg [DATA_WIDTH-1:0] rotar_3_0_1[1:0];
reg [DATA_WIDTH-1:0] rotar_3_1_0[1:0];
reg [DATA_WIDTH-1:0] rotar_3_1_1[1:0];


reg [DATA_WIDTH-1:0] rotar_4_0_0[1:0];
reg [DATA_WIDTH-1:0] rotar_4_0_1[1:0];
reg [DATA_WIDTH-1:0] rotar_4_1_0[1:0];
reg [DATA_WIDTH-1:0] rotar_4_1_1[1:0];
reg [DATA_WIDTH-1:0] rotar_4_2_0[1:0];
reg [DATA_WIDTH-1:0] rotar_4_2_1[1:0];
reg [DATA_WIDTH-1:0] rotar_4_3_0[1:0];
reg [DATA_WIDTH-1:0] rotar_4_3_1[1:0];

//buff 1
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_1_0[0]<={DATA_WIDTH{1'b0}};
        rotar_1_1[0]<={DATA_WIDTH{1'b0}};

        rotar_1_0[1]<={DATA_WIDTH{1'b0}};
        rotar_1_1[1]<={DATA_WIDTH{1'b0}};

    end
    else if((fft_cnt[2:0]==3'b000)&fft_ena)begin
        rotar_1_0[write_buff[0]]<=rotar_i_real;
        rotar_1_1[write_buff[0]]<=rotar_i_imag;
    end
end

//add delay loop stage reg to make sure no write-read complex
reg [DATA_WIDTH-1:0]rotar_i_real_delay[STAGE_4_BUFF_LOOP-1:0];
reg [DATA_WIDTH-1:0]rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1:0];
reg buff_2_0_ena[STAGE_2_BUFF_LOOP:0];
reg buff_2_1_ena[STAGE_2_BUFF_LOOP:0];
reg [1:0]buff_3_0_ena[STAGE_3_BUFF_LOOP-1:0];
reg [1:0]buff_3_1_ena[STAGE_3_BUFF_LOOP-1:0];
reg [3:0]buff_4_0_ena[STAGE_4_BUFF_LOOP-1:0];
reg [3:0]buff_4_1_ena[STAGE_4_BUFF_LOOP-1:0];

always @(posedge fft_clk)begin
    rotar_i_real_delay[0]<=rotar_i_real;
    rotar_i_imag_delay[0]<=rotar_i_imag;
end
integer i;
always @(posedge fft_clk)begin
    for(i=1;i<STAGE_4_BUFF_LOOP;i=i+1)begin
        rotar_i_real_delay[i]<=rotar_i_real_delay[i-1];
        rotar_i_imag_delay[i]<=rotar_i_imag_delay[i-1];
    end
end

//buff 2 ena delay
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        buff_2_0_ena[0] <=1'b0;
    end
    else if((fft_cnt[2:0]==3'b001)&(write_buff[1]==1'b0))begin
        buff_2_0_ena[0] <= 1'b1;
    end
    else begin
        buff_2_0_ena[0] <= buff_2_0_ena[0]<<1;
    end
end
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        buff_2_1_ena[0]<=2'b0;
    end
    else if((fft_cnt[2:0]==3'b001)&(write_buff[1]==1'b1))begin
        buff_2_1_ena[0] <= 2'b01;
    end
    else begin
        buff_2_1_ena[0] <= buff_2_1_ena[0]<<1;
    end
end
always @(posedge fft_clk)begin
    for(i=1;i<STAGE_2_BUFF_LOOP;i=i+1)begin
        buff_2_0_ena[i] <= buff_2_0_ena[i-1];
        buff_2_1_ena[i] <= buff_2_1_ena[i-1];
    end
end

//buff 3 ena delay
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        buff_3_0_ena[0]<=2'b00;
    end
    else if((fft_cnt[2:0]==3'b010)&(write_buff[2]==1'b0))begin
        buff_3_0_ena[0] <= 2'b01;
    end
    else begin
        buff_3_0_ena[0] <= buff_3_0_ena[0]<<1;
    end
end
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        buff_3_1_ena[0]<=2'b0;
    end
    else if((fft_cnt[2:0]==3'b010)&(write_buff[2]==1'b1))begin
        buff_3_1_ena[0] <= 2'b01;
    end
    else begin
        buff_3_1_ena[0] <= buff_3_1_ena[0]<<1;
    end
end
always @(posedge fft_clk)begin
    for(i=1;i<STAGE_3_BUFF_LOOP;i=i+1)begin
        buff_3_0_ena[i] <= buff_3_0_ena[i-1];
        buff_3_1_ena[i] <= buff_3_1_ena[i-1];
    end
end

//buff 4 ena delay
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        buff_4_0_ena[0]<=4'b0000;
    end
    else if((fft_cnt[2:0]==3'b100)&(write_buff[3]==1'b0))begin
        buff_4_0_ena[0] <= 4'b0001;
    end
    else begin
        buff_4_0_ena[0] <= buff_4_0_ena[0]<<1;
    end
end

always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        buff_4_1_ena[0]<=4'b0;
    end
    else if((fft_cnt[2:0]==3'b100)&(write_buff[3]==1'b1))begin
        buff_4_1_ena[0] <= 4'b0001;
    end
    else begin
        buff_4_1_ena[0] <= buff_4_1_ena[0]<<1;
    end
end

always @(posedge fft_clk)begin
    for(i=1;i<STAGE_4_BUFF_LOOP;i=i+1)begin
        buff_4_0_ena[i] <= buff_4_0_ena[i-1];
        buff_4_1_ena[i] <= buff_4_1_ena[i-1];
    end
end

//buff 2
reg switch_2_0;
reg switch_2_1;
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_2_0[0]<={DATA_WIDTH{1'b0}};
        rotar_2_1[0]<={DATA_WIDTH{1'b0}};
        switch_2_0<=1'b0;
    end
    else if(buff_2_0_ena[STAGE_2_BUFF_LOOP-1])begin//(fft_cnt[2:0]==3'b001)&(write_buff[1]==1'b0))begin
        rotar_2_0[0]<=rotar_i_real_delay[STAGE_2_BUFF_LOOP-1];
        rotar_2_1[0]<=rotar_i_imag_delay[STAGE_2_BUFF_LOOP-1];
        switch_2_0<=1'b0;
    end
    else if(read_buff_1[STAGE_2_WRDIFF-1]==1'b0)begin
        rotar_2_0[0]<=switch_2_0?-rotar_2_1[0]: rotar_2_1[0];
        rotar_2_1[0]<=switch_2_0? rotar_2_0[0]:-rotar_2_0[0];

        switch_2_0<=~switch_2_0;
    end
end

always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_2_0[1]<={DATA_WIDTH{1'b0}};
        rotar_2_1[1]<={DATA_WIDTH{1'b0}};
        switch_2_1<=1'b0;
    end
    else if(buff_2_1_ena[STAGE_2_BUFF_LOOP-1])begin
        rotar_2_0[1]<=rotar_i_real_delay[STAGE_2_BUFF_LOOP-1];
        rotar_2_1[1]<=rotar_i_imag_delay[STAGE_2_BUFF_LOOP-1];
        switch_2_1<=1'b0;
    end
    else if(read_buff_1[STAGE_2_WRDIFF-1]==1'b1)begin
        rotar_2_0[1]<=switch_2_1?-rotar_2_1[1]: rotar_2_1[1];
        rotar_2_1[1]<=switch_2_1? rotar_2_0[1]:-rotar_2_0[1];

        switch_2_1<=~switch_2_1;
    end
end

//buff 3
reg [1:0]switch_3_0;
reg [1:0]switch_3_1;
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_3_0_0[0]<={DATA_WIDTH{1'b0}};
        rotar_3_0_1[0]<={DATA_WIDTH{1'b0}};

        rotar_3_1_0[0]<={DATA_WIDTH{1'b0}};
        rotar_3_1_1[0]<={DATA_WIDTH{1'b0}};

        switch_3_0<=2'b0;
    end
    else if(buff_3_0_ena[STAGE_3_BUFF_LOOP-1][0])begin
        rotar_3_0_0[0]<=rotar_i_real_delay[STAGE_3_BUFF_LOOP-1];
        rotar_3_0_1[0]<=rotar_i_imag_delay[STAGE_3_BUFF_LOOP-1];
    end
    else if(buff_3_0_ena[STAGE_3_BUFF_LOOP-1][1])begin
        rotar_3_1_0[0]<=rotar_i_real_delay[STAGE_3_BUFF_LOOP-1];
        rotar_3_1_1[0]<=rotar_i_imag_delay[STAGE_3_BUFF_LOOP-1];
        switch_3_0<=2'b0;
    end
    else if(read_buff_2[STAGE_3_WRDIFF-1]==1'b0)begin
        rotar_3_0_0[0]<=rotar_3_1_0[0];
        rotar_3_0_1[0]<=rotar_3_1_1[0];
        rotar_3_1_0[0]<=switch_3_0[1]?-rotar_3_0_1[0]: rotar_3_0_1[0];
        rotar_3_1_1[0]<=switch_3_0[1]? rotar_3_0_0[0]:-rotar_3_0_0[0];
        switch_3_0<=switch_3_0+1;
    end
end

always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_3_0_0[1]<={DATA_WIDTH{1'b0}};
        rotar_3_0_1[1]<={DATA_WIDTH{1'b0}};
        rotar_3_1_0[1]<={DATA_WIDTH{1'b0}};
        rotar_3_1_1[1]<={DATA_WIDTH{1'b0}};
        switch_3_1<=2'b0;
    end
    else if(buff_3_1_ena[STAGE_3_BUFF_LOOP-1][0])begin
        rotar_3_0_0[1]<=rotar_i_real_delay[STAGE_3_BUFF_LOOP-1];
        rotar_3_0_1[1]<=rotar_i_imag_delay[STAGE_3_BUFF_LOOP-1];
    end
    else if(buff_3_1_ena[STAGE_3_BUFF_LOOP-1][1])begin
        rotar_3_1_0[1]<=rotar_i_real_delay[STAGE_3_BUFF_LOOP-1];
        rotar_3_1_1[1]<=rotar_i_imag_delay[STAGE_3_BUFF_LOOP-1];
        switch_3_1<=2'b0;
    end
    else if(read_buff_2[STAGE_3_WRDIFF-1]==1'b1)begin
        rotar_3_0_0[1]<=rotar_3_1_0[1];
        rotar_3_0_1[1]<=rotar_3_1_1[1];
        rotar_3_1_0[1]<=switch_3_1[1]?-rotar_3_0_1[1]: rotar_3_0_1[1];
        rotar_3_1_1[1]<=switch_3_1[1]? rotar_3_0_0[1]:-rotar_3_0_0[1];
        switch_3_1<=switch_3_1+1;
    end
end

//buff 4
reg [3:0]switch_4_0;
reg [3:0]switch_4_1;
always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_4_0_0[0]<={DATA_WIDTH{1'b0}};
        rotar_4_0_1[0]<={DATA_WIDTH{1'b0}};
        rotar_4_1_0[0]<={DATA_WIDTH{1'b0}};
        rotar_4_1_1[0]<={DATA_WIDTH{1'b0}};
        rotar_4_2_0[0]<={DATA_WIDTH{1'b0}};
        rotar_4_2_1[0]<={DATA_WIDTH{1'b0}};
        rotar_4_3_0[0]<={DATA_WIDTH{1'b0}};
        rotar_4_3_1[0]<={DATA_WIDTH{1'b0}};
        switch_4_0<=4'b0;
    end
    else if(buff_4_0_ena[STAGE_4_BUFF_LOOP-1][0])begin
        rotar_4_0_0[0]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_0_1[0]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
    end
    else if(buff_4_0_ena[STAGE_4_BUFF_LOOP-1][1])begin
        rotar_4_1_0[0]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_1_1[0]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
    end
    else if(buff_4_0_ena[STAGE_4_BUFF_LOOP-1][2])begin
        rotar_4_2_0[0]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_2_1[0]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
    end
    else if(buff_4_0_ena[STAGE_4_BUFF_LOOP-1][3])begin
        rotar_4_3_0[0]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_3_1[0]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
        switch_4_0<=4'b0;
    end
    else if(read_buff_3[STAGE_4_WRDIFF-1]==1'b0)begin
        rotar_4_0_0[0]<=rotar_4_1_0[0];
        rotar_4_0_1[0]<=rotar_4_1_1[0];
        rotar_4_1_0[0]<=rotar_4_2_0[0];
        rotar_4_1_1[0]<=rotar_4_2_1[0];
        rotar_4_2_0[0]<=rotar_4_3_0[0];
        rotar_4_2_1[0]<=rotar_4_3_1[0];
        rotar_4_3_0[0]<=switch_4_0[3]?-rotar_4_0_1[0]: rotar_4_0_1[0];
        rotar_4_3_1[0]<=switch_4_0[3]? rotar_4_0_0[0]:-rotar_4_0_0[0];
        switch_4_0<=switch_4_0+1;
    end
end

always @(posedge fft_clk)begin
    if(!fft_rstn)begin
        rotar_4_0_0[1]<={DATA_WIDTH{1'b0}};
        rotar_4_0_1[1]<={DATA_WIDTH{1'b0}};
        rotar_4_1_0[1]<={DATA_WIDTH{1'b0}};
        rotar_4_1_1[1]<={DATA_WIDTH{1'b0}};
        rotar_4_2_0[1]<={DATA_WIDTH{1'b0}};
        rotar_4_2_1[1]<={DATA_WIDTH{1'b0}};
        rotar_4_3_0[1]<={DATA_WIDTH{1'b0}};
        rotar_4_3_1[1]<={DATA_WIDTH{1'b0}};
        switch_4_1<=4'b0;
    end
    else if(buff_4_1_ena[STAGE_4_BUFF_LOOP-1][0])begin
        rotar_4_0_0[1]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_0_1[1]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
    end
    else if(buff_4_1_ena[STAGE_4_BUFF_LOOP-1][1])begin
        rotar_4_1_0[1]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_1_1[1]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
    end
    else if(buff_4_1_ena[STAGE_4_BUFF_LOOP-1][2])begin
        rotar_4_2_0[1]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_2_1[1]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
    end
    else if(buff_4_1_ena[STAGE_4_BUFF_LOOP-1][3])begin
        rotar_4_3_0[1]<=rotar_i_real_delay[STAGE_4_BUFF_LOOP-1];
        rotar_4_3_1[1]<=rotar_i_imag_delay[STAGE_4_BUFF_LOOP-1];
        switch_4_1<=4'b0;
    end
    else if(read_buff_3[STAGE_4_WRDIFF-1]==1'b1)begin
        rotar_4_0_0[1]<=rotar_4_1_0[1];
        rotar_4_0_1[1]<=rotar_4_1_1[1];
        rotar_4_1_0[1]<=rotar_4_2_0[1];
        rotar_4_1_1[1]<=rotar_4_2_1[1];
        rotar_4_2_0[1]<=rotar_4_3_0[1];
        rotar_4_2_1[1]<=rotar_4_3_1[1];
        rotar_4_3_0[1]<=switch_4_1[3]?-rotar_4_0_1[1]: rotar_4_0_1[1];
        rotar_4_3_1[1]<=switch_4_1[3]? rotar_4_0_0[1]:-rotar_4_0_0[1];
        switch_4_1<=switch_4_1+1;
    end
end

//rotar inn     
assign rotar_1_real = rotar_1_0[read_buff_0];
assign rotar_1_imag = rotar_1_1[read_buff_0];
assign rotar_2_real = rotar_2_0[read_buff_1[STAGE_2_WRDIFF-1]];
assign rotar_2_imag = rotar_2_1[read_buff_1[STAGE_2_WRDIFF-1]];
assign rotar_3_real = rotar_3_0_0[read_buff_2[STAGE_3_WRDIFF-1]];
assign rotar_3_imag = rotar_3_0_1[read_buff_2[STAGE_3_WRDIFF-1]];
assign rotar_4_real = rotar_4_0_0[read_buff_3[STAGE_4_WRDIFF-1]];
assign rotar_4_imag = rotar_4_0_1[read_buff_3[STAGE_4_WRDIFF-1]];
endmodule