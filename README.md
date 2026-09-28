# Problem-108-Divide-by-3-Clock-Generator-50-Duty-Cycle-
# Readme: Odd Clock Divider with 50% Duty Cycle

When dividing a clock by an **odd integer ($N = 3, 5, 7, \dots$)**, a standard single-edge counter cannot inherently produce a 50% duty cycle because $N$ cannot be evenly split into whole clock cycles. To achieve a 50% duty cycle output ($N/2$ cycles HIGH, $N/2$ cycles LOW), two primary techniques exist:

---

## Method 1: Dual-Edge Signal Generation + Logic Combination

This method uses two identical logic paths running on opposite clock edges and combines them with a single logic gate (AND/OR).

### 1. The OR Gate Approach
* **Posedge Generator:** Generate a signal `pos_out` on `posedge clk` that stays **HIGH for $\frac{N-1}{2}$ cycles** and **LOW for $\frac{N+1}{2}$ cycles**.
* **Negedge D Flip-Flop:** Pass `pos_out` through a D Flip-Flop sampled on `negedge clk` to create `neg_out` (shifted forward by half a clock cycle, or $0.5 \, T_{\text{clk}}$).
* **Combination:** Combine them with an **OR gate**:
  $$\text{clk\_out} = \text{pos\_out} \text{ OR } \text{neg\_out}$$
* **Result:** The OR gate extends the HIGH duration at the tail end by $+0.5$ cycles:
  $$\text{HIGH Duration} = \frac{N-1}{2} + 0.5 = \frac{N}{2} \text{ cycles (50\% Duty Cycle)}$$

---

## Method 2: The Phase Shortcut (Posedge & Negedge ANDing)

This shortcut directly clips an oversized pulse to obtain a exact $1.5$-cycle (or $N/2$-cycle) pulse width using an AND gate.

### How the Shortcut Works
1. **Posedge Signal:** Generate a `pos_out` pulse on `posedge clk` that stays **HIGH for $\frac{N+1}{2}$ cycles** (e.g., 2 full cycles for $N=3$).
2. **Negedge Signal:** Sample `pos_out` on `negedge clk` (or run a separate state machine on `negedge clk`) to generate `neg_out`. This shifts the waveform forward by **$0.5$ clock cycles**.
3. **Combination:** Perform a bitwise **AND operation**:
  $$\text{clk\_out} = \text{pos\_out} \text{ AND } \text{neg\_out}$$

### Mathematical Proof (for $N=3$)
* `pos_out` is HIGH from $t = 0.0$ to $t = 2.0$ ($2.0$ cycles).
* `neg_out` is HIGH from $t = 0.5$ to $t = 2.5$ ($2.0$ cycles, shifted by $+0.5$).
* Their overlap (`pos_out & neg_out`) is active from $t = 0.5$ to $t = 2.0$:
  $$\text{HIGH Time} = 2.0 - 0.5 = \mathbf{1.5 \text{ cycles}}$$
  $$\text{Total Period} = \mathbf{3.0 \text{ cycles}}$$
  $$\text{Duty Cycle} = \frac{1.5}{3.0} \times 100\% = \mathbf{50\%}$$

---

## Summary Comparison

| Parameter | OR Gate Method | AND Gate Method (Shortcut) |
| :--- | :--- | :--- |
| **Posedge Pulse Width** | $\frac{N-1}{2}$ cycles (Under-extended) | $\frac{N+1}{2}$ cycles (Over-extended) |
| **Shift Operation** | $+0.5$ cycles via `negedge clk` | $+0.5$ cycles via `negedge clk` |
| **Combining Gate** | **OR** (Adds $0.5$ cycles) | **AND** (Trims $0.5$ cycles) |
| **Final Duty Cycle** | **50%** ($N/2$ cycles) | **50%** ($N/2$ cycles) |
