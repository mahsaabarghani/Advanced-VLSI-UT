# Advanced VLSI - Cadence Virtuoso and HSPICE Coursework

This repository contains deliverables for the first and second computer assignments of the Advanced VLSI course. Student numbers are removed from the included reports; personal names are retained. CA1 covers Cadence Virtuoso transistor-level logic gates, 4-bit adders, XOR layout, physical verification, parasitic extraction, and post-layout simulation. CA2 studies logical-effort sizing and delay in a combinational CMOS network using HSPICE and a 32 nm bulk CMOS model.

Each assignment is kept in its own top-level directory with its report and design data: `CA1/` for the Virtuoso work and `CA2/` for the HSPICE work.

## Course and technology (CA1)

- Course: Advanced VLSI
- Assignment: Computer Assignment 1
- Design environment: Cadence Virtuoso
- Technology library: TSMC 0.18 um (`TSMC18rf`)
- Supply voltage: `VDD = 1.8 V`
- Transistor models: 2 V NMOS and 2 V PMOS
- Default transistor length: `L = 180 nm`
- Physical verification: Calibre with the required `1fF` rule/setup file

## CA1 assignment scope

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
├── CA1/                         # Cadence Virtuoso library and CA1 report
│   ├── INV/ ... XOR_TEST/       # Gate, adder, test, and layout cells
│   └── CA1_Report.pdf           # CA1 report with student number removed
├── CA2/
│   ├── CA2_Report.pdf           # CA2 report with student number removed
│   ├── models/
│   │   └── 32nm_bulk.pm         # Supplied 32 nm model source
│   └── simulation/
│       ├── CA2.sp               # HSPICE deck
│       ├── 32nm_bulk.pm.txt     # Model include used by the deck
│       ├── CA2.lis              # HSPICE log and measurements
│       └── CA2.*                # Transient and measurement output files
└── README.md
```

The Cadence lock files (`*.cdslck*`) are intentionally excluded from the CA1 clean copy because they are temporary session files and can contain machine-specific state. Cadence can recreate them when the library is opened.

## Opening the CA1 design in Cadence

The files are Cadence OpenAccess library data rather than a standalone Python or SPICE project. To use them:

1. Install or configure Cadence Virtuoso with access to the `TSMC18rf` 0.18 um technology library.
2. Place the `CA1` directory in the intended Cadence working/library location.
3. Open the cells listed in the repository layout.
4. Check that the technology library, model files, supply voltage, and simulation environment point to the local installation.
5. For physical verification, configure Calibre with the required `1fF` rule/setup files.

Cadence and Calibre configuration paths are installation-specific and are not embedded in this repository. A clean checkout may therefore require reconnecting the technology and model libraries before simulation.

## CA1 report checklist

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

## CA1 grading structure from the assignment

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

## CA2 - Gate sizing and delay in 32 nm CMOS

The second computer assignment studies how gate and transistor dimensions affect the delay of a simple combinational circuit. Its implementation uses HSPICE with the supplied 32 nm bulk CMOS transistor model.

### Technology and simulation conditions

- Supply voltage: `VDD = 1.8 V`.
- Minimum NMOS and PMOS dimensions: `Wmin = Lmin = 32 nm`.
- Reference inverter ratio: `W/L = 1` for NMOS and `W/L = 2` for PMOS.
- Input pulse rise and fall times: `0.01 ns` each.
- The submitted deck uses a `1 ps` transient step and a `2 ns` simulation interval.

### Circuit and analysis flow

The critical path runs from `A` through `NOR2`, `NOR3`, and `NAND2` gates to the inverter input `out`; the final inverter produces node `n`. Side branches produce the intermediate nodes `i`, `j`, and `k`. The output inverter is sized by a factor of 24 and drives a `72 fF` load in the submitted deck.

The assignment asks for these analyses:

1. Use logical effort to calculate gate effort, branching effort, electrical effort, stage effort, and path delay, then derive the sizing factors identified as `x` and `y` in the handout.
2. Define parameterized `inverter`, `nor2`, `nor3`, and `nand2` subcircuits. Size their pull-up and pull-down paths to approximate the reference inverter drive strength.
3. Simulate the circuit, inspect its intermediate and output waveforms, measure rise and fall times, and sweep the `NOR3` sizing parameter.
4. Add inverter stages, choose the stage count and gate sizes for minimum delay, and compare the measured result.

### Included CA2 files

- `CA2/CA2_Report.pdf`: assignment report with the student number removed from its cover.
- `CA2/models/32nm_bulk.pm`: supplied 32 nm model source.
- `CA2/simulation/CA2.sp`: parameterized HSPICE deck and measurement statements.
- `CA2/simulation/32nm_bulk.pm.txt`: model include referenced by the deck; keep it beside `CA2.sp` when rerunning.
- `CA2/simulation/CA2.lis` and the other `CA2.*` files: log, transient, and measurement outputs from the supplied run.

Run the deck from `CA2/simulation/` with HSPICE so its relative model include resolves correctly. Cadence Virtuoso cell views and physical-layout data are not part of the supplied CA2 archive.

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

## Privacy and clean-copy notes

Student-number identifiers have been removed from the included report filenames and report content. Personal names shown in the reports are retained. Original source files used to prepare this upload package remain unchanged.

