# Odd Clock Divider with 50% Duty Cycle

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![Duty Cycle](https://img.shields.io/badge/Duty%20Cycle-50%25-brightgreen)
![Divide By](https://img.shields.io/badge/Divide%20By-Odd%20N-orange)

## Table of Contents
- [Overview](#overview)
- [Method 1: OR Gate Approach](#method-1-dual-edge-signal-generation--or-gate)
- [Method 2: AND Gate Shortcut](#method-2-the-phase-shortcut-posedge--negedge-anding)
- [Summary Comparison](#summary-comparison)

---

## Overview

When dividing a clock by an **odd integer** ($N = 3, 5, 7, \dots$), a standard single-edge counter cannot inherently produce a 50% duty cycle, because $N$ cannot be evenly split into whole clock cycles.

To achieve a 50% duty cycle output ($N/2$ cycles HIGH, $N/2$ cycles LOW), two primary techniques exist:

1. Dual-edge signal generation combined with an **OR** gate
2. Over-extended pulse clipped with an **AND** gate (phase shortcut)

---

## Method 1: Dual-Edge Signal Generation + OR Gate

This method uses two identical logic paths running on opposite clock edges and combines them with a single logic gate.

### How It Works

1. **Posedge Generator:** Generate a signal `pos_out` on `posedge clk` that stays **HIGH for $\frac{N-1}{2}$ cycles** and **LOW for $\frac{N+1}{2}$ cycles**.
2. **Negedge D Flip-Flop:** Pass `pos_out` through a D flip-flop sampled on `negedge clk` to create `neg_out` (shifted forward by half a clock cycle, i.e. $0.5\,T_{clk}$).
3. **Combination:** Combine them with an **OR gate**:

$$
\text{clk\_out} = \text{pos\_out} \; \text{OR} \; \text{neg\_out}
$$

### Result

The OR gate extends the HIGH duration at the tail end by $+0.5$ cycles:

$$
\text{HIGH Duration} = \frac{N-1}{2} + 0.5 = \frac{N}{2} \text{ cycles} \quad (50\% \text{ duty cycle})
$$

---

## Method 2: The Phase Shortcut (Posedge & Negedge ANDing)

This shortcut directly clips an oversized pulse to obtain an exact $N/2$-cycle pulse width (1.5 cycles for $N=3$) using an AND gate.

### How the Shortcut Works

1. **Posedge Signal:** Generate a `pos_out` pulse on `posedge clk` that stays **HIGH for $\frac{N+1}{2}$ cycles** (e.g. 2 full cycles for $N=3$).
2. **Negedge Signal:** Sample `pos_out` on `negedge clk` (or run a separate state machine on `negedge clk`) to generate `neg_out`. This shifts the waveform forward by **$0.5$ clock cycles**.
3. **Combination:** Perform a bitwise **AND** operation:

$$
\text{clk\_out} = \text{pos\_out} \; \text{AND} \; \text{neg\_out}
$$

### Mathematical Proof (for $N=3$)

- `pos_out` is HIGH from $t = 0.0$ to $t = 2.0$ (2.0 cycles).
- `neg_out` is HIGH from $t = 0.5$ to $t = 2.5$ (2.0 cycles, shifted by $+0.5$).
- Their overlap (`pos_out & neg_out`) is active from $t = 0.5$ to $t = 2.0$:

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

| Parameter | OR Gate Method | AND Gate Method (Shortcut) |
| :--- | :--- | :--- |
| **Posedge Pulse Width** | $\frac{N-1}{2}$ cycles (under-extended) | $\frac{N+1}{2}$ cycles (over-extended) |
| **Shift Operation** | $+0.5$ cycles via `negedge clk` | $+0.5$ cycles via `negedge clk` |
| **Combining Gate** | **OR** (adds $0.5$ cycles) | **AND** (trims $0.5$ cycles) |
| **Final Duty Cycle** | **50%** ($N/2$ cycles) | **50%** ($N/2$ cycles) |
