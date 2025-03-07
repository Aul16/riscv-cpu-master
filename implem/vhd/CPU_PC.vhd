library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(mutant: integer := 0);
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    -- All states of the state machine
    type State_type is (
        S_Error,      S_Init,
        S_Pre_Fetch,  S_Fetch,
        S_Decode,     S_Bcond,
        S_LUI,        S_AUIPC,
        S_ArithI,     S_Arith,
        S_WriteSetup, S_WriteWrite,
        S_LoadSetup,  S_LoadRead, 
        S_Jalr,       S_LoadWrite,
        S_CSR
    );

    -- Used in the switch statement for Immediate Arithmetic 
    type ImmArithOp is (   IAO_ERR,
        IAO_add, IAO_slti, IAO_sltiu,
        IAO_and, IAO_or,   IAO_xor,
        IAO_sll, IAO_sra,  IAO_srl
    );

    -- Opcode defines for the case statement in the S_Decode state
    constant OPCODE_LUI :    unsigned(6 downto 0) := "0110111";
    constant OPCODE_ARITH_I: unsigned(6 downto 0) := "0010011";
    constant OPCODE_ARITH_R: unsigned(6 downto 0) := "0110011";
    constant OPCODE_AUIPC:   unsigned(6 downto 0) := "0010111";
    constant OPCODE_BRANCH:  unsigned(6 downto 0) := "1100011";
    constant OPCODE_LOAD:    unsigned(6 downto 0) := "0000011";
    constant OPCODE_STORE:   unsigned(6 downto 0) := "0100011";
    constant OPCODE_JAL:     unsigned(6 downto 0) := "1101111";
    constant OPCODE_JALR:    unsigned(6 downto 0) := "1100111";
    constant OPCODE_CSR:    unsigned(6 downto 0) := "1110011";

    -- LX modes (from funct3 bits)
    constant LSMODE_W:  UNSIGNED(2 downto 0) := "010";
    constant LSMODE_H:  UNSIGNED(2 downto 0) := "001";
    constant LSMODE_HU: UNSIGNED(2 downto 0) := "101";
    constant LSMODE_B:  UNSIGNED(2 downto 0) := "000";
    constant LSMODE_BU: UNSIGNED(2 downto 0) := "100";

    -- Useful subsections of the IR
    signal f7_bits : UNSIGNED(6 downto 0);
    signal f3_bits : UNSIGNED(2 downto 0);
    signal f10_bits : UNSIGNED(9 downto 0);

    -- Que faire lorsque l'IR n'est pas valide (S_Error / S_Init)
    constant ERROR_TARGET_STATE : State_type := S_Init; -- remplacer par S_Error

    -- Choose the correct operation for ArithI style operation
    -- returns IAO_ERR is the operation is invalid
    pure function getImmArithOp(f7: unsigned(6 downto 0); f3: UNSIGNED(2 downto 0)) return ImmArithOp is
        variable res : ImmArithOp;
        variable srx_op: ImmArithOp;
        variable slx_op: ImmArithOp;
    begin
        case f7 is
            when "0000000" =>
                slx_op := IAO_sll;
                srx_op := IAO_srl;
            when "0100000" =>
                slx_op := IAO_ERR;
                srx_op := IAO_sra;
            when others =>
                slx_op := IAO_ERR;
                srx_op := IAO_ERR;
        end case;
        with f3 select res := 
            IAO_add   when "000",
            slx_op    when "001",
            srx_op    when "101",
            IAO_or    when "110",
            IAO_and   when "111",
            IAO_xor   when "100",
            IAO_slti  when "010",
            IAO_sltiu when "011",
            IAO_ERR   when others;
        return res;
    end function;

    signal state_d, state_q : State_type;
begin
    f3_bits <= status.IR(14 downto 12);
    f7_bits <= status.IR(31 downto 25);
    f10_bits <= f7_bits & f3_bits;

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin
        -- Disable every write by default
        cmd.rst               <= '0';
        cmd.RF_we             <= '0';
        cmd.PC_we             <= '0';
        cmd.RF_SIGN_enable    <= '0';
        cmd.AD_we             <= '0';
        cmd.IR_we             <= '0';
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';
        cmd.cs.MSTATUS_mie_set   <= '0';
        cmd.cs.MSTATUS_mie_reset <= '0';
        cmd.cs.CSR_we            <= CSR_none;

        -- combinatorial controls, could have any default value
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_and;
        cmd.ALU_Y_sel         <= ALU_Y_immI;
        cmd.SHIFTER_op        <= SHIFT_rl;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.DATA_sel          <= DATA_from_pc;
        cmd.PC_sel            <= PC_from_pc;
        cmd.PC_X_sel          <= PC_X_cst_x00;
        cmd.PC_Y_sel          <= PC_Y_immU;
        cmd.TO_PC_Y_sel       <= TO_PC_Y_immB;
        cmd.AD_Y_sel          <= AD_Y_immS;
        cmd.ADDR_sel          <= ADDR_from_ad;

        cmd.cs.TO_CSR_sel        <= TO_CSR_from_imm;
        cmd.cs.CSR_sel           <= CSR_from_mstatus;
        cmd.cs.MEPC_sel          <= MEPC_from_csr;
        cmd.cs.CSR_WRITE_mode    <= WRITE_mode_simple;

        -- state register
        state_d <= state_q;

        case state_q is
            when S_Error =>
                state_d <= S_Error;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem_datain <- mem[PC]
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>
                -- PC <- PC + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';

                state_d <= ERROR_TARGET_STATE;

                case status.IR(6 downto 0) is
                    when OPCODE_LUI => 
                        state_d <= S_LUI;

                    when OPCODE_AUIPC =>
                        cmd.PC_we <= '0';
                        state_d <= S_AUIPC;

                    when OPCODE_ARITH_I =>
                        state_d <= S_ArithI;
                    when OPCODE_ARITH_R =>
                        state_d <= S_Arith;

                    when OPCODE_BRANCH =>
                        cmd.PC_we <= '0';
                        state_d <= S_Bcond;
                    when OPCODE_JALR =>
                        cmd.PC_we <= '0';
                        state_d <= S_Jalr;

                    -- JAL doesnt need $rs1 or $rs2 so we dont need to wait for
                    -- them to be updated and can gain a cycle
                    when OPCODE_JAL =>
                        cmd.PC_sel <= PC_from_pc;
                        cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                        cmd.PC_we <= '1';

                        cmd.PC_X_sel <= PC_X_pc;
                        cmd.PC_Y_sel <= PC_Y_cst_x04;
                        cmd.DATA_sel <= DATA_from_pc;
                        cmd.RF_we <= '1';

                        state_d <= S_Pre_Fetch;


                    when OPCODE_LOAD =>
                        state_d <= S_LoadSetup;
                    when OPCODE_STORE =>
                        state_d <= S_WriteSetup;
                    when OPCODE_CSR =>
                        state_d <= S_CSR;
                    when others =>
                        state_d <= ERROR_TARGET_STATE;
                end case;

                if status.it then
                    cmd.cs.CSR_we <= CSR_MEPC;
                    cmd.cs.MEPC_sel <= MEPC_from_PC;
                    cmd.cs.MSTATUS_mie_set <= '1';
                    cmd.PC_sel <= PC_mtvec;
                    state_d <= S_Pre_Fetch;
                end if;

            -----------------------------------------------------------
            ----| Instructions avec immediat de type U |---------------
            -----------------------------------------------------------

            when S_LUI => 
                -- write to target register
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.DATA_sel <= DATA_FROM_pc;
                cmd.RF_we <= '1';

                -- prefetch
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                cmd.ADDR_sel <= ADDR_from_pc;

                -- next state
                state_d <= S_Fetch;

            when S_AUIPC =>
                -- PC <- PC + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';

                -- write to target register
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.DATA_sel <= DATA_FROM_pc;
                cmd.RF_we <= '1';
                
                -- next state, extra prefetch cycle 
                state_d <= S_Pre_Fetch;


            -----------------------------------------------------------
            ---------| Instructions arithmétiques et logiques |--------
            -----------------------------------------------------------

            when S_ArithI =>
                -- prefetch
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                cmd.ADDR_sel <= ADDR_from_pc;

                -- next state
                state_d <= S_Fetch;

                -- arithmetic operation
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.RF_we <= '1';
                case getImmArithOp(f7_bits, f3_bits) is
                    when IAO_add =>
                        cmd.DATA_sel <= DATA_from_alu;
                        cmd.ALU_op <= ALU_plus;

                    when IAO_sra =>
                        cmd.DATA_sel <= DATA_from_shifter;
                        cmd.SHIFTER_op <= SHIFT_ra;
                    when IAO_srl => 
                        cmd.DATA_sel <= DATA_from_shifter;
                        cmd.SHIFTER_op <= SHIFT_rl;
                    when IAO_sll =>
                        cmd.DATA_sel <= DATA_from_shifter;
                        cmd.SHIFTER_op <= SHIFT_ll;

                    when IAO_or => 
                        cmd.DATA_sel <= DATA_from_logical;
                        cmd.LOGICAL_op <= LOGICAL_or;
                    when IAO_and => 
                        cmd.DATA_sel <= DATA_from_logical;
                        cmd.LOGICAL_op <= LOGICAL_and;
                    when IAO_xor => 
                        cmd.DATA_sel <= DATA_from_logical;
                        cmd.LOGICAL_op <= LOGICAL_xor;

                    when IAO_slti =>
                        cmd.DATA_sel <= DATA_from_slt;
                    when IAO_sltiu =>
                        cmd.DATA_sel <= DATA_from_slt;

                    when others =>
                        state_d <= ERROR_TARGET_STATE;
                end case;

            when S_Arith =>
                -- prefetch
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                cmd.ADDR_sel <= ADDR_from_pc;

                -- next state
                state_d <= S_Fetch;

                -- perform arithmetic
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.rf_we <= '1';
                case f10_bits is
                    when "0000000001" => 
                        cmd.DATA_sel <= DATA_from_shifter;
                        cmd.SHIFTER_op <= SHIFT_ll;
                    when "0000000101" => 
                        cmd.DATA_sel <= DATA_from_shifter;
                        cmd.SHIFTER_op <= SHIFT_rl;
                    when "0100000101" => 
                        cmd.DATA_sel <= DATA_from_shifter;
                        cmd.SHIFTER_op <= SHIFT_ra;

                    when "0000000000" => 
                        cmd.DATA_sel <= DATA_from_alu;
                        cmd.ALU_op <= ALU_plus;
                    when "0100000000" => 
                        cmd.DATA_sel <= DATA_from_alu;
                        cmd.ALU_op <= ALU_minus;

                    when "0000000110" =>
                        cmd.DATA_sel <= DATA_from_logical;
                        cmd.LOGICAL_op <= LOGICAL_or;
                    when "0000000111" =>
                        cmd.DATA_sel <= DATA_from_logical;
                        cmd.LOGICAL_op <= LOGICAL_and;
                    when "0000000100" =>
                        cmd.DATA_sel <= DATA_from_logical;
                        cmd.LOGICAL_op <= LOGICAL_xor;

                    
                    when "0000000010" =>
                        cmd.DATA_sel <= DATA_from_slt;
                    when "0000000011" =>
                        cmd.DATA_sel <= DATA_from_slt;

                    when others =>
                        state_d <= ERROR_TARGET_STATE;
                end case;


            -----------------------------------------------------------
            ---------| Jump instructions |-----------------------------
            -----------------------------------------------------------

            when S_Bcond =>
                -- use $rs2 for the CND
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

                -- set jump destination
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_from_pc;
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                if status.jcond then cmd.TO_PC_Y_sel <= TO_PC_Y_immB; end if;
                
                state_d <= S_Pre_Fetch;


            when S_Jalr =>
                -- PC <- $rs1 + ImmI
                cmd.PC_sel <= PC_from_alu;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.PC_we <= '1';

                -- $rd <- PC + 4
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';

                state_d <= S_Pre_Fetch;


            -----------------------------------------------------------
            ---------| Memory read instruction |-----------------------
            -----------------------------------------------------------

            when S_LoadSetup =>
                cmd.AD_we <= '1';
                cmd.AD_Y_sel <= AD_Y_immI;
                
                state_d <= S_LoadRead;

            when S_LoadRead =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIGN_enable <= '1';
                cmd.mem_ce <= '1';

                state_d <= S_LoadWrite;

            when S_LoadWrite =>
                -- do a register write
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;

                -- prefetch
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

                -- register write mode
                case f3_bits is
                    when LSMODE_W =>
                        cmd.RF_SIZE_sel <= RF_SIZE_word;
                        cmd.RF_SIGN_enable <= '0';
                    when LSMODE_H =>
                        cmd.RF_SIZE_sel <= RF_SIZE_half;
                        cmd.RF_SIGN_enable <= '1';
                    when LSMODE_HU =>
                        cmd.RF_SIZE_sel <= RF_SIZE_half;
                        cmd.RF_SIGN_enable <= '0';
                    when LSMODE_B =>
                        cmd.RF_SIZE_sel <= RF_SIZE_byte;
                        cmd.RF_SIGN_enable <= '1';
                    when LSMODE_BU =>
                        cmd.RF_SIZE_sel <= RF_SIZE_byte;
                        cmd.RF_SIGN_enable <= '0';
                    when others => 
                        state_d <= ERROR_TARGET_STATE;
                end case;


            -----------------------------------------------------------
            ---------| Memory store instructions |---------------------
            -----------------------------------------------------------

            when S_WriteSetup =>
                -- put write address in AD
                cmd.AD_we <= '1';
                cmd.AD_Y_sel <= AD_Y_immS;

                state_d <= S_WriteWrite;

            when S_WriteWrite =>
                --next state
                state_d <= S_Pre_Fetch;

                -- perform write
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                case f3_bits is
                    when LSMODE_W  =>
                        cmd.RF_SIZE_sel <= RF_SIZE_word;
                    when LSMODE_H =>
                        cmd.RF_SIZE_sel <= RF_SIZE_half;
                    when LSMODE_B =>
                        cmd.RF_SIZE_sel <= RF_SIZE_byte;
                    when others =>
                        state_d <= ERROR_TARGET_STATE;
                end case;

            ---------- Instructions d'accès aux CSR ----------

            when S_CSR =>

                case status.IR(31 downto 20) is
                    when x"304" => 
                        cmd.cs.CSR_we <= CSR_MIE;
                        cmd.cs.CSR_sel <= CSR_from_mie;
                    when x"300" => 
                        cmd.cs.CSR_we <= CSR_MSTATUS;
                        cmd.cs.CSR_sel <= CSR_from_mstatus;
                    when x"305" => 
                        cmd.cs.CSR_we <= CSR_MTVEC;
                        cmd.cs.CSR_sel <= CSR_from_mtvec;
                    when x"341" => 
                        cmd.cs.CSR_we <= CSR_MEPC;
                        cmd.cs.CSR_sel <= CSR_from_mepc;
                    when x"342" => 
                        -- cmd.cs.CSR_we <= CSR_MCAUSE;
                        cmd.cs.CSR_sel <= CSR_from_mcause;
                    when x"344" => 
                        -- cmd.cs.CSR_we <= CSR_MIP;
                        cmd.cs.CSR_sel <= CSR_from_mip;
                    when others => cmd.cs.CSR_we <= CSR_none;
                end case;

                if status.IR(14) = '1' then
                    cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;
                else
                    cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                end if;
                
                case f3_bits is
                    when "000" =>                       ----- MRET -----
                        cmd.cs.CSR_we <= CSR_none;
                        cmd.cs.MSTATUS_mie_reset <= '1';

                        cmd.PC_we <= '1';
                        cmd.PC_sel <= PC_from_mepc;
                    when "001" | "101" =>                       ----- RW -----
                        cmd.DATA_sel <= DATA_from_csr;
                        cmd.RF_we <= '1';
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                    when "010" | "110" =>                       ----- RS -----
                        cmd.DATA_sel <= DATA_from_csr;
                        cmd.RF_we <= '1';
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                    when "011" | "111" =>                       ----- RC -----
                        cmd.DATA_sel <= DATA_from_csr;
                        cmd.RF_we <= '1';
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                    when others =>
                        state_d <= ERROR_TARGET_STATE;
                end case;

                state_d <= S_Pre_Fetch;

            when others =>
                state_d <= ERROR_TARGET_STATE;
        end case;

    end process FSM_comb;

end architecture;
