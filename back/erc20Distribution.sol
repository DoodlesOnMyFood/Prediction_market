pragma solidity ^0.7.0;

import "./yescoin.sol";
import "./nocoin.sol";

contract ERC20Distribution is YesCoin, NoCoin {
    uint8 constant internal BLOCK_INTERVAL = 3; 

    struct request {
        uint8 tokenKind;                          //tokenKind가 0이면 yescoin, 1이면 nocoin.                                 
        uint256 suggestPrice;
        uint256 secretSuggester;
        uint256 suggestTime;       //거래가 살아있는 시간
    }

    mapping (address => request) private requestOf;
    mapping (address => bool) private alreadySuggest = false;

    //request 저장. 제안은 한 주소당 1번씩만. 다시 제안하려면 기존제안 취소하고 다시 제안.
    function suggest(uint8 _tokenKind, uint256 _price) external returns (bool){
        require(alreadySuggest[msg.sender] == false, "already suggest");   //기존 제안이 있는지 확인.
        requestOf[msg.sender].tokenKind = _tokenKind;
        requestOf[msg.sender].suggestPrice = _price;
        requestOf[msg.sender].secretSuggester = keccack256(msg.sender);   //! 제안자주소 now로 같이 hash;
        requestOf[msg.sender].suggestTime = now + BLOCK_INTERVAL;
        return true;
    }

    //제안했던거 바꾸기
    function suggestChange(uint8 _tokenKind, uint256 _price) external returns (bool){
        if (alreadySuggest[msg.sender] == false) {
            suggest(_tokenKind, _price);
            alreadySuggest[msg.sender] = true;
        }
        else {

        }
    }

    //요청 보여주기
    function showRequest()

    //요청수락이 들어오면 분배.
    function distribute() {

    }
}