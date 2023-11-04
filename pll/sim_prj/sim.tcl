############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#############################
#创建库
vlib ./lib
vlib ./lib/base_lib
vlib ./lib/altera_lib
#映射逻辑库到物理目录
vmap base_lib ./lib/base_lib
vmap altera_lib ./lib/altera_lib
#编译修改后的文件，这里把设计文件和仿真文件分开放了，所以写两个
vlog -work base_lib	"../rtl/*.v"
vlog -work base_lib	"../sim/*.v"
vlog -work base_lib	"../quartus_prj/ip_core/pll_ip.v"
vlog -work altera_lib	"C:/altera/13.1/quartus/eda/sim_lib/altera_mf.v"
#vsim用于仿真
#-voptargs=+acc：加快仿真速度 work.xxxxxxxx：仿真的顶层设计模块的名称 -t ns:仿真时间分辨率
#由于创建了多个逻辑映射库，而启动仿真的时候的是需要链接库
#因此 -L 逻辑映射库1 -L 逻辑映射库2... 就把映射库链接起来
vsim -voptargs=+acc -L base_lib -L altera_lib base_lib.tb_pll

############################## 添加波形模板#############################
#添加波形区分说明
add wave -divider {tb_pll} 
#添加波形
add wave tb_pll/*
add wave -divider {pll_inst}
add wave tb_pll/pll_inst/* 
############################## 运行#############################
run 10us