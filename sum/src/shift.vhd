library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift is
    port(
        clk : in  std_logic;
        rst : in  std_logic;

        d_in : in  std_logic_vector(3 downto 0);
        d_out: out std_logic_vector(3 downto 0)
    );
end entity shift;

architecture shif_rtl of shift is
    constant DEPHT : natural := 4;

    type my_array is array (DEPHT - 1 downto 0) of std_logic_vector(3 downto 0);
    
    signal a_reg, a_next : my_array; 
begin

    a_next <= d_in & a_reg(DEPHT - 2 downto 0);

    TICK: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                a_reg <= (others => (others => '0'));
            else
                a_reg <= a_next;
            end if;
        end if;
    end process TICK;

    d_out <= a_reg(0);

end architecture shif_rtl;