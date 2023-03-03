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

    function testNoPoolsCreated() public {
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(1, 1, alice);
        depositLizards(2, 2, bob);

        Mockusdc.test_mint(address(this), 100000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 100000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        lizardLounge.depositRewards(100000 * 1e18);
        // check global shares
        // if alice has one of the 4 lizards in the pool then she should get 1/4 of the results
        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "share calculation is off");
    }

    function testGetCurrentShareWithoutTimePassed() public {
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(1, 1, alice);
        depositLizards(2, 2, bob);

        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "share calculation is off start");
    }

    function testStakeBeforePoolCreated() public {
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(1, 1, alice);
        depositLizards(2, 2, bob);

        Mockusdc.test_mint(address(this), 100000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 100000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        // check global shares
        // if alice has one of the 4 lizards in the pool then she should get 1/4 of the results
        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "share calculation is off start");

        // TODO: need to check the maths for this is defs off
        vm.warp(block.timestamp + 15 days);
        lizardLounge.depositRewards(100000 * 1e18);

        vm.warp(block.timestamp + 30 days);
        assertEq(roundToTwoDecimalPlaces(lizardLounge.getCurrentShareRaw(1)), 117.94 * 1e18, "share calculation is off");
    }

    function testStakeBeforeCreationOfTwoPools() public {
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(1, 1, alice);
        depositLizards(2, 2, bob);

        Mockusdc.test_mint(address(this), 200000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 200000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        // check global shares
        // if alice has one of the 4 lizards in the pool then she should get 1/4 of the results
        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "start share calculation is off");

        // 30 Days passed
        vm.warp(block.timestamp + 30 days);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            116.1400082895 * 1e18,
            0.001 * 1e18,
            "share calculation is off after 30 days "
        );

        lizardLounge.depositRewards(100000 * 1e18);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            103.2280016579 * 1e18,
            0.001 * 1e18,
            "share calculation is off after first reset"
        );

        vm.warp(block.timestamp + 30 days);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            119.8890096826 * 1e18,
            0.001 * 1e18,
            "share calculation is off after first reset and 30 days"
        );

        lizardLounge.depositRewards(100000 * 1e18);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            103.97780193652 * 1e18,
            0.001 * 1e18,
            "share calculation is off after second reset"
        );

        vm.warp(block.timestamp + 30 days);
        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)), 120.7598277884 * 1e18, 0.001 * 1e18, "share calculation is off final"
        );
    }

    function testStakeInbetweenPools() public {
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(2, 2, bob);

        Mockusdc.test_mint(address(this), 100000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 300000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        vm.warp(block.timestamp + 15 days);
        lizardLounge.depositRewards(100000 * 1e18);

        depositLizards(1, 1, alice);
        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "share calculation is off");

        vm.warp(block.timestamp + 30 days);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            116.1400082895 * 1e18,
            0.001 * 1e18,
            "share calculation is off after 30 days "
        );

        lizardLounge.depositRewards(100000 * 1e18);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            103.2280016579 * 1e18,
            0.001 * 1e18,
            "share calculation is off after first reset"
        );

        vm.warp(block.timestamp + 30 days);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(1)),
            119.8890096826 * 1e18,
            0.001 * 1e18,
            "share calculation is off after first reset and 30 days"
        );
    }

    function testTwoPoolsCreatedAndUserWasStakedAfterThePools() public {
        mintLizardsToAccount(1, 1, alice);
        mintLizardsToAccount(2, 2, bob);
        depositLizards(1, 1, alice);

        Mockusdc.test_mint(address(this), 200000 * 1e18);
        Mockusdc.approve(address(lizardLounge), 200000 * 1e18);
        lizardLounge.setCouncilAddress(address(this));
        // check global shares
        // if alice has one of the 4 lizards in the pool then she should get 1/4 of the results
        assertEq(lizardLounge.getCurrentShareRaw(1), 100 * 1e18, "share calculation is off");

        vm.warp(block.timestamp + 15 days);
        lizardLounge.depositRewards(100000 * 1e18);

        vm.warp(block.timestamp + 30 days);

        lizardLounge.depositRewards(100000 * 1e18);
        vm.warp(block.timestamp + 30 days);

        depositLizards(2, 2, bob);

        vm.warp(block.timestamp + 30 days);

        assertApproxEqAbs(
            (lizardLounge.getCurrentShareRaw(2)),
            116.1400082895 * 1e18,
            0.001 * 1e18,
            "share calculation is off after 30 days "
        );
    }

    // helpers
    function mintLizardsToAccount(uint256 base, uint256 genisis, address user) internal {
        MockethLizards.Test_mint(user, base);
        MockgenesisEthLizards.Test_mint(user, genisis);
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
