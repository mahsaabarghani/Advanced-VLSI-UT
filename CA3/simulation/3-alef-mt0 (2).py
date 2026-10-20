import matplotlib.pyplot as plt
import numpy as np

# مسیر فایل خروجی mc0 از شبیه‌سازی مونت‌کارلو
filename = "KSA.mt0"  

# خواندن فایل و استخراج خطوط مفید
with open(filename, 'r') as f:
    lines = f.readlines()

# استخراج ولتاژ و توان از هر خط (بر اساس فرض ساختار فایل mc0)
voltages = []
delays = []
powers = []

for line in lines:
    parts = line.strip().split()
    if len(parts) >= 3:
        try:
            vdd = float(parts[0])      # مثلاً مقدار Vdd
            delay = float(parts[1])    # مثلاً تأخیر
            power = float(parts[2])    # مثلاً توان
            voltages.append(vdd)
            delays.append(delay)
            powers.append(power)
        except ValueError:
            continue  # نادیده گرفتن خطوطی که عددی نیستند

# تبدیل به آرایه‌های عددی
voltages = np.array(voltages)
delays = np.array(delays)
powers = np.array(powers)

# نمودار توان برحسب ولتاژ
plt.figure()
plt.scatter(voltages, powers, color='blue', alpha=0.6, label="Power vs Vdd")
plt.xlabel("Vdd (V)")
plt.ylabel("Dynamic Power (W)")
plt.title("Power vs. Vdd")
plt.grid(True)
plt.legend()
plt.show()

# هیستوگرام تأخیر
plt.figure()
plt.hist(delays, bins=30, color='green', alpha=0.7)
plt.xlabel("Delay (s)")
plt.ylabel("Frequency")
plt.title("Histogram of Delay")
plt.grid(True)
plt.show()

# هیستوگرام توان
plt.figure()
plt.hist(powers, bins=30, color='orange', alpha=0.7)
plt.xlabel("Power (W)")
plt.ylabel("Frequency")
plt.title("Histogram of Power")
plt.grid(True)
plt.show()
