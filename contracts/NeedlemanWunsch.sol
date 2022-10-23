// SPDX-License-Identifier: MIT
// Created by ZENODE (zenodeapp - https://github.com/zenodeapp/)

/**********************************************************************************
* MIT License                                                                     *
* Copyright (c) 2022 ZENODE                                                       *
*                                                                                 *
* Permission is hereby granted, free of charge, to any person obtaining a copy    *
* of this software and associated documentation files (the "Software"), to deal   *
* in the Software without restriction, including without limitation the rights    *
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell       *
* copies of the Software, and to permit persons to whom the Software is           *
* furnished to do so, subject to the following conditions:                        *
*                                                                                 *
* The above copyright notice and this permission notice shall be included in all  *
* copies or substantial portions of the Software.                                 *
*                                                                                 *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   *
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   *
* SOFTWARE.                                                                       *
**********************************************************************************/

pragma solidity ^0.8.17;
import './_PairwiseAlignment.sol';

contract NeedlemanWunsch is PairwiseAlignment {

  constructor(SubstitutionMatrices _matricesAddress) PairwiseAlignment(_matricesAddress) {}

  function needlemanWunsch(string memory sequenceA, string memory sequenceB, int gap, uint limit, string memory matrix)
  public view returns(AlignmentOutput memory) {
    return _needlemanWunsch(sequenceA, sequenceB, AlignmentOptions(gap, limit, matrix));
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