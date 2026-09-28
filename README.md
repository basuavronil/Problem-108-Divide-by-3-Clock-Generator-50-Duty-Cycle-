# Odd Clock Divider with 50% Duty Cycle

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![Duty Cycle](https://img.shields.io/badge/Duty%20Cycle-50%25-brightgreen)
![Divide By](https://img.shields.io/badge/Divide%20By-Odd%20N-orange)

## Table of Contents
- [Overview](#overview)
- [Method 1: Negedge D-FF + AND/OR Gate](#method-1-negedge-d-ff--andor-gate)
- [Method 2: Posedge Circuit AND Negedge Circuit](#method-2-posedge-circuit-and-negedge-circuit)
- [Summary Comparison](#summary-comparison)

---

## Overview

When dividing a clock by an **odd integer** ($N = 3, 5, 7, \dots$), a standard single-edge counter cannot inherently produce a 50% duty cycle, because $N$ cannot be evenly split into whole clock cycles.

To get a 50% duty cycle ($N/2$ cycles HIGH, $N/2$ cycles LOW), the output must be shifted by **half a clock cycle**, which needs the **negative edge** of the clock. There are two ways to do this:

1. Sample the output of a flip-flop with a **negedge D flip-flop**, then combine both signals with an **AND / OR gate**.
2. Build the **same circuit on posedge and on negedge**, then **AND** their outputs.

---

## Method 1: Negedge D-FF + AND/OR Gate

Take the output of any flip-flop (`pos_out`, generated on `posedge clk`), pass it through a **D flip-flop clocked on `negedge clk`** to get `neg_out` (shifted by $0.5\,T_{clk}$), and manipulate the two signals with an AND or OR gate to get the final output.

### Steps
1. **Posedge FF / counter:** generate `pos_out` on `posedge clk`.
2. **Negedge D-FF:** sample `pos_out` on `negedge clk` to get `neg_out` (delayed by 0.5 cycles).
3. **Combine `pos_out` and `neg_out`** with a gate. The gate depends on how wide `pos_out` was made:

| Case | `pos_out` HIGH width | Gate | Effect | Final HIGH width |
| :--- | :--- | :--- | :--- | :--- |
| Under-extended | $\frac{N-1}{2}$ cycles | **OR** | adds $+0.5$ cycles | $\frac{N-1}{2} + 0.5 = \frac{N}{2}$ |
| Over-extended | $\frac{N+1}{2}$ cycles | **AND** | trims $-0.5$ cycles | $\frac{N+1}{2} - 0.5 = \frac{N}{2}$ |

$$
\text{clk\_out} = \text{pos\_out} \;\text{OR}\; \text{neg\_out} \qquad \text{or} \qquad \text{clk\_out} = \text{pos\_out} \;\text{AND}\; \text{neg\_out}
$$

### Example ($N = 3$, AND version)
- `pos_out` is HIGH from $t = 0.0$ to $t = 2.0$.
- `neg_out` is HIGH from $t = 0.5$ to $t = 2.5$.
- Overlap = $2.0 - 0.5 = 1.5$ cycles HIGH out of 3.0, giving a **50% duty cycle**.

---

## Method 2: Posedge Circuit AND Negedge Circuit

Instead of adding a single D-FF, build the **same divider circuit twice**: one triggered on `posedge clk` and one on `negedge clk`. Then **AND** the two outputs.

### Steps
1. **Posedge circuit:** generates `pos_out` on `posedge clk`, HIGH for $\frac{N+1}{2}$ cycles.
2. **Negedge circuit:** the identical circuit on `negedge clk` generates `neg_out`, which is `pos_out` shifted by $0.5$ cycles.
3. **AND the outputs:**

$$
\text{clk\_out} = \text{pos\_out} \;\text{AND}\; \text{neg\_out}
$$

### Mathematical Proof (for $N = 3$)
- `pos_out` is HIGH from $t = 0.0$ to $t = 2.0$ (2.0 cycles).
- `neg_out` is HIGH from $t = 0.5$ to $t = 2.5$ (2.0 cycles, shifted by $+0.5$).
- Their overlap is active from $t = 0.5$ to $t = 2.0$:

$$
\text{HIGH Time} = 2.0 - 0.5 = \mathbf{1.5 \text{ cycles}}
$$

$$
\text{Total Period} = \mathbf{3.0 \text{ cycles}}
$$

$$
\text{Duty Cycle} = \frac{1.5}{3.0} \times 100\% = \mathbf{50\%}
$$

---

## Summary Comparison

| Parameter | Method 1: Negedge D-FF + AND/OR | Method 2: Posedge AND Negedge circuit |
| :--- | :--- | :--- |
| **Source of shifted signal** | Negedge D-FF sampling an existing FF output | Duplicate of the same circuit on `negedge clk` |
| **Combining gate** | **AND** or **OR** | **AND** |
| **Extra hardware** | One D-FF (+ gate) | A full second copy of the circuit (+ gate) |
| **Shift** | $+0.5$ cycles | $+0.5$ cycles |
| **Final Duty Cycle** | **50%** ($N/2$ cycles) | **50%** ($N/2$ cycles) |
