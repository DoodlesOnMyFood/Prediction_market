import logo from './logo.svg';
import React, {useState, useEffect, useRef} from "react"
import Web3 from 'web3'
import DummyBackend from "./contracts/DummyBackend.json"
import './App.css';

function App() {
  const [account, setAccount] = useState(null)
  const [exchanges, setExchanges] = useState(null)
  const [newExchange, setNewExchange] = useState("")
  const dummy = useRef(null)
  const web3 = useRef(null)
  
  const loadBlockChain = async () =>{
    web3.current = new Web3('http://localhost:9545') //connecting to ganache
    const network = await web3.current.eth.net.getNetworkType();
    console.log(network) //check network type
    const accounts = await web3.current.eth.getAccounts()
    setAccount(accounts[0])
  }

  const loadDummy = () => {
    const networkKey = Object.keys(DummyBackend.networks)[0]
    dummy.current = new web3.current.eth.Contract(
      DummyBackend.abi,
      DummyBackend.networks[networkKey].address
    )
  }

  useEffect(() => {
    loadBlockChain()
    loadDummy()
    console.log(dummy.current)
    dummy.current.methods.showExchanges().call()
      .then( result => {
        setExchanges(result)
      })
    setInterval(() => {
      dummy.current.methods.showExchanges().call()
      .then( result => {
        setExchanges(result)
      })
    }, 10000)
  }, [])

  
    
  

  const handleNewExchange = (e) => {
    e.preventDefault()
    console.log(newExchange)
    console.log(account)
    dummy.current.methods.setExchange(newExchange).send({from : account, gas : 700000})
      .then(() => console.log("success?"))
      .catch(e => console.log("Check gas usage"))
    setNewExchange("")
  }

  return (
    <>
      <p>{exchanges}</p>
      <form>
        <label>
          new exchange : 
          <input type='text' name="exchangeText" value={newExchange} onChange={(event) => {setNewExchange(event.target.value)}}/>
        </label>
        <button onClick={handleNewExchange}>submit</button>
      </form>
    </>
  );
}

export default App;
