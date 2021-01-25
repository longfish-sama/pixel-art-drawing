library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity key_to_led is
    port (
        key_code: in std_logic_vector(3 downto 0);
        ctrl: in std_logic;
        clk, rst: in std_logic;
        led_0, led_1, led_2, led_3: out std_logic
    );
end entity key_to_led;

architecture bhv of key_to_led is
begin
    led0: process(clk, rst)
        variable cnt: integer range 0 to 250000;
        variable flag: std_logic;
    begin
        if rst = '0' then
            cnt:= 0;
            led_0<= '0';
        elsif rising_edge(clk) then
            if key_code/= "0000" then
                flag:= '1';
            elsif flag= '1' then
                led_0<= '1';
                cnt:= cnt+ 1;
                if cnt= 250000 then
                    led_0<= '0';
                    cnt:= 0;
                    flag:= '0';
                end if;
            end if;
        end if;
    end process led0;
    
    led1: process(clk, rst)
    begin
        if rst = '0' then
            led_1<= '0';
        elsif rising_edge(clk) then
            led_1<= ctrl;
        end if;
    end process led1;
    
end architecture bhv;