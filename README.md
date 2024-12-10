# e155-final-project

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

This repository contains all of the source code needed to run Fix That Note!

Fix That Note! is a E155 class project. The class, focusing on microprocessors like FPGAs and MCUs challenges students at the end to ideate, create, and debug their own unique system.

Our team chose to create a system which reads in audio inputs via a microphone and amplifier circuit, then display out the dominant frequency via an LCD screen. It does this using an FFT function in the MCU, built using the CMSIS DSP library. It uses a custom LCD driver built into the FPGA.

For a full report and more documentation, see our report website below:
https://jacksonphilion.github.io/final-project-portfolio/ 

This github repository is organized as follows:
* `MCU/` which contains:
    * `src/` which contains our main.c file
    * `lib/` which contains all of our given, custom, and CMSIS libraries
    * `segger/` which contains the SEGGER project used to debug and upload our code
* `FPGA/` which contains:
    * `finalProject.sv`, an integrated single-file version of all of our FPGA modules.
    * `radiant_project/` which contains the Lattice Radiant project we used to build, test, and download finalProject.sv
    * `modelsim_project/` which contains the ModelSim project used to simulate and debug the integrated single-file solution. Note that it contains its own file, `finalProject_sim.sv`, which mirrors the main .sv file but is built for effective simulation with an externally fed clock signal.
* `notesAndExtras/` which contains:
    * `demo/` which contains the source files and SEGGER project for our initial 25% completion demonstration. Specifically, this prototype is made to read in an ADC value and print it out to the user
    * `KiCad/` which contains the KiCad schematic file used to create our schematic above
    * `simulationCaptures/` which contains the raw screenshot images taken of ModelSim waveforms for our simulated top.sv code, found in:
    * `simulationFiles/` which contains the deprecated version of top.sv back before we transitioned to a single file system
