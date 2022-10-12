pragma solidity ^0.8.17;
import './base/Owner.sol';
import '../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/).

contract SubstitutionMatrices is Owner {
  mapping(string => Structs.Matrix) matrices;
  mapping(string => Structs.Alphabet) alphabets;
  mapping(string => mapping(bytes1 => uint)) alphabetsMapping;
  string[] public insertedMatrices;
  string[] public insertedAlphabets;

  function isAlphabet(string memory id)
  public view returns(bool exists) {
    return bytes(alphabets[id].id).length > 0;
  }
  
  function testAlphabet(string memory id, bytes1[] memory alphabet)
  public view returns(bool isValid) {
    require(isAlphabet(id), "Testing failed for this alphabet does not exist, insert the alphabet first before testing.");
    
    bytes1[] memory _alphabet = alphabets[id].array;
    require(!(_alphabet.length < alphabet.length), "The provided alphabet contains more characters than the stored alphabet!");
    
    isValid = true;
    for(uint i = 0; i < alphabet.length; i++) {
      if(alphabet[i] != _alphabet[i]) {
        isValid = false;
        break;
      }
    }
  }

  function insertAlphabet(string memory id, bytes1[] memory alphabet)
  public onlyAdmin {
    require(!isAlphabet(id), "Alphabet with this id already exists, consider using a different name or update the alphabet.");
    
    alphabets[id].id = id;
    alphabets[id].array = alphabet;
    insertedAlphabets.push(id);
    alphabets[id].index = insertedAlphabets.length - 1;

    for(uint i = 0; i < alphabet.length; i++) {
      alphabetsMapping[id][alphabet[i]] = i + 1;
    }
  }

  function updateAlphabet(string memory id, bytes1[] memory alphabet)
  public onlyAdmin {
    require(isAlphabet(id), "Alphabet can't be updated for it does not exist.");
    require(alphabets[id].usage == 0, "This alphabet is being used by a matrix and can therefore not be updated.");
    
    alphabets[id].id = id;
    alphabets[id].array = alphabet;

    for(uint i = 0; i < alphabet.length; i++) {
      alphabetsMapping[id][alphabet[i]] = i + 1;
    }
  }

  function deleteAlphabet(string memory id)
  public onlyAdmin {
    require(isAlphabet(id), "This alphabet does not exist.");
    require(alphabets[id].usage == 0, "This alphabet is being used by a matrix and can therefore not be deleted.");

    uint rowToDelete = alphabets[id].index;
    string memory lastAlphabet = insertedAlphabets[insertedAlphabets.length - 1];

    insertedAlphabets[rowToDelete] = lastAlphabet;
    alphabets[lastAlphabet].index = rowToDelete; 
    insertedAlphabets.pop();
    
    alphabets[id].id = "";
    alphabets[id].index = 0;

    for(uint i = 0; i < alphabets[id].array.length; i++) {
      alphabetsMapping[id][alphabets[id].array[i]] = 0;
    }

    delete alphabets[id].array;
  }

  function getAlphabet(string memory id)
  public view returns(Structs.Alphabet memory) {
    require(isAlphabet(id), "Alphabet does not exist.");
    
    return alphabets[id];
  }

  function getAlphabets()
  public view returns(string[] memory) {
    return insertedAlphabets;
  }

  function isMatrix(string memory id)
  public view returns(bool exists) {
    return bytes(matrices[id].id).length > 0;
  }

  function insertMatrix(string memory id, string memory alphabetId, int[][] memory grid)
  public onlyAdmin {
    require(isAlphabet(alphabetId), "This alphabet does not exist, make sure to first add an alphabet before adding a matrix.");
    require(!isMatrix(id), "Matrix with this id already exists, consider using a different name or update the matrix.");
    
    alphabets[alphabetId].usage++;
    
    matrices[id].id = id; 
    matrices[id].grid = grid; 
    matrices[id].alphabetId = alphabetId;
    insertedMatrices.push(id);
    matrices[id].index = insertedMatrices.length - 1;
  }

  function updateMatrix(string memory id, int[][] memory grid)
  public onlyAdmin {
    require(isMatrix(id), "Matrix can't be updated for it does not exist.");
    
    matrices[id].id = id;
    matrices[id].grid = grid; 
  }

  function deleteMatrix(string memory id)
  public onlyAdmin {
    require(isMatrix(id), "This Matrix does not exist.");
    
    uint rowToDelete = matrices[id].index;
    string memory lastMatrix = insertedMatrices[insertedMatrices.length - 1];

    insertedMatrices[rowToDelete] = lastMatrix;
    matrices[lastMatrix].index = rowToDelete; 
    insertedMatrices.pop();
    
    alphabets[matrices[id].alphabetId].usage--;

    matrices[id].id = "";
    matrices[id].index = 0;
    matrices[id].alphabetId = "";
    delete matrices[id].grid;
  }

  function getMatrix(string memory id)
  public view returns(Structs.Matrix memory) {
    require(isMatrix(id), "Matrix does not exist.");
    
    return matrices[id];
  }

  function getMatrices()
  public view returns(string[] memory) {
    return insertedMatrices;
  }

  function getScore(string memory matrixId, bytes1 charA, bytes1 charB)
  public view returns(int) {
    require(isMatrix(matrixId), "Matrix does not exist.");

    uint firstIndex = alphabetsMapping[matrices[matrixId].alphabetId][charA];
    uint secondIndex = alphabetsMapping[matrices[matrixId].alphabetId][charB];

    require(firstIndex > 0, "charA is not part of the matrix's alphabet.");
    require(secondIndex > 0, "charB is not part of the matrix's alphabet.");

    return matrices[matrixId].grid[secondIndex - 1][firstIndex - 1];
  }
}