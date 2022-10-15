// SPDX-License-Identifier: UNLICENSED
// Created by Tousuke (zenodeapp - https://github.com/zenodeapp/)

pragma solidity ^0.8.17;
import './_PairwiseAlignment.sol';

contract SmithWaterman is PairwiseAlignment {

  constructor(SubstitutionMatrices _matricesAddress) PairwiseAlignment(_matricesAddress) {}

  function smithWaterman(string memory sequenceA, string memory sequenceB, int gap, uint limit, string memory matrix)
  public view returns(Alignment[] memory alignments, int score, uint count) {
    AlignmentOutput memory alignmentOutput = _smithWaterman(sequenceA, sequenceB, AlignmentOptions(gap, limit, matrix));
    
    alignments = alignmentOutput.alignments;
    score = alignmentOutput.score;
    count = alignmentOutput.count;
  }

  function _smithWaterman(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  public view returns(AlignmentOutput memory alignmentOutput) {
    alignmentOptions = _before(sequenceA, sequenceB, alignmentOptions);
    
    // Initialize matrices
    (AlignmentData memory alignmentData, int[] memory scoreMatrix) = initializeMatrices(
      sequenceA,
      sequenceB,
      0,
      [TracebackCommand.STOP, TracebackCommand.STOP, TracebackCommand.STOP]
    );

    // Score matrices
    ScoreOptions memory scoreOptions;
    scoreOptions.enableFloor = true;
    scoreOptions.floor = 0;
    alignmentData = scoreMatrices(scoreMatrix, alignmentData, alignmentOptions, scoreOptions);

    // Get starting points (For Smith-Waterman there can be multiple starting points)
    uint[] memory startingPoints = getStartingPoints(scoreMatrix, alignmentOptions.limit);

    // Traceback
    alignmentOutput.alignments = traceback(alignmentData, startingPoints, alignmentOptions.limit);
    
    // Remaining output
    alignmentOutput.sequenceA = sequenceA;
    alignmentOutput.sequenceB = sequenceB;
    alignmentOutput.score = scoreMatrix[startingPoints[0]];
    alignmentOutput.count = alignmentOutput.alignments.length;
  }

  function getStartingPoints(int[] memory scoreMatrix, uint limit)
  internal pure returns(uint[] memory) {
    require(scoreMatrix.length > 0);

    int highestScore = scoreMatrix[scoreMatrix.length - 1];
    uint[] memory indices = new uint[](limit);
    uint count = 0;

    for(uint i = scoreMatrix.length; i > 0; i--) {
      if(scoreMatrix[i - 1] > highestScore) {
        highestScore = scoreMatrix[i - 1];
        count = 1;
        indices[count - 1] = i - 1;
      } else if(scoreMatrix[i - 1] == highestScore) {
        if(count == limit) continue;

        count++;
        indices[count - 1] = i - 1;
      } 
    }

    // If we found less than the given limit, shorten the array to return
    if (count < limit) {
      uint[] memory startingPoints = new uint[](count);
      for(uint j = 0; j < startingPoints.length; j++) startingPoints[j] = indices[j];

      return startingPoints;
    } else {
      return indices;
    }
  }
}