library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        ina         : in w32;
        inb         : in w32;
        f           : in  std_logic; -- IR[14]
        r           : in  std_logic; -- IR[13]
        e           : in  std_logic; -- IR[12]
        d           : in  std_logic; -- IR[6]
        s           : out std_logic;
        j           : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
    signal sign_enable: std_logic;
    signal ir14: std_logic;
    signal ir13: std_logic;
    signal ir12: std_logic;
    signal ir6: std_logic;

    signal exA: unsigned(32 downto 0);
    signal exB: unsigned(32 downto 0);
    signal subs: unsigned(32 downto 0);

    signal is_zero: STD_LOGIC;
    signal is_lt: STD_LOGIC;
begin
    ir14 <= f;
    ir13 <= r;
    ir12 <= e;
    ir6 <= d;

    sign_enable <= ((not ir6) and (not ir12)) or ((not ir13) and ir6);

    -- add a bit to substraction to guarantee no overflow
    exA <= (ina(31) and sign_enable) & ina;
    exB <= (inb(31) and sign_enable) & inb;
    subs <= exA - exB;

    -- calculate (A == B) and (A < B)
    is_zero <= '1' when (subs = (32 downto 0 => '0')) else '0';
    is_lt <= subs(32);

    s <= is_lt;
    j <= ((ir12 xor is_zero) and (not ir14)) or ((ir12 xor is_lt) and ir14);
end architecture;
