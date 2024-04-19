`timescale 1ns / 1ps

module tb_pulsecatch();

  // 宏定义
  parameter _RAM_WIDTH = 32;
  parameter PWM_PULSE_WIDTH = 10000; // 单位为纳秒，代表1us的PWM脉冲宽度

  // 输入输出信号
  reg io_clk;
  reg io_rst;
  reg io_fb_in;
  wire io_fb_catch;
  reg [_RAM_WIDTH - 1:0] io_filterCnt;
  reg io_defaultLevel;
  //
  
  // 实例化DUT
  PulseCatch #(
    ._RAM_WIDTH(_RAM_WIDTH)
  ) uut (
    .io_clk(io_clk),
    .io_rst(io_rst),
    .io_fb_in(io_fb_in),
    .io_fb_catch(io_fb_catch),
    .io_filterCnt(io_filterCnt),
    .io_defaultLevel(io_defaultLevel)
  );

  // 时钟生成
  initial begin
    io_clk = 0;
    forever #50 io_clk = ~io_clk; // 生成100MHz的时钟信号
  end
  // always @(posedge io_clk) begin
  //   io_fb_in <= pwm_out;
  // end

  // 测试序列
  initial begin
    // 初始化信号
    io_rst = 1;
    io_fb_in = 0;
    io_filterCnt = 0;
    io_defaultLevel = 0;
    #20; // 等待几个时钟周期以稳定信号
    io_rst = 0; // 释放复位
    #20;

    // 设置PWM信号参数
    io_defaultLevel = 1'b0; // 假设默认电平为低
    io_filterCnt = PWM_PULSE_WIDTH / 1000; // 根据宏定义设置滤波计数
    #10000;
    $display("ready!");
    // 模拟PWM信号
    //reg pwm_out;
    generate_pwm  (10000); // 产生1us宽的PWM信号

    // 检查io_fb_catch是否正确
    // ...

    // 结束仿真
    #1000;
    //$finish;
  end

  // 生成PWM信号的函数
  task generate_pwm ;
    //input io_defaultLevel;
    input  [_RAM_WIDTH-1 :0] period;
    // output pwm_out;
    begin
      io_fb_in = ~io_defaultLevel;
      #(period/2); // 保持一段时间
      $display("pwm!");
      io_fb_in = io_defaultLevel;
      #(period/2);
    end
  endtask

endmodule