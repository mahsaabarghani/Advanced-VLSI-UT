* VLSI Advanced - Computer Assignment 4
* Part 1: Combinational Circuit

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

* Main circuit
X1 A B NAND_OUT VDD GND NAND size= 20
X2 B C NOR_OUT VDD GND NOR size= 30
X3 NAND_OUT NOR_OUT XOR_OUT VDD GND XOR size= 10
X4 XOR_OUT D NAND2_OUT VDD GND NAND size= 25
X5 XOR_OUT NOT_OUT VDD GND INV size= 40
X6 NAND2_OUT NOT_OUT FINAL_OUT VDD GND NOR size= 30
* Output capacitance
C1 FINAL_OUT 0 100f

* input description
VDD VDD GND DC 1.8
VA A GND PULSE(0 1.8 0 10p 10p 25n 50n)
VB B GND DC 1.8
VC C GND DC 0
VD D GND DC 1.8

* Transient Analysis
.TRAN 1p 200n
.PROBE V(A) V(B) V(C) V(D) V(FINAL_OUT)

* Measurements for worst-case delay

.measure tran tpd_fall_A trig v(A) val='vdd/2' fall=1 targ v(FINAL_OUT) val='vdd/2' rise=1
.measure tran tpd_rise_A trig v(A) val='vdd/2' rise=1 targ v(FINAL_OUT) val='vdd/2' fall=1


.print tran v(A) v(B) v(C) v(D) v(FINAL_OUT)
.end
