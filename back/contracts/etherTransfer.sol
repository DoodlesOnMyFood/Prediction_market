pragma solidity ^0.7.0;

import "./owner.sol";
import "./safeMath.sol";

contract WithdrawalContract is Ownable{
    using SafeMath for uint256;

    mapping (address => uint) internal pendingWithdrawls;
    uint private ownerPW;

    //자기 잔고 충전
    function addToBalance() external payable returns (bool){
        pendingWithdrawls[msg.sender] = pendingWithdrawls[msg.sender].add(msg.value);
        return true;
    }

    function addToOwnerPW() external payable onlyOwner returns (bool){
        ownerPW = ownerPW.add(msg.value);
        return true;
    }

    //웨이 송금... owner제외
    function weiTransfer(address _from,  address _to, uint256 _price) internal returns (bool){
        require(pendingWithdrawls[_from] >= _price, "Insufficient balance");
        pendingWithdrawls[_from] = pendingWithdrawls[_from].sub(_price);
        pendingWithdrawls[_to] = pendingWithdrawls[_to].add(_price);
        return true;
    }
    //owner에게 송금. 이건 코인초기분배시 사용됨.
    function ownerTransfer(address _from, uint256 _price) internal returns (bool){
        require(pendingWithdrawls[_from] >= _price, "Insufficient balance");
        pendingWithdrawls[_from] = pendingWithdrawls[_from].sub(_price);
        ownerPW = ownerPW.add(_price);
        return true;
    }
    
    //owner가 송금. 이건 토큰을 이더리움으로 교환 시 사용됨.
    function rewardTransfer(address _to, uint256 _price) internal returns (bool){
        require(ownerPW >= _price, "Owner doesn't have enough money");
        ownerPW = ownerPW.sub(_price);
        pendingWithdrawls[_to] = pendingWithdrawls[_to].add(_price);
        return true;
    }

    function withdraw() public {
        uint amount = pendingWithdrawls[msg.sender];
        // 리엔트란시(re-entrancy) 공격을 예방하기 위해
        // 송금하기 전에 보류중인 환불을 0으로 기억해 두십시오.
        pendingWithdrawls[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    //owner출금
    function ownerWithdraw() public onlyOwner{
        uint amount = ownerPW;
        // 리엔트란시(re-entrancy) 공격을 예방하기 위해
        // 송금하기 전에 보류중인 환불을 0으로 기억해 두십시오.
        ownerPW = 0;
        msg.sender.transfer(amount);
    }

    //자기 잔고 확인
    function getPW() public view returns (uint) {
        return pendingWithdrawls[msg.sender];
    }

    //owner 잔고 확인
    function getOwnerPW() public view onlyOwner returns (uint){
        return ownerPW;
    }
}
