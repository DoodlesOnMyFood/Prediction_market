pragma solidity ^0.7.0;
import "./tokenTrade.sol";

contract Exchange is TokenTrade {
    uint256 constant private REWARD = 1*10**18;
    mapping (uint8 => uint8) internal _winnerTokenOf;

    modifier expirationCheck(uint8 _market_id){
        require (block.timestamp > _expirationDateOf[_market_id], "the result is not happend yet");
        _;
    }

    function winnerTokenOf(uint8 _market_id) public view returns(uint8){
        return _winnerTokenOf[_market_id];
    }
    //exchange token for eth.
    function exchange(uint8 _market_id) external expirationCheck(_market_id) returns (bool){
        uint256 tokenCount;
        if (1 == winnerTokenOf(_market_id)){
            tokenCount = balanceOf(msg.sender, _market_id);
        }
        else if (2 == winnerTokenOf(_market_id)){
            tokenCount = balanceOf1(msg.sender, _market_id);
        }
        require(rewardTransfer(msg.sender, tokenCount*REWARD)==true);
        _burn(msg.sender, _market_id, balanceOf(msg.sender, _market_id));
        _burn1(msg.sender, _market_id, balanceOf1(msg.sender, _market_id));
    }

}

