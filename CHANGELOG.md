## ALIGNING PATHWAYS

#### 1.2.1 (2022-10-15)

- Refactored and decoupled the Pairwise Alignment algorithms as both have a lot in common. Shared code between the algorithms are now abstracted out. This was a bit of a sacrifice when it comes to performance, but no copy-pasting, thus less headaches when the code has to be adapted.
- Added MIT-license and created a boilerplate for the README.md

#### 1.2.0 (2022-10-13)

- Improved the algorithm by creating a while-loop alternative instead of a recursive method for the traceback. This gets rid of the stack-overflow issue and also makes it possible for the algorithm to pair larger sequences.
- Added SmithWaterman.sol, but the two algorithms require refactoring and decoupling (for they are very similar).

#### 1.1.1 (2022-10-12)

- Implemented the SubstitutionMatrices contract into NeedlemanWunsch.sol
- Partial refactoring

#### 1.1.0 (2022-10-11)

- Started separating the SubstitutionMatrices logic.
- A new contract has been made (SubstitutionMatrices.sol). It's a CRUD for matrices and alphabets, this way matrices become modular.
- Included a bunch of scripts to read matrices, alphabets and interact with the contract (Javascript logic).
- Added Owner.sol.

#### 1.0.0 (2022-10-08)

- Created the Needleman-Wunsch algorithm.
