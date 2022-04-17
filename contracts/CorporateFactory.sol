// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CorporateCard.sol";

contract CorporateFactory is Ownable {
    mapping(address => mapping(bytes32 => address[])) private contracts;
    mapping(address => string[]) private groups;
    mapping(bytes32 => bool) private listOfExistsGroup;

    function createContract(string memory name, string memory groupName)
        public
    {
        CorporateCard corporateCard = new CorporateCard(
            address(this),
            _msgSender(),
            name
        );

        bytes32 groupHash = keccak256(
            abi.encodePacked(_msgSender(), groupName)
        );

        if (!listOfExistsGroup[groupHash]) {
            groups[_msgSender()].push(groupName);
            listOfExistsGroup[groupHash] = true;
        }

        contracts[_msgSender()][keccak256(abi.encodePacked(groupName))].push(
            address(corporateCard)
        );
    }

    function myGroups() public view returns (string[] memory) {
        return groups[_msgSender()];
    }

    function myContractsByGoup(string memory groupName)
        public
        view
        returns (address[] memory)
    {
        return contracts[_msgSender()][keccak256(abi.encodePacked(groupName))];
    }
}
