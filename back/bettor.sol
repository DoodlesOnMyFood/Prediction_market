pragma solidity ^0.7.0;

import "./owner.sol";
import "./safeMath.sol";

contract Bettor is Ownable{
    using SafeMath for uint256;

    uint256[] SecretNotes ;

    function SecretNoteGenerate() private {
        
    }
    // mapping(address => uint256) private tokenKindNum;
    // mapping(uint256 => uint256) private tokenCount;

    // function tokenCountOf(address _account)public view returns (uint256){
    //     return tokenCount[tokenKindNum[_account]];
    // }
    // //showing list of token price suggestion;
    // function show_list() external pure returns(uint256[] memory){
        
    // }
}

