onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ps2_read/clk_sys
add wave -noupdate /tb_ps2_read/clk_ps2
add wave -noupdate /tb_ps2_read/data_in_ps2
add wave -noupdate /tb_ps2_read/rst
add wave -noupdate /tb_ps2_read/data_out_ps2
add wave -noupdate /tb_ps2_read/key_code_out
add wave -noupdate /tb_ps2_read/u1/clk_ps2_neg
add wave -noupdate /tb_ps2_read/u1/read_done
add wave -noupdate /tb_ps2_read/u1/data_tmp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2524160494 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 168
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {21716894328 ps}
