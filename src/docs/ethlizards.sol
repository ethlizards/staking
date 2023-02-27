// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ethlizards is ERC721 {
    constructor() ERC721("ETHLIZARD TEST", "TEST") {}

    function mint(uint256 _amount) external {
        for (uint256 i = 0; i < _amount; i++) {
            _mint(msg.sender, i);
        }
    }

    function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds) public {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            transferFrom(_from, _to, _tokenIds[i]);
        }
    }
}
