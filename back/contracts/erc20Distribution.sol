pragma solidity ^0.7.0;

import "./etherTransfer.sol";
import "./yescoin.sol";
import "./nocoin.sol";

contract ERC20Distribution is YesCoin, NoCoin, WithdrawalContract{
    struct Request {
        uint8 market_id;
        uint8 tokenKind;                          //tokenKind가 0이면 yescoin, 1이면 nocoin.                
        uint256 requestPrice;
        address requester;
        bool is_valid;
    }
    event RequestEmit(uint256 id, bool comp, string log);
    mapping (uint8 => Request[]) internal requests;

    
    mapping (address => mapping (uint8 => uint256)) internal requestIdOf;
    mapping (address => mapping (uint8 => bool)) internal alreadyRequest;
    
    //market이 끝났는지 확인.
    modifier marketCheck(uint8 _market_id){
        require(is_over_distribute[_market_id] == false, "Market Distribution is over");
        _;
    }
    modifier expireCheck(uint8 _market_id, uint8 _tokenKind){
       if (_tokenKind == 1){
           require(_expirationDateOf[_market_id] >= block.timestamp, "expiration date is over");
       }
       if (_tokenKind == 2){
           require(_expirationDateOf1[_market_id] >= block.timestamp, "expiration date is over");
       }
       _;
    }

    //요구하기 // 한시장당 1번.
    function request(uint8 _market_id, uint8 _tokenKind, uint256 _price) external marketCheck(_market_id) expireCheck(_market_id, _tokenKind) returns (bool){
        uint256 id;
        if (alreadyRequest[msg.sender][_market_id] == false){
            emit RequestEmit(id, alreadyRequest[msg.sender][_market_id] == false,"in if");
            requests[_market_id].push(Request(_market_id, _tokenKind, _price, msg.sender, true));
            id = requests[_market_id].length - 1;
            requestIdOf[msg.sender][_market_id] = id;
            alreadyRequest[msg.sender][_market_id] = true;
            return true;
        }
        else {   
            emit RequestEmit(id, alreadyRequest[msg.sender][_market_id] == false, "in else");
            id = requestIdOf[msg.sender][_market_id];
            requests[_market_id][id].is_valid = false;
            requests[_market_id][id].market_id = _market_id;
            requests[_market_id][id].tokenKind = _tokenKind;
            requests[_market_id][id].requestPrice = _price;
            requests[_market_id][id].requester = msg.sender;
            requests[_market_id][id].is_valid = true;
            return true;
        }
    }


    //요청 보여주기. 
    function showRequest(uint8 _market_id, uint8 _tokenKind) external view marketCheck(_market_id) returns (uint256[] memory) {
        uint256[] memory result = new uint256[](requests[_market_id].length);
        uint idx;
        uint8 searchKind;
        if (_tokenKind == 1) {
            searchKind = 2;
        }
        else if (_tokenKind == 2){
            searchKind = 1;
        }

        for (uint i = 0; i < requests[_market_id].length; i++){
            if (requests[_market_id][i].market_id == _market_id && requests[_market_id][i].is_valid == true && requests[_market_id][i].tokenKind == searchKind) {
                result[idx] = 1*10**18 - (requests[_market_id][i].requestPrice);
                idx++;    
            }
        }
        return result;
    }

    

    
}


