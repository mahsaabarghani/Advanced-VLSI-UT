# Advanced VLSI - Cadence Virtuoso and HSPICE Coursework

This repository contains deliverables for the first four computer assignments of the Advanced VLSI course. Student numbers are removed from the included reports; personal names are retained. CA1 covers Cadence Virtuoso transistor-level logic gates, 4-bit adders, XOR layout, physical verification, parasitic extraction, and post-layout simulation. CA2 studies logical-effort sizing and delay in a combinational CMOS network using HSPICE and a 32 nm bulk CMOS model. CA3 compares 8-bit ripple-carry and Kogge–Stone adders, including process-corner, supply-voltage variation, and temperature analyses. CA4 studies a combinational CMOS block in register and latch pipelines, including setup/hold timing and time borrowing.

Each assignment is kept in its own top-level directory with its report and design data: `CA1/` for the Virtuoso work, `CA2/` for the 32 nm HSPICE work, `CA3/` for the adder study, and `CA4/` for the register/latch timing study.

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
├── CA3/
│   ├── CA3_Report.pdf            # CA3 report with student number removed
│   └── simulation/
│       ├── CRA.sp                # 8-bit ripple-carry adder deck
│       ├── KSA.sp                # 8-bit Kogge–Stone adder deck
│       ├── crn90g_2d5_lk_v1d2p1.l # Supplied 90 nm model library
│       ├── DVF*.vec              # Random and tabular input vectors
│       ├── *.py                  # Vector-generation and result-analysis scripts
│       └── KSA.*, CRA.*          # HSPICE logs, checks, and measurement outputs
├── CA4/
│   ├── CA4_Report.pdf            # CA4 report with student number removed
│   ├── CA4_Report.docx           # Editable report with student number redacted
│   └── simulation/
│       ├── ca-p1.sp              # Combinational circuit
│       ├── ca-p2.sp              # Master-slave DFF pipeline
│       ├── ca-p3.sp              # Positive/negative latch pipeline
│       ├── mm018.l               # Supplied 180 nm model library
│       └── ca-p*.* # HSPICE logs and saved results
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


## CA3 - 8-bit adder architecture and variation analysis

The third computer assignment implements an 8-bit ripple-carry adder (RCA/CPA) and an 8-bit Kogge–Stone adder (KSA) in HSPICE. It compares delay and power, verifies the adders with digital vectors, and examines process corners, supply-voltage variation, and temperature.

### Technology and simulation setup

- Technology model: the supplied 90 nm CMOS library, `crn90g_2d5_lk_v1d2p1.l`.
- The included RCA deck selects the `TT` corner; the included KSA deck selects `FS` for its Monte Carlo run. Corner results for `SS`, `FF`, `FS`, and `SF` are discussed in the report.
- Nominal supply in the decks: `1.0 V`; minimum channel length and width parameters are set to `180 nm`.
- Input transition slope in the DVF files: `50 ps`.
- The supplied vector files use a `1.1 ns` period and provide 1,000 input/expected-output rows for each adder.

### Assignment scope

1. Build modular 8-bit ripple-carry and Kogge–Stone adders with `Cin`, eight sum outputs, and `Cout`.
2. Generate digital-vector files and check the simulated sum and carry against expected results. Demonstrate how a deliberately changed vector is reported by HSPICE.
3. Measure critical-path delay, average dynamic power with switching vectors, and static power with a long vector period.
4. Compare the Kogge–Stone adder at the `SS`, `FF`, `FS`, and `SF` process corners.
5. Run 100 Monte Carlo samples with `dev=agauss(0,0.1)` and `Vdd='1+dev'`; analyze voltage variation and the `.mc0`/`.mt0` measurements. Study temperature from `15 °C` to `90 °C` in `5 °C` increments.

### Included CA3 files

- `CA3/CA3_Report.pdf`: report copy with the student number removed from the cover.
- `CA3/simulation/CRA.sp` and `KSA.sp`: RCA and KSA HSPICE decks.
- `CA3/simulation/crn90g_2d5_lk_v1d2p1.l`: technology library referenced by both decks.
- `CA3/simulation/DVF.vec`, `DVF1.vec`, and `DVF-tabular.vec`: randomized and fixed test vectors.
- `CA3/simulation/*.py`: vector-generation and Monte Carlo/temperature result-analysis scripts.
- `CA3/simulation/CRA.*` and `KSA.*`: supplied HSPICE logs, `.err0` vector-check reports, Monte Carlo data, and temperature measurements (`KSA.mt0` through `KSA.mt15`).

Run the decks from `CA3/simulation/` so the relative model and vector-file paths resolve. Use HSPICE to run the decks; Python post-processing scripts require their usual scientific packages (for example, NumPy, pandas, and Matplotlib). Keep a backup of the supplied vectors before running a generator, since the generators write to `DVF.vec` or `DVF1.vec` in the current directory.

### Verification notes and limits of the supplied run

The supplied simulation outputs are included as evidence and diagnostics; they should not be read as a clean functional pass. Both `.err0` files contain output mismatches. The RCA deck simulates for `1100 ns`, while the KSA deck simulates for only `20 ns`, so the KSA run does not exercise the complete 1,000-row, `1.1 ns` vector set. The KSA deck also measures `S8` from an `A1` trigger that occurs after the reported target crossing; its saved `tpd_max_s8` values are negative. Its saved `power_avg` values are also negative; confirm the measurement sign convention before reporting power consumption.

Review the KSA carry-in path before relying on its functional or timing results: the netlist injects `Cin` into the first gray cell, but later carry cells use group-generate terms instead of propagating `Cin` through the prefix equations. Also check the temperature output mapping: `KSA.mt0` contains 100 Monte Carlo records at `25 °C`, while the included temperature-analysis script treats `mt0` as the `15 °C` result; the temperature output labels therefore need validation before plotting or quoting a 15–90 °C trend. The included generator scripts specify a `5 ns` vector period, which differs from the `1.1 ns` period in the supplied vector files.

Before presenting final comparisons, correct these setup/measurement issues and rerun functional vector checking, timing, power, corner, Monte Carlo, and temperature analyses. The included report describes the intended analysis flow and submitted results; the repository README records the mismatches and configuration differences visible in the supplied decks and outputs.


## CA4 - Register and latch timing in 180 nm CMOS

The fourth computer assignment uses HSPICE to study a sized combinational block, then places that logic between master-slave D flip-flops and transparent latches. It compares timing limits, sampling behavior, and time borrowing across pipeline structures.

### Technology and simulation setup

- Technology library: `CA4/simulation/mm018.l`, using the `TT` corner in the included decks.
- Supply voltage: `VDD = 1.8 V`.
- Minimum transistor dimensions: `Lmin = 180 nm` and `Wmin = 220 nm`.
- Clock duty cycle: 50%; the assignment assumes sequential inputs are specified before the rising clock edge.
- Output load on the combinational block: `100 fF`.

### Assignment scope

1. Build the specified combinational network from reusable gate subcircuits. Scale the gates according to the sizes shown in the handout, and identify the worst-case input sequence and propagation delay.
2. Build a master-slave DFF from two D latches. Place the combinational network between input and output registers, measure setup, hold, clock-to-Q, and combinational delay, and compare simulation-based and theoretical clock limits. Demonstrate incorrect sampling above the working frequency.
3. Build positive and negative latches and use them around the combinational network to study time borrowing. Split the logic into two blocks and compare the three-latch partition variants from the handout.

### Included CA4 files

- `CA4/CA4_Report.pdf`: report copy with the student number removed from its cover.
- `CA4/CA4_Report.docx`: editable report with the student number replaced by a redaction mask; personal metadata is scrubbed.
- `CA4/simulation/ca-p1.sp`, `ca-p2.sp`, and `ca-p3.sp`: the supplied combinational, DFF-pipeline, and positive/negative latch-pipeline decks.
- `CA4/simulation/mm018.l`: the model library included with the assignment and referenced by the decks.
- `CA4/simulation/ca-p*.lis`, `.mt0`, `.tr0`, `.st0`, `.ic0`, and `.pa0`: supplied HSPICE logs, measurements, waveforms, and analysis data.

Run each deck from `CA4/simulation/` so the relative `mm018.l` include resolves. The output files are from the supplied runs; no new HSPICE runs were generated for this package.

### Verification notes and limits of the supplied run

The first deck reports `tpd_fall_A ≈ 322.03 ps` and `tpd_rise_A ≈ 258.15 ps` for its saved stimulus. The DFF deck reports `tsetup_A = 45 ps`, `thold_A = -45 ps`, and `tCQ ≈ 222.07 ps`, but its `.mt0` and `.lis` show that `tpd_fall_A` failed. The report nevertheless uses an approximately `409 ps` combinational delay to calculate the DFF pipeline frequency; that value is present in the latch-pipeline run (`ca-p3.mt0`) as approximately `408.42 ps`. Treat the reported DFF frequency calculation as needing a reproducible delay measurement.

The saved hold-time measurement is negative because its trigger and target events are ordered such that the input crossing precedes the clock edge. It does not establish a positive hold-time requirement; sweep the input transition around the active edge to determine the valid hold boundary. The latch-pipeline run also reports `thold_A = -45 ps` and includes a duplicate `.TRAN` statement that HSPICE ignores.

The report discusses splitting the combinational block between three latches and comparing the partition variants shown in the handout, but the supplied archive contains only three decks (`ca-p1.sp` through `ca-p3.sp`). It does not include separate decks or saved output files for those three-latch partition variants. The included files therefore support the basic combinational, DFF, and two-latch pipeline runs; the full three-latch comparison cannot be reproduced from the supplied simulation files alone.

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

