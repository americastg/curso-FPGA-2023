library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;

package assert_for_vunit is

    procedure check_bfm_vunit (
        signal clk      : in std_logic;
        signal t_result : in std_logic_vector;
        signal t_ready  : in std_logic;
        constant value  : in integer
    );

    procedure assert_integer_vunit (
        constant expected : integer;
        constant actual   : integer
    );

end package assert_for_vunit;

package body assert_for_vunit is

    procedure check_bfm_vunit (
        signal clk      : in std_logic;
        signal t_result : in std_logic_vector;
        signal t_ready  : in std_logic;
        constant value  : in integer
    ) is
    begin
        wait until rising_edge(clk) and t_ready = '1';
        
        check (
            t_result = std_logic_vector(to_unsigned(value, t_result'length)),
            "Expected: " & integer'image(value) & " Actual: " & integer'image(to_integer(unsigned(t_result)))
        );
    end procedure;

    procedure assert_integer_vunit (
        constant expected : integer;
        constant actual   : integer
    ) is
    begin
        check(
            expected = actual,
            "Expected: " & integer'image(expected) & " Actual: " & integer'image(actual)
        );
    end procedure;

end package body assert_for_vunit;