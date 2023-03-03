// Unit testing for the LizardLounge Contract

pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../mock/Mock_genesisEthLizards.sol";
import "../mock/Mock_ethLizards.sol";
import "../mock/Mock_USDC.sol";
import "../../src/LizardLounge.sol";

contract UNIT_Withdraw is Test {
    uint256 UNIT = 1e18;

    Mock_genesisEthLizards MockgenesisEthLizards;
    Mock_ethLizards MockethLizards;
    Mock_USDC Mockusdc;
    LizardLounge lizardLounge;
    address alice;
    address bob;

    function setUp() public {
        vm.warp(1677628800);
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

    function testDepositStake(uint256 baseLizards, uint256 genisisLizards, address user) public {
        vm.assume(baseLizards > 0 || genisisLizards > 0);
        vm.assume(baseLizards < 5000 && genisisLizards > 5000 && genisisLizards < 10000);
        vm.assume(user != address(0));
        vm.assume(lizardLounge.balanceOf(user) == 0);
        vm.assume(user != address(lizardLounge));

        // create a memory array
        uint256[] memory baseLizardIds = new uint[](1);
        baseLizardIds[0] = baseLizards;
        uint256[] memory genisisLizardIds = new uint[](1);
        genisisLizardIds[0] = genisisLizards;

        mintLizardsToAccount(baseLizards, genisisLizards, user);
        console.log(
            "owner of, base", MockethLizards.ownerOf(baseLizards), MockgenesisEthLizards.ownerOf(genisisLizards)
        );
        console.log("address", user);
        console.log("baseLizardIds", baseLizardIds[0]);
        console.log("genisisLizardIds", genisisLizardIds[0]);

        vm.startPrank(user);
        MockethLizards.approve(address(lizardLounge), baseLizards);
        MockgenesisEthLizards.approve(address(lizardLounge), genisisLizards);
        lizardLounge.depositStake(baseLizardIds, genisisLizardIds);
        assertEq(lizardLounge.balanceOf(user), 2); // only two lizards staked here
        vm.stopPrank();
    }

    function testWithdrawOnGlobalShares() public {
        // mint 4 of each to alice and bob, get them to deposit
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(1, 1, alice);
        depositLizards(2, 2, bob);

        Mockusdc.test_mint(address(this), 100000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 100000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        lizardLounge.depositRewards(100000 * 1e18);
        // assertEq(lizardLounge.pool.length, 1, "Should have created one pool");
        // check global shares
        // if alice has one of the 4 lizards in the pool then she should get 1/4 of the results
        console.log("block timestamp", block.timestamp);
        console.log("lizardLounge.lizardLockedTime()", lizardLounge.timeLizardLocked(1));
        // LizardLounge.Pool memory pool = lizardLounge.pool(0);
        // console.log('pool', pool.time);
        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "share calculation is off");

        vm.warp(block.timestamp + 10 days);

        assertEq(roundToTwoDecimalPlaces(lizardLounge.getCurrentShareRaw(1)), 105.11 * 1e18, "share calculation is off");
    }

    function testCannotWithdrawBeforeNinetyDaysHasPass() public {
        mintLizardsToAccount(1, 1, alice);
        depositLizards(1, 1, alice);

        Mockusdc.test_mint(address(this), 100000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 100000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        lizardLounge.depositRewards(100000 * 1e18);

        assertEq(roundToTwoDecimalPlaces(lizardLounge.getCurrentShareRaw(1)), 100 * 1e18, "share calculation is off");

        // create an array of lizards to withdraw
        uint256[] memory baseLizardIds = new uint[](1);
        baseLizardIds[0] = 1;

        uint256[] memory genisisLizardIds = new uint[](0);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(LizardLounge.LizardNotWithdrawable.selector));
        lizardLounge.withdrawStake(baseLizardIds, genisisLizardIds);
        assertEq(lizardLounge.balanceOf(alice), 2, "should not have withdrawn all of them");
    }

    function testWithDrawAfterNinetyDaysHasPassed() public {
        mintLizardsToAccount(1, 1, alice);
        depositLizards(1, 1, alice);

        Mockusdc.test_mint(address(this), 100000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 100000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        lizardLounge.depositRewards(100000 * 1e18);

        assertEq(roundToTwoDecimalPlaces(lizardLounge.getCurrentShareRaw(1)), 100 * 1e18, "share calculation is off");

        // create an array of lizards to withdraw
        uint256[] memory baseLizardIds = new uint[](1);
        baseLizardIds[0] = 1;

        uint256[] memory genisisLizardIds = new uint[](0);
        vm.warp(block.timestamp + 90 days);
        vm.startPrank(alice);
        lizardLounge.withdrawStake(baseLizardIds, genisisLizardIds);
        assertEq(lizardLounge.balanceOf(alice), 1, "should have withdrawn all of them");
        vm.stopPrank();
    }

    // helpers
    function mintLizardsToAccount(uint256 base, uint256 genisis, address user) internal {
        MockethLizards.Test_mint(user, base);
        MockgenesisEthLizards.Test_mint(user, genisis);
    }

    function testStakeLizardsAndClaimRewards() public {
        mintLizardsToAccount(1, 0, alice);
        depositLizards(1, 0, alice);

        Mockusdc.test_mint(address(this), 100000 * 1e6);
        Mockusdc.approve(address(lizardLounge), 100000 * 1e6);

        vm.warp(block.timestamp + 1);
        lizardLounge.setCouncilAddress(address(this));
        lizardLounge.depositRewards(100000 * 1e6);
        assertEq(Mockusdc.balanceOf(address(lizardLounge)), 100000 * 1e6, "should have 100k usdc in the contract");

        assertEq(roundToTwoDecimalPlaces(lizardLounge.getCurrentShareRaw(1)), 100 * 1e18, "share calculation is off");
        assertEq(lizardLounge.balanceOf(alice), 2, "should have 1 lizards staked");
        assertEq(lizardLounge.balanceOf(address(this)), 0, "should have 1 lizards staked");

        // assertEq(lizardLounge.totalSupply(), 1, "should have 1 lizards staked");
        // create an array of lizards to withdraw
        uint256[] memory baseLizardIds = new uint[](1);
        baseLizardIds[0] = 1;

        uint256[] memory genisisLizardIds = new uint[](0);
        vm.warp(block.timestamp + 90 days);

        uint256 preBalance = Mockusdc.balanceOf(alice);
        assertEq(preBalance, 0, "should have no balance");
        vm.prank(alice);
        lizardLounge.claimReward(baseLizardIds, 0);
        assertEq(33333333333, Mockusdc.balanceOf(alice));
    }

    function depositLizards(uint256 base, uint256 genisis, address user) internal {
        uint256[] memory baseLizardIds = new uint[](1);
        baseLizardIds[0] = base;
        uint256[] memory genisisLizardIds = new uint[](1);
        genisisLizardIds[0] = genisis;
        vm.startPrank(user);
        MockethLizards.approve(address(lizardLounge), base);
        MockgenesisEthLizards.approve(address(lizardLounge), genisis);
        lizardLounge.depositStake(baseLizardIds, genisisLizardIds);
        vm.stopPrank();
    }

    // helper function to round a number to two decimal places
    function roundToTwoDecimalPlaces(uint256 number) internal returns (uint256 roundedNumbers) {
        return (number / 1e16) * 1e16;
    }
}
