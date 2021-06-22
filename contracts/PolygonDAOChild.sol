// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import {FxBaseChildTunnel} from "./matic/FxBaseChildTunnel.sol";

import "hardhat/console.sol";

contract PolygonDAOChild is FxBaseChildTunnel, Ownable {
    uint256 public latestStateId;
    address public latestRootMessageSender;
    bytes public latestData;

    constructor(address _fxChild) FxBaseChildTunnel(_fxChild) {}

    function _processMessageFromRoot(
        uint256 _stateId,
        address _sender,
        bytes memory _data
    ) internal override validateSender(_sender) {
        latestStateId = _stateId;
        latestRootMessageSender = _sender;
        latestData = _data;

        (address target, bytes memory payload) = abi.decode(_data, (address, bytes));

        (bool success, bytes memory result) = target.call(payload);
        if (!success) {
            // Next 5 lines from https://ethereum.stackexchange.com/a/83577
            if (result.length < 68) revert();
            assembly {
                result := add(result, 0x04)
            }
            console.log(abi.decode(result, (string)));
            revert(abi.decode(result, (string)));
        }
    }

    // NOTE i can't see us needing this
    function sendMessageToRoot(bytes memory message) public onlyOwner {
        _sendMessageToRoot(message);
    }
}

