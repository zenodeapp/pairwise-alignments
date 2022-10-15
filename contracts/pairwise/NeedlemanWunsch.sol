// SPDX-License-Identifier: UNLICENSED
// Created by Tousuke (zenodeapp - https://github.com/zenodeapp/)

pragma solidity ^0.8.17;
import './_PairwiseAlignment.sol';

contract NeedlemanWunsch is PairwiseAlignment {

  constructor(SubstitutionMatrices _matricesAddress) PairwiseAlignment(_matricesAddress) {}

  function needlemanWunsch(string memory sequenceA, string memory sequenceB, int gap, uint limit, string memory matrix)
  public view returns(Alignment[] memory alignments, int score, uint count) {
    AlignmentOutput memory alignmentOutput = _needlemanWunsch(sequenceA, sequenceB, AlignmentOptions(gap, limit, matrix));
    
    alignments = alignmentOutput.alignments;
    score = alignmentOutput.score;
    count = alignmentOutput.count;
  }

  function _needlemanWunsch(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  public view returns(AlignmentOutput memory alignmentOutput) {
    alignmentOptions = _before(sequenceA, sequenceB, alignmentOptions);
    
    // Initialize matrices
    (AlignmentData memory alignmentData, int[] memory scoreMatrix) = initializeMatrices(
      sequenceA,
      sequenceB,
      alignmentOptions.gap,
      [TracebackCommand.STOP, TracebackCommand.LEFT, TracebackCommand.UP]
    );

    // Score matrices
    ScoreOptions memory scoreOptions;
    scoreOptions.enableFloor = false;
    alignmentData = scoreMatrices(scoreMatrix, alignmentData, alignmentOptions, scoreOptions);

    // Get starting points (For Needleman-Wunsch there is only a single starting point)
    uint[] memory startingPoints = new uint[](1);
    startingPoints[0] = alignmentData.width * alignmentData.height - 1;

    // Traceback
    alignmentOutput.alignments = traceback(alignmentData, startingPoints, alignmentOptions.limit);
    
    // Remaining output
    alignmentOutput.sequenceA = sequenceA;
    alignmentOutput.sequenceB = sequenceB;
    alignmentOutput.score = scoreMatrix[startingPoints[0]];
    alignmentOutput.count = alignmentOutput.alignments.length;
  }
}