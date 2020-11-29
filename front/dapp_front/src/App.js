import React, {useState, useEffect, useRef} from "react"
import Web3 from 'web3'
import ManagerInterface from "./contracts/Manager.json"
import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css'
import Container from 'react-bootstrap/Container'
import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'
import filter from './Images/filter.svg'
import plus from './Images/plus.svg'
import reset from './Images/reset.png'
import SingleExchange from "./SingleExchange"
import {SendNewExchange} from "./Helpers"
import Modal from 'react-bootstrap/Modal'
import Button from 'react-bootstrap/Button'
import DetailsMode from "./Details"

function App() {
  const [account, setAccount] = useState(null)
  const [question, setQuestion] = useState("")
  const [deadLine, setDeadLine] = useState("")
  const [reseted, toggleReset] = useState(false)
  const [exchanges, setExchanges] = useState(null)
  const [newExchange, setNewExchange] = useState(false)
  const [nextId, setNextId] = useState(null)
  const [details, setDetails] = useState(null)
  const contract = useRef(null)
  const web3 = useRef(null)
  
  const loadBlockChain = async () =>{
    web3.current = new Web3('http://localhost:9545') //connecting to ganache
    const network = await web3.current.eth.net.getNetworkType();
    console.log(network) //check network type
    const accounts = await web3.current.eth.getAccounts()
    console.log(accounts)
    setAccount(accounts[0])
  }

  const loadContractInterface = () => {
    const networkKey = Object.keys(ManagerInterface.networks)[0]
    contract.current = new web3.current.eth.Contract(
      ManagerInterface.abi,
      ManagerInterface.networks[networkKey].address
    )
  }

  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  const openDetails = (obj) => {
    setDetails(obj)
  }
// loads web3
  useEffect(() => {  
    loadBlockChain()
    loadContractInterface()
    console.log(contract.current)
    contract.current.methods.marketData().call()
      .then( result => {
        console.log(result)
        setNextId(result[0].length)
        let i = 0
        let temp = []
        for(i; i < nextId; i++){
          temp.push({question : result[1][i], id : result[0][i], deadLine : result[2][i]})
        }
        setExchanges(temp.map(({question, id, deadLine}) => {return (
          <Container fluid style={{marginTop : "5px"}}>
            <SingleExchange question={question} id={id} deadLine={deadLine} contract={contract.current} account={account} openDetails={openDetails}/>
          </Container>
          )
        }))
      })
  }, [reseted])

  const frontPage = () => {
    return (
      <>
        <Container style={{ height:"600px", marginBottom:'0px', marginTop:'10px', padding : 0, borderRight : "10px solid #f8f9fa", borderLeft : "10px solid #f8f9fa", borderBottom : "10px solid #f8f9fa"}} className="scrollContainer" >
          <div style={{ position : 'relative', width : '100%', height:'40px', backgroundColor : '#f8f9fa', marginTop : '0px', marginLeft : '0px', marginRight : '0px', marginBottom:'20px'}}>
            <p style={{ position : 'absolute', zIndex : 1, top : "50%", fontSize : "0.8rem", fontFamily : 'Goldman-Bold'}}>
              total count : {nextId}
            </p>
            <img src={filter} style={{height:"70%", position : 'absolute', right : "0px", top:'20%'}}/>
            <img src={reset} style={{height:"70%", position : 'absolute', right : "80px", top:'20%'}} onClick={() => {toggleReset((prev) => !prev)}}/>
            <img src={plus} style={{height:"70%", position : 'absolute', right : "40px", top:'20%'}} onClick={() => {setNewExchange(true)}}/>
          </div>
          {exchanges ? exchanges : ""}
        </Container> 

        <Modal show={newExchange} onHide={()=>{setNewExchange(false)}}>
          <Modal.Header closeButton>
            <Modal.Title>Adding new exchange</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <form>
              <label>
                Question : 
                <input style={{margin : '5px'}} type="text" value={question} onChange={(e)=>{setQuestion(e.target.value)}}/>
              </label>
              <label>
                Dead-Line : 
                <input style={{margin : '5px'}}type="text" value={deadLine} onChange={(e)=>{setDeadLine(e.target.value)}}/>
              </label>
            </form>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={()=>{setNewExchange(false)}}>
              Close
            </Button>
            <Button variant="primary" onClick={()=>{
              SendNewExchange(contract.current, account, question, deadLine, nextId)
                .then(() => {
                    setNextId((prev)=>prev+1)
                    setNewExchange(false)
                  })
                .catch((e) => {
                  setNewExchange(false)
                  console.log(e)
                  alert(e)
                })
            }}>
              Save Changes
            </Button>
          </Modal.Footer>
        </Modal>
      </>
    )
  }
    
  return (
    <div style={{backgroundColor:"rgb(225 228 230)", position:"fixed", height:'100%', width:'100%', bottom:'0px'}}>
    <Container style={{backgroundColor: '#c9d2d8', height:"150px"}} fluid>
      <Row style={{paddingTop:'40px', textAlign:'center'}}>
        <Col style={{fontFamily : "BigShoulderStencilDisplay", fontSize: "46px" }} className="text-nowrap">
        {"The {Enter Company Name} Prediction Market"}
        </Col>
      </Row>
    </Container>
    {details ? <DetailsMode question={details.question} id={details.id} deadLine={details.deadLine} contract={contract.current} account={account} /> : frontPage()}
    </div>
  );
}

export default App;

