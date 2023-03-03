// SPDX-License-Identifier: GLP-3.0

pragma solidity ^0.8.16;

import "../../src/interfaces/IGenesisEthLizards.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Mock_genesisEthLizards is IGenesisEthlizards, ERC721 {
    uint256 tokenID;

    constructor() ERC721("Mock_genesisEthLizards", "MEGL") {}

    function setBalanceOf(address _owner, uint256 _balance) public {
        for (uint256 i = 0; i < _balance; i++) {
            _mint(_owner, tokenID);
            tokenID++;
        }
    }

    function batchTransferFrom(address _from, address _to, uint256[] memory _tokenId) external override {
        for (uint256 i = 0; i < _tokenId.length; i++) {
            transferFrom(_from, _to, _tokenId[i]);
        }
    }

    function Test_mint(address _to, uint256 _tokenId) public {
        _mint(_to, _tokenId);
        tokenID++;
    }
}
