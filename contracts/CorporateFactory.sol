// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CorporateCard.sol";

contract CorporateFactory is Ownable {
    mapping(address => mapping(bytes32 => address[])) private corporates;
    mapping(address => string[]) private corporateKeys;
    mapping(bytes32 => bool) private corporateAndKeysHash;

    function createCorporateContract(string memory key) public {
        CorporateCard corporateCard = new CorporateCard(address(this), _msgSender());
        corporates[_msgSender()][keccak256(abi.encodePacked(key))].push(
            address(corporateCard)
        );
        bytes32 corporateHash = keccak256(abi.encodePacked(_msgSender(), key));
        if (!corporateAndKeysHash[corporateHash]) {
            corporateKeys[_msgSender()].push(key);
            corporateAndKeysHash[corporateHash] = true;
        }
    }

    function myCorporateKeys() public view returns (string[] memory) {
        return corporateKeys[_msgSender()];
    }

    function myCorporatesByKey(string memory key)
        public
        view
        returns (address[] memory)
    {
        return corporates[_msgSender()][keccak256(abi.encodePacked(key))];
    }
}
