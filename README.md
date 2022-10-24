# Pairwise Alignments

Solidity implementations of well-known pairwise alignment methods such as Needleman-Wunsch's global sequence alignment and the Smith-Waterman local sequence alignment algorithm.

This has been built by ZENODE within the Hardhat environment and is licensed under the MIT-license (see [LICENSE.md](./LICENSE.md)).

## Overview

### Dependencies

- `hardhat` (npm module)
- Uses the [`substitution-matrices`](/submodules) repository, which is automatically included as a Git submodule.
- Uses the [`zenode-contracts`](/submodules) repository, which is automatically included as a Git submodule.

### Features

- Expandable; pairwise algorithms similar to Needleman-Wunsch's alignment method could inherit functionality from the [\_PairwiseAlignment](contracts/_PairwiseAlignment.sol)-contract.
- Ownership; access control and administrative privilege management.

### Algorithms

- [Needleman-Wunsch](contracts/NeedlemanWunsch.sol)'s <i>global</i> sequence alignment algorithm.
- [Smith-Waterman](contracts/SmithWaterman.sol)'s <i>local</i> sequence alignment algorithm.

### Hardhat

- Scripts
  - deployment/needlemanWunsch.js - deploys the Needleman-Wunsch contract to the configured network.
  - deployment/smithWaterman.js - deploys the Smith-Waterman contract to the configured network.
- Tasks for contract interaction (see [Interaction](#7-interaction)).

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
> [`3. Substitution Matrices (Intermezzo)`](#3-substitution-matrices-intermezzo) <i>--skip if you already have a SubstitutionMatrices contract deployed!</i>
>
> ```script
> cd submodules/substitution-matrices
> ```
>
> ```javascript
> // Now follow steps 1-5 (skip step 2) in TL;DR of the README.md in submodules/substitution-matrices
> ```
>
> [`4. Pre-configuration`](#4-pre-configuration) <i>--add SubstitutionMatrices address to [zenode.config.js](zenode.config.js)</i>
>
> ```javascript
>   contracts: {
>     needlemanWunsch: {
>       name: "NeedlemanWunsch",
>       address: "",
>       parameters: {
>         _matricesAddress: "ADD_SUBSTITUTION_MATRICES_ADDRESS_HERE",
>       },
>     },
>     ...
>   }
> ```
>
> > Repeat for any other algorithm you wish to deploy.
>
> [`5. Deployment`](#5-deployment)
>
> ```
> npx hardhat run scripts/deployment/needlemanWunsch.js
> ```
>
> ```
> npx hardhat run scripts/deployment/smithWaterman.js
> ```
>
> > Only deploy the one(s) you pre-configured, see [scripts/deployment](scripts/deployment) for all possible algorithms.
>
> [`6. Configuration`](#6-configuration) <i>--add algorithm's address to [zenode.config.js](zenode.config.js)</i>
>
> ```javascript
>   contracts: {
>     needlemanWunsch: {
>       name: "NeedlemanWunsch",
>       address: "ADD_NW_ALGORITHM_ADDRESS_HERE",
>       ...
>     },
>     ...
>   },
> ```
>
> > Repeat for any other algorithm you deployed.
>
> [`7. Interaction`](#7-interaction) <i>--use the scripts provided in the [Interaction](#7-interaction) phase.</i>

### 0. Clone

To get started, clone the repository with the `--recursive` flag:

```
git clone --recursive https://github.com/zenodeapp/pairwise-alignments.git <destination_folder>
```

> This repository includes submodules and should thus contain the `--recursive` flag.

<br>

If you've already downloaded, forked or cloned this repository without including the `--recursive` flag, then run this command from the root folder:

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

### 3. Substitution Matrices (Intermezzo)

> `This step can be skipped if you've already deployed and populated a SubstitutionMatrices-contract.`

Our pairwise alignment algorithms depend on the `SubstitutionMatrices`-contract as it's required for calculating alignment scores. So, before we continue, let us deploy these matrices to our node.

1. `cd` into the submodule's folder:

   ```
   cd submodules/substitution-matrices
   ```

2. Now, head over to the README.md file found in the [submodules/substitution-matrices](/submodules)-folder and continue from step 1 to 5 (skip step 2) found in the `Getting Started`-section.

   > TIP: follow the TL;DR for a quick setup!

   > NOTE: make sure you edit the files inside the submodule's folder and not in the root folder!

3. Once you've got the SubstitutionMatrices contract set up, `cd` back into the `pairwise-alignments` root folder:

   ```
   cd ../..
   ```

### 4. Pre-configuration

Before we can deploy any alignment algorithm, it's necessary to state which `SubstitutionMatrices`-contract we link our algorithm to.

To do this, open the [zenode.config.js](zenode.config.js) file and add the `SubstitutionMatrices address` (from [3. Substitution Matrices (Intermezzo)](#3-substitution-matrices-intermezzo)) to `parameters._matricesAddress`:

```javascript
  contracts: {
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "",
      parameters: {
        _matricesAddress: "ADD_SUBSTITUTION_MATRICES_ADDRESS_HERE",
      },
    },
    ...
  }
```

> Repeat this step for any other algorithm you would like to deploy.

### 5. Deployment

Now that we've pre-configured our `zenode.config.js`-file, we can deploy our algorithm(s) using:

<b>Needleman-Wunsch</b>

```
npx hardhat run scripts/deployment/needlemanWunsch.js
```

<b>Smith-Waterman</b>

```
npx hardhat run scripts/deployment/smithWaterman.js
```

> Only deploy the one(s) you pre-configured, see the [scripts/deployment](scripts/deployment) folder for all possible algorithms.

### 6. Configuration

Now head back to the [zenode.config.js](zenode.config.js) file and add the addresses for all the algorithms we deployed to the `contracts` object. That way it knows which deployed contracts it should interact with.

```javascript
  contracts: {
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "ADD_NW_ALGORITHM_ADDRESS_HERE",
      ...
    },
    ...
  },
```

> Same as before; repeat for any other algorithm you've deployed.

### 7. Interaction

We're all set!

<br>

Here are a few Hardhat tasks (written in [hardhat.config.js](/hardhat.config.js)) to test our contracts with:

<ul>
<li>

<b>needlemanWunsch</b>

Executes the Needleman-Wunsch <i>global</i> sequence alignment on the given string pair.

- `input:` `--matrix string` `--a string` `--b string`

- `input (optional):` `--gap int` <i>[default: "-1"]</i> `--limit uint` <i>[default: "0"]</i>

- `output:` `struct AlignmentOutput` <i>--see [contracts/\_PairwiseAlignment.sol](/contracts/_PairwiseAlignment.sol)</i>

> `--gap` is the [gap penalty](https://en.wikipedia.org/wiki/Gap_penalty) (links to Wikipedia).
>
> `--limit "0"` will default to the default limit configured in the deployed contract itself.
>
> Valid `MATRIX_ID`s depend on which matrices you've populated in the [Substitution Matrices](#3-substitution-matrices-intermezzo) phase; see the zenode.config.js file in the substitution-matrices submodule or call `getMatrices` in the SubstitutionMatrices-contract.

```
npx hardhat needlemanWunsch --matrix "MATRIX_ID" --a "SEQUENCE_A" --b "SEQUENCE_B"
```

</li>

<li>

<b>smithWaterman</b>

Executes the Smith-Waterman <i>local</i> sequence alignment on the given string pair.

- `input:` `--matrix string` `--a string` `--b string`

- `input (optional):` `--gap int` <i>[default: "-1"]</i> `--limit uint` <i>[default: "0"]</i>

- `output:` `struct AlignmentOutput` <i>--see [contracts/\_PairwiseAlignment.sol](/contracts/_PairwiseAlignment.sol)</i>

> see <b>needlemanWunsch</b>'s annotations.

```
npx hardhat smithWaterman --matrix "MATRIX_ID" --a "SEQUENCE_A" --b "SEQUENCE_B"
```

</li>

<li>

<b>linkNWToMatricesAddress</b>

This changes the SubstitutionMatrices-address for the Needleman-Wunsch algorithm.

- `input (optional):` `--address hex_address` <i>[default: [contracts.needlemanWunsch.parameters.\_matricesAddress](zenode.config.js)]</i>

- `output:` `void`

> IMPORTANT: run this command every time the `alphabets` in the `SubstitutionMatrices`-contract get updated! <i>(rarely happens)</i>
>
> > Why?
> >
> > Every time a `SubstitionMatrices`-contract gets linked to an algorithm (which happens once during the [Deployment](#5-deployment) phase), all the known `alphabets` get copied over to the algorithm's storage. This works like a cache and helps with optimizing our algorithms. However, if an update to the `alphabets` inside of the matrices' contract occurs, all algorithms that were deployed before the change will have outdated alphabets; relinking the matrices' address remedies such inconsistencies.

```
npx hardhat linkNWToMatricesAddress --address "hex_address"
```

</li>

<li>

<b>linkSWToMatricesAddress</b>

This changes the SubstitutionMatrices-address for the Smith-Waterman algorithm.

- `input (optional):` `--address hex_address` <i>[default: [contracts.smithWaterman.parameters.\_matricesAddress](zenode.config.js)]</i>

- `output:` `void`

> see <b>linkNWToMatricesAddress</b>' annotations.

```
npx hardhat linkSWToMatricesAddress --address "hex_address"
```

</li>
</ul>

## Appendix

### A. [zenode.config.js](/zenode.config.js)

This is where most of the <i>personalization</i> for contract deployment and filling takes place.

In the case of the `pairwise-alignments` repository this includes:

- Configuring which `SubstitutionMatrices`-contract we'll link our algorithms with.
- Configuring which contract we'll interact with in the [`Interaction`](#7-interaction) phase.
- Expanding (or shrinking for that matter) the list of known pairwise alignment algorithms.

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
