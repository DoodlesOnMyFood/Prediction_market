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
  const [date, setDate] = useState("")
  const [hours, setHours] = useState("")
  const [minutes, setMinutes] = useState("")
  const [seconds, setSeconds] = useState("")
  const [reseted, toggleReset] = useState(false)
  const [exchanges, setExchanges] = useState(null)
  const [owner, setOwner] = useState(true)
  const [newExchange, setNewExchange] = useState(false)
  const [nextId, setNextId] = useState(null)
  const [details, setDetails] = useState(null)
  const contract = useRef(null)
  const web3 = useRef(null)

  const initWeb3 = () => {
    return new Promise((resolve, reject) => {
      if(typeof window.ethereum !== 'undefined') { // For newer Metamask clients
        window.ethereum.enable()
          .then(() => {
            resolve(
              new Web3(window.ethereum)
            );
          })
          .catch(e => {
            reject(e);
          });
        return;
      }
      if(typeof window.web3 !== 'undefined') { // For older Metamask clients
        return resolve(
          new Web3(window.web3.currentProvider)
        );
      }
      resolve(new Web3('http://localhost:9545')); // Connecting to Truffle suite
    });
  };
  
  
  const loadBlockChain = async () =>{
    web3.current = await initWeb3()
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

  const openDetails = (obj) => {
    setDetails(obj)
  }
// loads web3
  useEffect(() => { 
    (async () => { 
      await loadBlockChain()
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
          setExchanges(temp.map(({question, id, deadLine}) => {
            const done = new Date(parseInt(deadLine) * 1000).getTime() < Date.now() ? true : false
            return (
              <Container fluid>
                <SingleExchange question={question} id={id} deadLine={deadLine} contract={contract.current} account={account} openDetails={openDetails} web3={web3.current} done={done}/>
              </Container>
            )
          }))
        })
      contract.current.methods.owner().call()
        .then( result => {
          setOwner(result)
        })
    })()
      //eslint-disable-next-line
  }, [reseted])

  const frontPage = () => {
    return (
      <>
        <Container style={{ height:"600px", marginBottom:'0px', marginTop:'10px', padding : 0, borderRight : "10px solid #f8f9fa", borderLeft : "10px solid #f8f9fa", borderBottom : "10px solid #f8f9fa"}} className="scrollContainer" >
          <div style={{ position : 'relative', width : '100%', height:'40px', backgroundColor : '#f8f9fa', marginTop : '0px', marginLeft : '0px', marginRight : '0px', marginBottom:'20px'}}>
            <p style={{ position : 'absolute', zIndex : 1, top : "50%", fontSize : "0.8rem", fontFamily : 'Goldman-Bold'}}>
              total count : {nextId}
            </p>
            <img src={filter} alt="" style={{height:"70%", position : 'absolute', right : "0px", top:'20%'}}/>
            <img src={reset} alt="" style={{height:"70%", position : 'absolute', right : "40px", top:'20%'}} onClick={() => {toggleReset((prev) => !prev)}}/>
            {account === owner? <img src={plus} alt="" style={{height:"70%", position : 'absolute', right : "80px", top:'20%'}} onClick={() => {setNewExchange(true)}}/> : ''}
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
                <input style={{margin : '5px', width : "250px"}} type="text" value={question} onChange={(e)=>{setQuestion(e.target.value)}} placeholder="Enter topic, ideally a question. "/>
              </label>
              <label>
                Dead-Line : 
                <input style={{margin : '5px', width : '40%'}}type="text" value={date} onChange={(e)=>{setDate(e.target.value)}} placeholder="YYYY-MM-DD"/>
              </label>
              <label>
                Time :
                <input style={{margin : '2px', width : '8%'}}type="text" value={hours} onChange={(e)=>{setHours(e.target.value)}} placeholder="HH"/>:
                <input style={{margin : '2px', width : '8%'}}type="text" value={minutes} onChange={(e)=>{setMinutes(e.target.value)}} placeholder="MM"/>:
                <input style={{margin : '2px', width : '8%'}}type="text" value={seconds} onChange={(e)=>{setSeconds(e.target.value)}} placeholder="SS"/>
              </label>
            </form>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={()=>{setNewExchange(false)}}>
              Close
            </Button>
            <Button variant="primary" onClick={()=>{
              console.log(contract.current, account, question, date, `${hours}:${minutes}:${seconds}`, nextId)
              SendNewExchange(contract.current, account, question, date, `${hours}:${minutes}:${seconds}`, nextId)
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
    {details ? <DetailsMode revert={setDetails} question={details.question} id={details.id} deadLine={details.deadLine} contract={contract.current} account={account} web3={web3.current} /> : frontPage()}
    </div>
  );
}

export default App;

