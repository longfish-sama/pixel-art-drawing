# pixel-drawing

a FPGA based pixel drawing platform

一个基于FPGA系统的像素画绘制平台

## start up

- 开发板平台：ALINX AX4010 with Cyclone IV EP4CE10F17C8N

- PS/2键盘输入，VGA/HDMI均可输出显示

## system structure

1. ps/2 keyboard read & decode
    - ps2_read.vhd
    - ps2_decode.vhd
2. color select
    - color_ctrl.vhd
3. coordinate pointer
    - pointer.vhd
4. draw control & storage
    - img_ctrl.vhd
    - 2-port ram (ip core)
5. LED digital display
    - pointer_to_smg_data.vhd
    - smg_6.vhd
6. 

