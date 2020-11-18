//we revise some codes from openzeppeline/erc20.sol.
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./context.sol";
import "./safeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context {
    using SafeMath for uint256;

    mapping (address => mapping (uint8 => uint256)) private _balances;

    mapping (address => mapping (address => mapping (uint8 => uint256))) private _allowances;

    mapping (uint8 => bool) internal is_over_distribute;  // market_id 당 distribute끝났는지 기록.
    mapping (uint8 => uint256) internal _totalSupply;
    mapping (uint8 => uint256) internal _expirationDateOf;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint8[] private _market_ids;

     /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint8 _market_id, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint8 _market_id, uint256 value);
    
    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }
    function endMarket(uint8 _market_id) external onlyOwner returns (bool){
    }

    function setExpiration(uint8 _market_id, uint256 _expiration_date)public onlyOwner returns (bool){
        _expirationDateOf[_market_id] = _expiration_date;
        return true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupplyOf(uint8 _market_id) public view returns (uint256) {
        return _totalSupply[_market_id];
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account, uint8 _market_id) public view returns (uint256) {
        return _balances[account][_market_id];
    }

    function market_ids() public view returns (uint8[] memory){
        uint8[] memory result;
        for (uint256 i = 0; i < _market_ids.length; i++){
            result[i] = _market_ids[i];
        }
        return result;
    }

    function expirationDateOf(uint8 _market_id) public view returns (uint256){
        return _expirationDateOf[_market_id];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint8 _market_id, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, _market_id, amount);
        return true;
    }

    // /**
    //  * @dev See {IERC20-allowance}.
    //  */
    // function allowance(address owner, address spender, uint8 _market_id) public view returns (uint256) {
    //     return _allowances[owner][spender][_market_id];
    // }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    // function approve(address spender, uint256 amount, uint8 _market_id) public returns (bool) {
    //     _approve(_msgSender(), spender, _market_id, amount);
    //     return true;
    // }

    // /**
    //  * @dev See {IERC20-transferFrom}.
    //  *
    //  * Emits an {Approval} event indicating the updated allowance. This is not
    //  * required by the EIP. See the note at the beginning of {ERC20}.
    //  *
    //  * Requirements:
    //  *
    //  * - `sender` and `recipient` cannot be the zero address.
    //  * - `sender` must have a balance of at least `amount`.
    //  * - the caller must have allowance for ``sender``'s tokens of at least
    //  * `amount`.
    //  */
    // function transferFrom(address sender, address recipient, uint8 _market_id, uint256 amount) public returns (bool) {
    //     _transfer(sender, recipient, _market_id, amount);
    //     _approve(sender, _msgSender(), _market_id, _allowances[sender][_msgSender()][_market_id].sub(amount, "ERC20: transfer amount exceeds allowance"));
    //     return true;
    // }

    // /**
    //  * @dev Atomically increases the allowance granted to `spender` by the caller.
    //  *
    //  * This is an alternative to {approve} that can be used as a mitigation for
    //  * problems described in {IERC20-approve}.
    //  *
    //  * Emits an {Approval} event indicating the updated allowance.
    //  *
    //  * Requirements:
    //  *
    //  * - `spender` cannot be the zero address.
    //  */
    // function increaseAllowance(address spender, uint8 _market_id, uint256 addedValue) public returns (bool) {
    //     _approve(_msgSender(), spender, _market_id, _allowances[_msgSender()][spender][_market_id].add(addedValue));
    //     return true;
    // }

    // /**
    //  * @dev Atomically decreases the allowance granted to `spender` by the caller.
    //  *
    //  * This is an alternative to {approve} that can be used as a mitigation for
    //  * problems described in {IERC20-approve}.
    //  *
    //  * Emits an {Approval} event indicating the updated allowance.
    //  *
    //  * Requirements:
    //  *
    //  * - `spender` cannot be the zero address.
    //  * - `spender` must have allowance for the caller of at least
    //  * `subtractedValue`.
    //  */
    // function decreaseAllowance(address spender, uint8 _market_id, uint256 subtractedValue) public returns (bool) {
    //     _approve(_msgSender(), spender, _market_id, _allowances[_msgSender()][spender][_market_id].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    //     return true;
    // }

    // /**
    //  * @dev Moves tokens `amount` from `sender` to `recipient`.
    //  *
    //  * This is internal function is equivalent to {transfer}, and can be used to
    //  * e.g. implement automatic token fees, slashing mechanisms, etc.
    //  *
    //  * Emits a {Transfer} event.
    //  *
    //  * Requirements:
    //  *
    //  * - `sender` cannot be the zero address.
    //  * - `recipient` cannot be the zero address.
    //  * - `sender` must have a balance of at least `amount`.
    //  */
    function _transfer(address sender, address recipient, uint8 _market_id, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender][_market_id] = _balances[sender][_market_id].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient][_market_id] = _balances[recipient][_market_id].add(amount);
        emit Transfer(sender, recipient, _market_id, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint8 _market_id, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        // _beforeTokenTransfer(address(0), account, amount);

        _totalSupply[_market_id] = _totalSupply[_market_id].add(amount);
        _balances[account][_market_id] = _balances[account][_market_id].add(amount);
        emit Transfer(address(0), account, _market_id, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint8 _market_id, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        // _beforeTokenTransfer(account, address(0), amount);

        _balances[account][_market_id] = _balances[account][_market_id].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply[_market_id] = _totalSupply[_market_id].sub(amount);
        emit Transfer(account, address(0), _market_id, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    // function _approve(address owner, address spender, uint8 _market_id, uint256 amount) internal {
    //     require(owner != address(0), "ERC20: approve from the zero address");
    //     require(spender != address(0), "ERC20: approve to the zero address");

    //     _allowances[owner][spender][_market_id] = amount;
    //     emit Approval(owner, spender, _market_id, amount);
    // }

    // /**
    //  * @dev Sets {decimals} to a value other than the default one of 18.
    //  *
    //  * WARNING: This function should only be called from the constructor. Most
    //  * applications that interact with token contracts will not expect
    //  * {decimals} to ever change, and may work incorrectly if it does.
    //  */
    // function _setupDecimals(uint8 decimals_) internal {
    //     _decimals = decimals_;
    // }

    // /**
    //  * @dev Hook that is called before any transfer of tokens. This includes
    //  * minting and burning.
    //  *
    //  * Calling conditions:
    //  *
    //  * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
    //  * will be to transferred to `to`.
    //  * - when `from` is zero, `amount` tokens will be minted for `to`.
    //  * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
    //  * - `from` and `to` are never both zero.
    //  *
    //  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
    //  */
    // // function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

     //market_ids 안에 이미 존재하는지 체크;
    function _already_market_id(uint8 _market_id) internal view returns (bool) {
        for (uint i = 0; i < _market_ids.length; i++) {
            if (_market_ids[i] == _market_id) {
                return true;
            }
        }
    }

    function set_market_id(uint8 _market_id) external onlyOwner returns (bool) {
        if (_already_market_id(_market_id) == true){
            is_over_distribute[_market_id] = true;
        }
        else {
            _market_ids.push(_market_id);
        }
    }
}
