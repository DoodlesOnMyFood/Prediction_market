pragma solidity >=0.4.22 <0.8.0;
pragma experimental ABIEncoderV2;

contract Coin {
    address backend;
    string name;
    string coinType;
    
    constructor(string memory _name, string memory _type) public{
        backend = msg.sender;
        name = _name;
        coinType = _type;
    }
    
    function status() view public returns(string memory, string memory) {
        if (msg.sender == backend){
            return (name, coinType);
        }
    }
}

contract DummyBackend {
    struct Exchange {
        Coin yesCoin;
        Coin noCoin;
        string name;
    }
    Exchange[] exchanges;
    uint count;
    
    function setExchange(string memory name) public{
        if(bytes(name).length < 80){ // name length check.
            Exchange memory newExchange = Exchange(new Coin(name, "_yes"), new Coin(name, "_no"), name);
            exchanges.push(newExchange);
            count++;
        }
    }
    
    function showExchanges() view public returns(string[] memory){
        string[] memory temp = new string[](count);
        for(uint i; i < count; i++){
            temp[i] = exchanges[i].name;
        }
        return temp;
    }
    
    function showExchangeInDetail(uint index) view public returns(string memory, string memory, string memory, string memory){
        (string memory x, string memory y) = exchanges[index].yesCoin.status();
        (string memory a, string memory b) = exchanges[index].noCoin.status();
        return (x,y,a,b);
    }
    
}
