// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenTimelock is Ownable {
  ERC20 public token;
  uint public ENTRY_PRICE = 0.1 ether;
  uint public AMOUNT_PER_UNLOCK = 10 ether;
  uint public UNLOCK_COUNT = 3;

  mapping(uint8 => uint256) public unlock_time;
  mapping(address => bool) public is_beneficiary;
  mapping(address => mapping(uint => bool)) public beneficiary_has_claimed;

  constructor()
  {
    token = ERC20(0x0000000000000000000000000000000000000000);

    unlock_time[0] = 1642052293;
    unlock_time[1] = 1642052293;
    unlock_time[2] = 1642052293;
  }

  function claim(uint8 unlock_number) public {
    require(unlock_number < UNLOCK_COUNT, "Must be below unlock count.");
    require(block.timestamp >= unlock_time[unlock_number], "Must have reached unlock time.");
    require(is_beneficiary[msg.sender], "Beneficiary must has bought.");
    require(beneficiary_has_claimed[msg.sender][unlock_number] == false, "Beneficiary should not have claimed.");

    beneficiary_has_claimed[msg.sender][unlock_number] = true;

    token.transfer(msg.sender, AMOUNT_PER_UNLOCK);
  }

  function buy() public payable
  {
    require(msg.value == ENTRY_PRICE, "Must pay the entry price.");
    is_beneficiary[msg.sender] = true;
  }

  function withdraw() public
  {
    (bool sent, bytes memory data) = address(owner()).call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
    data;
  }
}
