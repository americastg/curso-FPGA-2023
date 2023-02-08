library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.textio.all;
use work.stream_bfm.all;

entity miniMaxSum_tb is
end entity miniMaxSum_tb;

architecture miniMaxSum_tb_rtl of miniMaxSum_tb is
    constant PERIOD: time := 20 ns;

    constant SIZE: natural := 4;

    signal clk: std_logic := '0';
    signal rst: std_logic;
    signal running: std_logic := '1';

    signal valid_i  : std_logic;
    signal data_i   : std_logic_vector(SIZE downto 0);
    signal ready_i  : std_logic;
    signal result_i : std_logic_vector(SIZE downto 0);

    signal result   : integer;
begin

    clk <= not clk after PERIOD / 2 when running = '1';

    UUT: entity work.miniMaxSum (miniMaxSum_rtl)
    generic map (SIZE => SIZE)
    port map (
      clk      => clk,
      rst      => rst,
      t_valid  => valid_i,
      t_data   => data_i,
      t_ready  => ready_i,
      t_result => result_i
    );
    
    TEST: process
    begin
        
        reset_tb(clk, rst);
            
        write_bfm(clk, valid_i, data_i, ready_i, 5);
        
        write_bfm(clk, valid_i, data_i, ready_i, 1);
        write_bfm(clk, valid_i, data_i, ready_i, 2);
        write_bfm(clk, valid_i, data_i, ready_i, 3);
        write_bfm(clk, valid_i, data_i, ready_i, 4);
        write_bfm(clk, valid_i, data_i, ready_i, 5);
            
        read_bfm(clk, valid_i, result_i, ready_i, result);
        assert_integer(14, result);
        
        read_bfm(clk, valid_i, result_i, ready_i, result);
        assert_integer(10, result);
            
        printf("PASSSSSOOOUUUUU");

        running <= '0';
        wait;
    end process;

end architecture miniMaxSum_tb_rtl;