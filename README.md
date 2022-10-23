# Pairwise Alignments
Solidity implementations of well-known pairwise alignment methods such as Needleman-Wunsch's global sequence alignment and the Smith-Waterman local sequence alignment algorithm.

This has been built by ZENODE within the Hardhat environment and is licensed under the MIT-license (see [LICENSE.md](./LICENSE.md)).

## Overview

### Dependencies

- `hardhat` (npm module)
- Uses the [`substitution-matrices`](/submodules) repository, which is automatically included as a Git submodule.
- Uses the [`zenode-contracts`](/submodules) repository, which is automatically included as a Git submodule.

### Features

...

## Getting Started

### TL;DR

> [`0. Clone (recursively!)`](#0-clone)
>
> ```
> git clone --recursive https://github.com/zenodeapp/pairwise-alignments.git <destination_folder>
> ```
>
> [`1. Installation`](#1-installation) <i>--use npm, yarn or any other package manager.</i>
>
> ```
> npm install
> ```
>
> ```
> yarn install
> ```
>
> [`2. Run the test node`](#2-configure-and-run-your-test-node) <i>--do this in a separate terminal!</i>
>
> ```script
> npx hardhat node
> ```
>
> ...

### 0. Clone

To get started, clone the repository with the `--recursive` flag:

```
git clone --recursive https://github.com/zenodeapp/pairwise-alignments.git <destination_folder>
```

>  This repository includes submodules and should thus contain the `--recursive` flag.

<br>

If you've already downloaded or cloned this repository without including the `--recursive` flag, then run this command from the root folder:

```
git submodule update --init --recursive
```

### 1. Installation

Install all dependencies using a package manager of your choosing:

```
npm install
```

```
yarn install
```

### 2. Configure and run your (test) node

After having installed all dependencies, use:

```script
npx hardhat node
```

> Make sure to do this in a separate terminal!

<br>

This will create a test environment where we can deploy our contract(s) to. By default, this repository is configured to Hardhat's local test node, but can be changed in the [hardhat.config.js](/hardhat.config.js) file. For more information on how to do this, see [Hardhat's documentation](https://hardhat.org/hardhat-runner/docs/config).

...

## Credits
- Hardhat's infrastructure! (https://hardhat.org/)
- M (for requesting the creation of this project, sharing resourceful information and expertise; https://github.com/alpha-omega-labs)

## Sources of inspiration
- A tool by Greg Tucker-Kellogg demonstrating how pairwise alignment works (https://gtuckerkellogg.github.io/pairwise/demo/)
- Another inspiring tool (http://rna.informatik.uni-freiburg.de/Teaching/index.jsp?toolName=Needleman-Wunsch)
- Bioinformatics Course at the University of Melbourne by Vladimir Likić, Ph.D. (https://www.cs.sjsu.edu/~aid/cs152/NeedlemanWunsch.pdf)

</br>

<p align="right">— ZEN</p>
<p align="right">Copyright (c) 2022 ZENODE</p>
