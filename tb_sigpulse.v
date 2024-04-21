`timescale 1ns / 1ps

module tb_sigpulse();

  // 宏定义
  parameter _RAM_WIDTH = 32;
  parameter PWM_PULSE_WIDTH = 10000; // 单位为纳秒，代表1us的PWM脉冲宽度

  // 输入输出信号
  reg io_clk;
  reg io_rst;
  reg pwm_dis;
  reg io_en;
  // wire io_pulseOut;
  reg [_RAM_WIDTH - 1:0] io_pulseWidth;
  reg io_defaultLevel;
  //
  wire pulse_valid;
  wire io_pulseOut;

  reg en_d1;
  // 实例化DUT
  sigpulse #(
    ._RAM_WIDTH(_RAM_WIDTH)
  ) uut (
    .io_clk(io_clk),
    .io_rst(io_rst),
    .io_en(io_en & ~en_d1),
    .pwm_dis(pwm_dis),
    .io_pulseOut(io_pulseOut),
    .io_pulseWidth(io_pulseWidth),
    .io_defaultLevel(io_defaultLevel),
    .pulse_valid(pulse_valid)
  );

  // 时钟生成
  initial begin
    io_clk = 0;
    forever #50 io_clk = ~io_clk; // 生成100MHz的时钟信号
  end
  
  always @(posedge io_clk) begin
     en_d1 <= io_en;
  end

  // 测试序列
  initial begin
    // 初始化信号
    io_rst = 1;
    io_en = 0;
    pwm_dis =0;
    io_pulseWidth = 0;
    io_defaultLevel = 0;
    #20; // 等待几个时钟周期以稳定信号
    io_rst = 0; // 释放复位
    #20;

    // 设置PWM信号参数
    io_defaultLevel = 1'b1; // 假设默认电平为低
    io_pulseWidth = PWM_PULSE_WIDTH / 10; // 根据宏定义设置滤波计数
    #10000;
    $display("ready!");
    // 模拟PWM信号
    //reg pwm_out;
    //generate_pwm  (10001); // 产生1us宽的PWM信号
    // #100;
    // io_en = 1;
    // #150'
    // io_en = 1;
    // 检查io_pulseOut是否正确
    start_sigpulse;
    #2030 pwm_dis =1;
    #100 pwm_dis =0;
    $display("%t 2st abort!",$realtime);
    @(posedge pulse_valid)
      #500 start_sigpulse;
    #1000;
    // ...

    // 结束仿真
    // #1000;
    //$finish;
  end

  // 生成PWM信号的函数
  task start_sigpulse ;
    //input io_defaultLevel;
    // input  [_RAM_WIDTH-1 :0] period;
    // output pwm_out;
    begin
      io_en = 1;
      #150; // 保持一段时间
      // $display("pulus_access %t!",period/2);
      io_en = 0;
      // #(period/2);
    end
  endtask

endmodule