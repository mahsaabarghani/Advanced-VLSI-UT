import random
import sys

# Enable Unicode output (so we can print Persian messages if needed)
sys.stdout.reconfigure(encoding='utf-8')

def generate_dvf(num_samples=1000, filename="DVF1.vec"):
    """
    Generates a DVF file containing test vectors for an 8-bit ripple-carry adder.
    The file includes random inputs and their corresponding outputs.
    """

    # Open the output file to start writing our test data
    with open(filename, 'w') as f:
        # --- Header section: Let's tell the simulator what the signals are ---
        f.write(";8-bit Adder: A[8:1] B[8:1] cin sum[8:1] cout \n")
        f.write("radix 44 44 1 44 1 \n")  # radix = base for each column
        f.write(";define name for each vector \n")
        f.write("vname A[8:1] B[8:1] Cin S[8:1] Cout \n")
        f.write(";define IO directions (I = input, O = output) \n")
        f.write("IO II II I OO O \n\n")

        # --- Waveform settings section: define how signals behave over time ---
        f.write(";waveform definitions for simulation timing \n")
        f.write("tunit ps \n")           # Time unit: picoseconds
        f.write("Period 5000 \n")        # Duration of each clock cycle
        f.write("tdelay 4900.0 00 00 0 FF 1\n")  # Signal propagation delays
        f.write("Slope 50 \n")           # Transition sharpness
        f.write("VOH '0.8*Vdd'\n")       # Logic high voltage
        f.write("VOL '0.2*Vdd'\n\n")     # Logic low voltage

        # --- Data section: here's where the actual test vectors go ---
        f.write("; now comes the actual input/output data \n")

        # Let's generate random test cases for our adder
        for _ in range(num_samples):
            a = random.randint(0, 255)   # Random 8-bit input for A
            b = random.randint(0, 255)   # Random 8-bit input for B
            cin = random.randint(0, 1)   # Random single-bit carry-in

            # Compute expected result
            total = a + b + cin
            sum_result = total & 0xFF    # Keep only the lowest 8 bits
            cout = 1 if total > 255 else 0  # Set carry-out if there's an overflow

            # Format everything nicely in hexadecimal and write to file
            f.write(f"{a:02x} {b:02x} {cin} {sum_result:02x} {cout}\n")

    # Done! Let’s confirm to the user
    print(f"{num_samples} test vectors successfully written to '{filename}'.")

# Run the generator with 1000 random test samples
generate_dvf(1000)
