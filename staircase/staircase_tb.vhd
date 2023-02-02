library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use std.textio.all;
use work.stream_bfm.all;

entity staircase_tb is
    generic (runner_cfg : string);
end entity staircase_tb;

architecture staircase_tb_arch of staircase_tb is
    constant PERIOD: time := 20 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal valid_i  : std_logic;
    signal data_i   : std_logic_vector(7 downto 0);
    signal ready_i  : std_logic;
    signal result_i : std_logic_vector(7 downto 0);

    signal result : integer;

begin

    clk <= not clk after PERIOD/2;

    UUT: entity work.staircase (staircase_rtl)
    port map (
        clk      => clk,
        rst      => rst,
        t_valid  => valid_i,
        t_data   => data_i,
        t_ready  => ready_i,
        t_result => result_i
    );

    TEST: process

        procedure test_staircase (constant n : integer) is
        begin
            write_bfm(clk, valid_i, data_i, ready_i, n);
    
            for i in 1 to n loop
                for j in 1 to n - i loop
                    read_bfm(clk, valid_i, result_i, ready_i, result);
                    assert_integer_vunit(32, result);
                end loop;
    
                for j in 1 to i loop
                    read_bfm(clk, valid_i, result_i, ready_i, result);
                    assert_integer_vunit(35, result);
                end loop;
            end loop;
        end procedure;

    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop
        
            if run("depht 3") then
                reset_tb(clk, rst);
                test_staircase(3);
            elsif run("depht 4") then
                reset_tb(clk, rst);
                test_staircase(4);
            end if;
        end loop;
        
        test_runner_cleanup(runner);
    end process;

end architecture staircase_tb_arch;