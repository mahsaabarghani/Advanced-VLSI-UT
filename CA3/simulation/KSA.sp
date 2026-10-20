* 8-bit Kogge-Stone Adder Design

* === Simulation Parameters ===
.param dev=agauss(0, 0.1)
.param Vdd='1 + dev' 
.PARAM Lmin=180n
.PARAM Wmin=180n
 

* === Technology Library File ===
.lib 'crn90g_2d5_lk_v1d2p1.l' FS

* === Basic Logic Gates (Defined as Subcircuits) ===

* Simple inverter for NOT operation
.SUBCKT INV in out vdd gnd
M1 out in gnd gnd nch L=Lmin W=Wmin
M2 out in vdd vdd pch L=Lmin W='Wmin*2'
.ENDS INV

* Standard NAND gate (2-input)
.SUBCKT NAND2 inA inB out vdd gnd
M1 out inA vdd vdd pch L=Lmin W='Wmin*2'
M2 out inB vdd vdd pch L=Lmin W='Wmin*2'
M3 out inA net1 gnd nch L=Lmin W=Wmin
M4 net1 inB gnd gnd nch L=Lmin W=Wmin
.ENDS NAND2

* Standard NOR gate (2-input)
.SUBCKT NOR2 inA inB out vdd gnd
M1 out inA gnd gnd nch L=Lmin W=Wmin
M2 out inB gnd gnd nch L=Lmin W=Wmin
M3 out inA net1 vdd pch L=Lmin W='Wmin*2'
M4 net1 inB vdd vdd pch L=Lmin W='Wmin*2'
.ENDS NOR2

* AND gate constructed from NAND + inverter
.SUBCKT AND2 inA inB out vdd gnd
XU1 inA inB nand_out vdd gnd NAND2
XU2 nand_out out vdd gnd INV
.ENDS AND2

* OR gate built from NOR + inverter
.SUBCKT OR2 inA inB out vdd gnd
XU1 inA inB nor_out vdd gnd NOR2
XU2 nor_out out vdd gnd INV
.ENDS OR2

* 2-input XOR gate implemented using CMOS logic
.SUBCKT XOR2 A B out vdd gnd
Xinv1 A Abar vdd gnd INV
Xinv2 B Bbar vdd gnd INV
M1 net1 A Vdd Vdd pch L=Lmin W='2*Wmin'
M2 out Bbar net1 Vdd pch L=Lmin W='2*Wmin'
M3 net2 Abar Vdd Vdd pch L=Lmin W='2*Wmin'
M4 out B net2 Vdd pch L=Lmin W='2*Wmin'
M5 out A net3 gnd nch L=Lmin W=Wmin
M6 net3 B gnd gnd nch L=Lmin W=Wmin
M7 out Abar net4 gnd nch L=Lmin W=Wmin
M8 net4 Bbar gnd gnd nch L=Lmin W=Wmin
.ends XOR2

* Black Cell: Computes both group generate (G) and propagate (P)
.SUBCKT BLACK_CELL Gi_j Pi_j Gk_i_1 Pk_i_1 Gi_k Pi_k vdd gnd
* Output G = Gi_k + Pi_k.Gk_i_1
* Output P = Pi_k . Pk_i_1
XU1 Pi_k Gk_i_1 and_out vdd gnd AND2
XU2 Gi_k and_out Gi_j vdd gnd OR2
XU3 Pi_k Pk_i_1 Pi_j vdd gnd AND2
.ENDS BLACK_CELL

* Grey Cell: Only updates group generate (G) signal
.SUBCKT GREY_CELL Gi_j Gk_i_1 Pk_i Gi_k vdd gnd
* Output G = Gi_k + Pk_i.Gk_i_1
XU1 Pk_i Gk_i_1 and_out vdd gnd AND2
XU2 Gi_k and_out Gi_j vdd gnd OR2
.ENDS GREY_CELL

* Pre-Processing: Generates initial P and G signals from A, B
.SUBCKT PRE_PROCESS A B P G vdd gnd
XU1 A B P vdd gnd XOR2
XU2 A B G vdd gnd AND2
.ENDS PRE_PROCESS

* Sum Generator: Computes final sum from propagate and carry
.SUBCKT SUM_BLOCK P C S vdd gnd
XU1 P C S vdd gnd XOR2
.ENDS SUM_BLOCK

* === Top-Level: 8-bit Kogge-Stone Adder ===
.SUBCKT KSA8 A8 A7 A6 A5 A4 A3 A2 A1 B8 B7 B6 B5 B4 B3 B2 B1 Cin S8 S7 S6 S5 S4 S3 S2 S1 Cout vdd gnd

* Step 1: Pre-processing to generate P and G for each bit
XPP1 A1 B1 P1 G1 vdd gnd PRE_PROCESS
XPP2 A2 B2 P2 G2 vdd gnd PRE_PROCESS
XPP3 A3 B3 P3 G3 vdd gnd PRE_PROCESS
XPP4 A4 B4 P4 G4 vdd gnd PRE_PROCESS
XPP5 A5 B5 P5 G5 vdd gnd PRE_PROCESS
XPP6 A6 B6 P6 G6 vdd gnd PRE_PROCESS
XPP7 A7 B7 P7 G7 vdd gnd PRE_PROCESS
XPP8 A8 B8 P8 G8 vdd gnd PRE_PROCESS

* Handle carry-in: treat Cin as G0
* Pass Cin through first Grey Cell for position 1
XGC0 C1 Cin P1 G1 vdd gnd GREY_CELL

* Step 2: First stage of prefix tree (span 2)
XBC1_1 G2_1 P2_1 G1 P1 G2 P2 vdd gnd BLACK_CELL
XBC1_2 G3_2 P3_2 G2 P2 G3 P3 vdd gnd BLACK_CELL
XBC1_3 G4_3 P4_3 G3 P3 G4 P4 vdd gnd BLACK_CELL
XBC1_4 G5_4 P5_4 G4 P4 G5 P5 vdd gnd BLACK_CELL
XBC1_5 G6_5 P6_5 G5 P5 G6 P6 vdd gnd BLACK_CELL
XBC1_6 G7_6 P7_6 G6 P6 G7 P7 vdd gnd BLACK_CELL
XBC1_7 G8_7 P8_7 G7 P7 G8 P8 vdd gnd BLACK_CELL

* Step 3: Second stage (span 4)
* Intermediate carry calculations using Grey + Black cells
XGC2_1 C2 G1 P2_1 G2_1 vdd gnd GREY_CELL
XGC2_2 C3 G2_1 P3_2 G3_2 vdd gnd GREY_CELL
XBC2_3 G4_1 P4_1 G2_1 P2_1 G4_3 P4_3 vdd gnd BLACK_CELL
XBC2_4 G5_2 P5_2 G3_2 P3_2 G5_4 P5_4 vdd gnd BLACK_CELL
XBC2_5 G6_3 P6_3 G4_3 P4_3 G6_5 P6_5 vdd gnd BLACK_CELL
XBC2_6 G7_4 P7_4 G5_4 P5_4 G7_6 P7_6 vdd gnd BLACK_CELL
XBC2_7 G8_5 P8_5 G6_5 P6_5 G8_7 P8_7 vdd gnd BLACK_CELL

* Step 4: Third stage (span 8)
* Final carry computations before generating sum bits
XGC3_1 C4 G1 P4_1 G4_1 vdd gnd GREY_CELL
XGC3_2 C5 G2_1 P5_2 G5_2 vdd gnd GREY_CELL
XGC3_3 C6 G3_2 P6_3 G6_3 vdd gnd GREY_CELL
XGC3_4 C7 G4_1 P7_4 G7_4 vdd gnd GREY_CELL
XGC3_5 C8 G5_2 P8_5 G8_5 vdd gnd GREY_CELL

* Final carry-out of the adder (Cout = C8)
XGC_Cout Cout G5_2 P8_5 G8_5 vdd gnd GREY_CELL
* --- Final Sum Calculation Stage ---
* Each sum bit is computed as: S_i = P_i ⊕ C_(i-1)
XS1 P1 Cin S1 vdd gnd SUM_BLOCK
XS2 P2 C1  S2 vdd gnd SUM_BLOCK
XS3 P3 C2  S3 vdd gnd SUM_BLOCK
XS4 P4 C3  S4 vdd gnd SUM_BLOCK
XS5 P5 C4  S5 vdd gnd SUM_BLOCK
XS6 P6 C5  S6 vdd gnd SUM_BLOCK
XS7 P7 C6  S7 vdd gnd SUM_BLOCK
XS8 P8 C7  S8 vdd gnd SUM_BLOCK

.ENDS KSA8

* --- Simulation Setup Section ---
* Power supply definitions
Vdd  vdd  0 DC Vdd
Vgnd gnd  0 DC 0

* Load input vectors from external file
*.VEC 'DVF.vec'

* Instantiate the Kogge-Stone 8-bit adder
XKSA A8 A7 A6 A5 A4 A3 A2 A1 B8 B7 B6 B5 B4 B3 B2 B1 Cin S8 S7 S6 S5 S4 S3 S2 S1 Cout vdd gnd KSA8

* --- Optional: Manual stimulus for functional verification ---
* Uncomment below lines to apply custom fixed inputs
*VA1 A1 0 DC 1
*VA2 A2 0 DC 1
*VA3 A3 0 DC 1
*VA4 A4 0 DC 1
*VA5 A5 0 DC 1
*VA6 A6 0 DC 0
*VA7 A7 0 DC 1
*VA8 A8 0 DC 1

*VB1 B1 0 DC 1
*VB2 B2 0 DC 1
*VB3 B3 0 DC 0
*VB4 B4 0 DC 1
*VB5 B5 0 DC 0
*VB6 B6 0 DC 1
*VB7 B7 0 DC 0
*VB8 B8 0 DC 0

*VCin Cin 0 DC 0

* Input vector file
.VEC 'DVF.vec'

* Input DVF-tabular.vec file
*.VEC 'DVF-tabular.vec'

* --- Simulation Control ---
*.tran 10ps 200ns * ; Perform transient analysis over 50ns with 10ps step
.tran 1p 20n SWEEP MONTE=100 

*.temp 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90

* --- Performance Metrics ---
* Measure propagation delay from A8 to final carry-out
.MEASURE TRAN tpd_max_Cout TRIG V(A1) VAL='Vdd/2' RISE=1 TARG V(Cout) VAL='Vdd/2' RISE=1

* Measure propagation delay from A8 to final carry-out
.MEASURE TRAN tpd_max_S8 TRIG V(A1) VAL='Vdd/2' RISE=1 TARG V(S8) VAL='Vdd/2' RISE=1


* Measure average power consumption during the first 2ns
.MEASURE TRAN power_avg AVG P(Vdd) FROM=0ns TO=20ns

* Enable post-processing for waveform viewing
.option post=2

.END