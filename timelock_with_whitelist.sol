// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenTimelock is Ownable {
  ERC20 public token;
  uint public ENTRY_PRICE;
  uint public AMOUNT_PER_UNLOCK;
  uint public UNLOCK_COUNT;

  mapping(uint8 => uint256) public unlock_time;
  mapping(address => bool) public is_beneficiary;
  mapping(address => mapping(uint => bool)) public beneficiary_has_claimed;

  mapping(address => bool) public whitelist;

  constructor()
  {
    token = ERC20(0x0000000000000000000000000000000000000000);
  }

  function claim(uint8 unlock_number) public {
    require(unlock_number < UNLOCK_COUNT, "Must be below unlock count.");
    require(block.timestamp >= unlock_time[unlock_number], "Must have reached unlock time.");
    require(is_beneficiary[msg.sender], "Beneficiary must has bought.");
    require(beneficiary_has_claimed[msg.sender][unlock_number] == false, "Beneficiary should not have claimed.");
    require(whitelist[msg.sender],"Sender must be whitelisted");

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

  // Admin functions

  function setEntryPrice(uint entry_price) public onlyOwner
  {
    ENTRY_PRICE = entry_price;
  }

  function setAmountPerUnlock(uint amount_per_unlock) public onlyOwner
  {
    AMOUNT_PER_UNLOCK = amount_per_unlock;
  }

  function setUnlockCount(uint unlock_count) public onlyOwner
  {
    UNLOCK_COUNT = unlock_count;
  }

  function setUnlockTimes(uint[] memory unlock_times) public onlyOwner
  {
    setEntryPrice(unlock_times.length);
    for(uint8 i; i<unlock_times.length; i++)
    {
      unlock_time[i] = unlock_times[i];
    }
  }

  function editWhitelist(address[] memory addresses, bool value) public onlyOwner {
    for(uint i; i < addresses.length; i++){
      whitelist[addresses[i]] = value;
    }
  }
}
