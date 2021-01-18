library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity img_ram_test is
    port (
        clk_pix, rst: in std_logic;
        --data_out: out std_logic_vector(23 downto 0)
        add_rd: buffer std_logic_vector(11 downto 0)
    );
end entity img_ram_test;

architecture test of img_ram_test is
    --component img_ram
    --PORT
	--(
	--	data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
	--	--rd_aclr		: IN STD_LOGIC  := '0';
	--	rdaddress		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	--	rdclock		: IN STD_LOGIC ;
	--	wraddress		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	--	wrclock		: IN STD_LOGIC  := '1';
	--	wren		: IN STD_LOGIC  := '0';
	--	q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	--);
    --end component;
    signal data_in: std_logic_vector(23 downto 0);
    --signal add_rd, add_wr: std_logic_vector(11 downto 0);
    --signal data_out: std_logic_vector(23 downto 0);
    signal wr_en: std_logic;
    --signal rd_clr: std_logic;
begin
    --uram:img_ram
    --port map(
    --    data=> data_in,
    --    --rd_aclr=> rd_clr,
    --    rdaddress=> add_rd,
    --    rdclock=> clk_pix,
    --    wraddress=> add_wr,
    --    wrclock=> clk_pix,
    --    wren=> wr_en,
    --    q=> data_out
    --);
    --ram_wr: process(clk_pix, rst)
    --begin
    --    if rst = '0' then
    --        wr_en<= '0';
    --        add_wr<= (others=> '0');
    --        data_in<= (others=> '0');
    --    elsif rising_edge(clk_pix) then
    --        if add_wr= "111111111111" then
    --            add_wr<= (others => '0');
    --        else
    --            wr_en<= '1';
    --            add_wr<= add_wr+ 1;
    --            data_in<= data_in+ 1;
    --        end if;
    --    end if;
    --end process ram_wr;
    ram_rd: process(clk_pix, rst)
    begin
        if rst = '0' then
            add_rd<= (others=> '0');
            --rd_clr<= '1';
        elsif rising_edge(clk_pix) then
            --rd_clr<= '0';
            if add_rd= "111111111111" then
                add_rd<= (others => '0');
            else
                add_rd<= add_rd+ 1;
            end if;
        end if;
    end process ram_rd;
    
end architecture test;