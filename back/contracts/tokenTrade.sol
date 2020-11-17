pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./erc20Distribution.sol";

//토큰거래!
contract TokenTrade is ERC20Distribution {
    struct Suggest {
        uint8 market_id;
        uint8 tokenKind;                          //tokenKind가 0이면 yescoin, 1이면 nocoin. 
        address suggester;
        uint256 suggestPrice;         //1c당 ether가격
        uint256 suggestTCount;           //제안하는 C갯수
        bool is_valid;
    }

    struct ShowSugg {
        uint256 suggestPrice;         //1c당 ether가격
        uint256 suggestTCount; 
    }

    mapping (uint8 => Suggest[]) private suggests;  //시장 id당 제안들

    mapping (address => mapping (uint8 => uint8)) private suggestCountOf;   //각 주소의 제안한 횟수 기록. 한 주소당 최대 10번 가능.
    mapping (address => mapping (uint8 => uint256[])) private suggestIdxOf;       //주소의 제안들 인덱스 기록.
    
    event SuggestRemove(uint8 _del_market_id, uint8 _del_tokenKind, uint256 _del_price, uint256 _del_suggestTCount);
    event NoFound(uint8 _del_market_id, uint8 _del_tokenKind, uint256 _del_price, uint256 _del_suggestTCount);
    event NoIndex();
    event trnasferComplete(address suggester);

    modifier expireCheck(uint8 _market_id, uint8 _tokenKind){
       if (_tokenKind == 0){
           require(_expirationDateOf[_market_id] >= block.timestamp, "expiration date is over");
       }
       if (_tokenKind == 1){
           require(_expirationDateOf1[_market_id] >= block.timestamp, "expiration date is over");
       }
       _;
        
    }

    //거래가격들 기록. 한 주소당 10개 제안가능. 제안갯수 초과시 기존제안 취소하고 다시 제안. 
    function suggest(uint8 _market_id, uint8 _tokenKind, uint256 _price, uint256 _suggestTCount) external expireCheck(_market_id, _tokenKind) returns (bool){
        require(suggestCountOf[msg.sender][_market_id] <= 10, "Your suggests is full.");   //기존 제안갯수 확인.
        uint256 id;
        suggests[_market_id].push(Suggest(_market_id, _tokenKind, msg.sender, _price, _suggestTCount, true));
        id = suggests[_market_id].length -1;
        suggestCountOf[msg.sender][_market_id]++;
        suggestIdxOf[msg.sender][_market_id].push(id);
        return true;
    }

    //제안했던거 바꾸기. 한 번 제안한 것은 새로운 제안으로 바꾸지 않으면 지워지지 않으므로 신중히 제안한다.
    function suggestChange(uint8 _market_id, uint8 _del_tokenKind, uint256 _del_price, uint256 _del_suggestTCount, uint8 _tokenKind, uint256 _price, uint256 _suggestTCount) external expireCheck(_market_id, _tokenKind) returns (bool){
        uint256 index;
        uint256 id;
        //우선 지울 걸 찾는다.
        for (uint i = 0; i < suggestIdxOf[msg.sender][_market_id].length; i++) {
            index = suggestIdxOf[msg.sender][_market_id][i];
            if (suggests[_market_id][index].suggestPrice == _del_price && suggests[_market_id][index].market_id == _market_id && suggests[_market_id][index].tokenKind == _del_tokenKind && suggests[_market_id][index].suggestTCount == _suggestTCount){
                suggests[_market_id][index].is_valid = false; 
                suggestCountOf[msg.sender][_market_id]--;
                emit SuggestRemove(_market_id, _del_tokenKind, _del_price, _del_suggestTCount); 
                //새로 추가. 
                suggests[_market_id].push(Suggest(_market_id, _tokenKind, msg.sender, _price, _suggestTCount, true));
                id = suggests[_market_id].length - 1;
                suggestCountOf[msg.sender][_market_id]++;
                suggestIdxOf[msg.sender][_market_id][index] = id;  //각 주소의 suggestIdxOf는 uint256(10)의 크기를 유지하게 됨.
                return true;
            }
            else if (index == 0) {  //한번도 제안하지 않음.
                emit NoIndex();
                return false;
            }
            else {
                emit NoFound(_market_id, _del_tokenKind, _del_price, _del_suggestTCount); 
                return false;
            } 
        }
    }    

    //제안 보여주기. 
    function showSuggest(uint8 _market_id, uint8 _tokenKind) external view expireCheck(_market_id, _tokenKind) returns (ShowSugg[] memory) {
        ShowSugg[] memory result = new ShowSugg[](suggests[_market_id].length);
        uint counter;
        for (uint i = 0; i < suggests[_market_id].length; i++){
            if (suggests[_market_id][i].is_valid == true && suggests[_market_id][i].market_id == _market_id && suggests[_market_id][i].tokenKind == _tokenKind) {
                result[counter].suggestPrice = suggests[_market_id][i].suggestPrice;
                result[counter].suggestTCount = suggests[_market_id][i].suggestTCount;
                counter++;    
            }
        }
        return result;
    }

    //토큰 거래 시 노트생성. 만약 같은 가격이면 앞 사람것이 먼저 거래됨.
    function tradeWant(uint8 _market_id, uint8 _tokenKind, uint256 _price, uint256 _suggestTCount) public expireCheck(_market_id, _tokenKind) returns (bool){
        address suggester;
        uint256 amount;
        //조건에 맞는 것 찾기
        for (uint i = 0; i < suggests[_market_id].length; i++){
            if (suggests[_market_id][i].is_valid == true){
                if (suggests[_market_id][i].market_id == _market_id && suggests[_market_id][i].tokenKind == _tokenKind && suggests[_market_id][i].suggestPrice == _price && suggests[_market_id][i].suggestTCount == _suggestTCount){
                    suggester = suggests[_market_id][i].suggester;
                    amount = _price * _suggestTCount;
                }
            }
            else {
                emit NoFound(_market_id, _tokenKind, _price, _suggestTCount);
                return false;
            }
        } 
        require(weiTransfer(msg.sender, suggester, amount) == true);
        if (_tokenKind == 0){
            _transfer(suggester, msg.sender, _market_id, _suggestTCount);
        }  
        if (_tokenKind == 1){
            _transfer1(suggester, msg.sender, _market_id, _suggestTCount);
        }
        return true;
    }
    
}