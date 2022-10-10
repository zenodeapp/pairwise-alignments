pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/).

contract Owner {
  address owner;
  mapping(address => bool) admins;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(isOwner(msg.sender), "Only the owner is allowed to do this.");
    _;
  }

  modifier onlyAdmin {
    require(isOwner(msg.sender) || isAdmin(msg.sender), 
    "Only the owner or admins are allowed to do this.");
    _;
  }

  modifier onlyBy(address _address) {
    require(msg.sender == _address, "Sender not authorized.");
    _;
  }

  function isOwner(address _address) public view returns(bool) {
    return _address == owner;
  }

  function isAdmin(address _address) public view returns(bool) {
    return admins[_address];
  }

  function changeOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }

  function addAdmin(address _address) public onlyOwner {
    admins[_address] = true;
  }

  function removeAdmin(address _address) public onlyOwner {
    admins[_address] = false;
  }
} 