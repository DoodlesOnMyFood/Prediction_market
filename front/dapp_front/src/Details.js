import React, {useState, useEffect, useRef} from "react"
import Container from "react-bootstrap/Container"
import Modal from "react-bootstrap/Modal"
import Button from "react-bootstrap/Button"
import Form from "react-bootstrap/Form"
import Table from "react-bootstrap/Table"
import Views from './Views'
import settings from './Images/settings.svg'
import plus from './Images/plus.svg'
export default ({question, id, deadLine, account, contract} ) => {
    
    const [reset, setReset] = useState(true)
    const [spin, setSpin] = useState(true)
    const [date, setDate] = useState(null)
    const [yesCoin, setYesCoin] = useState(null)
    const [noCoin, setNoCoin] = useState(null)
    const [balance, setBalance] = useState(null)
    const [log, setLog] = useState(null)
    const [suggestYes, setSuggestYes] = useState(null)
    const [suggestNo, setSuggestNo] = useState(null)
    const [requestNo, setRequestNo] = useState(null)
    const [requestYes, setRequestYes] = useState(null)
    const [minted, setMinted] = useState(null)
    
    const [viewType, setViewType] = useState("trade")
    const [viewCoin, setViewCoin] = useState("yes")
    const [views, setViews] = useState(null)
    const [newValue, setNewValue] = useState("0")
    const [valueToSend, setValueToSend] = useState(null)
    const [tradeModal, tradeModalOn] = useState(false)
    const [settingModal, settingModalOn] = useState(false)
    const [newModal, newModalOn] = useState(false)
    console.log(account)

    useEffect(() => {
        if(reset){
            (async () => {
                setDate(new Date(parseInt(deadLine) * 1000))
                let _yesCoin = contract.methods.balanceOf(account, id).call()
                let _noCoin = contract.methods.balanceOf1(account, id).call()
                let _balance = contract.methods.getPW().call()
                let _log = contract.methods.showCurrent(id, 0).call()
                let _suggestYes = contract.methods.showSuggest(id, 1).call()
                let _suggestNo = contract.methods.showSuggest(id, 2).call()
                let _requestNo = contract.methods.showRequest(id, 2).call()
                let _requestYes = contract.methods.showRequest(id, 1).call()
                let _minted = contract.methods.totalSupplyOf(id).call()

                return {
                    _noCoin : await _noCoin,
                    _balance : await _balance,
                    _log : await _log,
                    _suggestYes : await _suggestYes,
                    _suggestNo : await _suggestNo,
                    _requestNo : await _requestNo,
                    _requestYes : await _requestYes,
                    _minted : await _minted,
                    _yesCoin : await _yesCoin,
                }
                
            })().then((ret) => {
                setNoCoin(ret._noCoin)
                setBalance(ret._balance)
                setLog(ret._log)
                setSuggestYes(ret._suggestYes)
                setSuggestNo(ret._suggestNo)
                setRequestNo(ret._requestNo)
                setMinted(ret._minted)
                setYesCoin(ret._yesCoin)
                setRequestYes(ret._requestYes)
                setSpin(false)
                setReset(false)
            })
        }

    }, [reset])

    useEffect(() => {
        if(log){
            if(viewType === "trade"){
                if(viewCoin === "yes"){
                    setViews(suggestYes.map((val) => {
                        if(val.toString !== '0'){
                            return (
                                <Views value={val.toString()} text={val.toString()} onClick={() => {
                                    setValueToSend(val.toString())
                                    tradeModalOn(true)
                                }}/>
                            )
                        }
                    }))
                }
                if(viewCoin === "no"){
                    
                }
            }
            if(viewType === "mint"){
                if(viewCoin === "yes"){
                    
                }
                if(viewCoin === "no"){
                    
                }
            }
            if(viewType === "log"){
                if(viewCoin === "yes"){
                    
                }
                if(viewCoin === "no"){
                    
                }
            }
        }
    }, [viewType, viewCoin])

    const spinny = () => {
        return (
            <div className='loader' style={{position:'absolute', left:"50%", top:'50%', transform:'translate(50%, 50%)'}}>
            </div>
        )
    }

    const temp = () => {
        return (
            <>
                <Container style={{ height:"600px", width:'490px', marginLeft : '9px', marginBottom:'0px', marginTop:'20px', padding : 0, borderRight : "1px solid #000000", borderLeft : "1px solid #000000", borderBottom : "1px solid #000000"}} >
                    <div style={{ position : 'relative', width : '100%', height:'60px', backgroundColor : '#ffffff', marginTop : '0px', marginLeft : '0px', marginRight : '0px', marginBottom:'20px', borderTop : '1px solid #000000', borderBottom : '1px solid #000000',}}>
                        {viewType}, {viewCoin}
                        <img src={plus} style={{position : 'absolute', top: '10%', height:"70%", left : '80%'}} onClick={() => {newModalOn(true)}}/>
                        <img src={settings} style={{position : 'absolute', top: '10%', height:"70%", left : '90%'}} onClick={() => {settingModalOn(true)}}/>
                    </div>
                    <Container style={{ position : 'relative', bottom: '15px', width : '475px', height : '530px', paddingBottom : '15px'}} className="scrollContainer">

                    </Container>
                    
                </Container> 
                <Table style={{position : "relative", width: '500px', bottom: "100px", left: '550px' }}>
                    <thead>
                        <tr>
                        <th>User Assets</th>
                        <th>Yes Coins : {yesCoin}</th>
                        <th>No Coins : {noCoin}</th>
                        </tr>
                        <tr>
                            <th>Balance : {balance}</th>
                            <th>
                                <Button>Deposit</Button>
                            </th>
                            <th>
                                <Button>Withdraw</Button>
                            </th>
                        </tr>
                    </thead>

               </Table>

                {/* Trade modal */}
                <Modal show={tradeModal} onHide={()=>{tradeModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Buy Coin?</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        Buy {viewCoin} for {valueToSend}?
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={()=>{tradeModalOn(false)}}>
                        Close
                        </Button>
                        <Button variant="primary" onClick={()=>{
                            const coin = viewCoin === 'yes' ? 1 : 2
                            contract.methods.tradeWant(id, coin, valueToSend).send({from : account})
                            .then(() => {console.log("successful"); tradeModalOn(false)})
                            .catch((e)=> {console.log(e); tradeModalOn(false)})
                        }}>
                        Confirm
                        </Button>
                    </Modal.Footer>
                </Modal>

                {/* Setting modal */}
                <Modal show={settingModal} onHide={()=>{settingModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Change list settings</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group>
                            <Form.Control as="select" type="text" onChange={(e) => {setViewType(e.target.value)}}>
                                <option value="trade">Trade</option>
                                <option value="mint">Mint</option>
                                <option value="log">Log</option>
                            </Form.Control>
                            <Form.Control as="select" type="text" onChange={(e) => {setViewCoin(e.target.value)}}>
                                <option value="yes">Yes Coins</option>
                                <option value="no">No Coins</option>
                            </Form.Control>
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="primary" onClick={()=>{settingModalOn(false)}}>
                        Close
                        </Button>
                    </Modal.Footer>
                </Modal>

                {/* new modal */}
                <Modal show={newModal} onHide={()=>{newModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Create Suggestion</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <form>
                            <label>Create new {viewType} offer?
                                <input type="text" value={newValue} onChange={(e) => {setNewValue(e.target.value)}}/>
                            </label>
                        </form>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={()=>{newModalOn(false)}}>
                        Close
                        </Button>
                        <Button variant="primary" onClick={()=>{
                            const coin = viewCoin === 'yes' ? 1 : 2
                            if(viewType === "trade"){
                                contract.methods.suggest(id, coin, newValue).send({from : account})
                                .then(() => {console.log("successful"); newModalOn(false)})
                                .catch((e)=> {console.log(e); newModalOn(false)})
                            }else if(viewType === "mint"){
                                contract.methods.request(id, coin, newValue).send({from : account})
                                .then(() => {console.log("successful"); newModalOn(false)})
                                .catch((e)=> {console.log(e); newModalOn(false)})
                            }
                        }}>
                        Confirm
                        </Button>
                    </Modal.Footer>
                </Modal>
            </>
        )
    }
    return (
        <>
            {spin ? spinny() : temp()}
        </>
    )
}