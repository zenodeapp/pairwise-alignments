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
import '../SubstitutionMatrices.sol';
import '../../submodules/zenode-helpers/contracts/base/Owner.sol';

contract PairwiseAlignment is Owner {
  SubstitutionMatrices matricesContract;
  uint defaultLimit = 25;

  mapping(string => mapping(bytes1 => uint)) alphabetIndices;

  enum TracebackCommand {
    LEFT,
    UP,
    DIAG,
    STOP
  }

  struct AlignmentOptions {
    int gap;
    uint limit;
    string matrix;
  }

  struct ScoreOptions {
    bool enableFloor;
    int floor;
  }

  struct AlignmentData {
    bytes sequenceA;
    bytes sequenceB;
    GridTile[] tracebackMatrix;
    uint width;
    uint height;
  }
  
  struct AlignmentOutput {
    string sequenceA;
    string sequenceB;
    Alignment[] alignments;
    int score;
    uint count;
  }

  struct GridTile {
    TracebackCommand[] commands;
  }

  struct Alignment {
    string alignmentA;
    string alignmentB;
  }

  struct Pathway {
    uint gridIndex;
    TracebackCommand[] commands;
    Alignment alignment;
  }

  constructor(SubstitutionMatrices _matricesAddress) {
    _linkToMatricesAddress(_matricesAddress);
  }

  function _before(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  internal view returns(AlignmentOptions memory) {
    require(matricesContract != SubstitutionMatrices(address(0)), "No substitution matrices known, a matrices contract first needs to be linked to this contract.");
    require(bytes(sequenceA).length > 0, "Sequence A can't be an empty string.");
    require(bytes(sequenceB).length > 0, "Sequence B can't be an empty string.");

    if(alignmentOptions.limit == 0) alignmentOptions.limit = defaultLimit;

    return alignmentOptions;
  }

  function initializeMatrices(string memory sequenceA, string memory sequenceB, int gap, TracebackCommand[3] memory tracebackCommands)
  internal pure returns(AlignmentData memory alignmentData, int[] memory scoreMatrix) {
    alignmentData.sequenceA = bytes(sequenceA);
    alignmentData.sequenceB = bytes(sequenceB);
    alignmentData.width = alignmentData.sequenceA.length + 1;
    alignmentData.height = alignmentData.sequenceB.length + 1;
    
    uint size = alignmentData.width * alignmentData.height;
    uint max = alignmentData.width > alignmentData.height ? alignmentData.width : alignmentData.height;

    alignmentData.tracebackMatrix = new GridTile[](size);
    scoreMatrix = new int[](size);
    
    for (uint i = 0; i < max; i++) {
      if(i == 0) {
        scoreMatrix[i] = 0;
        alignmentData.tracebackMatrix[i].commands = new TracebackCommand[](1);
        alignmentData.tracebackMatrix[i].commands[0] = tracebackCommands[0];
      } else {
        if(i < alignmentData.width) {
          scoreMatrix[i] = int(i) * gap;
          alignmentData.tracebackMatrix[i].commands = new TracebackCommand[](1);
          alignmentData.tracebackMatrix[i].commands[0] = tracebackCommands[1];
        }

        if(i < alignmentData.height) {
          uint index = i * alignmentData.width;
          scoreMatrix[index] = int(i) * gap;
          alignmentData.tracebackMatrix[index].commands = new TracebackCommand[](1);
          alignmentData.tracebackMatrix[index].commands[0] = tracebackCommands[2];
        }
      }
    }
  }

  function scoreMatrices(int[] memory scoreMatrix, AlignmentData memory alignmentData, AlignmentOptions memory alignmentOptions, ScoreOptions memory scoreOptions)
  internal view returns(AlignmentData memory) {
    Structs.Matrix memory substitutionMatrix = matricesContract.getMatrix(alignmentOptions.matrix);

    for(uint i = 1; i < alignmentData.width; i++) {
      for(uint j = 1; j < alignmentData.height; j++) {
        uint current = (j * alignmentData.width) + i;
        uint up = current - alignmentData.width;

        // Calculate scores for left, up and diagonal
        int scoreLeft = scoreMatrix[current - 1] + alignmentOptions.gap;
        int scoreUp = scoreMatrix[up] + alignmentOptions.gap;
        int scoreDiag = scoreMatrix[up - 1] 
          + substitutionMatrix.grid
            [alphabetIndices[substitutionMatrix.alphabetId][alignmentData.sequenceB[j-1]]]
            [alphabetIndices[substitutionMatrix.alphabetId][alignmentData.sequenceA[i-1]]];

        // Set max score for the current position
        int maxScore = scoreDiag;
        if (scoreUp > maxScore) maxScore = scoreUp;
        if (scoreLeft > maxScore) maxScore = scoreLeft;
        if (scoreOptions.enableFloor && maxScore < scoreOptions.floor) maxScore = scoreOptions.floor;
        scoreMatrix[current] = maxScore;

        // Create TracebackCommand branches
        uint branches = (scoreOptions.enableFloor && maxScore == scoreOptions.floor ? 1 : ((scoreDiag == maxScore ? 1 : 0) 
          + (scoreLeft == maxScore ? 1 : 0) 
          + (scoreUp == maxScore ? 1 : 0)));
        uint k = 0;

        alignmentData.tracebackMatrix[current].commands = new TracebackCommand[](branches);

        if(scoreOptions.enableFloor && maxScore == scoreOptions.floor) {
          alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.STOP;
          continue;
        }

        if (scoreDiag == maxScore) {
          alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.DIAG;
          k++;
        }
        if (scoreLeft == maxScore) {
          alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.LEFT;
          k++;
        }
        if (scoreUp == maxScore) {
          alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.UP;
        }
      }
    }

    return alignmentData;
  }

  function traceback(AlignmentData memory alignmentData, uint[] memory startIndices, uint limit)
  internal pure returns(Alignment[] memory alignments) {
    uint i = 0;
    uint count = startIndices.length;
    if(count > limit) count = limit;
    
    bytes memory charA = new bytes(1);
    bytes memory charB = new bytes(1);

    Pathway[] memory pathways = new Pathway[](limit);
    
    for(uint l = 0; l < pathways.length && l < startIndices.length; l++) {
      pathways[l] = Pathway(
        startIndices[l],
        alignmentData.tracebackMatrix[startIndices[l]].commands,
        Alignment("", "")
      );
    }

    while(i < pathways.length) {
      if(pathways[i].commands.length == 0) break;

      Pathway memory currentPathway = Pathway(
        pathways[i].gridIndex, 
        pathways[i].commands, 
        pathways[i].alignment
      );
      
      (uint row, uint col) = get2DPosition(alignmentData.width, currentPathway.gridIndex);
      
      for(uint j = 0; j < currentPathway.commands.length; j++) {
        if(j > 0 && count == pathways.length) break;

        if(currentPathway.commands[j] == TracebackCommand.STOP) {
          i++;

          if(i == pathways.length) break;
          else continue;
        }

        uint gridIndex = currentPathway.gridIndex;
        if(currentPathway.commands[j] == TracebackCommand.DIAG) {
          gridIndex = gridIndex - alignmentData.width - 1;
          charA[0] = alignmentData.sequenceA[col - 1];
          charB[0] = alignmentData.sequenceB[row - 1];
        } else if(currentPathway.commands[j] == TracebackCommand.UP) {
          gridIndex = gridIndex - alignmentData.width;
          charA[0] = "-";
          charB[0] = alignmentData.sequenceB[row - 1];
        } else if(currentPathway.commands[j] == TracebackCommand.LEFT) {
          gridIndex = gridIndex - 1;
          charA[0] = alignmentData.sequenceA[col - 1];
          charB[0] = "-";
        }

        uint index = j > 0 ? count : i;

        pathways[index].gridIndex = gridIndex;
        pathways[index].commands = alignmentData.tracebackMatrix[gridIndex].commands;
        pathways[index].alignment = Alignment(
          string.concat(string(charA), currentPathway.alignment.alignmentA),
          string.concat(string(charB), currentPathway.alignment.alignmentB)
        );

        if(j > 0 && count != pathways.length) count++;
      }
    }

    alignments = new Alignment[](count);
    for(uint j = 0; j < count; j++) alignments[j] = pathways[j].alignment;
  }

  // Helper function used in the traceback step
  function get2DPosition(uint width, uint gridIndex)
  internal pure returns(uint row, uint col) {
    gridIndex = gridIndex + 1;

    row = gridIndex / width;
    col = gridIndex % width == 0 ? width : gridIndex % width;
    if(gridIndex % width != 0) row = row + 1;

    row = row - 1;
    col = col - 1;
  }

  function _linkToMatricesAddress(SubstitutionMatrices _address) 
  public onlyAdmin {
    matricesContract = _address;
    _relinkAlphabets();
  }

  function _relinkAlphabets() 
  public onlyAdmin {
    require(matricesContract != SubstitutionMatrices(address(0)), "No substitution matrices known, a matrices contract first needs to be linked to this contract.");

    string[] memory alphabetIds = matricesContract.getAlphabets();

    for(uint i = 0; i < alphabetIds.length; i++) {
      Structs.Alphabet memory alphabet = matricesContract.getAlphabet(alphabetIds[i]);
      bytes1[] memory alphabetChars = alphabet.array;

      for(uint j = 0; j < alphabetChars.length; j++) alphabetIndices[alphabetIds[i]][alphabetChars[j]]= j;
    }
  }
  
  function _updateDefaultLimit(uint limit)
  public onlyAdmin {
    defaultLimit = limit;
  }
}
