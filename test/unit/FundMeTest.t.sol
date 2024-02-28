// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("Karan");
    uint256 constant SEND_VALUE = 0.5 ether;
    uint256 constant STARTING_BALANCE = 500 ether;
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
 
    function testMinDollarAmount() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testMsgSenderIsOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateSuccess() public funded {
        assertEq(SEND_VALUE, fundMe.getAddressToAmountFunded(USER));
    }

    function testAddsFunderToArray() public funded {
        assertEq(USER, fundMe.getFunder(0));
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 fundMeBalanceAfter = address(fundMe).balance;

        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore+fundMeBalanceBefore);
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        for(uint160 i=1; i<numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 fundMeBalanceAfter = address(fundMe).balance;

        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore+fundMeBalanceBefore);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        for(uint160 i=1; i<numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 fundMeBalanceAfter = address(fundMe).balance;

        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore+fundMeBalanceBefore);
    }

}