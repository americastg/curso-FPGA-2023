library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity staircase is
  port (
    clk      : in std_logic;
    rst      : in std_logic;
    t_valid  : in std_logic;
    t_data   : in std_logic_vector(7 downto 0);
    t_ready  : out std_logic;
    t_result : out std_logic_vector(7 downto 0)
  );
end entity staircase;

architecture staircase_rtl of staircase is

  type state_type is (idle, test_loop_i, test_loop_j, write_space, wait_space, test_loop_k, write_sharp, wait_sharp);

  signal state_reg, state_next: state_type;
  
  signal t_ready_reg, t_ready_next   : std_logic;
  signal t_result_reg, t_result_next : std_logic_vector(t_result'range);
  signal n_reg, n_next               : unsigned(t_data'range);
  signal i_reg, i_next               : unsigned(t_data'range);
  signal j_reg, j_next               : unsigned(t_data'range);
  signal k_reg, k_next               : unsigned(t_data'range);

begin

  COMBINATIONAL: process(state_reg, t_valid, t_data, t_ready_reg, t_result_reg, n_reg, i_reg, j_reg, k_reg)
  begin
    state_next <= state_reg;
    
    t_ready_next     <= t_ready_reg;
    t_result_next <= t_result_reg;
    n_next         <= n_reg;
    i_next         <= i_reg;
    j_next         <= j_reg;
    k_next         <= k_reg;

    case state_reg is
      when idle =>
        
        if t_valid = '1' then
          n_next       <= unsigned(t_data);
          i_next       <= to_unsigned(1, t_data'length);
          t_ready_next <= '0';
          state_next   <= test_loop_i;
        else
          t_ready_next <= '1';
        end if;

      when test_loop_i =>

        i_next <= i_reg + 1;
        j_next <= n_reg - i_reg;
        k_next <= i_reg;

        if i_reg <= n_reg then
          state_next <= test_loop_j;
        else
          t_ready_next <= '1';
          state_next   <= idle;
        end if;

      when test_loop_j =>
    
        j_next <= j_reg - 1;

        if j_reg > 0 then
          state_next <= write_space;
        else
          state_next <= test_loop_k;
        end if;

      when write_space =>

        t_result_next <= "00100000"; -- space
        t_ready_next  <= '1';
        state_next    <= wait_space;

      when wait_space =>
        
        if t_valid = '1' then
          t_ready_next <= '0';
          state_next   <= test_loop_j;
        else
          t_ready_next <= '1';
        end if;

      when test_loop_k =>

        k_next <= k_reg - 1;
        
        if k_reg > 0 then
          state_next <= write_sharp;
        else
          t_result_next <= "00001010"; -- \n
          state_next    <= test_loop_i;
        end if;

      when write_sharp =>

        t_result_next <= "00100011"; -- #
        t_ready_next  <= '1';
        state_next    <= wait_sharp;

      when wait_sharp =>

        if t_valid = '1' then
          t_ready_next <= '0';
          state_next   <= test_loop_k;
        else
          t_ready_next <= '1';
        end if;

    end case;

  end process COMBINATIONAL;

  TICK: process(clk, rst)
  begin

    if rising_edge(clk) then
      if rst = '1' then
      
        state_reg <= idle;

        t_ready_reg  <= '1';
        t_result_reg <= (others => '0');
        n_reg        <= (others => '0');
        i_reg        <= (others => '0');
        j_reg        <= (others => '0');
        k_reg        <= (others => '0');

      else
      
        state_reg <= state_next;

        t_ready_reg  <= t_ready_next;
        t_result_reg <= t_result_next;
        n_reg        <= n_next;
        i_reg        <= i_next;
        j_reg        <= j_next;
        k_reg        <= k_next;

      end if;
    
    end if;

  end process TICK;

  t_ready  <= t_ready_reg;
  t_result <= t_result_reg;

end architecture staircase_rtl;