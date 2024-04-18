`timescale 1ns / 1ps
module testbench ;
// define parameter
  // parameter 32        = 32;
  // parameter 32 = 32;
//define syncport port
  reg io_clk;
  reg io_rst;
  reg io_rst_ram;

  //Triger Port
  reg  io_pulseEn; 
  wire io_pulseOut;
  wire io_delayOut; //使能后延迟输出
  reg  [32 - 1:0] io_pulseWidth;//PWM持续时间
  reg  [32 - 1:0] io_trigDelay;//触发后延迟时间
  reg  io_pulseDefLev;//输出PWM默认电平
  wire   follow_led;

  //Fallback Port
  reg  io_fbIn; //输入检测信号
  wire io_fbCatch;//满足检测宽度后的catch信号
  reg  [32 - 1:0] io_fbFilterCnt;//输入信号检测宽度
  reg  io_fbDefLev;//输入信号的默认电平
  // Fallback delay Port
  reg [32 - 1:0] io_Fb_DelayCnt;//catch后的延迟时间
  reg io_Fb_en;//??
  wire  io_Fb_DelayEnd;//??
  //Timing
  reg   work_End ;//
  wire [32 - 1:0] io_timing1st;
  wire [32 - 1:0] io_timingMax;
  wire [32 - 1:0] io_timingMin;

  //Counter
  
  wire [15:0] io_pulseCounter;
  wire [15:0] io_fbCounter;

  //instance DUT 
SyncPort  #(
  ._RAM_WIDTH       (32) ,
  ._RAM_WIDTH_TIMING(32)
) uut(
  .io_clk(io_clk),
  .io_rst(io_rst),
  .io_rst_ram(io_rst_ram),

  //Triger Port
  .io_pulseEn(io_pulseEn),
  .io_pulseOut(io_pulseOut),
  .io_delayOut(io_delayOut),
  .io_pulseWidth(io_pulseWidth),
  .io_trigDelay(io_trigDelay),
  .io_pulseDefLev(io_pulseDefLev),
  .follow_led(follow_led),

  //Fallback Port
  .io_fbIn(io_fbIn),
  .io_fbCatch(io_fbCatch),
  .io_fbFilterCnt(io_fbFilterCnt),
  .io_fbDefLev(io_fbDefLev),
  // Fallback delay Port
  .io_Fb_DelayCnt(io_Fb_DelayCnt),
  .io_Fb_en(io_Fb_en),
  .io_Fb_DelayEnd(io_Fb_DelayEnd),
  //Timing
  .work_End (work_End),
  .io_timing1st(),
  .io_timingMax(),
  .io_timingMin(),

  //Counter
  
  .io_pulseCounter(io_pulseCounter),
  .io_fbCounter(io_fbCounter)
);
//create clock
initial begin
    io_clk = 0;
    forever begin
        # 50 io_clk = ~ io_clk; //10M 
    end
end
// testbench begin
initial begin
    // at the beginning
    io_rst = 1;
    io_rst_ram = 1;
    
      //Triger Port
    io_pulseEn   = 0;
    io_pulseWidth = 24'hc8;
    io_trigDelay    = 24'hfa;
    io_pulseDefLev  = 1'b0;

  //Fallback Port
    io_fbIn     = 0;
    io_fbFilterCnt = 24'h12c;
    io_fbDefLev  = 1'b0;
  // Fallback delay Port
    io_Fb_DelayCnt = 24'h96;
    io_Fb_en    = 0;
  //Timing
    work_End = 0;
    // begin
    #10000;
    io_rst = 0;
    #100;
    io_rst_ram = 0;
    #10000;
    
    // io_pulseEn   = 1;
    // #150 ;
    // io_pulseEn   = 0;
    #1000
    io_fbIn = 1;
    #45000;
    io_fbIn = 0;


end

    
endmodule