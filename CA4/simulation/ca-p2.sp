
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
.SUBCKT NAND A B OUT VDD GND size=1
MP1 OUT A VDD VDD PMOS W='Wmin*size*2' L='Lmin'
MP2 OUT B VDD VDD PMOS W='Wmin*size*2' L='Lmin'
MN1 OUT A N1 GND NMOS W='Wmin*size*2' L='Lmin'
MN2 N1 B GND GND NMOS W='Wmin*size*2' L='Lmin'
.ENDS NAND

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

* D-Latch subcircuit
.subckt DLATCH D CLK Q Qbar
X1 D Dbar VDD GND INV size=1
X2 D CLK net1 VDD GND NAND size=1
X3 net1 Qbar Q VDD GND NAND size=1
X4 CLK Dbar net2 VDD GND NAND size=1
X5 net2 Q Qbar VDD GND NAND size=1
.ends DLATCH

* D Flip-Flop (Master-Slave) subcircuit
.subckt DFF D CLK Q Qbar
X1 CLK CLKbar VDD GND INV size=1
X2 D CLKbar masterQ masterQbar DLATCH
X3 masterQ CLK Q Qbar DLATCH
.ends DFF

* Computational circuit from Part 1
.subckt COMP_CIRCUIT A B C D FINAL_OUT
X1 A B NAND_OUT VDD GND NAND size= 20
X2 B C NOR_OUT VDD GND NOR size= 30
X3 NAND_OUT NOR_OUT XOR_OUT VDD GND XOR size= 10
X4 XOR_OUT D NAND2_OUT VDD GND NAND size= 25
X5 XOR_OUT NOT_OUT VDD GND INV size= 40
X6 NAND2_OUT NOT_OUT FINAL_OUT VDD GND NOR size= 30
* Output capacitance
C1 FINAL_OUT 0 100f
.ends COMP_CIRCUIT

* input description
VCLK CLK 0 PULSE(0 vdd 0n 0.1n 0.1n 2n 4n)
VDD VDD GND DC 1.8
VA A GND PULSE(0 1.8 0 10p 10p 0.2n 0.4n)
VB B GND DC 1.8
VC C GND DC 0
VD D GND DC 1.8

******main circuit for part 2*****

* Register-Computational-Register Pipeline
X_FF1_A A CLK A_reg A_regbar DFF
X_FF1_B B CLK B_reg B_regbar DFF
X_FF1_C C CLK C_reg C_regbar DFF
X_FF1_D D CLK D_reg D_regbar DFF

X_COMP A_reg B_reg C_reg D_reg comp_out COMP_CIRCUIT

X_FF2 comp_out CLK FINAL_OUT FINAL_OUTbar DFF

* Transient Analysis
.TRAN 1p 200n
.PROBE V(A) V(B) V(C) V(D) V(FINAL_OUT)

* Measurements for setup, hold and clock-to-Q times
.measure tran tsetup_A trig v(A) val='vdd/2' cross=1 targ v(CLK) val='vdd/2' rise=1
.measure tran thold_A trig v(CLK) val='vdd/2' rise=1 targ v(A) val='vdd/2' cross=1
.measure tran tCQ trig v(CLK) val='vdd/2' rise=1 targ v(A_reg) val='vdd/2' cross=1

* Measurements for worst-case delay

.measure tran tpd_fall_A trig v(A_reg) val='vdd/2' fall=1 targ v(comp_out) val='vdd/2' rise=1

.end
