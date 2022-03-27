// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CorporateCard is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Strings for string;

    struct Receiver {
        bytes32 paymentGroup;
        uint256 totalSpended;
        uint256 groupBlockIndex;
    }

    struct Billing {
        uint256 groupTotalSuply;
        uint256 totalGroupReceivers; // total of users to share billings
    }

    address public factory;
    mapping(address => uint256) private paymentValues; //StableCoin address mapping to value to pay
    mapping(bytes32 => address) private paymentGroups; // id group mapping to paymentValues id
    mapping(bytes32 => string) private groupNames;
    mapping(bytes32 => uint256) private totalGroupReceivers; // total of users to share billings
    mapping(address => Receiver) private receivers; // receiver addres mapping to paymentGroups
    mapping(bytes32 => Billing[]) private billings; // group id mappint to array of payments value

    constructor(address _factory, address _owner) {
        factory = _factory;
        transferOwnership(_owner);
    }

    function balanceOf(address receiver) public view returns (uint256) {
        bytes32 paymentGroupId = receivers[receiver].paymentGroup;
        uint256 total = 0;
        for (uint256 i = receivers[receiver].groupBlockIndex; i < billings[paymentGroupId].length; i++) {
            total = total.add(billings[paymentGroupId][i].groupTotalSuply.div(billings[paymentGroupId][i].totalGroupReceivers));
        }
        return total - receivers[receiver].totalSpended;
    }

    function createBilling(string memory paymentGroup) public onlyOwner {
        bytes32 paymentGroupId = keccak256(abi.encodePacked(paymentGroup));
        address tokenAddress = paymentGroups[paymentGroupId];
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(_msgSender());
        uint256 groupCost = totalGroupReceivers[paymentGroupId].mul(paymentValues[tokenAddress]);
        require(
            keccak256(abi.encodePacked(groupNames[paymentGroupId])) ==
                paymentGroupId,
            "A group with this name do not exists"
        );
        require(tokenBalance >= groupCost, "your balance is not enough");
        IERC20(tokenAddress).transferFrom(
            _msgSender(),
            address(this),
            groupCost
        );
        billings[paymentGroupId].push(Billing(
            groupCost,
            totalGroupReceivers[paymentGroupId]
        ));
    }

    function addReceiver(address payable receiver, string memory paymentGroup)
        public
        onlyOwner
    {
        bytes32 paymentGroupId = keccak256(abi.encodePacked(paymentGroup));
        uint256 groupBlockIndex = billings[paymentGroupId].length;
        require(receiver != payable(0), "Receiver address required");
        require(
            receivers[receiver].paymentGroup != keccak256(abi.encodePacked("")),
            "Receiver already exists"
        );
        require(
            paymentGroupId != keccak256(abi.encodePacked("")),
            "Payment Group name required"
        );
        require(
            keccak256(abi.encodePacked(groupNames[paymentGroupId])) ==
                paymentGroupId,
            "A group with this name do not exists"
        );
        totalGroupReceivers[paymentGroupId] = totalGroupReceivers[paymentGroupId].add(1);
        receivers[receiver].paymentGroup = paymentGroupId;
        receivers[receiver].groupBlockIndex = groupBlockIndex;
    }

    function createPaymentGroup(string memory groupName, address paymentValue)
        public
        onlyOwner
    {
        bytes32 paymentGroupId = keccak256(abi.encodePacked(groupName));
        require(
            paymentGroupId != keccak256(abi.encodePacked("")),
            "Payment Group name required"
        );
        require(
            keccak256(abi.encodePacked(groupNames[paymentGroupId])) !=
                paymentGroupId,
            "A group with this name already exists"
        );
        require(
            paymentValues[paymentValue] > 0,
            "Payment value addess do not exists"
        );

        groupNames[paymentGroupId] = groupName;
        paymentGroups[paymentGroupId] = paymentValue;
    }

    function createPaymentValue(address token, uint256 value) public onlyOwner {
        require(
            paymentValues[token] == 0,
            "This payment token has already been created with this value"
        );
        paymentValues[token] = value;
    }
}
