# RISC-V Projects
This repository contains my university projects related to RISC-V architecture.

## Repository Structure
- /project1 - RISC-V Assembly Game Simulation
  - An assembly program inspired by the "poule-poule" card game
  - Implements a system to track eggs, chickens, foxes, guard dogs, and worms
  - Uses RISC-V assembly language to process character inputs and calculate available eggs
  - Features include:
    - Input validation and error handling
    - Multiple character commands ('o' for egg, 'p' for chicken, etc.)
    - Dynamic resource tracking system
    - State management for game elements

- /project2 - Conway's Game of Life in RISC-V Assembly
  - Implementation of the famous cellular automaton "Game of Life" in RISC-V assembly
  - Features:
    - Support for grids up to 64x64 cells
    - Uses a two-dimensional grid representation
    - Complete cell evolution rules implementation
    - Grid state management and validation
    - Multiple evolution steps processing
    - Efficient neighbor checking system for:
      - Corner cells
      - Border cells
      - Center cells
    - Dynamic grid state visualization
  - Technical aspects:
    - Memory-efficient grid management
    - Error handling for invalid grids
    - Uses libs.s for I/O operations

- /project3 - Morse Code Library in RISC-V Assembly
  - A comprehensive Morse code encoding/decoding library implementation
  - Key features:
    - Binary tree structure for Morse code representation
    - Character to Morse code conversion
    - Morse code to character decoding
    - Dynamic memory allocation for new Morse nodes
    - Tree traversal algorithms
  - Core functions:
    - miniMorse: Basic Morse tree implementation
    - decMorse: Decodes Morse sequences to characters
    - printMorse: Displays decoded characters
    - newMorse: Creates new Morse tree nodes
    - addMorse: Adds new characters to the Morse tree
    - printMorseLong: Enhanced output with detailed Morse patterns
  - Technical highlights:
    - Efficient binary tree navigation
    - Memory management using RARS system calls
    - Error handling for invalid Morse sequences
    - Support for dots (.) and dashes (-) parsing
