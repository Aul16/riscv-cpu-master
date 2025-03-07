
number of cycles per instruction, counted from S_Decode until
whenever S_Decode is called next


+------------------+--------------+---------------------------------------------+
| Imm Arithmetic   | 3 cycles     | Decode, ArithI, Fetch                       |
+------------------+--------------+---------------------------------------------+
| Arithmetic       | 3 cycles     | Decode, Arith, Fetch                        |
+------------------+--------------+---------------------------------------------+
| LUI              | 3 cycles     | Decode, Lui, Fetch                          |
+------------------+--------------+---------------------------------------------+
| AUIPC            | 4 cycles     | Decode, Auipc, Prefetch, Fetch              |
+------------------+--------------+---------------------------------------------+
| BXX / JALR       | 4 cycles     | Decode, Jump, Prefetch, Fetch               |
+------------------+--------------+---------------------------------------------+
| JAL              | 3 cycles     | Decode, Prefetch, Fetch                     |
+------------------+--------------+---------------------------------------------+
| Loads            | 5 cycles     | Decode, Setup, Read, Write, Fetch           |
+------------------+--------------+---------------------------------------------+
| Stores           | 5 cycles     | Decode, Setup+Prefetch, Write+Fetch (3)     |
+------------------+--------------+---------------------------------------------+

