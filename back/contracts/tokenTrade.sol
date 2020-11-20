pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./erc20Distribution.sol";
import "./safeMath.sol";

//토큰거래!
contract TokenTrade is ERC20Distribution {
    using SafeMath for uint256;
    
    struct Suggest {
        uint8 market_id;
        uint8 tokenKind;                          //tokenKind가 0이면 yescoin, 1이면 nocoin. 
        address suggester;
        uint256 suggestPrice;         //1c당 ether가격
        bool is_valid;
    }
    mapping (uint8 => mapping (uint8 => uint8)) count; //for market id, token kind, trade count 
    mapping (uint8 => mapping (uint8 => uint256)) recentTrade; 
    mapping (uint8 => uint256[]) private yesCoinP;
    mapping (uint8 => uint256[]) private noCoinP;

    mapping (uint8 => Suggest[]) private suggests;  //시장 id당 제안들

    mapping (address => mapping (uint8 => uint8)) private suggestCountOf;   //각 주소의 제안한 횟수 기록. 한 주소당 최대 10번 가능.
    mapping (address => mapping (uint8 => uint256[])) private suggestIdxOf;       //주소의 제안들 인덱스 기록.
    
    event SuggestRemove(uint8 _del_market_id, uint8 _del_tokenKind, uint256 _del_price);
    event NoFound(uint8 _del_market_id, uint8 _del_tokenKind, uint256 _del_price);
    event NoIndex();

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
    function suggest(uint8 _market_id, uint8 _tokenKind, uint256 _price) external expireCheck(_market_id, _tokenKind) returns (bool){
        require(suggestCountOf[msg.sender][_market_id] <= 10, "Your suggests is full.");   //기존 제안갯수 확인.
        uint256 id;
        if (_tokenKind == 0){
            _transfer(msg.sender, owner, _market_id, 1);
        }
        else if (_tokenKind == 1){
            _transfer1(msg.sender, owner, _market_id, 1);
        }
        suggests[_market_id].push(Suggest(_market_id, _tokenKind, msg.sender, _price, true));
        id = suggests[_market_id].length -1;
        suggestCountOf[msg.sender][_market_id]++;
        suggestIdxOf[msg.sender][_market_id].push(id);
        return true;
    }

    //제안했던거 바꾸기. 한 번 제안한 것은 새로운 제안으로 바꾸지 않으면 지워지지 않으므로 신중히 제안한다.
    function suggestChange(uint8 _market_id, uint8 _del_tokenKind, uint256 _del_price, uint8 _tokenKind, uint256 _price) external expireCheck(_market_id, _tokenKind) returns (bool){
        uint256 index;
        uint256 id;
        //우선 지울 걸 찾는다.
        for (uint i = 0; i < suggestIdxOf[msg.sender][_market_id].length; i++) {
            index = suggestIdxOf[msg.sender][_market_id][i];
            if (suggests[_market_id][index].suggestPrice == _del_price && suggests[_market_id][index].market_id == _market_id && suggests[_market_id][index].tokenKind == _del_tokenKind){
                suggests[_market_id][index].is_valid = false; 
                suggestCountOf[msg.sender][_market_id]--;
                 if (_tokenKind == 0){
                     _transfer(owner, msg.sender, _market_id, 1);
                }
                else if (_tokenKind == 1){
                    _transfer1(owner, msg.sender, _market_id, 1);
                }
                emit SuggestRemove(_market_id, _del_tokenKind, _del_price); 
                //새로 추가. 
                if (_tokenKind == 0){
                     _transfer(msg.sender, owner, _market_id, 1);
                }
                else if (_tokenKind == 1){
                    _transfer1(msg.sender, owner, _market_id, 1);
                }
                suggests[_market_id].push(Suggest(_market_id, _tokenKind, msg.sender, _price, true));
                id = suggests[_market_id].length - 1;
                suggestCountOf[msg.sender][_market_id]++;
                suggestIdxOf[msg.sender][_market_id][index] = id;  //각 주소의 suggestIdxOf는 uint256(10)의 크기를 유지하게 됨.
                return true;
            }
            else if (index == 0) {  //한번도 제안하지 않음.
                emit NoIndex();
                return false;
            }
        }
        emit NoFound(_market_id, _del_tokenKind, _del_price); 
        return false;
    }    

    //제안 보여주기. 
    function showSuggest(uint8 _market_id, uint8 _tokenKind) external view expireCheck(_market_id, _tokenKind) returns (uint256[] memory) {
        uint[] memory result = new uint[] (suggests[_market_id].length);
        uint counter;
        for (uint i = 0; i < suggests[_market_id].length; i++){
            if (suggests[_market_id][i].is_valid == true && suggests[_market_id][i].market_id == _market_id && suggests[_market_id][i].tokenKind == _tokenKind) {
                result[counter] = suggests[_market_id][i].suggestPrice;
                counter++;    
            }
        }
        return result;
    }

    function lookup (uint8 _market_id, uint8 _tokenKind, uint256 _price) internal view returns (address){
        address suggester;
        for (uint i = 0; i < suggests[_market_id].length; i++){
            if (suggests[_market_id][i].is_valid == true){
                if (suggests[_market_id][i].market_id == _market_id && suggests[_market_id][i].tokenKind == _tokenKind && suggests[_market_id][i].suggestPrice == _price){
                    suggester = suggests[_market_id][i].suggester;
                    return suggester;
                }
            }
        } 
    }

    //토큰 거래 시 노트생성. 만약 같은 가격이면 앞 사람것이 먼저 거래됨.
    function tradeWant(uint8 _market_id, uint8 _tokenKind, uint256 _price) public expireCheck(_market_id, _tokenKind) returns (bool){
        address suggester = lookup(_market_id, _tokenKind, _price);
        require(weiTransfer(msg.sender, suggester, _price) == true);
        if (_tokenKind == 0){
            _transfer(owner, msg.sender, _market_id, 1);
            count[_market_id][_tokenKind] ++;
            recentTrade[_market_id][_tokenKind]=recentTrade[_market_id][_tokenKind].add(_price);
            if (count[_market_id][_tokenKind] == 5){
                yesCoinP[_market_id].push(recentTrade[_market_id][_tokenKind]/5);
                count[_market_id][_tokenKind] = 0;
                recentTrade[_market_id][_tokenKind] = 0;
            }
        }  
        if (_tokenKind == 1){
            _transfer1(owner, msg.sender, _market_id, 1);
             count[_market_id][_tokenKind] ++;
             recentTrade[_market_id][_tokenKind]=recentTrade[_market_id][_tokenKind].add(_price);
            if (count[_market_id][_tokenKind] == 5){
                 noCoinP[_market_id].push(recentTrade[_market_id][_tokenKind]/5);
                 count[_market_id][_tokenKind] = 0;
                 recentTrade[_market_id][_tokenKind] = 0;
            }
        }
        return true;
    }

    //현재 시세 보여주기.
    function showCurrent(uint8 _market_id, uint _i)public view returns (uint256[] memory resultYes, uint256[] memory resultNo){
        uint256[] memory result1;
        uint256[] memory result2;
        for (uint i = _i; i< yesCoinP[_market_id].length ; i++){
            result1[i] = yesCoinP[_market_id][i];
        }
        for(uint i = _i; i< noCoinP[_market_id].length ; i++){
            result2[i] = noCoinP[_market_id][i];
        }
        return (result1, result2);
    } 
}
