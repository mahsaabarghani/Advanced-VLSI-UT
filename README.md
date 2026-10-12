# Advanced VLSI - Cadence Virtuoso Coursework

This repository contains the Cadence Virtuoso design files and report for the first computer assignment of the Advanced VLSI course. The work covers transistor-level gate design, symbol creation, transient simulation, 4-bit adder architectures, power and delay comparison, XOR layout, physical verification, parasitic extraction, and post-layout simulation.

The repository is organized so that later coursework can be added without changing the structure of the existing assignment. Each future assignment can be added as a new top-level directory such as `CA2/`, together with its report and a short entry in the **Future coursework** section below.

## Course and technology

- Course: Advanced VLSI
- Assignment: Computer Assignment 1
- Design environment: Cadence Virtuoso
- Technology library: TSMC 0.18 um (`TSMC18rf`)
- Supply voltage: `VDD = 1.8 V`
- Transistor models: 2 V NMOS and 2 V PMOS
- Default transistor length: `L = 180 nm`
- Physical verification: Calibre with the required `1fF` rule/setup file

## Assignment scope

### 1. Basic logic gates

The following gates are designed at transistor level:

- Inverter (`INV`)
- AND (`AND`)
- NAND (`NAND`)
- XOR (`XOR`)
- 2:1 multiplexer (`MUX` and supporting multiplexer cells)

For every gate, the assignment requires a schematic, a reusable symbol, and a transient test. The symbol interface uses input ports for logic inputs, output ports for logic outputs, and input-output ports for `VDD` and `GND`.

The transistor dimensions specified by the assignment are:

| Gate | PMOS width | NMOS width | Channel length |
|---|---:|---:|---:|
| Inverter | 2 um | 1 um | 180 nm |
| AND | 2 um | 2 um | 180 nm |
| NAND | 2 um | 2 um | 180 nm |
| XOR | 4 um | 2 um | 180 nm |
| 2:1 MUX | 4 um | 2 um | 180 nm |

The gate testbench is provided in `CA1_Q1_test`. Pulse voltage sources are used to exercise the truth tables. The inverter can be instantiated wherever a complementary control signal is required, for example in the XOR and MUX designs.

### 2. 4-bit adder architectures

Three 4-bit adder structures are included for functional, delay, and power comparison:

1. A ripple-carry adder whose full adders are built from NAND gates.
2. A ripple-carry adder whose full adders are built from XOR-based logic.
3. A Manchester carry-chain adder using dynamic precharge and pass-transistor structures.

The corresponding project cells include:

- `FULLadderWITHnand` and `4_bitRIPPLE_NAND`
- `FAWITHXOR` and `4bitRIPPLE_XOR`
- `Manchester`

The full-adder symbols expose `A`, `B`, and `Cin` as inputs and `Sum` and `Cout` as outputs. The final 4-bit adder symbols also expose the carry generated at every stage so that `C0`, `C1`, `C2`, and `C3` can be observed during simulation.

#### Manchester carry-chain notes

The Manchester design follows the assignment's precharge/evaluate behavior:

- `P_i = A_i XOR B_i` is the propagate signal.
- `G_i = A_i AND B_i` is the generate signal.
- Each sum bit is obtained by XORing `P_i` with the carry from the previous stage.
- The clock-like signal `phi` precharges the dynamic nodes. It is held low during the first `1 ns` and then asserted for evaluation.
- Delay measurements for this structure must subtract the `1 ns` precharge interval from the measured crossing time.

### 3. Simulation and comparison

The adder test structures are represented by `Q2_TEST`, `Q2TEST2`, and `Q2TEST3`. The required simulation time is `8 ns`. The assignment specifies the following input cases:

| Case | A | B | Cin |
|---:|---:|---:|---:|
| 1 | `1111` | `0000` | `1` |
| 2 | `0111` | `0000` | `1` |
| 3 | `0111` | `0001` | `0` |

For each architecture, the report should show the carry and sum waveforms, identify the maximum propagation delay for carry and sum, and compare the results in a single table. Delay is measured using the crossing of half the supply voltage, `VDD/2`.

Power is measured with a separate supply source for each adder. The average supply current is obtained from the transient simulation and converted to power using:

```text
P_avg = VDD x I_avg
```

where `VDD = 1.8 V`. The measured values depend on the selected test case and simulation setup, so the test conditions must be reported with the final comparison table.

### 4. XOR layout and post-layout verification

The transistor-level XOR cell is laid out in the `XOR` cell hierarchy. The physical-design part includes:

1. Layout creation from the XOR schematic.
2. Design Rule Check (DRC).
3. Layout Versus Schematic (LVS).
4. Parasitic Extraction (PEX).
5. Post-layout transient simulation.

The assignment requires the `1fF` setup/rule file for this part. The extracted parasitic resistors and capacitors should be documented in the report. The post-layout waveform is compared with the ideal schematic simulation, and differences are explained using routing resistance and parasitic capacitance.

The `XOR` hierarchy contains the main physical-design data:

```text
XOR/
├── schematic/
├── symbol/
├── layout/
├── calibre/
└── constraint/
```

The post-layout test configurations are stored in `XORTEST`, `XOR_T`, and `XOR_TEST`.

## Repository layout

```text
.
├── CA1/
│   ├── INV/                   # Inverter schematic and symbol
│   ├── AND/                   # AND gate schematic and symbol
│   ├── NAND/                  # NAND gate schematic and symbol
│   ├── XOR/                   # XOR schematic, symbol, layout, and verification data
│   ├── MUX/                   # 2:1 multiplexer design
│   ├── MUX2/                  # Supporting multiplexer cell
│   ├── CA1_Q1_test/           # Basic-gate test structure
│   ├── FULLadderWITHnand/     # NAND-based one-bit full adder
│   ├── 4_bitRIPPLE_NAND/      # NAND-based 4-bit ripple-carry adder
│   ├── FAWITHXOR/              # XOR-based one-bit full adder
│   ├── 4bitRIPPLE_XOR/         # XOR-based 4-bit ripple-carry adder
│   ├── Manchester/            # Manchester carry-chain adder
│   ├── Q2_TEST/               # Adder test structure
│   ├── Q2TEST2/               # Adder test variant
│   ├── Q2TEST3/               # Adder test variant
│   ├── XORTEST/               # XOR post-layout test configuration
│   ├── XOR_T/                 # XOR test configuration variant
│   └── XOR_TEST/              # XOR post-layout test schematic/configuration
│   └── CA1_Report.pdf             # Anonymized PDF report
└── README.md
```

The Cadence lock files (`*.cdslck*`) are intentionally excluded from this clean copy because they are temporary session files and can contain machine-specific state. Cadence can recreate them when the library is opened.

## Opening the design in Cadence

The files are Cadence OpenAccess library data rather than a standalone Python or SPICE project. To use them:

1. Install or configure Cadence Virtuoso with access to the `TSMC18rf` 0.18 um technology library.
2. Place the `CA1` directory in the intended Cadence working/library location.
3. Open the cells listed in the repository layout.
4. Check that the technology library, model files, supply voltage, and simulation environment point to the local installation.
5. For physical verification, configure Calibre with the required `1fF` rule/setup files.

Cadence and Calibre configuration paths are installation-specific and are not embedded in this repository. A clean checkout may therefore require reconnecting the technology and model libraries before simulation.

## Report checklist

The report should contain the following evidence for a complete submission:

- Schematic and symbol for every basic gate.
- Truth-table or transient verification of every basic gate.
- Schematic and symbol for each full-adder implementation.
- 4-bit adder schematics and symbols.
- Carry and sum waveforms for all three adder architectures.
- Explanation of the observed adder behavior for the required input cases.
- Maximum carry and sum propagation delays.
- Average power measurement for each adder.
- A final comparison table for delay and power.
- XOR layout image.
- Successful DRC and LVS results.
- PEX results, including extracted parasitic elements.
- Post-layout versus schematic simulation comparison.
- Explicit assumptions, simulation time, input timing, supply voltage, and technology information.

## Grading structure from the assignment

The attached assignment distributes 150 points as follows:

| Part | Points |
|---|---:|
| Basic-gate schematics | 10 |
| Basic-gate symbols | 5 |
| Basic-gate test and simulation | 15 |
| Adder schematics | 20 |
| Adder symbols | 6 |
| Adder test, simulation, and delay analysis | 49 |
| Power measurement | 15 |
| XOR layout | 5 |
| DRC, LVS, and PEX | 15 |
| Post-layout simulation | 10 |
| **Total** | **150** |

## Future coursework

Future assignments can be added using the following convention:

```text
.
├── CA1/
├── CA2/
├── CA3/
├── CA4/
└── README.md
```

For each new assignment, add a subsection with:

- Assignment title and objective.
- Technology and simulation assumptions.
- Main design blocks and cell names.
- Testbench names and input scenarios.
- Required measurements and verification results.
- A short repository-tree entry.
- A report checklist and known limitations.

### CA2 - To be added

This placeholder is reserved for the next Advanced VLSI computer assignment. It should be replaced with the official objective, design requirements, Cadence cells, simulation setup, physical-verification requirements, and report outputs when the next assignment is available.

## Privacy and clean-copy notes

This GitHub-ready copy removes the student number from the project paths, the editable report, and the PDF report cover. The original files supplied by the user remain unchanged. The personal name shown in the report was not removed because the requested cleanup specifically targeted the student number.

