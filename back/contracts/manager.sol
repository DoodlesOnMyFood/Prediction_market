pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
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
            if ( is_over_distribute[_market_id] == true){
                is_over_distribute[_market_id] = false;
                is_over_distribute1[_market_id] = false;
            }
        }
        else {
            _market_ids.push(_market_id);
            _market_ids1.push(_market_id);
        }
        _questionsOf[_market_id] = _question;
        _expirationDateOf[_market_id] = _expiration_date;
        _questionsOf1[_market_id] = _question;
        _expirationDateOf1[_market_id] = _expiration_date;
        return true;
    }
    
    function setWinner(uint8 _market_id, uint8 _tokenKind) external onlyOwner returns (bool){
        _winnerTokenOf[_market_id] = _tokenKind;
        return true;
    }
    
    function endMarket(uint8 _market_id) external onlyOwner returns (bool){
        delete _winnerTokenOf[_market_id];
        delete _questionsOf[_market_id];
        delete _totalSupply[_market_id];
        delete _expirationDateOf[_market_id];
        is_over_distribute[_market_id] = false;
        delete _questionsOf1[_market_id];
        delete _totalSupply1[_market_id];
        delete _expirationDateOf1[_market_id];
        is_over_distribute1[_market_id] = false;
        return true;
    }
    
    function marketData() public view returns (uint8[] memory, string[] memory, uint256[] memory){
        uint8[] memory ids = new uint8[](_market_ids.length);
        string[] memory questions = new string[](_market_ids.length);
        uint256[] memory expirationDates = new uint256[](_market_ids.length);
        for (uint i = 0; i < _market_ids.length; i++){
            ids[i] = _market_ids[i];
            questions[i] = _questionsOf[ids[i]];
            expirationDates[i] = _expirationDateOf[ids[i]];
        }
        return (ids, questions, expirationDates);
    }
}
