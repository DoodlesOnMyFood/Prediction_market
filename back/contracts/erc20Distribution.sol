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

    mapping (uint8 => Request[]) private requests;

    
    mapping (address => mapping (uint8 => uint256)) internal requestIdOf;
    mapping (address => mapping (uint8 => bool)) internal alreadyRequest;
    
    //market이 끝났는지 확인.
    modifier marketCheck(uint8 _market_id){
        require(is_over_distribute[_market_id] == false, "Market Distribution is over");
        _;
    }

    //요구하기 // 한시장당 1번.
    function request(uint8 _market_id, uint8 _tokenKind, uint256 _price) external marketCheck(_market_id) returns (bool){
        uint256 id;
        if (alreadyRequest[msg.sender][_market_id] == false){
            requests[_market_id].push(Request(_market_id, _tokenKind, _price, msg.sender, true));
            id = requests[_market_id].length - 1;
            requestIdOf[msg.sender][_market_id] = id;
            alreadyRequest[msg.sender][_market_id] == true;
            return true;
        }
        else {   
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

    //요청수락이 들어오면 분배. 단, 요청한 가격의 유효한 거래가 앞에 있는 것부터 나감.
    function distribute(uint8 _market_id, uint8 _tokenKind, uint256 _acceptedPrice) external marketCheck(_market_id) returns (bool){
        address requester;
        uint index;
        uint8 searchKind;
        if (_tokenKind == 1) {
            searchKind = 2;
        }
        else if (_tokenKind == 2){
            searchKind = 1;
        }
        for (uint i = 0; i < requests[_market_id].length; i++){
            if (requests[_market_id][i].market_id == _market_id && requests[_market_id][i].is_valid == true && requests[_market_id][i].requestPrice == 1*10**18 -_acceptedPrice && requests[_market_id][i].tokenKind == searchKind) {
                index = i;
                requester = requests[_market_id][i].requester;       
            }
            else return false;
        }
        //이더리움 송금.
        require(ownerTransfer(msg.sender, _acceptedPrice)==true, "payment fail");
        require(ownerTransfer(requester, (1*10**18-_acceptedPrice))==true,"payment fail");
        
        //토큰분배
        if (_tokenKind == 1) {
            super._yesCoin_mint(msg.sender,_market_id, 1);
            super._noCoin_mint(requests[_market_id][index].requester, _market_id, 1);
        }
        else if (_tokenKind == 2){
            super._noCoin_mint(msg.sender, _market_id, 1);
            super._yesCoin_mint(requests[_market_id][index].requester, _market_id, 1);
        }
        requests[_market_id][index].is_valid = false;
        alreadyRequest[requester][_market_id] = false;
        delete requestIdOf[requester][_market_id];
    }

    
}
