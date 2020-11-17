pragma solidity 0.7.0;

import "./erc20Burnable.sol";
import "./erc20Capped.sol";


abstract contract CustomToken is ERC20, ERC20Capped, ERC20Burnable {
    constructor(
            string memory _name,
            string memory _symbol,
            uint256 _maxSupply
        )
        ERC20Burnable()
        ERC20Capped(_maxSupply)
        ERC20(_name, _symbol)
        {
            
        }
}