# Pairwise Alignments

Solidity implementations of well-known pairwise alignment methods such as Needleman-Wunsch's global sequence alignment and the Smith-Waterman local sequence alignment algorithm.

This has been built by ZENODE within the Hardhat environment and is licensed under the MIT-license (see [LICENSE.md](./LICENSE.md)).

## Overview

### Dependencies

- `hardhat` (npm module)
- Uses the [`substitution-matrices`](/submodules) repository, which is automatically included as a Git submodule.
- Uses the [`zenode-contracts`](/submodules) repository, which is automatically included as a Git submodule.

### Features

- Needleman-Wunsch's <i>global</i> sequence alignment algorithm.
- Smith-Waterman's <i>local</i> sequence alignment algorithm.
- Expandability; pairwise algorithms similar to Needleman-Wunsch and Smith-Waterman could inherit functionality from the `_PairwiseAlgorithm`-contract.
- Ownership; access control and administrative privilege management.

### Hardhat

- Scripts
  - deployment/needlemanWunsch.js - deploys the Needleman-Wunsch contract to the configured network.
  - deployment/smithWaterman.js - deploys the Smith-Waterman contract to the configured network.
- Tasks for contract interaction (see [Interaction](#6-interaction)).

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

### 3. Deploy and populate SubstitutionMatrices.sol (Intermezzo)

> `This step can be skipped if you've already deployed and populated a SubstitutionMatrices-contract.`

Our pairwise alignment algorithms depend on the `SubstitutionMatrices`-contract as these matrices are required for the calculation of alignment scores.

So, before we continue, we'll deploy our matrices.

1. First, `cd` into the submodule's folder:

   ```
   cd submodules/substitution-matrices
   ```

2. Now, head over to the README.md file found in the [submodules/substitution-matrices](/submodules)-folder and continue from step 3 to 5 in the `Getting Started`-section.

   > TIP: use the TL;DR for a quick setup!

   > NOTE: make sure to edit the files inside the submodule's folder and not in the root folder when following the guideline!

3. Once you've got the SubstitutionMatrices contract set up, `cd` back into `pairwise-alignments` root folder:

   ```
   cd ../..
   ```

### 4. Pre-configuration

Before we can deploy our alignment algorithms, it's necessary to state which `SubstitutionMatrices`-contract we're linking our algorithms to.

To configure this, open the [`zenode.config.js`](zenode.config.js) file ([learn more](#b-zenodeconfigjs)) and add the `SubstitutionMatrices` address to `parameters._matricesAddress`:

```javascript
  contracts: {
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "",
      parameters: {
        _matricesAddress: "ADD_SUBSTITUTION_MATRICES_ADDRESS_HERE",
      },
    },

    smithWaterman: {
      name: "SmithWaterman",
      address: "",
      parameters: {
        _matricesAddress: "ADD_SUBSTITUTION_MATRICES_ADDRESS_HERE",
      },
    },
  }
```

### 5. Deployment

Now that we've deployed our SubstitutionMatrices contract and pre-configured our setup, we can finally deploy the algorithms using:

```
npx hardhat run scripts/deployment/needlemanWunsch.js
npx hardhat run scripts/deployment/smithWaterman.js
```

> Check the [scripts/deployment](/scripts/deployment)-folder to see if there are any more algorithms available for deployment.

> You should see a message appear in your terminal, stating that the contract was deployed successfully.

### 6. Configuration

Add the addresses of our algorithms to the `contracts` object. That way it knows which deployed contracts it should interact with.

```javascript
  contracts: {
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "ADD_NW_ALGORITHM_ADDRESS_HERE",
      ...
    },
    smithWaterman: {
      name: "SmithWaterman",
      address: "ADD_SW_ALGORITHM_ADDRESS_HERE",
      ...
    },
    ...
  },
```

> The contract address can be found in your terminal after deployment.

### 7. Interaction

We're all set!

Here are a few Hardhat tasks (written in [hardhat.config.js](/hardhat.config.js)) to test our contracts with:

<ul>
<li>

<b>needlemanWunsch</b>

Executes the Needleman-Wunsch <i>global</i> sequence alignment on the given pair.

- `input:` `--matrix string` `--a string` `--b string`

- `input (optional):` `--gap int [default: -1]` `--limit uint [default: 0]`

  > gap is the gap penalty.

  > limit = 0 will default to the default limit configured in the deployed contract itself.

- `output:` `struct AlignmentOutput` <i>--see [contracts/\_PairwiseAlignment.sol](/contracts/_PairwiseAlignment.sol)</i>

```
npx hardhat smithWaterman --matrix "MATRIX_ID" --a "SEQUENCE_A" --b "SEQUENCE_B"
```

<b>smithWaterman</b>

Executes the Smith-Waterman <i>local</i> sequence alignment on the given pair.

- `input:` `--matrix string` `--a string` `--b string`

- `input (optional):` `--gap int [default: -1]` `--limit uint [default: 0]`
  > gap is the gap penalty.
  > limit = 0 will default to the default limit configured in the deployed contract itself.
- `output:` `struct AlignmentOutput` <i>--see [contracts/\_PairwiseAlignment.sol](/contracts/_PairwiseAlignment.sol)</i>

```
npx hardhat smithWaterman --matrix "MATRIX_ID" --a "SEQUENCE_A" --b "SEQUENCE_B"
```

> MATRIX_IDs you can use depend on the IDs you've populated in the [SubstitutionMatrices] phase.

</li>

<li>

<b>linkNWToMatricesAddress</b>

This can be used to change the SubstitutionMatrices address for the Needleman-Wunsch algorithm.

> This will also refetch the alphabets known to the `SubstitutionMatrices` contract and store them locally in the algorithm's contract (works like a cache). So if you make changes to the `alphabets` in the SubstitutionMatrices contract, run this command to sync the algorithm with the SubstitutionMatrices contract.

- `input (optional):` `--address hex_address` `[default: contracts.needlemanWunsch.parameters._matricesAddress]`

- `output:` `void`

```
npx hardhat linkNWToMatricesAddress --address "hex_address"
```

e.g.

```
npx hardhat linkNWToMatricesAddress --address "0x5FbDB2315678afecb367f032d93F642f64180aa3"
```

</li>

<li>

<b>linkSWToMatricesAddress</b>

The same as `linkNWToMatricesAddress` but then for the Smith-Waterman algorithm.

- `input (optional):` `--address hex_address` `[default: contracts.smithWaterman.parameters._matricesAddress]`

- `output:` `void`

```
npx hardhat linkSWToMatricesAddress --address "hex_address"
```

e.g.

```
npx hardhat linkSWToMatricesAddress --address "0x5FbDB2315678afecb367f032d93F642f64180aa3"
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
