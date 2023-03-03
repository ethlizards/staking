// Unit testing for the LizardLounge Contract

pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../mock/Mock_genesisEthLizards.sol";
import "../mock/Mock_ethLizards.sol";
import "../mock/Mock_USDC.sol";
import "../../src/LizardLounge.sol";

contract UNIT_SanityChecking is Test {
    uint256 UNIT = 1e18;

    Mock_genesisEthLizards MockgenesisEthLizards;
    Mock_ethLizards MockethLizards;
    Mock_USDC Mockusdc;
    LizardLounge lizardLounge;
    address alice;
    address bob;

    function setUp() public {
        // create a new instance of the mocked contracts and the lizard lounge
        MockgenesisEthLizards = new Mock_genesisEthLizards();
        MockethLizards = new Mock_ethLizards();
        Mockusdc = new Mock_USDC(1_000_000_000 * 1e18, 'Mockusdc', 18, 'USDC');
        lizardLounge =
            new LizardLounge(IEthlizards(MockethLizards), IGenesisEthlizards(MockgenesisEthLizards), IUSDc(Mockusdc));
        lizardLounge.setDepositsActive();
        alice = address(0xaa);
        bob = address(0xbb);
    }
}
