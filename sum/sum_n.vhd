library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sum_n is
  generic(
    SIZE : natural := 4
  );
  port(
    clk      : in std_logic;
    rst      : in std_logic;
    t_valid  : in std_logic;
    t_data   : in std_logic_vector(SIZE downto 0);
 
    t_ready  : out std_logic;
    t_result : out std_logic_vector(SIZE downto 0)
  );
end entity sum_n;

architecture sum_n_rtl of sum_n is

  type state_type is (idle, test_loop, getting, sum);

  signal state_reg, state_next: state_type;
  
  signal t_ready_reg, t_ready_next : std_logic;
  signal n_reg, n_next             : unsigned(t_data'range);
  signal aux_reg, aux_next         : unsigned(t_data'range);
  signal acc_reg, acc_next         : unsigned(t_data'range);

begin

  COMBINATIONAL: process(state_reg, t_valid, t_data, t_ready_reg, aux_reg, acc_reg)
  begin
    
    state_next <= state_reg;
    
    t_ready_next <= t_ready_reg;
    n_next       <= n_reg;
    aux_next     <= aux_reg;
    acc_next     <= acc_reg;
    
    case state_reg is
      when idle =>
        
        if t_valid = '1' then
          n_next       <= unsigned(t_data);
          acc_next     <= (others => '0');
          t_ready_next <= '0';
          state_next   <= test_loop;
        else
          t_ready_next <= '1';
        end if;
      
      when test_loop =>
        
        n_next       <= n_reg - 1;
        t_ready_next <= '1';
        
        if n_reg > 0 then
          state_next <= getting;
        else
          state_next <= idle;
        end if;

      when getting =>
      
        if t_valid = '1' then
          aux_next     <= unsigned(t_data);
          t_ready_next <= '0';
          state_next   <= sum;
        else
          t_ready_next <= '1';
        end if;
      
      when sum =>
        
        acc_next   <= acc_reg + aux_reg;
        state_next <= test_loop;
    
    end case;

  end process COMBINATIONAL;

  TICK: process(clk, rst)
  begin

    if rising_edge(clk) then
      if rst = '1' then

        state_reg <= idle;
        
        t_ready_reg <= '1';
        n_reg       <= (others => '0');
        aux_reg     <= (others => '0');
        acc_reg     <= (others => '0');

      else
        
        state_reg   <= state_next;
        
        t_ready_reg <= t_ready_next;
        n_reg       <= n_next;
        aux_reg     <= aux_next;
        acc_reg     <= acc_next;

      end if;
    end if;

  end process TICK;

  t_ready  <= t_ready_reg;
  t_result <= std_logic_vector(acc_reg);

end architecture sum_n_rtl;