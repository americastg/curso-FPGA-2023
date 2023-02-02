library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;

package stream_bfm is

    procedure reset_tb (
        signal clk : in  std_logic;
        signal rst : out std_logic
    );

    procedure printf (constant s: string);

    function to_string (a: std_logic_vector) return string;

    procedure write_bfm (
        signal clk     : in  std_logic;
        signal t_valid : out std_logic;
        signal t_data  : out std_logic_vector;
        signal t_ready : in  std_logic;
        constant value : in  integer
    );

    procedure check_bfm (
        signal clk      : in std_logic;
        signal t_result : in std_logic_vector;
        signal t_ready  : in std_logic;
        constant value  : in integer
    );

    procedure read_bfm (
        signal clk      : in  std_logic;
        signal t_valid  : out std_logic;
        signal t_result : in  std_logic_vector;
        signal t_ready  : in  std_logic;
        signal result   : out integer
    );

    procedure assert_integer (
        constant expected : integer;
        constant actual   : integer
    );

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

end package stream_bfm;

package body stream_bfm is

    procedure reset_tb (
        signal clk : in  std_logic;
        signal rst : out std_logic
    ) is
    begin
        rst <= '1';
        wait until rising_edge(clk);

        rst <= '0';
        wait until rising_edge(clk);
    end procedure;

    procedure printf (constant s: string) is
        variable l : line;
    begin
        write (l, s);
        writeline(output, l);
        return;
    end procedure;

    function to_string (a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1; 
        begin
            for i in a'range loop
                b(stri) := std_logic'image(a((i)))(2);
            stri := stri+1;
            end loop;
        return b;
    end function;

    procedure write_bfm (
        signal clk     : in  std_logic;
        signal t_valid : out std_logic;
        signal t_data  : out std_logic_vector;
        signal t_ready : in  std_logic;
        constant value : in  integer
    ) is
    begin
        t_valid <= '1';
        t_data <= std_logic_vector(to_unsigned(value, t_data'length));
        wait until rising_edge(clk) and t_ready = '1';
        
        t_valid <= '0';
        wait until rising_edge(clk);
    end procedure;

    procedure check_bfm (
        signal clk      : in std_logic;
        signal t_result : in std_logic_vector;
        signal t_ready  : in std_logic;
        constant value  : in integer
    ) is
    begin
        wait until rising_edge(clk) and t_ready = '1';
        
        assert t_result = std_logic_vector(to_unsigned(value, t_result'length))
        report "Expected: " & integer'image(value) & " Actual: " & integer'image(to_integer(unsigned(t_result)))
        severity FAILURE;
    end procedure;

    procedure read_bfm (
        signal clk      : in  std_logic;
        signal t_valid  : out std_logic;
        signal t_result : in  std_logic_vector;
        signal t_ready  : in  std_logic;
        signal result   : out integer
    )is
    begin
        wait until rising_edge(clk) and t_ready = '1';

        result <= to_integer(unsigned(t_result));

        t_valid <= '1';
        wait until rising_edge(clk);

        t_valid <= '0';
        wait until rising_edge(clk);
    end procedure;

    procedure assert_integer (
        constant expected : integer;
        constant actual   : integer
    ) is
    begin
        assert expected = actual
        report "Expected: " & integer'image(expected) & " Actual: " & integer'image(actual)
        severity FAILURE;
    end procedure;

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

end package body stream_bfm;