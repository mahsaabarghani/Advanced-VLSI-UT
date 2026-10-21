* VLSI Advanced - Computer Assignment 4
* Part 3: Combinational Circuit and LATCH

.OPTIONS POST=2 PROBE
.GLOBAL VDD GND
.PARAM VDD=1.8

* Minimum transistor dimensions
.param Lmin=180n
.param Wmin=220n

* getting transistor model from library "mm0181"
.LIB 'mm018.l' TT
*.include 'mm018.l'

* Inverter subcircuit
.SUBCKT INV IN OUT VDD GND size=1
MP1 OUT IN VDD VDD PMOS W='Wmin*size*2' L='Lmin'
MN1 OUT IN GND GND NMOS W='Wmin*size' L= 'Lmin'
.ENDS INV

* NAND2 subcircuit
.SUBCKT NAND2 A B OUT VDD GND size=1
MP1 OUT A VDD VDD PMOS W='Wmin*size*2' L='Lmin'
MP2 OUT B VDD VDD PMOS W='Wmin*size*2' L='Lmin'
MN1 OUT A N1 GND NMOS W='Wmin*size*2' L='Lmin'
MN2 N1 B GND GND NMOS W='Wmin*size*2' L='Lmin'
.ENDS NAND2

*NOR2 subcircuit
.SUBCKT NOR A B OUT VDD GND size=1
MP1 N1 A VDD VDD PMOS W='Wmin*size*4' L='Lmin'
MP2 OUT B N1 VDD PMOS W='Wmin*size*4' L='Lmin'
MN1 OUT A GND GND NMOS W='Wmin*size' L='Lmin'
MN2 OUT B GND GND NMOS W='Wmin*size' L='Lmin'
.ENDS NOR

.SUBCKT XOR A B OUT VDD GND
Xinv1 A Abar VDD GND INV size=1
Xinv2 B Bbar VDD GND INV size=1
MP1 N1 A VDD VDD PMOS W='Wmin*size*4' L='Lmin'
MP2 OUT Bbar N1 VDD PMOS W='Wmin*size*4' L='Lmin'
MP3 N2 Abar VDD VDD PMOS W='Wmin*size*4' L='Lmin'
MP4 OUT B N2 VDD PMOS W='Wmin*size*4' L='Lmin'
MN1 OUT A N3 GND NMOS W='Wmin*size*2' L='Lmin'
MN2 N3 B GND GND NMOS W='Wmin*size*2' L='Lmin'
MN3 OUT Abar N4 GND NMOS W='Wmin*size*2' L='Lmin'
MN4 N4 Bbar GND GND NMOS W='Wmin*size*2' L='Lmin'
.ENDS XOR


* Negative D-Latch subcircuit
.subckt NEG_DLATCH D CLK Q Qbar
X_inv2 D Dbar VDD GND INV size=1
X_inv CLK CLKbar VDD GND INV size=1
X1 D CLKbar net1 VDD GND NAND2 size=1
X2 net1 Qbar Q VDD GND NAND2 size=1
X3 CLKbar Dbar net2 VDD GND NAND2 size=1
X4 net2 Q Qbar VDD GND NAND2 size=1
.ends NEG_DLATCH

* Positive D-Latch subcircuit
.subckt POS_DLATCH D CLK Q Qbar
X_inv2 D Dbar VDD GND INV size=1
X1 D CLK net1 VDD GND NAND2 size=1
X2 net1 Qbar Q VDD GND NAND2 size=1
X3 CLK Dbar net2 VDD GND NAND2 size=1
X4 net2 Q Qbar VDD GND NAND2 size=1
.ends POS_DLATCH

* Computational circuit from Part 1
.subckt COMP_CIRCUIT A B C D FINAL_OUT
X1 A B NAND_OUT VDD GND NAND2 size= 20
X2 B C NOR_OUT VDD GND NOR size= 30
X3 NAND_OUT NOR_OUT XOR_OUT VDD GND XOR size= 10
X4 XOR_OUT D NAND2_OUT VDD GND NAND2 size= 25
X5 XOR_OUT NOT_OUT VDD GND INV size= 40
X6 NAND2_OUT NOT_OUT FINAL_OUT VDD GND NOR size= 30
* Output capacitance
C1 FINAL_OUT 0 100f
.ends COMP_CIRCUIT

******main circuit for part 3*****

* LATCH-Computational Pipeline
X_L1_A A CLK A_latch A_latchbar POS_DLATCH
X_L2_B B CLK B_latch B_latchbar POS_DLATCH
X_L3_C C CLK C_latch C_latchbar POS_DLATCH
X_L4_D D CLK D_latch D_latchbar POS_DLATCH

X_COMP A_latch B_latch C_latch D_latch comp_out COMP_CIRCUIT

X_L5 comp_out CLK FINAL_OUT FINAL_OUTbar NEG_DLATCH

* Transient Analysis
.TRAN 1p 200n
.PROBE V(A) V(B) V(C) V(D) V(FINAL_OUT)

* input description
VCLK CLK 0 PULSE(0 vdd 0n 0.1n 0.1n 2n 4n)
VDD VDD GND DC 1.8
VA A GND PULSE(0 1.8 0 10p 10p 3n 6n)
VB B GND DC 1.8
VC C GND DC 0
VD D GND DC 1.8

* Transient Analysis
.TRAN 1p 200n
.PROBE V(A) V(B) V(C) V(D) V(FINAL_OUT)

* Measurements for setup, hold and clock-to-Q times
.measure tran tsetup_A trig v(A) val='vdd/2' cross=1 targ v(CLK) val='vdd/2' rise=1
.measure tran thold_A trig v(CLK) val='vdd/2' rise=1 targ v(A) val='vdd/2' cross=1
.measure tran tCQ trig v(CLK) val='vdd/2' rise=1 targ v(A_latch) val='vdd/2' cross=1

* Measurements for worst-case delay

.measure tran tpd_fall_A trig v(A_latch) val='vdd/2' fall=1 targ v(comp_out) val='vdd/2' rise=1
.end
