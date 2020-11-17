pragma solidity 0.7.0;

import "./erc20Burnable1.sol";
import "./erc20Capped1.sol";

abstract contract CustomToken1 is ERC201, ERC20Capped1, ERC20Burnable1 {
    constructor(
            string memory _name,
            string memory _symbol,
            uint256 _maxSupply
        )
        ERC20Burnable1()
        ERC20Capped1(_maxSupply)
        ERC201(_name, _symbol)
        {
            
        }
}