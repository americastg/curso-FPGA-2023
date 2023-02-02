library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use std.textio.all;
use work.stream_bfm.all;

entity sum_n_tb is
    generic (runner_cfg : string);
end entity sum_n_tb;

architecture tb of sum_n_tb is
    constant SIZE : natural := 8;
    
    constant PERIOD: time := 20 ns;

    type depht_3 is record
        a, b, c : integer;
    end record;

    type depht_5 is record
        a, b, c, d, e : integer;
    end record;

    type test_vector_3t is array (natural range <>) of depht_3;
    constant test_vectors_3 : test_vector_3t := (
        (1, 1, 1),
        (2, 1, 1),
        (0, 0, 0)
    );

    type test_vector_5t is array (natural range <>) of depht_5;
    constant test_vectors_5 : test_vector_5t := (
        (1, 1, 1, 1, 1),
        (2, 1, 1, 2, 3),
        (0, 0, 0, 0, 0)
    );

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal valid_i  : std_logic;
    signal data_i   : std_logic_vector(SIZE downto 0);
    signal ready_i  : std_logic;
    signal result_i : std_logic_vector(SIZE downto 0);

begin

    clk <= not clk after PERIOD/2;

    UUT: entity work.sum_n (sum_n_rtl)
    generic map (SIZE => SIZE)
    port map(
        clk      => clk,
        rst      => rst,
        t_valid  => valid_i,
        t_data   => data_i,
        t_ready  => ready_i,
        t_result => result_i
    );

    TEST: process
        variable a, b, c, d, e : integer;
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop

            if run("test depht 3") then
                reset_tb(clk, rst);

                for i in test_vectors_3'range loop
                    a := test_vectors_3(i).a;
                    b := test_vectors_3(i).b;
                    c := test_vectors_3(i).c;
                    
                    write_bfm(clk, valid_i, data_i, ready_i, 3);                    
                    check_bfm_vunit(clk, result_i, ready_i, 0);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, a);
                    check_bfm_vunit(clk, result_i, ready_i, a);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, b);
                    check_bfm_vunit(clk, result_i, ready_i, a + b);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, c);
                    check_bfm_vunit(clk, result_i, ready_i, a + b + c);
                end loop;
            elsif run("test depht 5") then
                reset_tb(clk, rst);

                ------------------------------------------------------------------
                for i in test_vectors_5'range loop
                    a := test_vectors_5(i).a;
                    b := test_vectors_5(i).b;
                    c := test_vectors_5(i).c;
                    d := test_vectors_5(i).d;
                    e := test_vectors_5(i).e;
                    
                    write_bfm(clk, valid_i, data_i, ready_i, 5);
                    check_bfm_vunit(clk, result_i, ready_i, 0);
                    
                    
                    write_bfm(clk, valid_i, data_i, ready_i, a);
                    check_bfm_vunit(clk, result_i, ready_i, a);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, b);
                    check_bfm_vunit(clk, result_i, ready_i, a + b);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, c);
                    check_bfm_vunit(clk, result_i, ready_i, a + b + c);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, d);
                    check_bfm_vunit(clk, result_i, ready_i, a + b + c + d);
                    
                    write_bfm(clk, valid_i, data_i, ready_i, e);
                    check_bfm_vunit(clk, result_i, ready_i, a + b + c + d + e);
                end loop;
            elsif run("reset test") then
                reset_tb(clk, rst);

                write_bfm(clk, valid_i, data_i, ready_i, 3);
                check_bfm_vunit(clk, result_i, ready_i, 0);
                
                write_bfm(clk, valid_i, data_i, ready_i, 1);
                check_bfm_vunit(clk, result_i, ready_i, 1);
                
                reset_tb(clk, rst);
                
                check_bfm_vunit(clk, result_i, ready_i, 0);
            end if;

          end loop;

        test_runner_cleanup(runner);
    end process;

end architecture tb;