############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#############################
#编译修改后的文件，这里把设计文件和仿真文件分开放了，所以写两个
vlog "../rtl/*.v"
vlog "../sim/*.v"
#vsim用于仿真
#-voptargs=+acc：加快仿真速度 work.xxxxxxxx：仿真的顶层设计模块的名称 -t ns:仿真时间分辨率
vsim -t ns -voptargs=+acc work.tb_complex_fsm

############################## 添加波形模板#############################
# 添加虚拟类型
virtual    type {
{01 IDLE}
{02 HALF}
{04 ONE}
{08 ONE_HALF}
{16 TWO}
} vir_new_signal
#添加波形区分说明
add wave -divider {tb_complex_fsm} 
#添加波形
add wave tb_complex_fsm/*
add wave -divider {complex_fsm_inst}
add wave -radix decimal tb_complex_fsm/complex_fsm_inst/* 
virtual    function {(vir_new_signal)tb_complex_fsm/complex_fsm_inst/state} new_state
add wave  -color red  -itemcolor blue  tb_complex_fsm/complex_fsm_inst/new_state

###常用添加波形指令
#-radix red -----设置波形颜色
#-itemcolor Violet -----设置波形名字颜色
#常用颜色：red,blue,yellow,pink,orange,cyan,violet
#-radix decimal----定义显示进制形式
#常用进制有 binary, ascii, decimal, octal, hex, symbolic, time, and default

## 配置时间线单位(不配置时默认为ns)
configure wave -timelineunits us
############################## 运行#############################
run 10us