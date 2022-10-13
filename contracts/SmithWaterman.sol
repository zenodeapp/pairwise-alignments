pragma solidity ^0.8.17;
import './base/Owner.sol';
import './SubstitutionMatrices.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/)

contract SmithWaterman is Owner {
  SubstitutionMatrices matricesContract;
  uint defaultLimit = 25;

  mapping(string => mapping(bytes1 => uint)) alphabetIndices;

  enum TracebackCommand {
    LEFT,
    UP,
    DIAG,
    STOP
  }

  constructor(SubstitutionMatrices _matricesAddress) {
    updateMatricesAddress(_matricesAddress);
  }

  struct AlignmentOptions {
    int gap;
    uint limit;
    string substitutionMatrix;
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

  struct TestStruct {
    uint[] maxScorePositions;
    uint ind;
    int totalMaxScore;
  }

  function smithWaterman(string memory sequenceA, string memory sequenceB,
    int gap,
    string memory substitutionMatrix,
    uint limit)
  public view returns(AlignmentOutput memory alignmentOutput) {
    return _smithWaterman(sequenceA, sequenceB, AlignmentOptions(gap, limit, substitutionMatrix));
  }

  function _smithWaterman(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  public view returns(AlignmentOutput memory alignmentOutput) {
    require(matricesContract != SubstitutionMatrices(address(0)), "No substitution matrices known, a matrices contract first needs to be linked to this contract.");

    if(alignmentOptions.limit == 0) alignmentOptions.limit = defaultLimit;

    // 1. Initialization
    (AlignmentData memory alignmentData, int[] memory scoreMatrix) = initializeMatrices(sequenceA, sequenceB);

    // 2. Scoring matrices
    uint[] memory startPositions;
    (alignmentData, startPositions) = scoreMatrices(scoreMatrix, alignmentData, alignmentOptions);

    // 3. Traceback & remaining output
    alignmentOutput.alignments = traceback(alignmentData, startPositions, alignmentOptions.limit);
    alignmentOutput.sequenceA = sequenceA;
    alignmentOutput.sequenceB = sequenceB;
    alignmentOutput.score = scoreMatrix[startPositions[0]];
    alignmentOutput.count = alignmentOutput.alignments.length;
  }

  function initializeMatrices(string memory sequenceA, string memory sequenceB)
  internal pure returns(AlignmentData memory alignmentData, int[] memory scoreMatrix) {
    alignmentData.sequenceA = bytes(sequenceA);
    alignmentData.sequenceB = bytes(sequenceB);
    alignmentData.width = alignmentData.sequenceA.length + 1;
    alignmentData.height = alignmentData.sequenceB.length + 1;
    
    alignmentData.tracebackMatrix = new GridTile[](alignmentData.width * alignmentData.height);
    scoreMatrix = new int[](alignmentData.width * alignmentData.height);
    uint max = alignmentData.width > alignmentData.height ? alignmentData.width : alignmentData.height;
    
    for (uint i = 0; i < max; i++) {
      if(i == 0) {
        scoreMatrix[i] = 0;
        alignmentData.tracebackMatrix[i].commands = new TracebackCommand[](1);
        alignmentData.tracebackMatrix[i].commands[0] = TracebackCommand.STOP;
      } else {
        if(i < alignmentData.width) {
          scoreMatrix[i] = 0;
          alignmentData.tracebackMatrix[i].commands = new TracebackCommand[](1);
          alignmentData.tracebackMatrix[i].commands[0] = TracebackCommand.STOP;
        }

        if(i < alignmentData.height) {
          uint index = i * alignmentData.width;
          scoreMatrix[index] = 0;
          alignmentData.tracebackMatrix[index].commands = new TracebackCommand[](1);
          alignmentData.tracebackMatrix[index].commands[0] = TracebackCommand.STOP;
        }
      }
    }
  }

  function scoreMatrices(int[] memory scoreMatrix, AlignmentData memory alignmentData, AlignmentOptions memory alignmentOptions)
  internal view returns(AlignmentData memory, uint[] memory startPositions) {
    Structs.Matrix memory substitutionMatrix = matricesContract.getMatrix(alignmentOptions.substitutionMatrix);
    TestStruct memory testStruct = TestStruct(new uint[](alignmentData.width * alignmentData.height), 0, 0);

    for(uint i = 1; i < alignmentData.width; i++) {
      for(uint j = 1; j < alignmentData.height; j++) {
        uint current = (j * alignmentData.width) + i;

        // Calculate scores for left, up and diagonal
        int scoreLeft = scoreMatrix[current - 1] + alignmentOptions.gap;
        int scoreUp = scoreMatrix[current - alignmentData.width] + alignmentOptions.gap;
        int scoreDiag = scoreMatrix[current - alignmentData.width - 1] 
          + substitutionMatrix.grid
            [alphabetIndices[substitutionMatrix.alphabetId][alignmentData.sequenceB[j-1]]]
            [alphabetIndices[substitutionMatrix.alphabetId][alignmentData.sequenceA[i-1]]];

        // Set max score for the current position
        int maxScore = scoreDiag;
        if (scoreUp > maxScore) maxScore = scoreUp;
        if (scoreLeft > maxScore) maxScore = scoreLeft;
        if (maxScore < 0) maxScore = 0;
        scoreMatrix[current] = maxScore;

        if(maxScore > testStruct.totalMaxScore) {
          testStruct.ind = 0;
          testStruct.maxScorePositions[testStruct.ind] = current;
          testStruct.totalMaxScore = maxScore;
        } else if(maxScore == testStruct.totalMaxScore) {
          testStruct.ind++;
          testStruct.maxScorePositions[testStruct.ind] = current;
        }


        // Create TracebackCommand branches
        uint branches = (maxScore == 0 ? 1 : ((scoreDiag == maxScore ? 1 : 0) 
          + (scoreLeft == maxScore ? 1 : 0) 
          + (scoreUp == maxScore ? 1 : 0)));
        uint k = 0;

        alignmentData.tracebackMatrix[current].commands = new TracebackCommand[](branches);

        if(maxScore == 0) {
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

    startPositions = new uint[](testStruct.ind + 1);
    for(uint l = 0; l < startPositions.length; l++) {
      startPositions[l] = testStruct.maxScorePositions[l];
    }
    return (alignmentData, startPositions);
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
  private pure returns(uint row, uint col) {
    gridIndex = gridIndex + 1;

    row = gridIndex / width;
    col = gridIndex % width == 0 ? width : gridIndex % width;
    if(gridIndex % width != 0) row = row + 1;

    row = row - 1;
    col = col - 1;
  }

  function updateMatricesAddress(SubstitutionMatrices _address) 
  public onlyAdmin {
    matricesContract = _address;
    updateAlphabetIndices();
  }

  function updateAlphabetIndices() 
  public onlyAdmin {
    require(matricesContract != SubstitutionMatrices(address(0)), "No substitution matrices known, a matrices contract first needs to be linked to this contract.");

    string[] memory alphabetIds = matricesContract.getAlphabets();

    for(uint i = 0; i < alphabetIds.length; i++) {
      Structs.Alphabet memory alphabet = matricesContract.getAlphabet(alphabetIds[i]);
      bytes1[] memory alphabetChars = alphabet.array;

      for(uint j = 0; j < alphabetChars.length; j++) alphabetIndices[alphabetIds[i]][alphabetChars[j]]= j;
    }
  }
  
  function updateDefaultLimit(uint limit)
  public onlyAdmin {
    defaultLimit = limit;
  }
}