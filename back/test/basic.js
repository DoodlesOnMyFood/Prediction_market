const Manager = artifacts.require('Manager')

contract("Manager", accounts => {
    let manager = null
    before(() => {
        Manager.deployed()
            .then((instance) => { manager = instance })
    })

   it("Should be able to add exchanges", async () => {
       await manager.set_market_id(1, "Test Question", 1607731200, {from : accounts[0]})
       let returns = await manager.marketData({from : accounts[0]})
       console.log(returns)
   })

   it("Should return correct address of owner", async () =>{
       const addressOfOwner = await manager.owner()
       assert(addressOfOwner === accounts[0])
   })

   it("Should create coins correctly", async () => {
       await manager.addToBalance({from : accounts[0], value : web3.utils.toWei('2', 'ether')})
       await manager.addToBalance({from : accounts[1], value : web3.utils.toWei('2', 'ether')})
       let balance1 = await manager.getPW({from:accounts[0]}) 
       let balance2 = await manager.getPW({from:accounts[1]}) 
       assert(balance1.toString() === "2000000000000000000", `init balance1 was ${balance1.toString()}`)
       assert(balance2.toString() === "2000000000000000000", `init balance2 was ${balance2.toString()}`)
       await manager.request(1, 1, "300000000000000000")    
       const result = await manager.showRequest(1, 2)    
       await manager.distribute(1, 2, result[0].toString(), {from : accounts[1]})
       balance1 = await manager.getPW({from:accounts[0]}) 
       balance2 = await manager.getPW({from:accounts[1]}) 
       assert(balance1.toString() === "1700000000000000000", `balance1 was ${balance1.toString()}`)
       assert(balance2.toString() === "1300000000000000000", `balance2 was ${balance2.toString()}`)
   })
   it("Should trade coins", async () => {
       await manager.suggest(1, 1,'400000000000000000', {from : accounts[0]})
       const suggestion = await manager.showSuggest(1, 1)
       await manager.tradeWant(1,1,suggestion[0].toString(), {from : accounts[1]})
       const balance1 = await manager.getPW({from:accounts[0]}) 
       const balance2 = await manager.getPW({from:accounts[1]})
       assert(balance1.toString() === "2100000000000000000", `balance1 was ${balance1.toString()}`)
       assert(balance2.toString() === "900000000000000000", `balance2 was ${balance2.toString()}`)
       const yesCoin0 = await manager.balanceOf(accounts[0], 1)
       const yesCoin1 = await manager.balanceOf(accounts[1], 1)
       const noCoin0 = await manager.balanceOf(accounts[0], 1)
       const noCoin1 = await manager.balanceOf(accounts[1], 1)
       assert(yesCoin0.toString() === '0', "yescoin0")
       assert(yesCoin1.toString() === '1', "yesCoin1")
       assert(noCoin0.toString() === '0', "noCoin0")
       assert(noCoin1.toString() === '1', "noCoin1")
    
   })
 }
)
