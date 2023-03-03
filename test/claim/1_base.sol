// Unit testing for the LizardLounge Contract

pragma solidity ^0.8.16;

import "forge-std/Test.sol";

// import mocks
import "../mock/Mock_genesisEthLizards.sol";
import "../mock/Mock_ethLizards.sol";
import "../mock/Mock_USDC.sol";
import "../../src/LizardLounge.sol";

contract UNIT_Base is Test {
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
        vm.startPrank(alice);
    }

    // mint lizard and check balance, deposit to lizard lounge
    function testRevertMintLizardAndDeposit() public {
        // mint lizard
        MockethLizards.Test_mint(alice, 1);
        // check balance
        assertEq(MockethLizards.balanceOf(alice), 1);

        // create a list
        uint256[] memory _tokenId = new uint256[](1);
        _tokenId[0] = 1;

        // create a second list for genesis token
        uint256[] memory _genesisTokenId = new uint256[](1);
        vm.expectRevert();
        lizardLounge.depositStake(_tokenId, _genesisTokenId);

        // set deposits enabled
        assertEq(lizardLounge.balanceOf(alice), 0, "deposited one lizard, should get one LLZ back");
    }

    function testCannotStakeLizardIfNotOwner(address _address) public {
        vm.assume(_address != address(0));

        // create a list
        uint256[] memory _tokenId = new uint256[](0);
        // _tokenId[0] = 1;

        // create a second list for genesis token
        uint256[] memory _genesisTokenId = new uint256[](0);
        // _genesisTokenId[0] = 1;

        vm.stopPrank();
        vm.prank(_address);
        lizardLounge.depositStake(_tokenId, _genesisTokenId);
        assertEq(lizardLounge.balanceOf(alice), 0, "should not be able to stake lizard if not owner");
    }

    function testNoMintWhenEmptyArrayPassedIn() public {
        // create a list
        uint256[] memory _tokenId = new uint256[](0);
        uint256[] memory _genesisTokenId = new uint256[](0);
        lizardLounge.depositStake(_tokenId, _genesisTokenId);
        assertEq(lizardLounge.balanceOf(alice), 0, "should not be able to mint when empty array passed in");
    }
}
