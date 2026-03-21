# ProjectEuler.ARM64

Solutions to the first 100 [Project Euler](https://projecteuler.net/) problems in **AArch64 (ARM64) assembly**.

## About This Project

This is one of **10 language repositories** where each contains solutions to the same 100 problems, all generated using [Claude Code](https://claude.ai/claude-code) powered by **Anthropic's Claude Opus 4.6**. The goal is twofold:

1. **Explore how LLMs work across languages** — Can Claude produce idiomatic, correct, and performant solutions in languages ranging from C to APL to raw assembly? How does the generated code differ across paradigms (imperative, functional, array-oriented)?

2. **Compare language performance** — When solving the same algorithmic problems with equivalent approaches, does the language of choice actually matter? Or are modern compilers and runtimes close enough that the algorithm dominates?

### Why ARM Assembly?

ARM64 assembly represents the **zero-abstraction baseline** — the raw instructions that every other language compiles down to. Including it answers the question: does hand-written assembly actually beat modern compilers? (Spoiler: often it doesn't, because compilers are very good at optimization.)

### All Language Repos

| Language | Repository | Paradigm |
|----------|------------|----------|
| [APL](https://github.com/august-hill/ProjectEuler.APL) | ProjectEuler.APL | Array-oriented |
| [ARM64](https://github.com/august-hill/ProjectEuler.ARM64) | ProjectEuler.ARM64 | Assembly |
| [C](https://github.com/august-hill/ProjectEuler.C) | ProjectEuler.C | Imperative |
| [C#](https://github.com/august-hill/ProjectEuler.CSharp) | ProjectEuler.CSharp | Object-oriented |
| [C++](https://github.com/august-hill/ProjectEuler.CPlusPlus) | ProjectEuler.CPlusPlus | Multi-paradigm |
| [Go](https://github.com/august-hill/ProjectEuler.Go) | ProjectEuler.Go | Imperative/CSP |
| [Haskell](https://github.com/august-hill/ProjectEuler.Haskell) | ProjectEuler.Haskell | Functional |
| [Java](https://github.com/august-hill/ProjectEuler.Java) | ProjectEuler.Java | Object-oriented |
| [Python](https://github.com/august-hill/ProjectEuler.Python) | ProjectEuler.Python | Multi-paradigm |
| [Rust](https://github.com/august-hill/ProjectEuler.Rust) | ProjectEuler.Rust | Systems |

Cross-language benchmarks: [ProjectEuler.Benchmarks](https://github.com/august-hill/ProjectEuler.Benchmarks)

## Architecture

Each problem has a `solve.s` file containing a `_solve` function in AArch64 assembly that returns the answer as a `long long` (int64) in register `x0`. A shared C harness (`bench.c`) handles timing and BENCHMARK line output.

## Building & Running

```bash
# Build and run a specific problem
make run N=001

# Just build
make problem N=001

# Run all benchmarks
./benchmark.sh
```

## Platform

- **Architecture**: AArch64 (Apple Silicon M-series)
- **Assembler**: macOS `as` (Clang integrated assembler)
- **Linker**: System linker with `-lSystem`
- **ABI**: Apple ARM64 calling convention (x0-x7 args, x0 return, x19-x28 callee-saved)

## Problems Solved

2 problems (in progress): 001, 010

## Generated with Claude

All solutions were generated using Claude Opus 4.6 via [Claude Code](https://claude.ai/claude-code). The algorithms are based on a shared understanding of each problem, translated into idiomatic AArch64 assembly. This project demonstrates that modern LLMs can generate working assembly code — and that hand-written assembly doesn't always beat optimizing compilers.
