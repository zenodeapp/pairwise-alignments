pragma solidity ^0.8.17;
import './base/Owner.sol';
import './SubstitutionMatrices.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/) - Work in Progress.

contract NeedlemanWunsch is Owner {
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

  function needlemanWunsch(string memory sequenceA, string memory sequenceB,
    int gap,
    string memory substitutionMatrix,
    uint limit)
  public view returns(AlignmentOutput memory alignmentOutput) {
    return _needlemanWunsch(sequenceA, sequenceB, AlignmentOptions(gap, limit, substitutionMatrix));
  }

  function _needlemanWunsch(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  public view returns(AlignmentOutput memory alignmentOutput) {
    require(matricesContract != SubstitutionMatrices(address(0)), "No substitution matrices known, a matrices contract first needs to be linked to this contract.");

    if(alignmentOptions.limit == 0) alignmentOptions.limit = defaultLimit;

    // 1. Initialization
    (AlignmentData memory alignmentData, int[] memory scoreMatrix) = initializeMatrices(sequenceA, sequenceB, alignmentOptions.gap);

    // 2. Scoring matrices
    alignmentData = scoreMatrices(scoreMatrix, alignmentData, alignmentOptions);

    // 3. Traceback & remaining output
    alignmentOutput.alignments = traceback(alignmentData, alignmentOptions.limit);
    alignmentOutput.sequenceA = sequenceA;
    alignmentOutput.sequenceB = sequenceB;
    alignmentOutput.score = scoreMatrix[alignmentData.width * alignmentData.height - 1];
    alignmentOutput.count = alignmentOutput.alignments.length;
  }

  function initializeMatrices(string memory sequenceA, string memory sequenceB, int gap)
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
          scoreMatrix[i] = int(i) * gap;
          alignmentData.tracebackMatrix[i].commands = new TracebackCommand[](1);
          alignmentData.tracebackMatrix[i].commands[0] = TracebackCommand.LEFT;
        }

        if(i < alignmentData.height) {
          uint index = i * alignmentData.width;
          scoreMatrix[index] = int(i) * gap;
          alignmentData.tracebackMatrix[index].commands = new TracebackCommand[](1);
          alignmentData.tracebackMatrix[index].commands[0] = TracebackCommand.UP;
        }
      }
    }
  }

  function scoreMatrices(int[] memory scoreMatrix, AlignmentData memory alignmentData, AlignmentOptions memory alignmentOptions)
  internal view returns(AlignmentData memory) {
    Structs.Matrix memory substitutionMatrix = matricesContract.getMatrix(alignmentOptions.substitutionMatrix);

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
        scoreMatrix[current] = maxScore;

        // Create TracebackCommand branches
        uint branches = (scoreDiag == maxScore ? 1 : 0) 
        + (scoreLeft == maxScore ? 1 : 0) 
        + (scoreUp == maxScore ? 1 : 0);
        alignmentData.tracebackMatrix[current].commands = new TracebackCommand[](branches);

        uint k = 0;
        if (scoreDiag == maxScore) {
          alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.DIAG;
          k++;
        }

        if (scoreLeft == maxScore) {
          alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.LEFT;
          k++;
        }

        if (scoreUp == maxScore) alignmentData.tracebackMatrix[current].commands[k] = TracebackCommand.UP;
      }
    }

    return alignmentData;
  }

  function traceback(AlignmentData memory alignmentData, uint limit)
  internal pure returns(Alignment[] memory alignments) {
    bytes memory charA = new bytes(1);
    bytes memory charB = new bytes(1);
    Pathway[] memory pathways = new Pathway[](limit);

    uint count = 1;
    uint i = 0;
    uint start = alignmentData.width * alignmentData.height - 1;

    pathways[0] = Pathway(
      start,
      alignmentData.tracebackMatrix[start].commands,
      Alignment("", "")
    );

    while(i < pathways.length) {
      if(pathways[i].commands.length == 0) break;

      Pathway memory currentPathway = Pathway(
        pathways[i].gridIndex, 
        pathways[i].commands, 
        pathways[i].alignment
      );
      
      (uint row, uint col) = convertArrayPosition(alignmentData.width, currentPathway.gridIndex);
      
      for(uint j = 0; j < currentPathway.commands.length; j++) {
        if(j > 0 && count == pathways.length) break;

        uint gridIndex = currentPathway.gridIndex;
        Alignment memory newAlignment;

        if(currentPathway.commands[j] == TracebackCommand.STOP) {
          i++;

          if(i == pathways.length) break;
          else continue;
          
        } else if(currentPathway.commands[j] == TracebackCommand.DIAG) {
          charA[0] = alignmentData.sequenceA[col - 1];
          charB[0] = alignmentData.sequenceB[row - 1];
          newAlignment = Alignment(
            
          string.concat(string(charA), currentPathway.alignment.alignmentA),
            string.concat(string(charB), currentPathway.alignment.alignmentB));

          gridIndex = gridIndex - alignmentData.width - 1;
        } else if(currentPathway.commands[j] == TracebackCommand.UP) {
          charB[0] = alignmentData.sequenceB[row - 1];
          newAlignment = Alignment(
            string.concat("-", currentPathway.alignment.alignmentA),
            string.concat(string(charB), currentPathway.alignment.alignmentB));

          gridIndex = gridIndex - alignmentData.width;
        } else if(currentPathway.commands[j] == TracebackCommand.LEFT) {
            charA[0] = alignmentData.sequenceA[col - 1];
          newAlignment = Alignment(
            string.concat(string(charA), currentPathway.alignment.alignmentA),
            string.concat("-", currentPathway.alignment.alignmentB));

          gridIndex = gridIndex - 1;
        }
        
        if(j > 0 && count != pathways.length) count++;

        uint index = j > 0 ? (count - 1) : i;
        
        pathways[index].gridIndex = gridIndex;
        pathways[index].commands = alignmentData.tracebackMatrix[gridIndex].commands;
        pathways[index].alignment = newAlignment;
      }
    }

    alignments = new Alignment[](count);
    for(uint j = 0; j < count; j++) alignments[j] = pathways[j].alignment;
  }

  // function tracebackRecursive(AlignmentData memory alignmentData, uint current, uint k, Alignment[] memory alignments)
  // internal view returns(Alignment[] memory, uint total) {
  //   uint basePosition = current;
  //   if(alignmentData.tracebackMatrix[basePosition].commands[0] == TracebackCommand.STOP) return (alignments, k + 1);

  //   bytes memory bytesString = new bytes(1);
  //   (uint row, uint col) = convertArrayPosition(alignmentData.width, basePosition);
    
  //   string memory prevAlignmentA = alignments[k].alignmentA;
  //   string memory prevAlignmentB = alignments[k].alignmentB;

  //   for(uint i = 0; i < alignmentData.tracebackMatrix[basePosition].commands.length; i++) {
  //     if(i > 0) {
  //       for(uint j = 0; j < alignments.length; j++) {
  //         if(bytes(alignments[j].alignmentA).length == 0) {
  //           k = j;
  //           alignments[k].alignmentA = prevAlignmentA;
  //           alignments[k].alignmentB = prevAlignmentB;
  //           break;
  //         }
  //       }
  //     }

  //     TracebackCommand currentDir = alignmentData.tracebackMatrix[basePosition].commands[i];

  //     if(currentDir == TracebackCommand.LEFT) {
  //       bytesString[0] = alignmentData.sequenceA[col - 1];

  //       alignments[k].alignmentA = string.concat(string(bytesString), alignments[k].alignmentA);
  //       alignments[k].alignmentB = string.concat("-", alignments[k].alignmentB);
        
  //       current = basePosition - 1;
  //     } else if(currentDir == TracebackCommand.UP) {
  //       bytesString[0] = alignmentData.sequenceB[row - 1];

  //       alignments[k].alignmentA = string.concat("-", alignments[k].alignmentA);
  //       alignments[k].alignmentB = string.concat(string(bytesString), alignments[k].alignmentB);

  //       current = basePosition - alignmentData.width;
  //     } else {
  //       bytesString[0] = alignmentData.sequenceA[col - 1];
  //       alignments[k].alignmentA = string.concat(string(bytesString), alignments[k].alignmentA);

  //       bytesString[0] = alignmentData.sequenceB[row - 1];
  //       alignments[k].alignmentB = string.concat(string(bytesString), alignments[k].alignmentB);

  //       current = basePosition - alignmentData.width - 1;
  //     }


  //     (alignments, total) = tracebackRecursive(alignmentData, current, k, alignments);
      
  //     if(k == alignments.length - 1) return (alignments, k + 1);
  //   }

  //   return (alignments, k + 1);
  // }

  function getScore(Structs.Matrix memory matrix, bytes1 firstLetter, bytes1 secondLetter)
  internal view returns(int) {
    uint firstIndex = alphabetIndices[matrix.alphabetId][firstLetter];
    uint secondIndex = alphabetIndices[matrix.alphabetId][secondLetter];

    return matrix.grid[secondIndex][firstIndex];
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