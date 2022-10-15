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

contract Owner {
  address owner;
  mapping(address => bool) admins;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(_isOwner(msg.sender), "Only the owner is allowed to do this.");
    _;
  }

  modifier onlyAdmin {
    require(_isOwner(msg.sender) || _isAdmin(msg.sender), 
    "Only the owner or admins are allowed to do this.");
    _;
  }

  modifier onlyBy(address _address) {
    require(msg.sender == _address, "Sender not authorized.");
    _;
  }

  function _isOwner(address _address) public view returns(bool) {
    return _address == owner;
  }

  function _isAdmin(address _address) public view returns(bool) {
    return admins[_address];
  }

  function _changeOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }

  function _addAdmin(address _address) public onlyOwner {
    admins[_address] = true;
  }

  function _removeAdmin(address _address) public onlyOwner {
    admins[_address] = false;
  }
} 