library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CSR is
    generic (
        INTERRUPT_VECTOR : waddr   := w32_zero;
        mutant           : integer := 0
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Interface de et vers la PO
        cmd         : in  PO_cs_cmd;
        it          : out std_logic;
        pc          : in  w32;
        rs1         : in  w32;
        imm         : in  W32;
        csr         : out w32;
        mtvec       : out w32;
        mepc        : out w32;

        -- Interface de et vers les IP d'interruption
        irq         : in  std_logic;
        meip        : in  std_logic;
        mtip        : in  std_logic;
        mie         : out w32;
        mip         : out w32;
        mcause      : in  w32
    );
end entity;

architecture RTL of CPU_CSR is
    -- Fonction retournant la valeur à écrire dans un csr en fonction
    -- du « mode » d'écriture, qui dépend de l'instruction
    function CSR_write (CSR        : w32;
                         CSR_reg    : w32;
                         WRITE_mode : CSR_WRITE_mode_type)
        return w32 is
        variable res : w32;
    begin
        case WRITE_mode is
            when WRITE_mode_simple =>
                res := CSR;
            when WRITE_mode_set =>
                res := CSR_reg or CSR;
            when WRITE_mode_clear =>
                res := CSR_reg and (not CSR);
            when others => null;
        end case;
        return res;
    end CSR_write;
--a_supprimer_debut

    signal MCAUSE_d,  MCAUSE_q  : w32;
    signal MTVAL_d,   MTVAL_q   : w32;
    signal MIP_d,     MIP_q     : w32;
    signal MIE_d,     MIE_q     : w32;
    signal MSTATUS_d, MSTATUS_q : w32;
    signal MTVEC_d,   MTVEC_q   : w32;
    signal MEPC_d,    MEPC_q    : w32;
    signal To_CSR_value         : w32;
    signal CSR_value            : w32;
--a_supprimer_fin

begin
--a_supprimer_debut

    --
    -- Partie concernant les csr et les interruptions
    --

    -- TODO: Sortir l'interruption lorsqu'elle est autorisée
    -- FIXME: vérifier la différence entre MSTATUS_q(3) et mie !
    it <= (irq and MSTATUS_q(3));

    -- TODO: Sortir mtvec et mepc
    mtvec <= MTVEC_q;
    mepc  <= MEPC_q;

    -- TODO: Registres de contrôle et d'état
    csr_flip_flops : process(clk)
    begin
        if clk'event and clk='1' then
            if rst ='1' then
                MCAUSE_q  <= w32_zero;
                MTVAL_q   <= w32_zero;
                MIP_q     <= w32_zero;
                MIE_q     <= w32_zero;
                MSTATUS_q <= w32_zero;
                MTVEC_q   <= INTERRUPT_VECTOR;
                MEPC_q    <= w32_zero;
            else
                MCAUSE_q  <= MCAUSE_d;
                MTVAL_q   <= MTVAL_d;
                MIP_q     <= MIP_d;
                MIE_q     <= MIE_d;
                MSTATUS_q <= MSTATUS_d;
                MTVEC_q   <= MTVEC_d(31 downto 2) & "00";
                MEPC_q    <= MEPC_d(31 downto 2) & "00";
            end if;
        end if;
    end process csr_flip_flops;

    -- TODO: Calcul des entrées des registres de contrôle et d'état
    csr_input_selection : process(all)
    begin
        MCAUSE_d  <= MCAUSE_q;
        MTVAL_d   <= MTVAL_q;
        MIP_d     <= MIP_q;
        MIE_d     <= MIE_q;
        MSTATUS_d <= MSTATUS_q;
        MTVEC_d   <= MTVEC_q;
        MEPC_d    <= MEPC_q;

        if cmd.CSR_we = CSR_MCAUSE then
            MCAUSE_d <= CSR_write(To_CSR_value, MCAUSE_q, cmd.CSR_WRITE_mode);
        end if;

        if cmd.CSR_we = CSR_MTVAL then
            MTVAL_d <= CSR_write(To_CSR_value, MTVAL_q, cmd.CSR_WRITE_mode);
        end if;

        if cmd.CSR_we = CSR_MIE then
            MIE_d <= CSR_write(To_CSR_value, MIE_q, cmd.CSR_WRITE_mode);
        end if;

        if cmd.CSR_we = CSR_MSTATUS then
            MSTATUS_d <= CSR_write(To_CSR_value, MSTATUS_q, cmd.CSR_WRITE_mode);
        end if;

        if cmd.CSR_we = CSR_MTVEC then
            MTVEC_d <= CSR_write(To_CSR_value, MTVEC_q, cmd.CSR_WRITE_mode);
        end if;

        if cmd.MSTATUS_mie_set = '1' then
            MSTATUS_d(3) <= '0';
        end if;

        if cmd.MSTATUS_mie_reset = '1' then
            MSTATUS_d(3) <= '1';
        end if;

        if cmd.CSR_we = CSR_MEPC then
            case cmd.MEPC_sel is
                when MEPC_from_csr =>
                    MEPC_d <= CSR_write(To_CSR_value, MEPC_q, cmd.CSR_WRITE_mode);
                when MEPC_from_PC =>
                    MEPC_d <= pc;
                when others => null;
            end case;
        end if;

        MIP_d(11) <= meip;
        MIP_d(7)  <= mtip;

        mie <= MIE_q;
        mip <= MIP_q;

        if irq = '1' then
            MCAUSE_d <= mcause;
        end if;
    end process csr_input_selection;

    -- TODO: Sélection de l'origine de CSR, si c'est un registre ou un immédiat
    To_CSR_value <= rs1 when cmd.To_CSR_sel = To_CSR_from_rs1 else
                    imm when cmd.To_CSR_sel = To_CSR_from_imm else
                    (others => 'U');

    -- Sélection du registre CSR désiré afin de le mettre dans le banc de registre
    csr <= MCAUSE_q  when cmd.CSR_sel = CSR_from_mcause  else
           MTVAL_q   when cmd.CSR_sel = CSR_from_mtval   else
           MIP_q     when cmd.CSR_sel = CSR_from_mip     else
           MIE_q     when cmd.CSR_sel = CSR_from_mie     else
           MSTATUS_q when cmd.CSR_sel = CSR_from_mstatus else
           MTVEC_q   when cmd.CSR_sel = CSR_from_mtvec   else
           MEPC_q    when cmd.CSR_sel = CSR_from_mepc    else
           (others => 'U');
--a_supprimer_fin
end architecture;