# pixel-drawing

a FPGA based pixel drawing platform

一个基于FPGA系统的像素画绘制平台

## start up

- 开发板平台：ALINX AX4010 with Cyclone IV EP4CE10F17C8N

- PS/2键盘输入，VGA/HDMI均可输出显示

## system structure

1. ps/2 keyboard read & decode: decode key up, down, left, right, space (and more?)
    - ps2_read.vhd
    - ps2_decode.vhd
2. color select: press key space to choose color
    - color_ctrl.vhd
3. coordinate pointer: indicate the active area
    - pointer.vhd
4. draw control & storage: use key up, down, left, right to select the area, press key space to paint it
    - img_ctrl.vhd
    - 2-port ram (ip core)
5. LED digital display: display the pointer location and the current color No.
    - ctrl_info_to_smg_data.vhd
    - smg_6.vhd
6. contral infomation buffer: for clock domain crossing problem
    - ctrl_ram_wr.vhd
    - ctrl_ram (IP core)
    - ctrl_ram_rd.vhd
7. generate VGA signal (in RGB888): raw image signal ready to display on the screen
    - vga_signal_gen.vhd
8. VGA signal out: RGB888 to RGB565
    - vga_port_out.vhd
9. DVI (HDMI) signal out: TMDS encode
    - dvi_encoder.v
    - par10bit_to_ddr_signal.vhd
    - ALTDDIO-OUT (IP core)
    - ALTIOBUF (IP core)

    1--> 2

    &ensp;--> 3

    &ensp;--> 4

    2--> 5

    &ensp;--> 6

    3--> 5

    &ensp;--> 6

    4--> 7

    6--> 7

    7--> 8

    &ensp;--> 9