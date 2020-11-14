const Dummy = artifacts.require('DummyBackend')

contract('DummyBackend', ()=>{
    let dummy = null

    before(async () => {
        dummy = await Dummy.deployed()
    })

    it("Should create and update exchanges", async () => {
        await dummy.setExchange("test1")
        const state1 = await dummy.showExchanges()
        console.log(state1)
        assert(state1.length === 1)
        assert(state1[0] === "test1")
        await dummy.setExchange("test2")
        const state2 = await dummy.showExchanges()
        console.log(state2)
        assert(state2.length === 2)
        assert(state2[0] === "test1" && state2[1] === 'test2')
    })

    it("Should show details of exchanges", async () => {
        await dummy.setExchange("Show coin type : ")
        const result = await dummy.showExchangeInDetail(2)
        assert(result[0] + result[1] === 'Show coin type : _yes')
        assert(result[2] + result[3] === 'Show coin type : _no')
    })
})
