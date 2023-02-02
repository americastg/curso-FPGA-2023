library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
 
entity miniMaxSum is
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
end entity miniMaxSum;

architecture miniMaxSum_rtl of miniMaxSum  is

  type state_t is (idle, valid_n, get_head, test_loop, get_body, compare, wait_max, wait_min);

  signal state_reg, state_next : state_t;

  signal t_ready_reg, t_ready_next   : std_logic;
  signal n_reg, n_next               : unsigned(t_data'range);
  signal acc_reg, acc_next           : unsigned(t_data'range);
  signal aux_reg, aux_next           : unsigned(t_data'range);
  signal max_reg, max_next           : unsigned(t_data'range);
  signal min_reg, min_next           : unsigned(t_data'range);
  signal t_result_reg, t_result_next : unsigned(t_data'range);
  
  begin
  
    COMBINATIONAL: process(state_reg, t_valid, t_data, t_ready_reg, n_reg, acc_reg, aux_reg,  max_reg, min_reg, t_result_reg)
    begin
      
      state_next <= state_reg;
      
      t_ready_next  <= t_ready_reg;
      n_next        <= n_reg;
      acc_next      <= acc_reg;
      aux_next      <= aux_reg;
      max_next      <= max_reg;
      min_next      <= min_reg;     
      t_result_next <= t_result_reg;
      
      case state_reg is
        when idle =>
          
          if t_valid = '1' and t_ready_reg = '1' then
            n_next       <= unsigned(t_data);
            t_ready_next <= '0';
            state_next   <= valid_n;
          else
            t_ready_next <= '1';
          end if;
        
        when valid_n =>
          t_ready_next <= '1';

          if n_reg > 0 then
            state_next <= get_head;
          else
            state_next <= idle;
          end if;

        when get_head =>
          
          if t_valid = '1' and t_ready_reg = '1' then
            acc_next     <= unsigned(t_data);
            max_next     <= unsigned(t_data);
            min_next     <= unsigned(t_data);
            t_ready_next <= '0';
            state_next   <= test_loop;
          else
            t_ready_next <= '1';
          end if;

        when test_loop =>
          
          n_next       <= n_reg - 1;
          t_ready_next <= '1';
          
          if n_reg > 1 then
            state_next <= get_body;
          else
            t_result_next <= acc_reg - min_reg;
            state_next    <= wait_max;
          end if;

        when get_body =>

          if t_valid = '1' and t_ready_reg = '1' then
            acc_next     <= acc_reg + unsigned(t_data);
            aux_next     <= unsigned(t_data);
            t_ready_next <= '0';
            state_next   <= compare;
          else
            t_ready_next <= '1';
          end if;

        when compare =>
          
          if max_reg < aux_reg then
            max_next <= aux_reg;
          end if;

          if min_reg > aux_reg then
            min_next <= aux_reg;
          end if;

          state_next <= test_loop;
  
        when wait_max =>
          t_ready_next <= '1';  

          if t_valid = '1' and t_ready_reg = '1' then
            t_result_next <= acc_reg - max_reg;
            state_next    <= wait_min;
          end if;
  
        when wait_min =>
          t_ready_next <= '1';  

          if t_valid = '1' and t_ready_reg = '1' then
            state_next <= idle;
          end if;
      
      end case;

    end process COMBINATIONAL;

    TICK: process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
              
              state_reg    <= idle;
              t_ready_reg  <= '1';
              n_reg        <= (others => '0');
              acc_reg      <= (others => '0');
              aux_reg      <= (others => '0');
              max_reg      <= (others => '0');
              min_reg      <= (others => '0');
              t_result_reg <= (others => '0');

            else
              
              state_reg    <= state_next;
              t_ready_reg  <= t_ready_next;
              n_reg        <= n_next;
              acc_reg      <= acc_next;
              aux_reg      <= aux_next;
              max_reg      <= max_next;
              min_reg      <= min_next;
              t_result_reg <= t_result_next;

            end if;
        end if;
    end process TICK;
  

    t_ready  <= t_ready_reg;
    t_result <= std_logic_vector(t_result_reg);
 
end architecture miniMaxSum_rtl;