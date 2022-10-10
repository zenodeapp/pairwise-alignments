pragma solidity ^0.8.17;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/) - Work in Progress.

contract NeedlemanWunsch {
  mapping(bytes1 => uint) dnaMapping;
  mapping(bytes1 => uint) proteinMapping;
  mapping(string => uint) tracebackMapping;
  uint DEFAULT_ALIGNMENT_LIMIT = 25;

  int[4][4] simpleDnaMatrix = [
    [int(1), -1, -1, -1],
    [int(-1), 1, -1, -1],
    [int(-1), -1, 1, -1],
    [int(-1), -1, -1, 1]
  ];

  int[4][4] smarterDnaMatrix = [
    [int(2), 1, -1, -1],
    [int(1), 2, -1, -1],
    [int(-1), -1, 2, 1],
    [int(-1), -1, 1, 2]
  ];
  
  int[24][24] blosum62Matrix = [
    [int(4), -1, -2, -2, 0, -1, -1, 0, -2, -1, -1, -1, -1, -2, -1, 1, 0, -3, -2, 0, -2, -1, 0, -4],
    [int(-1), 5, 0, -2, -3, 1, 0, -2, 0, -3, -2, 2, -1, -3, -2, -1, -1, -3, -2, -3, -1, 0, -1, -4],
    [int(-2), 0, 6, 1, -3, 0, 0, 0, 1, -3, -3, 0, -2, -3, -2, 1, 0, -4, -2, -3, 3, 0, -1, -4],
    [int(-2), -2, 1, 6, -3, 0, 2, -1, -1, -3, -4, -1, -3, -3, -1, 0, -1, -4, -3, -3, 4, 1, -1, -4],
    [int(0), -3, -3, -3, 9, -3, -4, -3, -3, -1, -1, -3, -1, -2, -3, -1, -1, -2, -2, -1, -3, -3, -2, -4],
    [int(-1), 1, 0, 0, -3, 5, 2, -2, 0, -3, -2, 1, 0, -3, -1, 0, -1, -2, -1, -2, 0, 3, -1, -4],
    [int(-1), 0, 0, 2, -4, 2, 5, -2, 0, -3, -3, 1, -2, -3, -1, 0, -1, -3, -2, -2, 1, 4, -1, -4],
    [int(0), -2, 0, -1, -3, -2, -2, 6, -2, -4, -4, -2, -3, -3, -2, 0, -2, -2, -3, -3, -1, -2, -1, -4],
    [int(-2), 0, 1, -1, -3, 0, 0, -2, 8, -3, -3, -1, -2, -1, -2, -1, -2, -2, 2, -3, 0, 0, -1, -4],
    [int(-1), -3, -3, -3, -1, -3, -3, -4, -3, 4, 2, -3, 1, 0, -3, -2, -1, -3, -1, 3, -3, -3, -1, -4],
    [int(-1), -2, -3, -4, -1, -2, -3, -4, -3, 2, 4, -2, 2, 0, -3, -2, -1, -2, -1, 1, -4, -3, -1, -4],
    [int(-1), 2, 0, -1, -3, 1, 1, -2, -1, -3, -2, 5, -1, -3, -1, 0, -1, -3, -2, -2, 0, 1, -1, -4],
    [int(-1), -1, -2, -3, -1, 0, -2, -3, -2, 1, 2, -1, 5, 0, -2, -1, -1, -1, -1, 1, -3, -1, -1, -4],
    [int(-2), -3, -3, -3, -2, -3, -3, -3, -1, 0, 0, -3, 0, 6, -4, -2, -2, 1, 3, -1, -3, -3, -1, -4],
    [int(-1), -2, -2, -1, -3, -1, -1, -2, -2, -3, -3, -1, -2, -4, 7, -1, -1, -4, -3, -2, -2, -1, -2, -4],
    [int(1), -1, 1, 0, -1, 0, 0, 0, -1, -2, -2, 0, -1, -2, -1, 4, 1, -3, -2, -2, 0, 0, 0, -4],
    [int(0), -1, 0, -1, -1, -1, -1, -2, -2, -1, -1, -1, -1, -2, -1, 1, 5, -2, -2, 0, -1, -1, 0, -4],
    [int(-3), -3, -4, -4, -2, -2, -3, -2, -2, -3, -2, -3, -1, 1, -4, -3, -2, 11, 2, -3, -4, -3, -2, -4],
    [int(-2), -2, -2, -3, -2, -1, -2, -3, 2, -1, -1, -2, -1, 3, -3, -2, -2, 2, 7, -1, -3, -2, -1, -4],
    [int(0), -3, -3, -3, -1, -2, -2, -3, -3, 3, 1, -2, 1, -1, -2, -2, 0, -3, -1, 4, -3, -2, -1, -4],
    [int(-2), -1, 3, 4, -3, 0, 1, -1, 0, -3, -4, 0, -3, -3, -2, 0, -1, -4, -3, -3, 4, 1, -1, -4],
    [int(-1), 0, 0, 1, -3, 3, 4, -2, 0, -3, -3, 1, -1, -3, -1, 0, -1, -3, -2, -2, 1, 4, -1, -4],
    [int(0), -1, -1, -1, -2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2, 0, 0, -2, -1, -1, -1, -1, -1, -4],
    [int(-4), -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, 1]
  ];

  int[24][24] blosum50Matrix = [
    [int(5), -2, -1, -2, -1, -1, -1, 0, -2, -1, -2, -1, -1, -3, -1, 1, 0, -3, -2, 0, -2, -1, -1, -5],
    [int(-2), 7, -1, -2, -4, 1, 0, -3, 0, -4, -3, 3, -2, -3, -3, -1, -1, -3, -1, -3, -1, 0, -1, -5],
    [int(-1), -1, 7, 2, -2, 0, 0, 0, 1, -3, -4, 0, -2, -4, -2, 1, 0, -4, -2, -3, 5, 0, -1, -5],
    [int(-2), -2, 2, 8, -4, 0, 2, -1, -1, -4, -4, -1, -4, -5, -1, 0, -1, -5, -3, -4, 6, 1, -1, -5],
    [int(-1), -4, -2, -4, 13, -3, -3, -3, -3, -2, -2, -3, -2, -2, -4, -1, -1, -5, -3, -1, -3, -3, -1, -5],
    [int(-1), 1, 0, 0, -3, 7, 2, -2, 1, -3, -2, 2, 0, -4, -1, 0, -1, -1, -1, -3, 0, 4, -1, -5],
    [int(-1), 0, 0, 2, -3, 2, 6, -3, 0, -4, -3, 1, -2, -3, -1, -1, -1, -3, -2, -3, 1, 5, -1, -5],
    [int(0), -3, 0, -1, -3, -2, -3, 8, -2, -4, -4, -2, -3, -4, -2, 0, -2, -3, -3, -4, -1, -2, -1, -5],
    [int(-2), 0, 1, -1, -3, 1, 0, -2, 10, -4, -3, 0, -1, -1, -2, -1, -2, -3, 2, -4, 0, 0, -1, -5],
    [int(-1), -4, -3, -4, -2, -3, -4, -4, -4, 5, 2, -3, 2, 0, -3, -3, -1, -3, -1, 4, -4, -3, -1, -5],
    [int(-2), -3, -4, -4, -2, -2, -3, -4, -3, 2, 5, -3, 3, 1, -4, -3, -1, -2, -1, 1, -4, -3, -1, -5],
    [int(-1), 3, 0, -1, -3, 2, 1, -2, 0, -3, -3, 6, -2, -4, -1, 0, -1, -3, -2, -3, 0, 1, -1, -5],
    [int(-1), -2, -2, -4, -2, 0, -2, -3, -1, 2, 3, -2, 7, 0, -3, -2, -1, -1, 0, 1, -3, -1, -1, -5],
    [int(-3), -3, -4, -5, -2, -4, -3, -4, -1, 0, 1, -4, 0, 8, -4, -3, -2, 1, 4, -1, -4, -4, -1, -5],
    [int(-1), -3, -2, -1, -4, -1, -1, -2, -2, -3, -4, -1, -3, -4, 10, -1, -1, -4, -3, -3, -2, -1, -1, -5],
    [int(1), -1, 1, 0, -1, 0, -1, 0, -1, -3, -3, 0, -2, -3, -1, 5, 2, -4, -2, -2, 0, 0, -1, -5],
    [int(0), -1, 0, -1, -1, -1, -1, -2, -2, -1, -1, -1, -1, -2, -1, 2, 5, -3, -2, 0, 0, -1, -1, -5],
    [int(-3), -3, -4, -5, -5, -1, -3, -3, -3, -3, -2, -3, -1, 1, -4, -4, -3, 15, 2, -3, -5, -2, -1, -5],
    [int(-2), -1, -2, -3, -3, -1, -2, -3, 2, -1, -1, -2, 0, 4, -3, -2, -2, 2, 8, -1, -3, -2, -1, -5],
    [int(0), -3, -3, -4, -1, -3, -3, -4, -4, 4, 1, -3, 1, -1, -3, -2, 0, -3, -1, 5, -3, -3, -1, -5],
    [int(-2), -1, 5, 6, -3, 0, 1, -1, 0, -4, -4, 0, -3, -4, -2, 0, 0, -5, -3, -3, 6, 1, -1, -5],
    [int(-1), 0, 0, 1, -3, 4, 5, -2, 0, -3, -3, 1, -1, -4, -1, 0, -1, -2, -2, -3, 1, 5, -1, -5],
    [int(-1), -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -5],
    [int(-5), -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, 1]
  ];

  int[24][24] pam250Matrix = [
    [int(2), -2, 0, 0, -2, 0, 0, 1, -1, -1, -2, -1, -1, -3, 1, 1, 1, -6, -3, 0, 0, 0, 0, -8],
    [int(-2), 6, 0, -1, -4, 1, -1, -3, 2, -2, -3, 3, 0, -4, 0, 0, -1, 2, -4, -2, -1, 0, -1, -8],
    [int(0), 0, 2, 2, -4, 1, 1, 0, 2, -2, -3, 1, -2, -3, 0, 1, 0, -4, -2, -2, 2, 1, 0, -8],
    [int(0), -1, 2, 4, -5, 2, 3, 1, 1, -2, -4, 0, -3, -6, -1, 0, 0, -7, -4, -2, 3, 3, -1, -8],
    [int(-2), -4, -4, -5, 12, -5, -5, -3, -3, -2, -6, -5, -5, -4, -3, 0, -2, -8, 0, -2, -4, -5, -3, -8],
    [int(0), 1, 1, 2, -5, 4, 2, -1, 3, -2, -2, 1, -1, -5, 0, -1, -1, -5, -4, -2, 1, 3, -1, -8],
    [int(0), -1, 1, 3, -5, 2, 4, 0, 1, -2, -3, 0, -2, -5, -1, 0, 0, -7, -4, -2, 3, 3, -1, -8],
    [int(1), -3, 0, 1, -3, -1, 0, 5, -2, -3, -4, -2, -3, -5, 0, 1, 0, -7, -5, -1, 0, 0, -1, -8],
    [int(-1), 2, 2, 1, -3, 3, 1, -2, 6, -2, -2, 0, -2, -2, 0, -1, -1, -3, 0, -2, 1, 2, -1, -8],
    [int(-1), -2, -2, -2, -2, -2, -2, -3, -2, 5, 2, -2, 2, 1, -2, -1, 0, -5, -1, 4, -2, -2, -1, -8],
    [int(-2), -3, -3, -4, -6, -2, -3, -4, -2, 2, 6, -3, 4, 2, -3, -3, -2, -2, -1, 2, -3, -3, -1, -8],
    [int(-1), 3, 1, 0, -5, 1, 0, -2, 0, -2, -3, 5, 0, -5, -1, 0, 0, -3, -4, -2, 1, 0, -1, -8],
    [int(-1), 0, -2, -3, -5, -1, -2, -3, -2, 2, 4, 0, 6, 0, -2, -2, -1, -4, -2, 2, -2, -2, -1, -8],
    [int(-3), -4, -3, -6, -4, -5, -5, -5, -2, 1, 2, -5, 0, 9, -5, -3, -3, 0, 7, -1, -4, -5, -2, -8],
    [int(1), 0, 0, -1, -3, 0, -1, 0, 0, -2, -3, -1, -2, -5, 6, 1, 0, -6, -5, -1, -1, 0, -1, -8],
    [int(1), 0, 1, 0, 0, -1, 0, 1, -1, -1, -3, 0, -2, -3, 1, 2, 1, -2, -3, -1, 0, 0, 0, -8],
    [int(1), -1, 0, 0, -2, -1, 0, 0, -1, 0, -2, 0, -1, -3, 0, 1, 3, -5, -3, 0, 0, -1, 0, -8],
    [int(-6), 2, -4, -7, -8, -5, -7, -7, -3, -5, -2, -3, -4, 0, -6, -2, -5, 17, 0, -6, -5, -6, -4, -8],
    [int(-3), -4, -2, -4, 0, -4, -4, -5, 0, -1, -1, -4, -2, 7, -5, -3, -3, 0, 10, -2, -3, -4, -2, -8],
    [int(0), -2, -2, -2, -2, -2, -2, -1, -2, 4, 2, -2, 2, -1, -1, -1, 0, -6, -2, 4, -2, -2, -1, -8],
    [int(0), -1, 2, 3, -4, 1, 3, 0, 1, -2, -3, 1, -2, -4, -1, 0, 0, -5, -3, -2, 3, 2, -1, -8],
    [int(0), 0, 1, 3, -5, 3, 3, 0, 2, -2, -3, 0, -2, -5, 0, 0, -1, -6, -4, -2, 2, 3, -1, -8],
    [int(0), -1, 0, -1, -3, -1, -1, -1, -1, -1, -1, -1, -1, -2, -1, 0, 0, -4, -2, -1, -1, -1, -1, -8],
    [int(-8), -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, 1]
  ];

  int[24][24] pam120Matrix = [
    [int(3), -3, -1, 0, -3, -1, 0, 1, -3, -1, -3, -2, -2, -4, 1, 1, 1, -7, -4, 0, 0, -1, -1, -8],
    [int(-3), 6, -1, -3, -4, 1, -3, -4, 1, -2, -4, 2, -1, -5, -1, -1, -2, 1, -5, -3, -2, -1, -2, -8],
    [int(-1), -1, 4, 2, -5, 0, 1, 0, 2, -2, -4, 1, -3, -4, -2, 1, 0, -4, -2, -3, 3, 0, -1, -8],
    [int(0), -3, 2, 5, -7, 1, 3, 0, 0, -3, -5, -1, -4, -7, -3, 0, -1, -8, -5, -3, 4, 3, -2, -8],
    [int(-3), -4, -5, -7, 9, -7, -7, -4, -4, -3, -7, -7, -6, -6, -4, 0, -3, -8, -1, -3, -6, -7, -4, -8],
    [int(-1), 1, 0, 1, -7, 6, 2, -3, 3, -3, -2, 0, -1, -6, 0, -2, -2, -6, -5, -3, 0, 4, -1, -8],
    [int(0), -3, 1, 3, -7, 2, 5, -1, -1, -3, -4, -1, -3, -7, -2, -1, -2, -8, -5, -3, 3, 4, -1, -8],
    [int(1), -4, 0, 0, -4, -3, -1, 5, -4, -4, -5, -3, -4, -5, -2, 1, -1, -8, -6, -2, 0, -2, -2, -8],
    [int(-3), 1, 2, 0, -4, 3, -1, -4, 7, -4, -3, -2, -4, -3, -1, -2, -3, -3, -1, -3, 1, 1, -2, -8],
    [int(-1), -2, -2, -3, -3, -3, -3, -4, -4, 6, 1, -3, 1, 0, -3, -2, 0, -6, -2, 3, -3, -3, -1, -8],
    [int(-3), -4, -4, -5, -7, -2, -4, -5, -3, 1, 5, -4, 3, 0, -3, -4, -3, -3, -2, 1, -4, -3, -2, -8],
    [int(-2), 2, 1, -1, -7, 0, -1, -3, -2, -3, -4, 5, 0, -7, -2, -1, -1, -5, -5, -4, 0, -1, -2, -8],
    [int(-2), -1, -3, -4, -6, -1, -3, -4, -4, 1, 3, 0, 8, -1, -3, -2, -1, -6, -4, 1, -4, -2, -2, -8],
    [int(-4), -5, -4, -7, -6, -6, -7, -5, -3, 0, 0, -7, -1, 8, -5, -3, -4, -1, 4, -3, -5, -6, -3, -8],
    [int(1), -1, -2, -3, -4, 0, -2, -2, -1, -3, -3, -2, -3, -5, 6, 1, -1, -7, -6, -2, -2, -1, -2, -8],
    [int(1), -1, 1, 0, 0, -2, -1, 1, -2, -2, -4, -1, -2, -3, 1, 3, 2, -2, -3, -2, 0, -1, -1, -8],
    [int(1), -2, 0, -1, -3, -2, -2, -1, -3, 0, -3, -1, -1, -4, -1, 2, 4, -6, -3, 0, 0, -2, -1, -8],
    [int(-7), 1, -4, -8, -8, -6, -8, -8, -3, -6, -3, -5, -6, -1, -7, -2, -6, 12, -2, -8, -6, -7, -5, -8],
    [int(-4), -5, -2, -5, -1, -5, -5, -6, -1, -2, -2, -5, -4, 4, -6, -3, -3, -2, 8, -3, -3, -5, -3, -8],
    [int(0), -3, -3, -3, -3, -3, -3, -2, -3, 3, 1, -4, 1, -3, -2, -2, 0, -8, -3, 5, -3, -3, -1, -8],
    [int(0), -2, 3, 4, -6, 0, 3, 0, 1, -3, -4, 0, -4, -5, -2, 0, 0, -6, -3, -3, 4, 2, -1, -8],
    [int(-1), -1, 0, 3, -7, 4, 4, -2, 1, -3, -3, -1, -2, -6, -1, -1, -2, -7, -5, -3, 2, 4, -1, -8],
    [int(-1), -2, -1, -2, -4, -1, -1, -2, -2, -1, -2, -2, -2, -3, -2, -1, -1, -5, -3, -1, -1, -1, -2, -8],
    [int(-8), -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, 1]
  ];

  int[24][24] pam40Matrix = [
    [int(6), -6, -3, -3, -6, -3, -2, -1, -6, -4, -5, -6, -4, -7, -1, 0, 0, -12, -7, -2, -3, -2, -3, -15],
    [int(-6), 8, -5, -9, -7, -1, -8, -8, -1, -5, -8, 1, -3, -8, -3, -2, -5, -1, -9, -7, -6, -3, -5, -15],
    [int(-3), -5, 7, 2, -9, -3, -1, -2, 1, -4, -6, 0, -7, -8, -5, 0, -1, -7, -4, -7, 6, -2, -3, -15],
    [int(-3), -9, 2, 7, -12, -2, 3, -3, -3, -6, -11, -4, -9, -13, -7, -3, -4, -13, -10, -7, 6, 2, -5, -15],
    [int(-6), -7, -9, -12, 9, -12, -12, -8, -7, -5, -13, -12, -12, -11, -7, -2, -7, -14, -3, -5, -11, -12, -8, -15],
    [int(-3), -1, -3, -2, -12, 8, 2, -6, 1, -7, -4, -2, -3, -11, -2, -4, -5, -11, -10, -6, -2, 6, -4, -15],
    [int(-2), -8, -1, 3, -12, 2, 7, -3, -4, -5, -8, -4, -6, -12, -5, -4, -5, -15, -8, -6, 2, 6, -4, -15],
    [int(-1), -8, -2, -3, -8, -6, -3, 6, -8, -9, -9, -6, -7, -8, -5, -1, -5, -13, -12, -5, -2, -4, -4, -15],
    [int(-6), -1, 1, -3, -7, 1, -4, -8, 9, -8, -5, -5, -9, -5, -3, -5, -6, -6, -3, -6, -1, 0, -4, -15],
    [int(-4), -5, -4, -6, -5, -7, -5, -9, -8, 8, -1, -5, 0, -2, -7, -6, -2, -12, -5, 2, -5, -5, -4, -15],
    [int(-5), -8, -6, -11, -13, -4, -8, -9, -5, -1, 7, -7, 1, -2, -6, -7, -6, -5, -6, -2, -8, -6, -5, -15],
    [int(-6), 1, 0, -4, -12, -2, -4, -6, -5, -5, -7, 6, -1, -12, -6, -3, -2, -10, -8, -8, -2, -3, -4, -15],
    [int(-4), -3, -7, -9, -12, -3, -6, -7, -9, 0, 1, -1, 11, -3, -7, -5, -3, -11, -10, -1, -8, -4, -4, -15],
    [int(-7), -8, -8, -13, -11, -11, -12, -8, -5, -2, -2, -12, -3, 9, -9, -6, -8, -4, 2, -7, -9, -12, -7, -15],
    [int(-1), -3, -5, -7, -7, -2, -5, -5, -3, -7, -6, -6, -7, -9, 8, -1, -3, -12, -12, -5, -6, -3, -4, -15],
    [int(0), -2, 0, -3, -2, -4, -4, -1, -5, -6, -7, -3, -5, -6, -1, 6, 1, -4, -6, -5, -1, -4, -2, -15],
    [int(0), -5, -1, -4, -7, -5, -5, -5, -6, -2, -6, -2, -3, -8, -3, 1, 7, -11, -6, -2, -2, -5, -3, -15],
    [int(-12), -1, -7, -13, -14, -11, -15, -13, -6, -12, -5, -10, -11, -4, -12, -4, -11, 13, -4, -14, -9, -13, -9, -15],
    [int(-7), -9, -4, -10, -3, -10, -8, -12, -3, -5, -6, -8, -10, 2, -12, -6, -6, -4, 10, -6, -6, -8, -7, -15],
    [int(-2), -7, -7, -7, -5, -6, -6, -5, -6, 2, -2, -8, -1, -7, -5, -5, -2, -14, -6, 7, -7, -6, -4, -15],
    [int(-3), -6, 6, 6, -11, -2, 2, -2, -1, -5, -8, -2, -8, -9, -6, -1, -2, -9, -6, -7, 6, 1, -4, -15],
    [int(-2), -3, -2, 2, -12, 6, 6, -4, 0, -5, -6, -3, -4, -12, -3, -4, -5, -13, -8, -6, 1, 6, -4, -15],
    [int(-3), -5, -3, -5, -8, -4, -4, -4, -4, -4, -5, -4, -4, -7, -4, -2, -3, -9, -7, -4, -4, -4, -4, -15],
    [int(-15), -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, 1]
  ];

  constructor() {
    dnaMapping["C"] = 0;
    dnaMapping["T"] = 1;
    dnaMapping["A"] = 2;
    dnaMapping["G"] = 3;

    proteinMapping["A"] = 0;
    proteinMapping["R"] = 1;
    proteinMapping["N"] = 2;
    proteinMapping["D"] = 3;
    proteinMapping["C"] = 4;
    proteinMapping["Q"] = 5;
    proteinMapping["E"] = 6;
    proteinMapping["G"] = 7;
    proteinMapping["H"] = 8;
    proteinMapping["I"] = 9;
    proteinMapping["L"] = 10;
    proteinMapping["K"] = 11;
    proteinMapping["M"] = 12;
    proteinMapping["F"] = 13;
    proteinMapping["P"] = 14;
    proteinMapping["S"] = 15;
    proteinMapping["T"] = 16;
    proteinMapping["W"] = 17;
    proteinMapping["Y"] = 18;
    proteinMapping["V"] = 19;
    proteinMapping["B"] = 20;
    proteinMapping["Z"] = 21;
    proteinMapping["X"] = 22;
    proteinMapping["*"] = 23;

    tracebackMapping["done"] = 0;
    tracebackMapping["left"] = 1;
    tracebackMapping["up"] = 2;
    tracebackMapping["diag"] = 3;
  }

  struct MatrixPositions {
    uint current;
    uint up;
    uint left;
    uint diag;
  }
  
  struct TracebackData {
    uint currentPos;
    uint width;
    uint k;
  }

  struct MatrixScores {
    int current;
    int up;
    int left;
    int diag;
  }

  struct AlignmentOptions {
    int gapPenalty;
    string schemeType; //nt (nucleotides) or aa (amino acids)
    string substitutionMatrix; // blosum62, blosum50, pam250, simple, smart etc.
    // bool showMatrices;
    uint limit;
  }

  struct AlignmentBranches {
    uint[] positions;
  }

  struct Matrices {
    int[] scoreMatrix;
    AlignmentBranches[] tracebackMatrix;
  }

  struct AlignmentSequences {
    string alignmentA;
    string alignmentB;
  }

  struct AlignmentOutput {
    string sequenceA;
    string sequenceB;
    AlignmentSequences[] alignments;
    // Matrices matrices;
    int score;
    uint alignmentsFound;
  }

  function needlemanWunsch(string memory sequenceA, string memory sequenceB,
    int gapPenalty,
    string memory schemeType,
    string memory substitutionMatrix,
    uint limit)
  public view returns(AlignmentOutput memory alignmentOutput) {
    return _needlemanWunsch(sequenceA, sequenceB, AlignmentOptions(gapPenalty, schemeType, substitutionMatrix, limit));
  }

  function _needlemanWunsch(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  public view returns(AlignmentOutput memory alignmentOutput) {
    uint width = bytes(sequenceA).length + 1;
    uint height = bytes(sequenceB).length + 1;
    uint currentPos = width * height - 1;

    if(alignmentOptions.limit == 0) alignmentOptions.limit = DEFAULT_ALIGNMENT_LIMIT;

    // Initialization
    (Matrices memory matrices) = initializeMatrices(width, height, alignmentOptions.gapPenalty);

    // Scoring
    uint total = 1;
    (matrices, total) = scoreMatrices(matrices, width, height, [sequenceA, sequenceB], alignmentOptions);

    // Traceback
    AlignmentSequences[] memory _alignments = new AlignmentSequences[](total);
    (_alignments, total) = traceback(TracebackData(currentPos, width, 0), [sequenceA, sequenceB], _alignments, matrices.tracebackMatrix);
    alignmentOutput.alignments = new AlignmentSequences[](total);
    for(uint i = 0; i < total; i++) {
      alignmentOutput.alignments[i] = _alignments[i];
    }

    alignmentOutput.sequenceA = sequenceA;
    alignmentOutput.sequenceB = sequenceB;
    alignmentOutput.score = matrices.scoreMatrix[currentPos];
    alignmentOutput.alignmentsFound = total;
    // if (alignmentOptions.showMatrices) alignmentOutput.matrices = matrices;

  }

  function initializeMatrices(uint width, uint height, int gapPenalty)
  internal view returns(Matrices memory matrices) {
    int[] memory scoreMatrix = new int[](width * height);
    AlignmentBranches[] memory tracebackMatrix = new AlignmentBranches[](width * height);

    for(uint i = 0; i < width || i < height; i++) {
      if(i == 0) {
        scoreMatrix[i] = 0;
        tracebackMatrix[i].positions = new uint[](1);
        tracebackMatrix[i].positions[0] = tracebackMapping["done"];
      } else {
        if(i < width) {
          scoreMatrix[i] = int(i) * gapPenalty;
          tracebackMatrix[i].positions = new uint[](1);
          tracebackMatrix[i].positions[0] = tracebackMapping["left"];
        }
        if(i < height) {
          scoreMatrix[i*width] = int(i) * gapPenalty;
          tracebackMatrix[i*width].positions = new uint[](1);
          tracebackMatrix[i*width].positions[0] = tracebackMapping["up"];
        }
      }
    }

    return Matrices(scoreMatrix, tracebackMatrix);
  }

  function scoreMatrices(Matrices memory matrices, uint width, uint height, string[2] memory sequences, AlignmentOptions memory alignmentOptions)
  internal view returns(Matrices memory, uint total) {
    MatrixPositions memory matrixPositions;
    MatrixScores memory matrixScores;

    for(uint i = 1; i < width; i++) {
      for(uint j = 1; j < height; j++) {
        matrixPositions.current = (j * width) + i;
        matrixPositions.left = matrixPositions.current - 1;
        matrixPositions.up = matrixPositions.current - width;
        matrixPositions.diag = matrixPositions.up - 1;

        matrixScores.left = matrices.scoreMatrix[matrixPositions.left] + alignmentOptions.gapPenalty;
        matrixScores.up = matrices.scoreMatrix[matrixPositions.up] + alignmentOptions.gapPenalty;
        matrixScores.diag = matrices.scoreMatrix[matrixPositions.diag] + getScore(bytes(sequences[0])[i-1], bytes(sequences[1])[j-1], alignmentOptions);

        int maxScore = matrixScores.diag;
        if (matrixScores.up > maxScore) maxScore = matrixScores.up;
        if (matrixScores.left > maxScore) maxScore = matrixScores.left;

        uint branches = (matrixScores.diag == maxScore ? 1 : 0) 
        + (matrixScores.left == maxScore ? 1 : 0) 
        + (matrixScores.up == maxScore ? 1 : 0);

        uint k = 0;
        matrices.tracebackMatrix[matrixPositions.current].positions = new uint[](branches);
        
        if (matrixScores.diag == maxScore) {
          matrices.scoreMatrix[matrixPositions.current] = matrixScores.diag;
          matrices.tracebackMatrix[matrixPositions.current].positions[k] = tracebackMapping["diag"];
          k++;
        }

        if (matrixScores.left == maxScore) {
          matrices.scoreMatrix[matrixPositions.current] = matrixScores.left;
          matrices.tracebackMatrix[matrixPositions.current].positions[k] = tracebackMapping["left"];
          k++;
        }

        if (matrixScores.up == maxScore) {
          matrices.scoreMatrix[matrixPositions.current] = matrixScores.up;
          matrices.tracebackMatrix[matrixPositions.current].positions[k] = tracebackMapping["up"];
          k++;
        }
      }
    }

    uint l = width < height ? width : height;
    total = 2;

    while(l != 0) {
      if(total > alignmentOptions.limit) {
        total = alignmentOptions.limit;
        break;
      }

      total = total + 2*(2**l);
      l--;
    }

    return(matrices, total);
  }

  function traceback(TracebackData memory tracebackData, string[2] memory sequences, AlignmentSequences[] memory alignments, AlignmentBranches[] memory tracebackMatrix)
  internal view returns(AlignmentSequences[] memory, uint total) {
    uint basePosition = tracebackData.currentPos;
    if(tracebackMatrix[basePosition].positions[0] == tracebackMapping["done"]) return (alignments, tracebackData.k + 1);

    bytes memory bytesString = new bytes(1);
    (uint row, uint col) = convertArrayPosition(tracebackData.width, basePosition);
    
    string memory prevAlignmentA = alignments[tracebackData.k].alignmentA;
    string memory prevAlignmentB = alignments[tracebackData.k].alignmentB;

    for(uint i = 0; i < tracebackMatrix[basePosition].positions.length; i++) {
      if(i > 0) {
        for(uint j = 0; j < alignments.length; j++) {
          if(bytes(alignments[j].alignmentA).length == 0) {
            tracebackData.k = j;
            alignments[tracebackData.k].alignmentA = prevAlignmentA;
            alignments[tracebackData.k].alignmentB = prevAlignmentB;
            break;
          }
        }
      }

      uint currentDir = tracebackMatrix[basePosition].positions[i];

      if(currentDir == tracebackMapping["left"]) {
        bytesString[0] = bytes(sequences[0])[col - 1];

        alignments[tracebackData.k].alignmentA = string.concat(string(bytesString), alignments[tracebackData.k].alignmentA);
        alignments[tracebackData.k].alignmentB = string.concat("-", alignments[tracebackData.k].alignmentB);
        
        tracebackData.currentPos = basePosition - 1;
      } else if(currentDir == tracebackMapping["up"]) {
        bytesString[0] = bytes(sequences[1])[row - 1];

        alignments[tracebackData.k].alignmentA = string.concat("-", alignments[tracebackData.k].alignmentA);
        alignments[tracebackData.k].alignmentB = string.concat(string(bytesString), alignments[tracebackData.k].alignmentB);

        tracebackData.currentPos = basePosition - tracebackData.width;
      } else {
        bytesString[0] = bytes(sequences[0])[col - 1];
        alignments[tracebackData.k].alignmentA = string.concat(string(bytesString), alignments[tracebackData.k].alignmentA);

        bytesString[0] = bytes(sequences[1])[row - 1];
        alignments[tracebackData.k].alignmentB = string.concat(string(bytesString), alignments[tracebackData.k].alignmentB);

        tracebackData.currentPos = basePosition - tracebackData.width - 1;
      }


      (alignments, total) = traceback(tracebackData, sequences, alignments, tracebackMatrix);
      
      if(tracebackData.k == alignments.length - 1) return (alignments, tracebackData.k + 1);
    }

    return (alignments, tracebackData.k + 1);
  }

  function getScore(bytes1 firstLetter, bytes1 secondLetter, AlignmentOptions memory alignmentOptions)
  internal view returns(int) {
    uint firstIndex;
    uint secondIndex;

    bytes32 schemeType = keccak256(bytes(alignmentOptions.schemeType));
    bytes32 substitutionMatrix = keccak256(bytes(alignmentOptions.substitutionMatrix));

    if(schemeType == keccak256(bytes("aa"))) {
      firstIndex = proteinMapping[firstLetter];
      secondIndex = proteinMapping[secondLetter];

      return substitutionMatrix == keccak256(bytes("pam250"))
        ? pam250Matrix[secondIndex][firstIndex]
        : substitutionMatrix == keccak256(bytes("pam120"))
        ? pam120Matrix[secondIndex][firstIndex]
        : substitutionMatrix == keccak256(bytes("pam40"))
        ? pam40Matrix[secondIndex][firstIndex]
        : substitutionMatrix == keccak256(bytes("blosum50"))
        ? blosum50Matrix[secondIndex][firstIndex]
        : blosum62Matrix[secondIndex][firstIndex];
    } else if(schemeType == keccak256(bytes("nt"))) {
      firstIndex = dnaMapping[firstLetter];
      secondIndex = dnaMapping[secondLetter];
      

      return substitutionMatrix == keccak256(bytes("smart")) 
        ? smarterDnaMatrix[secondIndex][firstIndex] 
        : simpleDnaMatrix[secondIndex][firstIndex];
    }
   
    return 0;
  }

  function convertArrayPosition(uint width, uint currentPosition)
  internal pure returns(uint row, uint col) {
    currentPosition = currentPosition + 1;

    row = currentPosition / width;
    col = currentPosition % width == 0 ? width : currentPosition % width;
    if(currentPosition % width != 0) row = row + 1;

    row = row - 1;
    col = col - 1;
  }

}