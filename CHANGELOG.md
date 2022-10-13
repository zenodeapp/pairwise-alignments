## ALIGNING PATHWAYS

#### 1.2.0 (2022-10-13)

- Improved the algorithm by creating a while-loop alternative instead of a recursive method for the traceback. This gets rid of the stack-overflow issue and also makes it possible for the algorithm to pair larger sequences.

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
