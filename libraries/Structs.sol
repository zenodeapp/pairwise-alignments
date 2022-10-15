// SPDX-License-Identifier: UNLICENSED
// Created by Tousuke (zenodeapp - https://github.com/zenodeapp/)

pragma solidity ^0.8.17;

library Structs {
  struct Matrix {
    string id;
    int[][] grid;
    string alphabetId;
    uint index;
  }

  struct Alphabet {
    string id;
    bytes1[] array;
    uint usage;
    uint index;
  }
}