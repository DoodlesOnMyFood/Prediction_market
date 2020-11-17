// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



// /*
// Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// .*/


// pragma solidity ^0.7.0;

// import "./EIP20InterFace.sol";


// contract EIP20 is EIP20Interface {

//     uint256 constant private MAX_UINT256 = 2**256 - 1;
//     mapping (address => uint256) public balances;
//     mapping (address => mapping (address => uint256)) public allowed;
//     /*
//     NOTE:
//     The following variables are OPTIONAL vanities. One does not have to include them.
//     They allow one to customise the token contract & in no way influences the core functionality.
//     Some wallets/interfaces might not even bother to look at this information.
//     */
//     string public name;                   //fancy name: eg Simon Bucks
//     uint8 public decimals;                //How many decimals to show.
//     string public symbol;                 //An identifier: eg SBX

//     constructor (
//         uint256 _initialAmount,
//         string memory _tokenName,
//         uint8 _decimalUnits,
//         string memory _tokenSymbol
//         ) public { 
//         balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
//         totalSupply = _initialAmount;                        // Update total supply
//         name = _tokenName;                                   // Set the name for display purposes
//         decimals = _decimalUnits;                            // Amount of decimals for display purposes
//         symbol = _tokenSymbol;                               // Set the symbol for display purposes
//     }

//     function transfer(address _to, uint256 _value) public override returns (bool success) {
//         require(balances[msg.sender] >= _value);
//         balances[msg.sender] -= _value;
//         balances[_to] += _value;
//         emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
//         return true;
//     }

//     function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
//         uint256 allowance = allowed[_from][msg.sender];
//         require(balances[_from] >= _value && allowance >= _value);
//         balances[_to] += _value;
//         balances[_from] -= _value;
//         if (allowance < MAX_UINT256) {
//             allowed[_from][msg.sender] -= _value;
//         }
//         emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
//         return true;
//     }

//     function balanceOf(address _owner) public override view returns (uint256 balance) {
//         return balances[_owner];
//     }

//     function approve(address _spender, uint256 _value) public override returns (bool success) {
//         allowed[msg.sender][_spender] = _value;
//         emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
//         return true;
//     }

//     function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
//         return allowed[_owner][_spender];
//     }
// }
