pragma solidity ^0.8.16;

import "../../src/interfaces/IEthLizards.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Mock_ethLizards is IEthlizards, ERC721 {
    constructor() ERC721("Mock_ethLizards", "MEL") {}

    function batchTransferFrom(address _from, address _to, uint256[] memory _tokenId) external override {
        for (uint256 i = 0; i < _tokenId.length; i++) {
            _safeTransfer(_from, _to, _tokenId[i], "");
        }
    }

    function Test_mint(address _to, uint256 _tokenId) public {
        _mint(_to, _tokenId);
    }
}
