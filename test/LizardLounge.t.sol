// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "../src/LizardLounge.sol";
import "forge-std/Test.sol";

contract LizardLoungeTest is Test {
    LizardLounge lizardLoungeDeployment;

    constructor(IEthlizards ethLizardsAddress, IGenesisEthlizards genesisLizaddress, IUSDc USDCAddress) {
        lizardLoungeDeployment = new LizardLounge(ethLizardsAddress, genesisLizaddress, USDCAddress);
    }

    function setUp() public {
        lizardLoungeDeployment.setDepositsActive();
    }

    function testDepositMintRegular() public {
        uint256[] memory regLizArray = new uint256[](3);
        regLizArray[0] = 1;
        regLizArray[1] = 6;
        regLizArray[2] = 50;
        uint256[] memory genLizArray;
        lizardLoungeDeployment.depositStake(regLizArray, genLizArray);
        assertEq(lizardLoungeDeployment.ownerOf(1), msg.sender);
        assertEq(lizardLoungeDeployment.ownerOf(6), msg.sender);
        assertEq(lizardLoungeDeployment.ownerOf(50), msg.sender);
    }

    function testDepositRemintRegular() public {}

    function testDepositMintGenesis() public {}

    function testDepositRemintGenesis() public {}

    function testWithdraw() public {}

    function testFailTimeWithdraw() public {}

    function testFailWrongIdWithdraw() public {}
}
