// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';

contract CorporateCard is Ownable {
  address private factory;
  constructor() {
    factory = tx.origin;
  }
}
