pragma solidity ^0.7.0;

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
    struct priceLog {
        uint256 price;       
        uint256 timestamp;
    }
    event DistributeEmit(bool a, bool b, bool c, bool d);
    mapping (uint8 => priceLog[]) private yesCoinP;
    mapping (uint8 => priceLog[]) private noCoinP;

    mapping (uint8 => Suggest[]) private suggests;  //시장 id당 제안들

    mapping (address => mapping (uint8 => uint8)) private suggestCountOf;   //각 주소의 제안한 횟수 기록. 한 주소당 최대 10번 가능.
    mapping (address => mapping (uint8 => uint256[])) private suggestIdxOf;       //주소의 제안들 인덱스 기록.
    
    event SuggestRemove(uint8 _del_market_id, uint8 _del, uint256 _del_price);
    event NoFound(uint8 _del_market_id, uint8 _del_tokenKind, uint256 _del_price);
    event NoIndex();

    

    //거래가격들 기록. 한 주소당 10개 제안가능. 제안갯수 초과시 기존제안 취소하고 다시 제안. 
    function suggest(uint8 _market_id, uint8 _tokenKind, uint256 _price) external expireCheck(_market_id, _tokenKind) returns (bool){
        require(suggestCountOf[msg.sender][_market_id] <= 10, "Your suggests is full.");   //기존 제안갯수 확인.
        uint256 id;
        if (_tokenKind == 1){
            _transfer(msg.sender, owner, _market_id, 1);
        }
        else if (_tokenKind == 2){
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
                 if (_tokenKind == 1){
                     _transfer(owner, msg.sender, _market_id, 1);
                }
                else if (_tokenKind == 2){
                    _transfer1(owner, msg.sender, _market_id, 1);
                }
                emit SuggestRemove(_market_id, _del_tokenKind, _del_price); 
                //새로 추가. 
                if (_tokenKind == 1){
                     _transfer(msg.sender, owner, _market_id, 1);
                }
                else if (_tokenKind == 2){
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
    function showSuggest(uint8 _market_id, uint8 _tokenKind) external view returns (uint256[] memory) {
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

    function lookup (uint8 _market_id, uint8 _tokenKind, uint256 _price) internal returns (address){
        address suggester;
        for (uint i = 0; i < suggests[_market_id].length; i++){
            if (suggests[_market_id][i].is_valid == true){
                if (suggests[_market_id][i].market_id == _market_id && suggests[_market_id][i].tokenKind == _tokenKind && suggests[_market_id][i].suggestPrice == _price){
                    suggester = suggests[_market_id][i].suggester;
                    delete suggests[_market_id][i];
                    return suggester;
                }
            }
        } 
        return address(0);
    }

    //토큰 거래 시 노트생성. 만약 같은 가격이면 앞 사람것이 먼저 거래됨.
    function tradeWant(uint8 _market_id, uint8 _tokenKind, uint256 _price) public expireCheck(_market_id, _tokenKind) returns (bool){
        address suggester = lookup(_market_id, _tokenKind, _price);
        if(suggester != address(0)){
            require(weiTransfer(msg.sender, suggester, _price) == true);
            if (_tokenKind == 1){
                _transfer(owner, msg.sender, _market_id, 1);
                yesCoinP[_market_id].push(priceLog(_price, block.timestamp));
            }  
            if (_tokenKind == 2){
                _transfer1(owner, msg.sender, _market_id, 1);
                 noCoinP[_market_id].push(priceLog(_price, block.timestamp));
            }
            return true;
        }
        return false;
    }

    //현재 시세 보여주기.
    function showCurrent(uint8 _market_id, uint _i)public view returns (uint256[] memory priceYes, uint256[] memory timeYes, uint256[] memory priceNo, uint256[] memory timeNo){
        uint256[] memory price1 = new uint256[](yesCoinP[_market_id].length);
        uint256[] memory time1 = new uint256[](yesCoinP[_market_id].length);
        uint256[] memory price2 = new uint256[](noCoinP[_market_id].length);
        uint256[] memory time2 = new uint256[](noCoinP[_market_id].length);
        for (uint i = _i; i< yesCoinP[_market_id].length ; i++){
            price1[i] = yesCoinP[_market_id][i].price;
            time1[i] = yesCoinP[_market_id][i].timestamp;
        }
        for(uint i = _i; i< noCoinP[_market_id].length ; i++){
            price2[i] = noCoinP[_market_id][i].price;
            time2[i] = noCoinP[_market_id][i].timestamp;
        }
        return (price1, time1, price2, time2);
    } 
    
    //요청수락이 들어오면 분배. 단, 요청한 가격의 유효한 거래가 앞에 있는 것부터 나감.
    function distribute(uint8 _market_id, uint8 _tokenKind, uint256 _acceptedPrice) external marketCheck(_market_id) expireCheck(_market_id, _tokenKind) returns (bool){
        address requester = address(0);
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
        }
        if(requester == address(0)){
            return false;
        }
        //이더리움 송금.
        require(ownerTransfer(msg.sender, _acceptedPrice)==true, "payment fail");
        require(ownerTransfer(requester, (1*10**18-_acceptedPrice))==true,"payment fail");
        if (_tokenKind == 1) {
            yesCoinP[_market_id].push(priceLog(_acceptedPrice, block.timestamp));
            noCoinP[_market_id].push(priceLog(1*10**18 - _acceptedPrice, block.timestamp));
        }
        else if (_tokenKind == 2){
            noCoinP[_market_id].push(priceLog(_acceptedPrice, block.timestamp));
            yesCoinP[_market_id].push(priceLog(1*10**18 - _acceptedPrice, block.timestamp));
        }
        //토큰분배
        if (_tokenKind == 1) {
            super._yesCoin_mint(msg.sender, _market_id, 1);
            super._noCoin_mint(requests[_market_id][index].requester, _market_id, 1);
        }
        else if (_tokenKind == 2){
            super._noCoin_mint(msg.sender, _market_id, 1);
            super._yesCoin_mint(requests[_market_id][index].requester, _market_id, 1);
        }
        requests[_market_id][index].is_valid = false;
        alreadyRequest[requester][_market_id] = false;
        delete requestIdOf[requester][_market_id];
        return true;
    }
}


