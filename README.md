\# INT8 Matrix Multiplication Accelerator



A 4×4 systolic-array-based INT8 matrix multiplication accelerator designed using Verilog HDL for the Intel Cyclone IV E FPGA (DE0-Nano).



\## Architecture



\- 4×4 systolic array with 16 Processing Elements (PEs).

\- Signed INT8 multiplication.

\- INT32 accumulation.

\- BRAM-based input and output matrix storage.

\- FSM-based computation controller.

\- Automated result writeback.



\## Hardware Design



| Component | Implementation |

|---|---|

| HDL | Verilog |

| FPGA | Intel Cyclone IV E (EP4CE22F17C6) |

| Board | DE0-Nano |

| Simulation | Icarus Verilog |

| Synthesis | Quartus Prime Lite 18.1 |

| Array | 4×4 |

| Input precision | Signed INT8 |

| Accumulator | Signed INT32 |

| Clock constraint | 50 MHz |



\## Verification



Verified using self-checking Verilog testbenches.



\- Signed multiplier and MAC operations.

\- Processing element functionality.

\- Systolic array computation.

\- Positive, negative and boundary-value inputs.

\- BRAM read/write operations.

\- Controller FSM and matrix loading.

\- C memory writeback.

\- Complete top-level integration.



\*\*At least 181 explicitly counted simulation checks passed.\*\*



\## FPGA Implementation Results



| Resource | Usage |

|---|---:|

| Logic Elements | 1,558 / 22,320 (7%) |

| Registers | 931 / 23,018 (4%) |

| M9K Memory Blocks | 2 / 66 |

| Embedded Multipliers | 16 / 132 |



Quartus compilation and programming-file generation completed successfully. Physical DE0-Nano board validation remains pending.



\## Project Structure



```text

INT8\_Accelerator/

├── rtl/

│   ├── arithmetic/

│   ├── control/

│   ├── memory/

│   └── systolic/

├── testbench/

├── INT8\_Accelerator.qpf

├── INT8\_Accelerator.qsf

├── INT8\_Accelerator.sdc

└── README.md

```



\## Simulation



Install Icarus Verilog and run the testbenches using:



```cmd

iverilog -g2012 -o simulation/test.vvp <source\_files> <testbench\_file>

vvp simulation/test.vvp

```



Refer to the project documentation PDFs for detailed architecture, implementation and verification information.



\## Objective



To explore FPGA-based parallel computing through systolic architecture, signed fixed-point arithmetic, memory interfacing, control logic and hardware acceleration.



\*\*Designed and implemented from scratch using Verilog HDL.\*\*

