library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


int sum(int x, int n)
{
    int result = 0;
    for (int i = 0; i < n; i++)
    {
        result = result + x;
    }
    return result;
}

entity sum is
    generic( SIZE : natural := 100);
    port(
        clk : in  std_logic;
        rst : in  std_logic;

        tvalid : in std_logic;
        d_in : in  std_logic_vector(SIZE - 1 downto 0);

        result : out std_logic_vector(SIZE - 1 downto 0);
        tready : out std_logic

    );
end entity sum;

architecture sum_rtl of sum is

    signal n_reg, n_next : std_logic_vector(SIZE - 1 downto 0);
    signal x_reg, x_next : std_logic_vector(SIZE - 1 downto 0);
    signal result_reg, result_next: std_logic_vector(SIZE - 1 downto 0);

    signal tready_reg, tready_next : std_logic;

    type state_t is (idle, get_x, test_loop, sum);

    signal state_reg, state_next : state_t;

begin

    TICK: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                n_reg <= (others => '0');
                x_reg <= (others => '0');
                result_reg <= (others => '0');
                tready_reg <= '0';
                state_reg <= idle;
            else
                n_reg <= n_next;
                x_reg <= x_next;
                result_reg <= result_next;
                tready_reg <= tready_next;
                state_reg <= state_next;
            end if;
        end if;
    end process TICK;

    SUM_P : process(tvalid, state_reg, n_reg, x_reg, tready_reg, result_reg)
    begin
        state_next <= state_reg;
        n_next <= n_reg;
        x_next <= x_reg;
        result_next <= result_reg;
        tready_next <= tready_reg;

        case state_reg is
            when idle =>
                n_next <= d_in;
                tready_next <= '1';
                
                if tvalid = '1' and tready_reg = '1' then
                    state_next <= get_x;
                end if;
            when get_x =>
                result_next <= 0;
                x_next <= d_in;

                if tvalid = '1' and tready_reg = '1' then
                    state_next <= test_loop;
                end if;
            when test_loop =>
                n_next <= n_reg - 1;

                if n_reg > 0 then
                    state_next <= sum;
                else
                    state_next <= idle;
                end if;
            when sum =>
                result_next <= result_reg + x_reg;
                state_next <= test_loop;
        end case;
    end process;

end architecture sum_rtl;

