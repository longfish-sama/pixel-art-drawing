library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ps2_read is
    port (
        clk_sys: in std_logic;
        clk_ps2: in std_logic;
        data_in_ps2: in std_logic;
        rst: in std_logic;
        data_out_ps2: out std_logic_vector(7 downto 0)
    );
end entity ps2_read;

architecture bhv of ps2_read is
    signal data_tmp: std_logic_vector(7 downto 0);
    signal read_done: std_logic;    
begin
    com: process(clk_ps2, rst)
        variable bit_tmp: std_logic;
        type state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
        variable state: state_type;    
    begin
        if rst= '0' then
            state:= s0;
            data_tmp<= "00000000";
            read_done<= '0';
        elsif falling_edge(clk_ps2) then
            case state is
                when s0 =>
                    bit_tmp:= data_in_ps2;
                    if bit_tmp='0' then
                        state:= s1;
                        read_done<= '0';
                    else
                        state:= s0;
                    end if;
                when s1 =>
                    data_tmp(0)<= data_in_ps2;
                    state:= s2;
                when s2 =>
                    data_tmp(1)<= data_in_ps2;
                    bit_tmp:= data_tmp(0) xor data_tmp(1);
                    state:= s3;
                when s3 =>
                    data_tmp(2)<= data_in_ps2;
                    bit_tmp:= bit_tmp xor data_tmp(2);
                    state:= s4;
                when s4 =>
                    data_tmp(3)<= data_in_ps2;
                    bit_tmp:= bit_tmp xor data_tmp(3);
                    state:= s5;
                when s5 =>
                    data_tmp(4)<= data_in_ps2;
                    bit_tmp:= bit_tmp xor data_tmp(4);
                    state:= s6;
                when s6 =>
                    data_tmp(5)<= data_in_ps2;
                    bit_tmp:= bit_tmp xor data_tmp(5);
                    state:= s7;
                when s7 =>
                    data_tmp(6)<= data_in_ps2;
                    bit_tmp:= bit_tmp xor data_tmp(6);
                    state:= s8;
                when s8 =>
                    data_tmp(7)<= data_in_ps2;
                    bit_tmp:= bit_tmp xor data_tmp(7);
                    state:= s9;
                when s9 =>
                    bit_tmp:= bit_tmp xor data_in_ps2;
                    if bit_tmp='1' then
                        state:= s10;
                    else
                        state:= s10;
                    end if;
                when s10 =>
                    bit_tmp:= data_in_ps2;
                    if bit_tmp='1' then
                        read_done<= '1';
                    else
                        read_done<= '0';
                    end if;
                    state:= s0;
            end case;
        end if;
    end process com;

    data_out: process(clk_sys, rst)
    begin
        if rst = '0' then
            data_out_ps2<= "00000000";
        elsif rising_edge(clk_sys) then
            if read_done='1' then
                data_out_ps2<= data_tmp;
            end if;
        end if;
    end process data_out;

end architecture bhv;