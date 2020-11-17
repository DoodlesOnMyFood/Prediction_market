// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./erc201.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */


abstract contract ERC20Burnable1 is ERC201 {
    using SafeMath for uint256;
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn1(uint8 _market_id, uint256 amount) public virtual {
        _burn1(_msgSender1(), _market_id, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom1(address account, uint8 _market_id, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance1(account, _msgSender1(), _market_id).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve1(account, _msgSender1(), _market_id, decreasedAllowance);
        _burn1(account, _market_id, amount);
    }
}