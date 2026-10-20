# -*- coding: utf-8 -*-
import sys
import os
import pandas as pd
import matplotlib.pyplot as plt

# ---------------------------------------------------
# اگر بخواهید پیام‌های یونیکد (مثلاً فارسی) در کنسول چاپ شود،
# از خط زیر استفاده کنید (Python 3.7+):
# sys.stdout.reconfigure(encoding='utf-8')
# ---------------------------------------------------

def read_mc0(filepath):
    """
    Read a MonteCarlo output file (mc0) with a header like:
        index vdd:@:dev:@:IGNC
    and parse only the 'index' and 'dev' columns into a DataFrame,
    then compute Vdd_actual = 1.0 + dev.
    """
    colnames = None
    data = []

    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        # Step 1: Find the header line starting with "index "
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            if line.startswith("index "):
                # Example header: "index vdd:@:dev:@:IGNC"
                parts = line.split(None, 1)   # ['index', 'vdd:@:dev:@:IGNC']
                rest = parts[1]               # "vdd:@:dev:@:IGNC"
                extra_cols = rest.split(":@:")  # ['vdd', 'dev', 'IGNC']
                colnames = ["index"] + extra_cols
                break

        if colnames is None:
            raise ValueError("Header line (e.g. 'index vdd:@:dev:@:IGNC') not found in file.")

        # Step 2: Read data lines until a blank line or a line starting with '$' or '.'
        for raw in f:
            line = raw.strip()
            if not line:
                # Reached a blank line → data block is over
                break

            if line.startswith("$") or line.startswith("."):
                # Entered another section (footer or different block) → stop
                break

            parts = line.split()
            if len(parts) < 2:
                continue

            try:
                idx = int(parts[0])
                dev = float(parts[1])
            except ValueError:
                # If conversion fails, skip this line
                continue

            data.append((idx, dev))

    # Convert the collected list of tuples into a DataFrame
    df = pd.DataFrame(data, columns=["index", "dev"])
    # Compute actual Vdd = nominal + dev (assuming nominal = 1.0 V)
    nominal_vdd = 1.0
    df["Vdd_actual"] = nominal_vdd + df["dev"]
    return df


if __name__ == "__main__":
    # -----------------------
    # مسیر فایل mc0 را اینجا تنظیم کنید
    filepath = "KSA.mc0"
    # -----------------------

    if not os.path.isfile(filepath):
        print(f"ERROR: File not found: {filepath}")
        sys.exit(1)

    try:
        df_mc0 = read_mc0(filepath)

        # نمایش چند سطر اولِ DataFrame
        print("---- First 5 rows of the DataFrame ----")
        print(df_mc0.head(), "\n")

        # تعداد رکوردها
        print(f"Number of records read: {len(df_mc0)}\n")

        # آمار توصیفی ستون 'Vdd_actual'
        print("Statistics for 'Vdd_actual':")
        print(df_mc0["Vdd_actual"].describe(), "\n")

        # ===============================
        # بخش رسم نمودارها با matplotlib
        # ===============================

        # 1. Histogram از توزیع Vdd_actual
        plt.figure(figsize=(6,4))
        plt.hist(df_mc0["Vdd_actual"], bins=30, edgecolor='black')
        plt.title("Histogram of Vdd_actual")
        plt.xlabel("Vdd_actual [V]")
        plt.ylabel("Frequency")
        plt.grid(linestyle='--', alpha=0.4)
        # اگر بخواهید نمودار را ذخیره کنید، از این خط استفاده کنید:
        # plt.savefig("histogram_vdd.png", dpi=150, bbox_inches='tight')
        plt.show()

        # 2. Scatter plot: index vs Vdd_actual
        plt.figure(figsize=(6,4))
        plt.scatter(df_mc0["index"], df_mc0["Vdd_actual"], s=15, alpha=0.7)
        plt.title("Scatter: index vs Vdd_actual")
        plt.xlabel("index (sample number)")
        plt.ylabel("Vdd_actual [V]")
        plt.grid(linestyle='--', alpha=0.4)
        # plt.savefig("scatter_index_vdd.png", dpi=150, bbox_inches='tight')
        plt.show()

        # اگر متغیری دیگر (مثلاً delay یا dynamic_power) را به DataFrame اضافه کرده باشید
        # (در اینجا فرض نمی‌کنیم فایل mc0 آن را دارد)، می‌توانید به همین شکل:
        #
        # plt.figure(figsize=(6,4))
        # plt.scatter(df_mc0["Vdd_actual"], df_mc0["delay"], s=15, alpha=0.7)
        # plt.title("Delay vs Vdd_actual")
        # plt.xlabel("Vdd_actual [V]")
        # plt.ylabel("Delay [unit]")
        # plt.grid(linestyle='--', alpha=0.4)
        # plt.show()
        #
        # یا برای توان دینامیک:
        #
        # plt.figure(figsize=(6,4))
        # plt.plot(df_mc0["Vdd_actual"], df_mc0["dynamic_power"], 'o-', markersize=4, alpha=0.8)
        # plt.title("Dynamic Power vs Vdd_actual")
        # plt.xlabel("Vdd_actual [V]")
        # plt.ylabel("Dynamic Power [unit]")
        # plt.grid(linestyle='--', alpha=0.4)
        # plt.show()

    except Exception as e:
        print("ERROR occurred:", e)
        sys.exit(1)
