[TOC]

## 前言

在编写完成verilog代码时，我们常用需要使用modelsim软件进行仿真，一般我们都是在modelsim中手动添加文件，波形等等，小工程倒是无所谓，但是一旦信号量较多，涉及到观察以及编译方式使用GUI界面操作的方式未免有些麻烦，所以在此介绍利用tcl脚本去是实现modelsim的自动化仿真。

*Tcl*全称是Tool Command Language，其在fpga设计、ic设计和验证中作为一种比较常用的脚本语言（其他的还有：perl,shell,python）

==环境准备：==

> 1.已安装好modelsim软件
>
> 2.有notepad++或sublime等文本编辑器，用以编写tcl脚本

## 常用的tcl脚本仿真

1. 下载实验工程——[Modelsim_Tcl_Simulation]()
2. 一般我们的工程文件下有下列子文件夹，其中`sim_prj`为存放tcl脚本等仿真文件的文件夹

![image-20231104184303641](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041843756.png)

3. 打开sim_prj文件可以看到其中名为：`sim.tcl`的文件，即为comflex_fsm工程的仿真脚本文件

其中内容如下,其实现了对于本工程的仿真说明：

```tcl
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
```

<table><tr><td bgcolor=PowderBlue>上述sim.tcl脚本补充解释</td></tr></table>

`quit -sim`退出仿真，即如果当前modelsim中具有仿真运行，可以将其中止并退出仿真界面

`.main clear`清除modelsim `Transcript`中的内容

`vlog "../rtl/*.v"`，vlog为编译的意思，则`../rtl/*.v`代表路径，因为仿真工程在`sim_prj`中，所以需要利用`../`退到上一级文件夹，再选择`/rtl/*.v`，即rtl文件夹下的所有.v文件，当然如果不需要全部编译，也可以指定文件，eg：`vlog "../rtl/complex_fsm.v"`

```tcl
# 添加虚拟类型
virtual    type {
{01 IDLE}
{02 HALF}
{04 ONE}
{08 ONE_HALF}
{16 TWO}
} vir_new_signal
virtual    function {(vir_new_signal)tb_complex_fsm/complex_fsm_inst/state} new_state
add wave  -color red  -itemcolor blue  tb_complex_fsm/complex_fsm_inst/new_state
```

这块代码，比如在状态机中直接使用0001,0010....这种数字不太好直观体现变化以及观察，这里可以运用`virtual    type`定义虚拟类型，这样让数值和字符一一对应，根据complex_fsm.v代码可以配置对应关系：

![image-20231104191148422](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041911469.png)

一般来说根据自己实际的状态机名字配置就可以了。

4. 打开modelsim软件，切换路径至你下载仿真工程的sim_prj下（`xxxx\Modelsim_Tcl_Simulation\complex_fsm\sim_prj`）

![image-20231104191631528](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041916581.png)

5. 在命令窗口输入`ls`可以看到sim_prj文件下的tcl脚本

![image-20231104191859556](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041918600.png)

6. 输入指令`do sim.tcl`,则执行编写的脚本内容，进行仿真，打开wave波形如下：

![image-20231104192148490](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041921563.png)

可以看到无论是波形分区说明，虚拟类型状态机（包括波形颜色，名称颜色），时间线单位，波形数据类型都和配置相符，说明了利用tcl脚本仿真的成功。

==后面对于不同的仿真需要根据上述脚本模块进行修改即可==

## 复杂tcl脚本仿真（以Quartus中带ipcore为例）

上面的仿真仅仅涉及自己编写的.v文件，但是在实际中我们可能需要添加ip核，并进行仿真，这就需要添加不同软件ip核仿真所支持的文件。

以quartus软件中生成pll锁相环为例。其重要在下载的仿真工程中：

![image-20231104193303970](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041933018.png)

在配置pll锁相环中，quartus提醒借用第三方软件进行仿真需要添加Altera的仿真库文件`altera_mf`，所以在编译文件中需要将该文件添加至脚本编译

![image-20231104193523534](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041935588.png)

`pll/sim_prj/sim.tcl`脚本内容如下：

```tcl
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
```

<table><tr><td bgcolor=PowderBlue>上述sim.tcl脚本补充解释</td></tr></table>

和`常用的tcl脚本仿真中的sim.tcl`相比，这里创立了`lib,base_lib,altera_lib`并进行物理路径进行映射。

`vlog -work base_lib	"../rtl/*.v"`将rtl路径下的.v文件编译的结果和源文件放入base_lib，这样不同的编译结果仿真不同的地方方便进行管理。

此时由于顶层仿真文件在`base_lib`库中，所以tb_pll的库名字需要更改为：`base_lib.tb_pll`。之前`常用的tcl脚本仿真中的sim.tcl`未有vlib创建和vmap映射则默认对应`work`库，并且物理路径为`./rtl_work`，且之前的所有源文件和编译文件都在`work`库中，所以直接写`work.tb_complex_fsm`

此外，由于现在编译库不为默认的work库，所以需要利用`-L lib_name`去链接使用的库：`vsim -voptargs=+acc -L base_lib -L altera_lib base_lib.tb_pll`

| ![image-20231104205733703](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311042057754.png) |
| :----------------------------------------------------------: |
| ![image-20231104205925873](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311042059916.png) |

<font face="微软雅黑" color=red size=4>最后注意的是：不同电脑的altera_mf.v路径不同，需要进行更改，我的文件路径如下：</font>

![image-20231104194037313](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041940371.png)

接着直接按照上一节的操作方法，进行仿真即可，结果如下。证明仿真是没问题的。

![image-20231104194806768](https://gitee.com/lgziyan/cloudimages/raw/master/img/202311041948825.png)

## 参考

> [使用tcl脚本进行Modelsim的工程创建以及波形仿真与波形显示等功能](https://www.bilibili.com/video/BV1TA411F7rL/?spm_id_from=333.337.search-card.all.click&vd_source=676a97c1df5bde5fb2bba7e5a29957d4)
>
> [基于脚本的modelsim自动化仿真笔记](https://mp.weixin.qq.com/s/ieG4vLZakfDg0OnLRwaEfw)
>
> [Modelsim的使用——复杂的仿真](https://www.cnblogs.com/IClearner/p/7279267.html)
>
> [基于脚本的modelsim自动化仿真笔记](https://www.cnblogs.com/IClearner/p/7273441.html)
>
> [Modelsim中使用TCL脚本编写do文件实现自动化仿真](https://mp.weixin.qq.com/s/q5yV7ozvOPJCIJ90-JTnYg)

