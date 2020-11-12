pragma solidity 0.7.0;

import "./erc20Capped.sol";

abstract contract CustomToken is ERC20Capped {
    uint256 private expirationDate;
    constructor(
            string memory _name,
            string memory _symbol,
            uint256 _maxSupply,
            uint256 _expirationDate
        ) {
            ERC20Capped(_maxSupply);
            ERC20(_name, _symbol);
            expirationDate = _expirationDate;
        }
}
        