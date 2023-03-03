// Unit testing for the LizardLounge Contract

pragma solidity ^0.8.16;

import "forge-std/Test.sol";

// import mocks
import "../mock/Mock_genesisEthLizards.sol";
import "../mock/Mock_ethLizards.sol";
import "../mock/Mock_USDC.sol";
import "../../src/LizardLounge.sol";

contract UNIT_AdminBase is Test {
    uint256 UNIT = 1e18;

    Mock_genesisEthLizards MockgenesisEthLizards;
    Mock_ethLizards MockethLizards;
    IUSDc Mockusdc;
    LizardLounge lizardLounge;
    address alice;
    address bob;

    function setUp() public {
        // create a new instance of the mocked contracts and the lizard lounge
        MockgenesisEthLizards = new Mock_genesisEthLizards();
        MockethLizards = new Mock_ethLizards();
        Mockusdc = new Mock_USDC(1_000_000_000 * 1e18, 'Mockusdc', 18, 'USDC');
        lizardLounge = new LizardLounge(MockethLizards, MockgenesisEthLizards, Mockusdc);
        alice = address(0xaa);
        bob = address(0xbb);
    }

    // check basic nft view function
    function testGetName() public {
        assertEq(lizardLounge.name(), "Locked Lizard");
        assertEq(lizardLounge.symbol(), "LLZ");
    }

    function testCannotSetAllowedContactsIfNotAdmin(address _address) public {
        vm.assume(_address != lizardLounge.owner());
        vm.prank(_address);
        vm.expectRevert("Ownable: caller is not the owner");
        lizardLounge.setAllowedContracts(_address, true);
    }

    function testCannotSetMinResetValueIfNotAdmin(address _address, uint256 _newVal) public {
        vm.assume(_address != lizardLounge.owner());
        vm.prank(_address);
        vm.expectRevert("Ownable: caller is not the owner");
        lizardLounge.setMinResetValue(_newVal);
    }

    function testCannotSetResetShareValueIfNotAdmin(address _address, uint256 _newVal) public {
        vm.assume(_address != lizardLounge.owner());
        vm.prank(_address);
        vm.expectRevert("Ownable: caller is not the owner");
        lizardLounge.setResetShareValue(_newVal);
    }

    function testCannotSetDespositsActiveIfNotAdmin(address _address) public {
        vm.assume(_address != lizardLounge.owner());
        vm.prank(_address);
        vm.expectRevert("Ownable: caller is not the owner");
        lizardLounge.setDepositsActive();
    }

    function testCannotSetWhiteListCouncilIfNotAdmin(address _address) public {
        lizardLounge.setCouncilAddress(_address);
        assertEq(lizardLounge.councilAddress(), _address);
    }

    // postiive case owner can set all of the above functions

    function testCanSetAllowedContactsIfAdmin(address _address) public {
        lizardLounge.setAllowedContracts(_address, true);
        assertEq(lizardLounge.allowedContracts(_address), true);
    }

    function testCanSetMinResetValueIfAdmin(uint256 _newVal) public {
        lizardLounge.setMinResetValue(_newVal);
        assertEq(lizardLounge.minResetValue(), _newVal);
    }

    function testCanSetResetShareValueIfAdmin(address _address, uint256 _newVal) public {
        lizardLounge.setResetShareValue(_newVal);
        assertEq(lizardLounge.resetShareValue(), _newVal);
    }

    function testCanSetDespositsActiveIfAdmin(address _address) public {
        lizardLounge.setDepositsActive();
        assertEq(lizardLounge.depositsActive(), true);
    }

    function testCanSetWhiteListCouncilIfAdmin(address _address) public {
        lizardLounge.setCouncilAddress(_address);
        assertEq(lizardLounge.councilAddress(), _address);
    }

    function testOnERC721Received() public {
        vm.startPrank(alice);
        MockethLizards.Test_mint(alice, 1);
        MockethLizards.approve(address(lizardLounge), 1);
        MockethLizards.safeTransferFrom(alice, address(lizardLounge), 1, "");
    }
}
