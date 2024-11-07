# FPGA Morse Code Transmitter

An FPGA implementation of a Morse Code Transmitter using Finite State Machine (FSM) designs in Verilog HDL on the De1-SoC board. This project focuses on encoding Morse sequences and transmitting them with precise timing, highlighting FSM techniques and digital design principles.

## Core Components

### 1. One-Hot Sequence Detector
- Recognizes specific input patterns (four consecutive 1s or 0s)
- Features:
 - 9 state flip-flops with one-hot encoding
 - Overlapping sequence detection
 - Active-low synchronous reset
 - Real-time state visualization on LEDs
- Two implementations:
 - Standard one-hot (A = 000000001)
 - Modified zero-reset (A = 000000000)

### 2. Binary-Encoded Sequence Detector
- Alternative implementation using:
 - 4 state flip-flops
 - Binary state encoding
 - Case statement-based state transitions
 - Parameterized state definitions
- State machine processing options:
 - User-encoded mode
 - Synthesis tool optimization

### 3. Morse Code Transmitter
- Implements A-H character transmission
- Features:
 - 0.5s dots and 1.5s dashes
 - Shift register-based pattern generation
 - Synchronous reset functionality
 - Letter selection via switches
- Components:
 - Morse code shift register
 - Length counter
 - Half-second counter
 - FSM controller

## Technical Implementation

### Input Controls
```verilog
SW[0]  : Active-low synchronous reset
SW[1]  : Input sequence bit
SW[2:0]: Letter selection (Morse code)
KEY[0] : Clock input (manual)
KEY[1] : Morse code transmission trigger
```

### Output Display
```verilog
LEDR[9]  : Sequence detection output
LEDR[8:0]: Current state visualization
LEDR[0]  : Morse code output
```

### Morse Code Patterns
```Verilog
A: • —
B: — • • •
C: — • — •
D: — • •
E: •
F: • • — •
G: — — •
H: • • • •
```

This was done as part of Lab 5 for ECE241 at the University of Toronto.
