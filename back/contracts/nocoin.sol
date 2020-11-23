pragma solidity 0.7.0;
import "./erc20Capped1.sol";

contract NoCoin is ERC201, ERC20Capped1{
    uint8 private constant TOKENKIND1 = 2;
    string private constant NAME1 = "NoCoin";
    string private constant SYMBOL1 = "No";
    uint256 private constant MAX_SUPPLY1 = 1000;   // 토큰은 1시장당 yes coin 1천개, no coin 1천개가 발행된다.             
    
    //nocoin 설정
    constructor() ERC20Capped1(MAX_SUPPLY1) ERC201(NAME1, SYMBOL1) {
    }
        
    //nocoin minting. 
    function _noCoin_mint(address _owner,  uint8 _market_id, uint256 _amount) internal {
        super._beforeTokenTransfer1(address(0), _market_id, _amount);    //cap넘는지 검사
        _mint1(_owner, _market_id, _amount);               
    } 
}
