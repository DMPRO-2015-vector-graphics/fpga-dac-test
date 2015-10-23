library ieee; 

use ieee.std_logic_1164.all;

entity piso is

generic ( n : integer := 24);

port( ext_clk: in std_logic; 
      reset: in std_logic; 
      enable: in std_logic; --enables shifting 
      fb_mem_addr: out std_logic_vector(15 downto 0);
      fb_mem_data: in std_logic_vector(15 downto 0); 
      dac0_data: out std_logic; --serial output
      sync: out std_logic := '1';
      dac_clk: out std_logic;
		leds: out std_logic_vector(3 downto 0)
);
end piso;

architecture behavioral of piso is
signal temp_reg: std_logic_vector(n-1 downto 0) := (others => '0');
TYPE POSSIBLE_STATES IS (waiting, shifting);
signal state : POSSIBLE_STATES;
begin

dac_clk <=  ext_clk;
fb_mem_addr <= x"ffff";
leds(0) <= enable;
leds(2) <= '0';
leds(3) <= '1';

process(ext_clk,reset)
    variable shift_counter: integer := 0;
begin
   
    if(reset = '1') then
        temp_reg <= (others => '0');   
        state <= waiting;
        shift_counter := 0;
        sync <= '1';
    elsif(rising_edge(ext_clk)) then
        case state is
            when waiting =>
                shift_counter := 0;
                temp_reg <= "00000000" & fb_mem_data;
                dac0_data <= '0';
					 sync <= '1';
                if(enable = '1') then
                    state <= shifting;
                else
                    state <= waiting;
						  
                end if;
            when shifting =>
                shift_counter := shift_counter + 1;
                dac0_data <= temp_reg(n-1);
                temp_reg <= temp_reg(n-2 downto 0) & '0';
                sync <= '0';
                if (shift_counter >= n or enable = '0') then
                    state <= waiting;
                else
                    state <= shifting;
                end if; 
				when others =>
					null;
        end case;
		  if(state = shifting) then
				leds(1) <= '1';
		  else
				leds(1) <= '0';
		  end if;
    end if;
end process;

end behavioral;
