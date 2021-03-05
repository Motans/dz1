library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dc_remove is
  generic(
    dig_size : integer := 16
  );
  port(
    clk         : in std_logic;
    Rs          : in std_logic;
    filter_in   : in std_logic_vector(dig_size-1 downto 0);
    alpha       : in std_logic_vector(dig_size-1 downto 0);
    filter_out  : out std_logic_vector(dig_size-1 downto 0)
  );
end dc_remove;


architecture dc_remove_arch of dc_remove is
  begin
    process(clk, Rs)
        variable buf        : signed(dig_size-1 downto 0) := to_signed(0, dig_size);
        variable x_i        : signed(dig_size-1 downto 0) := to_signed(0, dig_size);
        variable y_i        : signed(dig_size-1 downto 0) := to_signed(0, dig_size);
        variable mult_res   : signed(2*dig_size-1 downto 0) := to_signed(0, 2*dig_size);
      begin
        if (Rs = '1') then
            buf := to_signed(0, dig_size);
            x_i := to_signed(0, dig_size);
        elsif (clk'event and clk = '1') then
            x_i := signed(filter_in);
            y_i := x_i + buf;
            mult_res := shift_left(signed(alpha)*y_i, 1);
          
            buf := mult_res(2*dig_size - 1 downto dig_size) - x_i;
            filter_out <= std_logic_vector(y_i);
        end if;
    end process;
end dc_remove_arch;