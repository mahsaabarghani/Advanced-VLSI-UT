# -*- coding: utf-8 -*-
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def read_mt0(filepath):
    """
    این تابع یک فایل mt0 را می‌خواند و:
      - خط هدر (شامل 'tpd_max_cout') را پیدا می‌کند.
      - خط بعدیِ هدر (alter#) را رد می‌کند.
      - سطر بعدِ آن را که چهار عدد دارد (delay_cout, delay_s8, power_avg, temper) می‌خواند.
    خروجی: یک DataFrame تک‌ردیفی با ستون‌های ["delay", "dynamic_power", "temper_actual"].
    """
    data = []
    found_header = False

    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        for raw in f:
            line = raw.strip()
            # رد کردن خطوط خالی یا متادیتا
            if not line or line.startswith("$") or line.startswith("."):
                continue

            # پیدا کردن هدر (خطی که شامل tpd_max_cout باشد)
            if not found_header and "tpd_max_cout" in line:
                found_header = True
                continue

            # رد کردن خط 'alter#' بعد از هدر
            if found_header and line.startswith("alter#"):
                continue

            # خواندن اولین سطر داده‌ای که دست‌کم 4 عدد دارد
            if found_header:
                parts = line.split()
                if len(parts) >= 4:
                    try:
                        delay_cout    = float(parts[0])  # tpd_max_cout
                        # delay_s8 = float(parts[1])    # tpd_max_s8  (می‌توان نادیده گرفت)
                        dynamic_power = float(parts[2])  # power_avg
                        temper_actual = float(parts[3])  # دمای واقعیِ شبیه‌سازی
                    except ValueError:
                        # اگر نتوان تبدیل کرد، صرفا ادامه بده
                        continue

                    data.append((delay_cout, dynamic_power, temper_actual))
                    break  # چون فقط یک سطر داده در هر mt0 داریم

    if not data:
        raise ValueError(f"در فایل '{filepath}' دادهٔ معتبری پیدا نشد یا هدر اشتباه است.")

    df = pd.DataFrame(data, columns=["delay", "dynamic_power", "temper_actual"])
    return df


if __name__ == "__main__":
    # لیست 16 دمای شبیه‌سازی‌شده (ایندکس 0→15°C، 1→20°C، …، 15→90°C)
    temps = [15, 20, 25, 30, 35, 40, 45, 50,
             55, 60, 65, 70, 75, 80, 85, 90]

    # آرایه‌هایی برای ذخیرهٔ مقادیر Delay و Power در نرخ هر دما
    delays = []
    powers = []

    # ۱۶ فایل mt0 را بخوانیم و Delay/Power را استخراج کنیم
    for idx, T in enumerate(temps):
        filename = f"KSA.mt{idx}"
        if not os.path.isfile(filename):
            raise FileNotFoundError(f"فایل mt0 برای دمای {T}°C پیدا نشد: {filename}")

        df = read_mt0(filename)

        # اعتبارسنجی دما (اختیاری)
        temper_val = df["temper_actual"].iloc[0]
        if abs(temper_val - T) > 1e-3:
            print(f"WARNING: دمای داخل فایل ({temper_val}) با دمای لیست ({T}) فرق دارد.")

        # چون یک ردیف داده وجود دارد، مستقیماً آن را append می‌کنیم
        delays.append(df["delay"].iloc[0])
        powers.append(df["dynamic_power"].iloc[0])

    # تبدیل لیست‌ها به آرایهٔ NumPy
    temps_array = np.array(temps)
    delays_arr  = np.array(delays)
    powers_arr  = np.array(powers)

    # --------------------------------------------------------
    # نمودار ۱: تاخیر (Delay) برحسب دما
    # --------------------------------------------------------
    plt.figure(figsize=(6,4))
    plt.plot(
        temps_array,
        delays_arr,
        marker='o',
        linestyle='-',
        color='tab:green',
        label="Delay vs Temp"
    )
    plt.title("Delay vs. Temperature")
    plt.xlabel("Temperature (°C)")
    plt.ylabel("Delay (s)")      # اگر واحد تأخیر ps است، بنویسید "Delay (ps)"
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.legend()
    plt.tight_layout()
    # اگر می‌خواهید ذخیره کنید:
    # plt.savefig("delay_vs_temp.png", dpi=150, bbox_inches='tight')
    plt.show()

    # --------------------------------------------------------
    # نمودار ۲: توان دینامیک (Dynamic Power) برحسب دما
    # --------------------------------------------------------
    plt.figure(figsize=(6,4))
    plt.plot(
        temps_array,
        powers_arr,
        marker='s',
        linestyle='-',
        color='tab:orange',
        label="Power vs Temp"
    )
    plt.title("Dynamic Power vs. Temperature")
    plt.xlabel("Temperature (°C)")
    plt.ylabel("Dynamic Power (W)")
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.legend()
    plt.tight_layout()
    # اگر می‌خواهید ذخیره کنید:
    # plt.savefig("power_vs_temp.png", dpi=150, bbox_inches='tight')
    plt.show()

    print("نمودارهای Delay vs Temp و Power vs Temp با موفقیت رسم شدند.")
