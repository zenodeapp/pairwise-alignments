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
    string substitutionMatrix; // blosum62, blosum50, pam250, simple, smart etc.
    // bool showMatrices;
    uint limit;
  }

  struct AlignmentBranches {
    TracebackCommand[] positions;
  }

  struct Matrices {
    int[] scoreMatrix;
    AlignmentBranches[] tracebackMatrix;
  }

  struct Alignment {
    string alignmentA;
    string alignmentB;
  }

  struct AlignmentOutput {
    string sequenceA;
    string sequenceB;
    Alignment[] alignments;
    int score;
    uint alignmentsFound;
  }



  function needlemanWunsch(string memory sequenceA, string memory sequenceB,
    int gapPenalty,
    string memory substitutionMatrix,
    uint limit)
  public view returns(AlignmentOutput memory alignmentOutput) {
    return _needlemanWunsch(sequenceA, sequenceB, AlignmentOptions(gapPenalty, substitutionMatrix, limit));
  }

  function _needlemanWunsch(string memory sequenceA, string memory sequenceB, AlignmentOptions memory alignmentOptions)
  public view returns(AlignmentOutput memory alignmentOutput) {
    require(matricesContract != SubstitutionMatrices(address(0)), "No substitution matrices known, a matrices contract first needs to be linked to this contract.");
    Structs.Matrix memory matrix = matricesContract.getMatrix(alignmentOptions.substitutionMatrix);

    uint width = bytes(sequenceA).length + 1;
    uint height = bytes(sequenceB).length + 1;
    uint currentPos = width * height - 1;

    if(alignmentOptions.limit == 0) alignmentOptions.limit = defaultLimit;

    // Initialization
    (Matrices memory matrices) = initializeMatrices(width, height, alignmentOptions.gapPenalty);

    // Scoring
    uint total = 1;
    (matrices, total) = scoreMatrices(matrices, width, height, [sequenceA, sequenceB], alignmentOptions, matrix);

    // Traceback
    Alignment[] memory _alignments = new Alignment[](total);
    (_alignments, total) = traceback(TracebackData(currentPos, width, 0), [sequenceA, sequenceB], _alignments, matrices.tracebackMatrix);
    alignmentOutput.alignments = new Alignment[](total);
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
  internal pure returns(Matrices memory matrices) {
    int[] memory scoreMatrix = new int[](width * height);
    AlignmentBranches[] memory tracebackMatrix = new AlignmentBranches[](width * height);

    for(uint i = 0; i < width || i < height; i++) {
      if(i == 0) {
        scoreMatrix[i] = 0;
        tracebackMatrix[i].positions = new TracebackCommand[](1);
        tracebackMatrix[i].positions[0] = TracebackCommand.STOP;
      } else {
        if(i < width) {
          scoreMatrix[i] = int(i) * gapPenalty;
          tracebackMatrix[i].positions = new TracebackCommand[](1);
          tracebackMatrix[i].positions[0] = TracebackCommand.LEFT;
        }
        if(i < height) {
          scoreMatrix[i*width] = int(i) * gapPenalty;
          tracebackMatrix[i*width].positions = new TracebackCommand[](1);
          tracebackMatrix[i*width].positions[0] = TracebackCommand.UP;
        }
      }
    }

    return Matrices(scoreMatrix, tracebackMatrix);
  }

  function scoreMatrices(Matrices memory matrices, uint width, uint height, string[2] memory sequences, AlignmentOptions memory alignmentOptions, Structs.Matrix memory matrix)
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
        matrixScores.diag = matrices.scoreMatrix[matrixPositions.diag] + getScore(matrix, bytes(sequences[0])[i-1], bytes(sequences[1])[j-1]);

        int maxScore = matrixScores.diag;
        if (matrixScores.up > maxScore) maxScore = matrixScores.up;
        if (matrixScores.left > maxScore) maxScore = matrixScores.left;

        uint branches = (matrixScores.diag == maxScore ? 1 : 0) 
        + (matrixScores.left == maxScore ? 1 : 0) 
        + (matrixScores.up == maxScore ? 1 : 0);

        uint k = 0;
        matrices.tracebackMatrix[matrixPositions.current].positions = new TracebackCommand[](branches);
        
        if (matrixScores.diag == maxScore) {
          matrices.scoreMatrix[matrixPositions.current] = matrixScores.diag;
          matrices.tracebackMatrix[matrixPositions.current].positions[k] = TracebackCommand.DIAG;
          k++;
        }

        if (matrixScores.left == maxScore) {
          matrices.scoreMatrix[matrixPositions.current] = matrixScores.left;
          matrices.tracebackMatrix[matrixPositions.current].positions[k] = TracebackCommand.LEFT;
          k++;
        }

        if (matrixScores.up == maxScore) {
          matrices.scoreMatrix[matrixPositions.current] = matrixScores.up;
          matrices.tracebackMatrix[matrixPositions.current].positions[k] = TracebackCommand.UP;
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

  function traceback(TracebackData memory tracebackData, string[2] memory sequences, Alignment[] memory alignments, AlignmentBranches[] memory tracebackMatrix)
  internal view returns(Alignment[] memory, uint total) {
    uint basePosition = tracebackData.currentPos;
    if(tracebackMatrix[basePosition].positions[0] == TracebackCommand.STOP) return (alignments, tracebackData.k + 1);

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

      TracebackCommand currentDir = tracebackMatrix[basePosition].positions[i];

      if(currentDir == TracebackCommand.LEFT) {
        bytesString[0] = bytes(sequences[0])[col - 1];

        alignments[tracebackData.k].alignmentA = string.concat(string(bytesString), alignments[tracebackData.k].alignmentA);
        alignments[tracebackData.k].alignmentB = string.concat("-", alignments[tracebackData.k].alignmentB);
        
        tracebackData.currentPos = basePosition - 1;
      } else if(currentDir == TracebackCommand.UP) {
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