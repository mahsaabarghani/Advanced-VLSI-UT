import random
import sys

# Enable Unicode output (so we can print Persian messages if needed)
sys.stdout.reconfigure(encoding='utf-8')
def generate_dvf(num_samples=1000, filename="DVF.vec"):
    """
    Generates a DVF (Digital Vector File) for testing an 8-bit ripple-carry adder.
    The file includes random input vectors and their corresponding expected outputs.
    """
    import random

    # Open the output file for writing
    with open(filename, 'w') as f:
        # Section 1: Vector definition (names, radix, I/O direction)
        f.write("; 8-bit Ripple-Carry Adder: A[8:1] B[8:1] cin sum[8:1] cout\n")
        f.write("radix 44 44 1 44 1\n")  # Number base: hex for A, B, sum; binary for cin, cout
        f.write("; define names for each signal vector\n")
        f.write("vname A[8:1] B[8:1] cin S[8:1] cout\n")
        f.write("; define I/O direction (I = input, O = output)\n")
        f.write("IO II II I OO O\n\n")

        # Section 2: Waveform characteristics for simulation
        f.write("; waveform configuration\n")
        f.write("tunit ps\n")             # Time unit: picoseconds
        f.write("Period 5000\n")          # Period of each vector (5ns)
        f.write("tdelay 4900.0 00 00 0 FF 1\n")  # Delay before each signal is applied
        f.write("Slope 50\n")             # Slope (edge transition time)
        f.write("VOH '0.8*Vdd'\n")        # Logic High Voltage
        f.write("VOL '0.2*Vdd'\n\n")      # Logic Low Voltage

        # Section 3: Tabular data of input vectors and expected outputs
        f.write("; tabular input/output vectors\n")

        for _ in range(num_samples):
            a = random.randint(0, 255)    # Random 8-bit value for input A
            b = random.randint(0, 255)    # Random 8-bit value for input B
            cin = random.randint(0, 1)    # Random single-bit carry-in

            total = a + b + cin
            sum_result = total & 0xFF     # Keep only the lower 8 bits for the sum
            cout = 1 if total > 255 else 0  # Generate carry-out if overflow occurs

            # Write data as formatted hexadecimal and binary values
            f.write(f"{a:02x} {b:02x} {cin} {sum_result:02x} {cout}\n")

    print(f"DVF file with {num_samples} test cases successfully created as '{filename}'.")
generate_dvf(1000)
