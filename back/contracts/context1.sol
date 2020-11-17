pragma solidity ^0.7.0;
import "./owner.sol";
abstract contract Context1 is Ownable{
    function _msgSender1() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData1() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
