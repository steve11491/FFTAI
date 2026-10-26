module sign_bit_exp #(
    parameter IDATA_WIDTH = 34,
    parameter EXP_BIT = 2,
    parameter ODATA_WIDTH = IDATA_WIDTH + EXP_BIT
) (
    input wire is_int16,
    input wire [IDATA_WIDTH-1:0] idata,
    output logic [ODATA_WIDTH-1:0] odata
);


    // assign odata[ODATA_WIDTH-1:0] = is_int16?{{(EXP_BIT){idata[IDATA_WIDTH-1]}},idata[IDATA_WIDTH-1:0]}
    //                                             :{{(EXP_BIT/2){idata[IDATA_WIDTH-1]}},idata[IDATA_WIDTH-1:IDATA_WIDTH/2],
    //                                             {(EXP_BIT/2){idata[IDATA_WIDTH/2-1]}},idata[IDATA_WIDTH/2-1:0]};
    generate
        if (EXP_BIT == 0) begin
            assign odata = idata;
        end else begin
            assign odata[IDATA_WIDTH/2-1:0] = idata[IDATA_WIDTH/2-1:0];
            assign odata[ODATA_WIDTH-EXP_BIT/2-1:IDATA_WIDTH/2] = is_int16?{{(EXP_BIT/2){idata[IDATA_WIDTH-1]}},idata[IDATA_WIDTH-1:IDATA_WIDTH/2]}
                                                :{idata[IDATA_WIDTH-1:IDATA_WIDTH/2],{(EXP_BIT/2){idata[IDATA_WIDTH/2-1]}}};

            assign odata[ODATA_WIDTH-1:ODATA_WIDTH-EXP_BIT/2] = {(EXP_BIT / 2) {idata[IDATA_WIDTH-1]}};
        end
    endgenerate




endmodule

module sign_bit_cut #(
    parameter IDATA_WIDTH = 34,
    parameter CUT_BIT = 2,
    parameter ODATA_WIDTH = IDATA_WIDTH - CUT_BIT
) (
    input wire is_int16,
    input wire [IDATA_WIDTH-1:0] idata,
    output logic [ODATA_WIDTH-1:0] odata
);
    // assign odata[ODATA_WIDTH-1:0] = is_int16?{idata[ODATA_WIDTH-1:0]}
    //                                                 :{idata[IDATA_WIDTH-CUT_BIT/2-1:IDATA_WIDTH/2],idata[IDATA_WIDTH/2-CUT_BIT-1:0]};

    generate
        if (CUT_BIT == 0) begin
            assign odata = idata;
        end else begin
            assign odata[ODATA_WIDTH/2-1:0] = idata[ODATA_WIDTH/2-1:0];
            assign odata[ODATA_WIDTH-1:ODATA_WIDTH/2] = is_int16?idata[ODATA_WIDTH-1:ODATA_WIDTH/2]:idata[ODATA_WIDTH-1-CUT_BIT/2:ODATA_WIDTH/2+CUT_BIT/2];

        end
    endgenerate



endmodule
