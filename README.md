# RISC-V Benchmark Suite

This benchmark suite is a comprehensive collection of third-party benchmarks designed to evaluate the performance of various hardware components: including CPU, GPU, RAM, I/O, temperature and AI perfomances.
It provides a standardized and simpler way to measure and compare the capabilities of your RISC-V system.

## Getting Started

Initial setup:

```bash
git submodule update --init --recursive
```

## Launch the suite

There are two primary ways to compile and run the benchmark suite:

### Using the Launch Script (Recommended)

The easiest way to get started is by using the provided launch script:

```bash
./launch-benchmark-suite
```

This script will handle the compilation and execution of all benchmarks automatically.

**Note:** If you encounter issues running the script, it might be due to missing execution permissions. You can grant them by running:
```bash
chmod +x launch-benchmark-suite.sh
```
**Important:** The `./launch-benchmark-suite` script (and manual `make setup`) may require `sudo` privileges for certain setup operations, such as installing system packages.

### Manual Compilation and Execution (Using Makefile)

For more granular control, you can compile and run the benchmarks manually using the `Makefile`.

The main targets are:

1.  **Setup the environment and dependencies:**
    ```bash
    make setup
    ```

2.  **Compile all benchmarks:**
    ```bash
    make all
    ```

3.  **Run all benchmarks:**
    ```bash
    make run
    ```

## Credits
- **Michelangelo Stefanini**  
    GitHub: [michelangelostefanini](https://github.com/michelangelostefanini)  
    Email: michelangelo.stefanini@mail.polimi.it

- **Edoardo Tedesco**  
    GitHub: [Tededo02](https://github.com/Tededo02)  
    Email: edoardo.tedesco@mail.polimi.it
