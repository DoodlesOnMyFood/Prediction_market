pragma solidity ^0.7.0;

import "./exchange.sol";

contract Manager is Exchange{
     //쓸 수 있는 marketid 출력
    function usableMarketId() external view onlyOwner returns (uint8[] memory){
        uint8[] memory result = new uint8[](_market_ids.length);
        uint8 counter;
        for (uint16 i = 0; i < _market_ids.length ; i++) {
            if (is_over_distribute[uint8(i)] == false) {
                result[counter] = uint8(i);
                counter++;
            }
        }
        return result;
    }
    
    function set_market_id(uint8 _market_id, string memory _question,  uint256 _expiration_date) external onlyOwner returns (bool){
        if (_already_market_id(_market_id) == true){
            if ( is_over_distribute[_market_id] = true){
                is_over_distribute[_market_id] = false;
                return true;
            }
        }
        else {
            _market_ids.push(_market_id);
            return true;
        }
        _questionsOf[_market_id] = _question;
        _expirationDateOf[_market_id] = _expiration_date;
        if (_already_market_id1(_market_id) == true){
            if ( is_over_distribute1[_market_id] = true){
                is_over_distribute1[_market_id] = false;
                return true;
            }
        }
        else {
            _market_ids1.push(_market_id);
            return true;
        }
        _questionsOf1[_market_id] = _question;
        _expirationDateOf1[_market_id] = _expiration_date;
    }
    
    function setWinner(uint8 _market_id, uint8 _tokenKind) external onlyOwner returns (bool){
        _winnerTokenOf[_market_id] = _tokenKind;
        return true;
    }
    
    function endMarket(uint8 _market_id) external onlyOwner returns (bool){
        delete _questionsOf[_market_id];
        is_over_distribute[_market_id] = false;
        delete _questionsOf1[_market_id];
        is_over_distribute1[_market_id] = false;
        return true;
    }
}
