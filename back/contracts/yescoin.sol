pragma solidity 0.7.0;

import "./erc20Capped.sol";

contract YesCoin is ERC20, ERC20Capped{
    uint8 private constant TOKENKIND = 0;
    string private constant NAME = "YesCoin";
    string private constant SYMBOL = "Yes";
    uint256 private constant MAX_TOKEN_COUNT = 1000;    //1천개
    uint256 private constant MAX_SUPPLY = MAX_TOKEN_COUNT;   // 토큰은 1시장당 yes coin 1천개, no coin 1천개가 발행된다.             

    //yescoin 설정
    constructor() ERC20Capped(MAX_SUPPLY) ERC20(NAME, SYMBOL) {  
    }
        
    //yescoin minting. 
    function _yesCoin_mint(address _owner,  uint8 _market_id, uint256 _amount) internal {
        super._beforeTokenTransfer(address(0), _market_id, _amount);    //cap넘는지 검사
        _mint(_owner, _market_id, _amount);               
    } 
}
