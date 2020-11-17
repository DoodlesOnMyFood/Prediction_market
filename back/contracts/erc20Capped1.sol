// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./erc201.sol";
/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */

abstract contract ERC20Capped1 is ERC201 {
    using SafeMath for uint256;

    uint256 private _cap1;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (uint256 cap) {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap1 = cap;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap1() public view returns (uint256) {
        return _cap1;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer1(address from, uint8 _market_id, uint256 amount) internal {

        if (from == address(0)) { // When minting tokens
            if (totalSupplyOf1(_market_id).add(amount) == _cap1) {
                is_over_distribute1[_market_id] = true;
            }
            require(totalSupplyOf1(_market_id).add(amount) <= _cap1, "ERC20Capped: cap exceeded");
        }
    }
}