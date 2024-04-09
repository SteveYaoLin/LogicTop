
`timescale  1ns / 1ps

module tb_LogicTop;

// SyncTrig_LogicTop Parameters
parameter PERIOD_10M  = 100;
parameter PERIOD_80M  = 12.5;


// SyncTrig_LogicTop Inputs
reg   io_clk                               = 0 ;
reg   io_rst                               = 0 ;
reg   io_rst_ram                           = 0 ;
reg   [0:0]  BUS_CLK                       = 0 ;
reg   [31:0]  BUS_ADDR                     = 0 ;
reg   [3:0]  BUS_BE                        = 0 ;
reg   [31:0]  BUS_DATA_WR                  = 0 ;
reg   io_trigDriv_PulseIn                  = 0 ;
reg   [7:0]  io_syncTrig_FbIn              = 0 ;

// SyncTrig_LogicTop Outputs
wire  [31:0]  BUS_DATA_RD                  ;
wire  [7:0]  io_syncTrig_PulseOut          ;
wire  [8:0]  io_workingFb_PulseOut         ;
wire  [6:0]  io_ind                        ;
wire  [7:0]  io_follow_led                 ;


initial begin forever #(PERIOD_10M/2)  io_clk=~io_clk; end
initial begin forever #(PERIOD_80M/2)  BUS_CLK=~BUS_CLK; end

reg [8:0] logicRst_80M;
reg [8:0] ramRst_80M;
reg [5:0] logicRst_10M;
reg [5:0] ramRst_10M;
always @ (posedge BUS_CLK) begin
  logicRst_80M <= {logicRst_80M[7:0],io_rst};
  ramRst_80M   <= {ramRst_80M[7:0]  ,io_rst_ram};
end
always @ (posedge io_clk) begin
  logicRst_10M <= {logicRst_10M[4:0],|logicRst_80M};
  ramRst_10M   <= {ramRst_10M[4:0]  ,|ramRst_80M};
end

SyncTrig_LogicTop  uut (
    .io_clk                  ( io_clk                        ),
    .io_rst                  ( |logicRst_10M                 ),
    .io_rst_ram              ( |ramRst_10M                   ),
    .BUS_CLK                 ( BUS_CLK                [0:0]  ),
    .BUS_ADDR                ( BUS_ADDR               [31:0] ),
    .BUS_BE                  ( BUS_BE                 [3:0]  ),
    .BUS_DATA_WR             ( BUS_DATA_WR            [31:0] ),
    .io_trigDriv_PulseIn     ( io_trigDriv_PulseIn           ),
    .io_syncTrig_FbIn        ( io_syncTrig_FbIn       [7:0]  ),
    .io_follow_led            (io_follow_led),
    .BUS_DATA_RD             ( BUS_DATA_RD            [31:0] ),
    .io_syncTrig_PulseOut    ( io_syncTrig_PulseOut   [7:0]  ),
    .io_workingFb_PulseOut   ( io_workingFb_PulseOut  [8:0]  ),
    .io_ind                  ( io_ind                 [6:0]  )
);

  wire [7:0] pulseCatchWire;
  wire [7:0] feedBackWire;

  always @ * io_syncTrig_FbIn[0] <= #(PERIOD_10M * 500) feedBackWire[0];
  always @ * io_syncTrig_FbIn[1] <= #(PERIOD_10M * 900) feedBackWire[1];
  always @ * io_syncTrig_FbIn[2] <= #(PERIOD_10M * 568) feedBackWire[2];
  always @ * io_syncTrig_FbIn[3] <= #(PERIOD_10M * 415) feedBackWire[3];
  always @ * io_syncTrig_FbIn[4] <= #(PERIOD_10M * 538) feedBackWire[4];
  always @ * io_syncTrig_FbIn[5] <= #(PERIOD_10M * 859) feedBackWire[5];
  always @ * io_syncTrig_FbIn[6] <= #(PERIOD_10M * 551) feedBackWire[6];
  always @ * io_syncTrig_FbIn[7] <= #(PERIOD_10M * 355) feedBackWire[7];

  reg [7:0] tb_fbDefLev = 0;
  reg [7:0] tb_pulseDefLev = 0;
  reg [(24*8)-1:0] tb_FbPulseWidth = 0;
  SyncPort #(
    24,32
  ) pulseGen[7:0] (
    .io_clk        (io_clk),
    .io_rst        (io_rst),

    //Triger Port
    .io_pulseEn    (pulseCatchWire),
    .io_pulseOut   (feedBackWire),
    .io_pulseWidth (tb_FbPulseWidth),
    .io_pulseDefLev(tb_fbDefLev),

    //Fallback Port
    .io_fbIn        (~io_syncTrig_PulseOut),
    .io_fbCatch     (pulseCatchWire),
    .io_fbFilterCnt ({24'd10}),
    .io_fbDefLev    (tb_pulseDefLev)
  );

task writeBUS;
  input [31:0] addr;
  input [3:0] be;
  input [31:0] data;
  begin : busWirte
    BUS_BE = 3'b0;
    BUS_ADDR = 'h0;
    BUS_DATA_WR = 3'b0;
    #(PERIOD_80M);
    BUS_ADDR = addr;
    BUS_DATA_WR = data;
    #(PERIOD_80M) BUS_BE = be;
    #(PERIOD_80M*2) BUS_BE = 'h0;
    #(PERIOD_80M);
    BUS_ADDR = 'h0;
    BUS_DATA_WR = 3'b0;
    #(PERIOD_80M);
  end
endtask

task CleanRam;
  begin : CleanRam 
    
    integer i;
    for(i = 'hc;i<'h204;i=i+4) begin
      writeBUS(i,'b1111,'d0);
    end
    writeBUS('h0,'b1111,'d0);
    writeBUS('hc,'b1111,'d0);
  end
endtask
//第一页 逻辑循环3次
task sam1_fb;
  begin : sam1_fb
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    #(PERIOD_10M*200);
    tb_pulseDefLev = 8'b00000000;
    tb_fbDefLev = 8'b00000010;
    tb_FbPulseWidth = {{3{24'd0}},24'd0,24'd0,24'd0,24'd600,24'd500};

    writeBUS('h8  ,'b0001,'b00000001);  //首个触发
    writeBUS('h0  ,'b0010,'b00000010 << (8 * 1));  //模式配置
    writeBUS('h0  ,'b1100,'d3        << (8 * 2));  //逻辑循环次数
    writeBUS('h4  ,'b1110,'d100      << (8 * 1));  //逻辑循环 延时
    writeBUS('h8  ,'b0010,'b00000000 << (8 * 1));  //脉冲默认电平
    writeBUS('h8  ,'b0100,'b00000010 << (8 * 2));  //反馈默认电平
    writeBUS('h1C ,'b0001,'b00000010 << (8 * 0));  //反馈 0
    writeBUS('h1C ,'b0010,'b00000001 << (8 * 1));  //反馈 1
    writeBUS('h2c ,'b0011,'d3 * 2   );             //层循环 0
    writeBUS('h24 ,'b0001,'b00000011);             //层配置 0
    // writeBUS('h2c ,'b1100,'d3        << (8 * 2));  //层循环 1
    // writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1
    // writeBUS('h30 ,'b0011,'d2       );             //层循环 2
    // writeBUS('h24 ,'b0100,'b00010000 << (8 * 2));  //层配置 2

    // writeBUS('h0c ,'b0001,'b00001000 << (8 * 0));  //层结束 0
    // writeBUS('h0c ,'b0010,'b00010000 << (8 * 1));  //层结束 1
    // writeBUS('h0c ,'b0100,'b00000000 << (8 * 2));  //层结束 2

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h50 ,'b0111,'d1000     );  //端口 0 脉宽
    writeBUS('h54 ,'b0111,'d800     );  //端口 1 脉宽

    writeBUS('h90 ,'b0111,'d500     );  //端口 1 反馈 脉宽
    writeBUS('h94 ,'b0111,'d600     );  //端口 1 反馈 脉宽
    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 20)io_rst_ram = 0;    
    writeBUS('h0  ,'b0001,'b00000001 << (8 * 0));  //触发
    // #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 1 ;
    // #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 0 ;
  end
endtask
//第六页
task sam4_fb;
  begin : sam4_fb
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_pulseDefLev = 8'b00000000;
    tb_fbDefLev = 8'b00000000;
    tb_FbPulseWidth = {{3{24'd0}},24'd150,24'd250,24'd200,24'd250,24'd0};
    $display("ENter sam_f4 case!,at %t",$realtime);
    writeBUS('h8  ,'b0001,'b00010000);  //首个触发
    writeBUS('h8  ,'b0010,'b00000000 << (8 * 1));  //脉冲默认电平
    writeBUS('h8  ,'b0100,'b00000000 << (8 * 2));  //反馈默认电平
    writeBUS('h1C ,'b0010,'b00000100 << (8 * 1));  //反馈 1
    writeBUS('h1C ,'b0100,'b00000010 << (8 * 2));  //反馈 2
    writeBUS('h1C ,'b1000,'b00000100 << (8 * 3));  //反馈 3
    writeBUS('h20 ,'b0001,'b00001000 << (8 * 0));  //反馈 4
    writeBUS('h2c ,'b0011,'d2 * 2   );             //层循环 0
    writeBUS('h24 ,'b0001,'b00000110);             //层配置 0
    writeBUS('h2c ,'b1100,'d3        << (8 * 2));  //层循环 1
    writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1
    writeBUS('h30 ,'b0011,'d2       );             //层循环 2
    writeBUS('h24 ,'b0100,'b00010000 << (8 * 2));  //层配置 2

    writeBUS('h0c ,'b0001,'b00001000 << (8 * 0));  //层结束 0
    writeBUS('h0c ,'b0010,'b00010000 << (8 * 1));  //层结束 1
    writeBUS('h0c ,'b0100,'b00000000 << (8 * 2));  //层结束 2

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h54 ,'b0111,'d600     );  //端口 1 脉宽
    writeBUS('h58 ,'b0111,'d200     );  //端口 2 脉宽
    writeBUS('h5c ,'b0111,'d2900    );  //端口 3 脉宽
    writeBUS('h60 ,'b0111,'d8900    );  //端口 4 脉宽

    writeBUS('h94 ,'b0111,'d250     );  //端口 1 反馈 脉宽
    writeBUS('h98 ,'b0111,'d200     );  //端口 2 反馈 脉宽
    writeBUS('h9c ,'b0111,'d250     );  //端口 3 反馈 脉宽
    writeBUS('ha0 ,'b0111,'d150     );  //端口 4 反馈 脉宽
    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20)  io_trigDriv_PulseIn = 1 ;
    #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 0 ;
  end
endtask
//第四页
task sam3_fb;
  begin : sam3_fb
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_fbDefLev = 8'b00000001;
    tb_pulseDefLev = 8'b00001000;
    tb_FbPulseWidth = {{4{24'd0}},24'd150,24'd0,24'd500,24'd100};

    writeBUS('h8  ,'b0001,'b00001000);  //首个触发
    writeBUS('h8  ,'b0010,'b00001000 << (8 * 1));  //脉冲默认电平
    writeBUS('h8  ,'b0100,'b00000001 << (8 * 2));  //反馈默认电平
    writeBUS('h1C ,'b1000,'b00000001 << (8 * 3));  //反馈 3
    writeBUS('h1C ,'b0001,'b00000010);             //反馈 0
    writeBUS('h1C ,'b0010,'b00000001 << (8 * 1));  //反馈 1
    writeBUS('h0c ,'b0001,'b00001000);             //层结束 0
    writeBUS('h2c ,'b0011,'d6       );             //层循环 0
    writeBUS('h2c ,'b1100,'d2        << (8 * 2));  //层循环 1
    writeBUS('h24 ,'b0001,'b00000011);             //层配置 0
    writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h50 ,'b0111,'d800     );  //端口 0 脉宽
    writeBUS('h54 ,'b0111,'d1000    );  //端口 1 脉宽
    writeBUS('h5c ,'b0111,'d1500    );  //端口 3 脉宽

    writeBUS('h90 ,'b0111,'d100     );  //端口 0 反馈 脉宽
    writeBUS('h94 ,'b0111,'d500     );  //端口 1 反馈 脉宽
    writeBUS('h9c ,'b0111,'d150     );  //端口 3 反馈 脉宽
    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20)  io_trigDriv_PulseIn = 1 ;
    #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 0 ;
  end
endtask
//第五页
task sam3_delay;
  begin : sam3_fb
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_fbDefLev = 8'b00000001;
    tb_pulseDefLev = 8'b00001000;
    tb_FbPulseWidth = 0;

    writeBUS('h0  ,'b0010,'b00000001 << 8);        //模式配置
    writeBUS('h0  ,'b1100,'d3        << (8 * 2));  //逻辑循环次数
    writeBUS('h4  ,'b1110,'d30      << (8 * 1));  //逻辑循环 延时
    writeBUS('h8  ,'b0001,'b00001000);             //首个触发
    writeBUS('h8  ,'b0010,'b00001000 << (8 * 1));  //脉冲默认电平
    writeBUS('h8  ,'b0100,'b00000001 << (8 * 2));  //反馈默认电平
    writeBUS('h14 ,'b1000,'b00000001 << (8 * 3));  //延时 3
    writeBUS('h14 ,'b0001,'b00000010);             //延时 0
    writeBUS('h14 ,'b0010,'b00000001 << (8 * 1));  //延时 1
    writeBUS('h0c ,'b0001,'b00001000);             //层结束 0
    writeBUS('h2c ,'b0011,'d6       );             //层循环 0
    writeBUS('h2c ,'b1100,'d2        << (8 * 2));  //层循环 1
    writeBUS('h24 ,'b0001,'b00000011);             //层配置 0
    writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h50 ,'b0111,'d100     );  //端口 0 脉宽
    writeBUS('h54 ,'b0111,'d800     );  //端口 1 脉宽
    writeBUS('h5c ,'b0111,'d1500    );  //端口 3 脉宽

    writeBUS('h70 ,'b0111,'d500     );  //端口 0 延时
    writeBUS('h74 ,'b0111,'d1200    );  //端口 1 延时
    writeBUS('h7c ,'b0111,'d500     );  //端口 3 延时

    #(PERIOD_10M * 2)   io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20)  io_trigDriv_PulseIn = 1 ;
    #(PERIOD_10M * 2)   io_trigDriv_PulseIn = 0 ;
    #(PERIOD_10M * 40000);
     #(PERIOD_10M * 20)  io_trigDriv_PulseIn = 1 ;
    #(PERIOD_10M * 2)   io_trigDriv_PulseIn = 0 ;
  end
endtask
//第七页
task sam4_p7;
  begin : sam4_p7
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_pulseDefLev = 8'b00000000;
    tb_fbDefLev = 8'b00000000;
    // tb_FbPulseWidth = {{3{24'd0}},24'd150,24'd250,24'd200,24'd250,24'd0};

    writeBUS('h8  ,'b0001,'b00010000);  //首个触发
    writeBUS('h0  ,'b0010,'b00000001 << 8);        //模式配置
    writeBUS('h8  ,'b0010,'b00000000 << (8 * 1));  //脉冲默认电平

    writeBUS('h14 ,'b0010,'b00000100 << (8 * 1));  //延时 1
    writeBUS('h14 ,'b0100,'b00000010 << (8 * 2));  //延时 2
    writeBUS('h14 ,'b1000,'b00000100 << (8 * 3));  //延时 3
    writeBUS('h18 ,'b0001,'b00001000 << (8 * 0));  //延时 4

    writeBUS('h2c ,'b0011,'d2 * 2   );             //层循环 0
    writeBUS('h24 ,'b0001,'b00000110);             //层配置 0
    writeBUS('h2c ,'b1100,'d3        << (8 * 2));  //层循环 1
    writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1
    writeBUS('h30 ,'b0011,'d2       );             //层循环 2
    writeBUS('h24 ,'b0100,'b00010000 << (8 * 2));  //层配置 2

    writeBUS('h0c ,'b0001,'b00001000 << (8 * 0));  //层结束 0
    writeBUS('h0c ,'b0010,'b00010000 << (8 * 1));  //层结束 1
    writeBUS('h0c ,'b0100,'b00000000 << (8 * 2));  //层结束 2

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h54 ,'b0111,'d600     );  //端口 1 脉宽
    writeBUS('h58 ,'b0111,'d200     );  //端口 2 脉宽
    writeBUS('h5c ,'b0111,'d2900    );  //端口 3 脉宽
    writeBUS('h60 ,'b0111,'d8900    );  //端口 4 脉宽

    writeBUS('h74 ,'b0111,'d1000     );  //端口 1 延时
    writeBUS('h78 ,'b0111,'d500      );  //端口 2 延时
    writeBUS('h7c ,'b0111,'d2        );  //端口 3 延时
    writeBUS('h80 ,'b0111,'d2        );  //端口 4 延时

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20)  io_trigDriv_PulseIn = 1 ;
    #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 0 ;
  end
endtask

task sam4_p8;
  begin : sam4_p8
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_pulseDefLev = 8'b00000000;
    tb_fbDefLev = 8'b00000000;
    // tb_FbPulseWidth = {{3{24'd0}},24'd150,24'd250,24'd200,24'd250,24'd0};

    writeBUS('h8  ,'b0001,'b00010000);  //首个触发
    writeBUS('h0  ,'b0010,'b00000001 << 8);        //模式配置
    writeBUS('h8  ,'b0010,'b00000000 << (8 * 1));  //脉冲默认电平

    writeBUS('h14 ,'b0010,'b00000100 << (8 * 1));  //延时 1
    writeBUS('h14 ,'b0100,'b00000010 << (8 * 2));  //延时 2
    writeBUS('h14 ,'b1000,'b00000100 << (8 * 3));  //延时 3
    writeBUS('h18 ,'b0001,'b00000100 << (8 * 0));  //延时 4

    writeBUS('h2c ,'b0011,'d2 * 2   );             //层循环 0
    writeBUS('h24 ,'b0001,'b00000110);             //层配置 0
    writeBUS('h2c ,'b1100,'d3        << (8 * 2));  //层循环 1
    writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1
    writeBUS('h30 ,'b0011,'d2       );             //层循环 2
    writeBUS('h24 ,'b0100,'b00010000 << (8 * 2));  //层配置 2

    writeBUS('h0c ,'b0001,'b00001000 << (8 * 0));  //层结束 0
    writeBUS('h0c ,'b0010,'b00010000 << (8 * 1));  //层结束 1
    writeBUS('h0c ,'b0100,'b00000000 << (8 * 2));  //层结束 2

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h54 ,'b0111,'d600     );  //端口 1 脉宽
    writeBUS('h58 ,'b0111,'d200     );  //端口 2 脉宽
    writeBUS('h5c ,'b0111,'d2900    );  //端口 3 脉宽
    writeBUS('h60 ,'b0111,'d8900    );  //端口 4 脉宽

    writeBUS('h74 ,'b0111,'d1000     );  //端口 1 延时
    writeBUS('h78 ,'b0111,'d500      );  //端口 2 延时
    writeBUS('h7c ,'b0111,'d2        );  //端口 3 延时
    writeBUS('h80 ,'b0111,'d2        );  //端口 4 延时

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20)  io_trigDriv_PulseIn = 1 ;
    #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 0 ;
  end
endtask

task ind;
  begin : ind
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_pulseDefLev = 8'b00000000;
    tb_fbDefLev = 8'b00000000;
    // tb_FbPulseWidth = {{3{24'd0}},24'd150,24'd250,24'd200,24'd250,24'd0};
    //writeBUS('h0  ,'b0010,'b00001000 << 8);        //模式配置
    writeBUS('h8  ,'b1000,'b00010000  << 8*3 );  //独立控制 默认电平
    //writeBUS('h3c ,'b0011,'d10  << 8*0 );  //独立控制 循环次数0
    //writeBUS('h3c ,'b1100,'d10  << 8*2 );  //独立控制 循环次数1
    //writeBUS('h40 ,'b0011,'d10  << 8*0 );  //独立控制 循环次数2
    //writeBUS('h40 ,'b1100,'d10  << 8*2 );  //独立控制 循环次数3
    //writeBUS('h44 ,'b0011,'d10  << 8*0 );  //独立控制 循环次数4
    //writeBUS('h44 ,'b1100,'d10  << 8*2 );  //独立控制 循环次数5
    //writeBUS('h48 ,'b0011,'d10  << 8*0 );  //独立控制 循环次数6
    //writeBUS('hb0 ,'b0111,'d00  << 8*0 );  //独立控制 脉宽0
    //writeBUS('hb4 ,'b0111,'d00  << 8*0 );  //独立控制 脉宽1
    //writeBUS('hb8 ,'b0111,'d00  << 8*0 );  //独立控制 脉宽2
    //writeBUS('hbc ,'b0111,'d0  << 8*0 );  //独立控制 脉宽3
    //writeBUS('hc0 ,'b0111,'d0  << 8*0 );  //独立控制 脉宽4
    //writeBUS('hc4 ,'b0111,'d0  << 8*0 );  //独立控制 脉宽5
    //writeBUS('hc8 ,'b0111,'d0  << 8*0 );  //独立控制 脉宽6
    //writeBUS('hcc ,'b0111,'d800  << 8*0 );  //独立控制 延迟0
    //writeBUS('hd0 ,'b0111,'d800  << 8*0 );  //独立控制 延迟1
    //writeBUS('hd4 ,'b0111,'d800  << 8*0 );  //独立控制 延迟2
    //writeBUS('hd8 ,'b0111,'d800  << 8*0 );  //独立控制 延迟3
    //writeBUS('hdc ,'b0111,'d800  << 8*0 );  //独立控制 延迟4
    //writeBUS('he0 ,'b0111,'d800  << 8*0 );  //独立控制 延迟5
    //writeBUS('he4 ,'b0111,'d800  << 8*0 );  //独立控制 延迟6

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20);
    writeBUS('h4 ,'b0001,'hff  << 0 );  //独立控制 触发
    #(PERIOD_10M * 2000);
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    #(PERIOD_10M * 20);
    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 10) io_rst_ram = 0;
    #(PERIOD_10M * 20);
    writeBUS('h8  ,'b1000,'b01101111  << 8*3 );  //独立控制 默认电平
    writeBUS('h4 ,'b0001,'hff  << 0 );  //独立控制 触发
  end
endtask
//1.2 p3
task sam1_fb_1_2;
  begin : sam1_fb_1_2
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    tb_pulseDefLev = 8'b00000000;
    tb_fbDefLev = 8'b00000010;
    tb_FbPulseWidth = {{3{24'd0}},24'd0,24'd0,24'd0,24'd600,24'd500};

    writeBUS('h8  ,'b0001,'b00000001);  //首个触发
    writeBUS('h0  ,'b0010,'b00000010 << (8 * 1));  //模式配置
    // writeBUS('h0  ,'b1100,'d3        << (8 * 2));  //逻辑循环次数
    writeBUS('h4  ,'b1110,'d300      << (8 * 1));  //逻辑循环 延时
    writeBUS('h8  ,'b0010,'b00000000 << (8 * 1));  //脉冲默认电平
    writeBUS('h8  ,'b0100,'b00000010 << (8 * 2));  //反馈默认电平
    writeBUS('h16C ,'b0001,'b00000010 << (8 * 0));  //反馈延时 0
    writeBUS('h16C ,'b0010,'b00000001 << (8 * 1));  //反馈延时 1
    writeBUS('h2c ,'b0011,'d3 * 2   );             //层循环 0
    writeBUS('h24 ,'b0001,'b00000011);             //层配置 0
    // writeBUS('h2c ,'b1100,'d3        << (8 * 2));  //层循环 1
    // writeBUS('h24 ,'b0010,'b00001000 << (8 * 1));  //层配置 1
    // writeBUS('h30 ,'b0011,'d2       );             //层循环 2
    // writeBUS('h24 ,'b0100,'b00010000 << (8 * 2));  //层配置 2

    // writeBUS('h0c ,'b0001,'b00001000 << (8 * 0));  //层结束 0
    // writeBUS('h0c ,'b0010,'b00010000 << (8 * 1));  //层结束 1
    // writeBUS('h0c ,'b0100,'b00000000 << (8 * 2));  //层结束 2

    writeBUS('h4c ,'b0111,'d2       );  //触发驱动 脉宽
    writeBUS('h50 ,'b0111,'d1000     );  //端口 0 脉宽
    writeBUS('h54 ,'b0111,'d800     );  //端口 1 脉宽

    writeBUS('h90 ,'b0111,'d500     );  //端口 0 反馈 脉宽
    writeBUS('h94 ,'b0111,'d600     );  //端口 1 反馈 脉宽
    writeBUS('h174 ,'b0111,'d200     );  //端口 0 反馈 延时
    writeBUS('h178 ,'b0111,'d300     );  //端口 1 反馈 延时
    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 5) io_rst_ram = 0;
    #(PERIOD_10M * 200);
    writeBUS('h0  ,'b0001,'b00000001 << (8 * 0));  //触发
    // #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 1 ;
    // #(PERIOD_10M * 2)  io_trigDriv_PulseIn = 0 ;
  end
endtask

initial
begin
   //sam3_fb();
  // wait (io_workingFb_PulseOut[8]);
  // #(PERIOD_10M * 20);
  // sam3_delay();
  // wait (io_workingFb_PulseOut[8]);
  // #(PERIOD_10M * 20);
  //sam1_fb_1_2();
  sam4_fb();
   //sam4_p8();
  //ind();
  // forever begin
  //sam1_fb();
  // #(PERIOD_10M * 13000);

  // end
end


//initial begin
//  $fsdbDumpfile("test.fsdb");
//  $fsdbDumpvars;
//end

endmodule
