import React, {useState, useEffect, useRef} from "react"
import Chart from 'chart.js'
import Container from "react-bootstrap/Container"
import Modal from "react-bootstrap/Modal"
import Button from "react-bootstrap/Button"
import Form from "react-bootstrap/Form"
import Table from "react-bootstrap/Table"
import Views from './Views'
import settings from './Images/settings.svg'
import resetImg from './Images/reset.png'
import plus from './Images/plus.svg'
import {chartifyLog, LogDetail} from './Helpers'

const Details = ({question, id, deadLine, account, contract, web3, revert} ) => {
    
    const [reset, setReset] = useState(true)
    const [spin, setSpin] = useState(true)
    const [yesCoin, setYesCoin] = useState(null)
    const [noCoin, setNoCoin] = useState(null)
    const [balance, setBalance] = useState(null)
    const [log, setLog] = useState(null)
    const [suggestYes, setSuggestYes] = useState(null)
    const [suggestNo, setSuggestNo] = useState(null)
    const [requestNo, setRequestNo] = useState(null)
    const [requestYes, setRequestYes] = useState(null)
    const [minted, setMinted] = useState(null)
    const [chartYes, setchartYes] = useState(true)
    const [winner, setWinner] = useState(null)
    
    const [viewType, setViewType] = useState("trade")
    const [viewCoin, setViewCoin] = useState("yes")
    const [views, setViews] = useState(null)
    const [newValue, setNewValue] = useState("0")
    const [valueToSend, setValueToSend] = useState("0")
    const [tradeModal, tradeModalOn] = useState(false)
    const [settingModal, settingModalOn] = useState(false)
    const [depositModal, depositModalOn] = useState(false)
    const [withdrawModal, withdrawModalOn] = useState(false)
    const [newModal, newModalOn] = useState(false)
    const [cashOutModal, cashOutModalOn] = useState(false)

    const canvasRef = useRef()
    const chart = useRef(null)


    useEffect(() => {
        if(log && canvasRef.current){
            const ctx = canvasRef.current.getContext('2d')
            const chartData = chartYes ? chartifyLog(log.priceYes, log.timeYes, web3) : chartifyLog(log.priceNo, log.timeNo, web3)
            const label = chartYes ? "Yes Coin Prices" : "No Coin Prices"
            const color = chartYes ? "#49bae9" : "#cc0000"
            console.log(chartData)
            chart.current = new Chart(ctx, {
                type: "line",
                data: {
                    datasets: [
                        {
                            label: label,
                            lineTension : 0,
                            fill : false,
                            data: chartData,
                            backgroundColor: color,
                            borderColor : [color],
                        },
                        {
                            label : "DeadLine",
                            data:[{t : deadLine, y: null}] 
                        }
                    ]
                },
                options: {
                    fill : false,
                    legend : {
                        labels : {
                            filter: function(legendItem, chartData) {
                                if (legendItem.datasetIndex === 1) {
                                return false;
                                }
                            return true;
                            }
                        }
                    },
                    scales: {
                        xAxes: [{
                            type: 'time',
                            distribution: 'linear'
                        }],
                        yAxes : [{
                            ticks : {
                                suggestedMin : 0,
                                suggestedMax : 1
                            }
                        }]
                    }
                }
            })
        }
        // eslint-disable-next-line 
    }, [log, canvasRef.current])

    useEffect(() => {
        if(chart.current){
            const chartData = chartYes ? chartifyLog(log.priceYes, log.timeYes, web3) : chartifyLog(log.priceNo, log.timeNo, web3)
            const label = chartYes ? "Yes Coin Prices" : "No Coin Prices"
            const color = chartYes ? "#49bae9" : "#cc0000"  
            chart.current.data.datasets[0].data = chartData
            chart.current.data.datasets[0].label = label
            chart.current.data.datasets[0].borderColor = [color]
            chart.current.data.datasets[0].backgroundColor = color
            chart.current.data.datasets[1].data = [{t : deadLine, y: null}] 
            chart.current.options = {
                legend : {
                    labels : {
                        filter: function(legendItem, chartData) {
                            if (legendItem.datasetIndex === 1) {
                            return false;
                            }
                        return true;
                        }
                    }
                },
                scales: {
                    xAxes: [{
                        type: 'time',
                        distribution: 'linear'
                    }],
                    yAxes : [{
                        ticks : {
                            suggestedMin : 0,
                            suggestedMax : 1
                        }
                    }]
                }
            }
            chart.current.update()
        }
        // eslint-disable-next-line 
    }, [chartYes])
    useEffect(() => {
        if(reset){
            (async () => {
                let _yesCoin = contract.methods.balanceOf(account, id).call({from : account})
                let _noCoin = contract.methods.balanceOf1(account, id).call({from : account})
                let _balance = contract.methods.getPW().call({from : account})
                let _log = contract.methods.showCurrent(id, 0).call({from : account})
                let _suggestYes = contract.methods.showSuggest(id, 1).call({from : account})
                let _suggestNo = contract.methods.showSuggest(id, 2).call({from : account})
                let _requestNo = contract.methods.showRequest(id, 2).call({from : account})
                let _requestYes = contract.methods.showRequest(id, 1).call({from : account})
                let _minted = contract.methods.totalSupplyOf(id).call({from : account})
                let _winner = contract.methods.winnerTokenOf(id).call({from : account})

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
                    _winner : await _winner,
                }
                
            })().then((ret) => {
                console.log(ret)
                setNoCoin(ret._noCoin)
                setBalance(ret._balance)
                setLog(ret._log)
                setSuggestYes(ret._suggestYes)
                setSuggestNo(ret._suggestNo)
                setRequestNo(ret._requestNo)
                setMinted(ret._minted)
                setYesCoin(ret._yesCoin)
                setRequestYes(ret._requestYes)
                if(ret._winner !== "0"){
                    console.log(ret._winner)
                    setWinner(parseInt(ret._winner))
                }
                setSpin(false)
                setReset(false)
            })
            .catch(e => console.log(e))
        }
// eslint-disable-next-line 
    }, [reset])


    useEffect(() => {
        if(log){
            if(viewType === "trade"){
                if(viewCoin === "yes"){
                    // eslint-disable-next-line 
                    setViews(suggestYes.map((val, idx) => {
                        if(val !== '0'){
                            return (
                                <Views key={idx} value={web3.utils.fromWei(val)} text={web3.utils.fromWei(val)} onClick={() => {
                                    setValueToSend(val)
                                    tradeModalOn(true)
                                }}/>
                            )
                        }
                    }))
                }
                if(viewCoin === "no"){
                    // eslint-disable-next-line 
                    setViews(suggestNo.map((val, idx) => {
                        if(val !== '0'){
                            return (
                                <Views key={idx} value={web3.utils.fromWei(val)} text={web3.utils.fromWei(val)} onClick={() => {
                                    setValueToSend(val)
                                    tradeModalOn(true)
                                }}/>
                            )
                        }
                    }))
                }
            }
            
            if(viewType === "mint"){
                if(viewCoin === "yes"){
                    // eslint-disable-next-line 
                    setViews(requestYes.map((val, idx) => {
                        if(val !== '0'){
                            return (
                                <Views key={idx} value={web3.utils.fromWei(val)} text={web3.utils.fromWei(val)} onClick={() => {
                                    setValueToSend(val)
                                    tradeModalOn(true)
                                }}/>
                            )
                        }
                    }))
                }
                if(viewCoin === "no"){
                    // eslint-disable-next-line 
                    setViews(requestNo.map((val, idx) => {
                        if(val !== '0'){
                            return (
                                <Views key={idx} value={web3.utils.fromWei(val)} text={web3.utils.fromWei(val)} onClick={() => {
                                    setValueToSend(val)
                                    tradeModalOn(true)
                                }}/>
                            )
                        }
                    }))
                }
            }
        }
        // eslint-disable-next-line 
    }, [viewType, viewCoin, reset])

    const spinny = () => {
        return (
            <div className='loader' style={{position:'absolute', left:"50%", top:'50%', transform:'translate(50%, 50%)'}}>
            </div>
        )
    }
    const checkWinner = () =>{
        if(winner){
            return (
                <>
                    <tr style={{border: '1px solid black', }}>
                        <th style={{border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                            Winning Token 
                        </th>
                        <th style={{backgroundColor: 'white', border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                            {winner === 1 ? "Yes Coins" : "No Coins"}
                        </th>
                    </tr>
                    <tr style={{border: '1px solid black', }}>
                        <th colSpan="2" style={{backgroundColor: 'white', border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                            <Button onClick={() => {cashOutModalOn(true)}}>
                                Cash Out
                            </Button>
                        </th>
                    </tr>
                </>
            )
        }
    }
    
    const temp = () => {
        const logDetails = LogDetail(log)    
        return (
            <>
                <Container style={{ height:"600px", width:'490px', marginLeft : '9px', marginBottom:'0px', marginTop:'20px', padding : 0, borderRight : "1px solid #000000", borderLeft : "1px solid #000000", borderBottom : "1px solid #000000"}} >
                    <div style={{ position : 'relative', width : '100%', height:'60px', backgroundColor : '#ffffff', marginTop : '0px', marginLeft : '0px', marginRight : '0px', marginBottom:'20px', borderTop : '1px solid #000000', borderBottom : '1px solid #000000'}}>
                        <p style={{paddingTop : "7px", paddingLeft : "60px", fontSize : "2rem"}}>
                            {viewType} - {viewCoin} Coins
                        </p>
                        <img src={plus} alt="" style={{position : 'absolute', top: '10%', height:"70%", left : '80%'}} onClick={() => {newModalOn(true)}}/>
                        <img src={settings} alt="" style={{position : 'absolute', top: '10%', height:"70%", left : '90%'}} onClick={() => {settingModalOn(true)}}/>
                        <img src={resetImg} alt="" style={{position : 'absolute', top: '10%', height:"70%", left : '70%'}} onClick={() => {setReset(false);setReset(true)}}/>
                    </div>
                    <Container style={{ position : 'relative', bottom: '15px', width : '475px', height : '530px', paddingBottom : '15px'}} className="scrollContainer">
                        {views}
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
                            <th>Balance : {web3.utils.fromWei(balance)} eth</th>
                            <th>
                                <Button onClick={() => {depositModalOn(true)}}>Deposit</Button>
                            </th>
                            <th>
                                <Button onClick={() => {withdrawModalOn(true)}}>Withdraw</Button>
                            </th>
                        </tr>
                    </thead>
                </Table>
                <div style={{position : "relative", bottom : '600px', left: '550px', width : '500px', height : '300px'}}>
                    <canvas ref={canvasRef} style={{width:'100%', height: '100%'}} />
                </div>
                <Button style={{position : 'relative', bottom : '600px', left : '550px'}} onClick={()  => {setchartYes(prev => !prev) }}>
                    {chartYes ? "Switch to No Coins" : "Switch to Yes Coins"}
                </Button>
                <Button style={{position : 'relative', bottom : '1000px', left : '550px'}} onClick={()  => {revert(null)}}>
                    Back to front page
                </Button>
                <Table style={{backgroundColor : 'rgb(201, 210, 216)', position : 'relative', bottom : '1000px', width:'450px', left : '1100px', border: '1px solid black', textAlign: 'center'}}>
                    <thead style={{border: '1px solid black'}}>
                        <tr style={{border: '1px solid black'}}>
                            <th colSpan='2' style={{border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                {id} : {question}
                            </th>
                        </tr>
                        <tr>
                            <th style={{border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                Yes Coin Price 
                            </th>
                            <th style={{backgroundColor: 'white', border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                {logDetails.yesPrice === 'N/A' ? logDetails.yesPrice : web3.utils.fromWei(logDetails.yesPrice)}
                            </th>
                        </tr>
                        <tr>
                            <th style={{border: '1px solid black'}}>
                                No Coin Price 
                            </th>
                            <th style={{backgroundColor: 'white', border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                {logDetails.noPrice === 'N/A' ? logDetails.noPrice : web3.utils.fromWei(logDetails.noPrice)}
                            </th>
                        </tr>
                        <tr>
                            <th style={{border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                Market deadline 
                            </th>
                            <th style={{backgroundColor: 'white', border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                {deadLine.toLocaleString()}
                            </th>
                        </tr>
                        <tr style={{border: '1px solid black', }}>
                            <th style={{border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                Market Cap 
                            </th>
                            <th style={{backgroundColor: 'white', border: '1px solid black', display :"table-cell", verticalAlign : 'middle'}}>
                                {1000-minted}
                            </th>
                        </tr>
                        {winner !== null ? checkWinner() : ""}

                    </thead>
                </Table>
                {/* Trade modal */}
                <Modal show={tradeModal} onHide={()=>{tradeModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Buy Coin?</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        Buy {viewCoin} for {web3.utils.fromWei(valueToSend)}?
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={()=>{tradeModalOn(false)}}>
                        Close
                        </Button>
                        <Button variant="primary" onClick={()=>{
                            const coin = viewCoin === 'yes' ? 1 : 2
                            if(viewType === "trade"){
                                contract.methods.tradeWant(id, coin, valueToSend).send({from : account})
                                .then((rec) => {console.log(rec); tradeModalOn(false)})
                                .catch((e)=> {console.log(e); tradeModalOn(false)})
                            }else if(viewType === "mint"){
                                console.log(id, coin, valueToSend)
                                contract.methods.distribute(id, coin, valueToSend).send({from : account})
                                .then((rec) => {console.log(rec); tradeModalOn(false)})
                                .catch((e)=> {console.log(e); tradeModalOn(false)})
                            }
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
                                <option value="">Choose trade type</option>
                                <option value="trade">Trade</option>
                                <option value="mint">Mint</option>
                            </Form.Control>
                            <Form.Control as="select" type="text" onChange={(e) => {setViewCoin(e.target.value)}}>
                                <option value="">Choose Coin</option>
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
                            <label>Create new {viewType} offer for
                                <input type="text" value={newValue} style={{margin:'7px'}} onChange={(e) => {setNewValue(e.target.value)}}/>
                                eth?
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
                                contract.methods.suggest(id, coin, web3.utils.toWei(newValue)).send({from : account})
                                .then(() => {console.log("successful"); newModalOn(false)})
                                .catch((e)=> {console.log(e); newModalOn(false)})
                            }else if(viewType === "mint"){
                                contract.methods.request(id, coin, web3.utils.toWei(newValue)).send({from : account})
                                .then(() => {console.log("successful"); newModalOn(false)})
                                .catch((e)=> {console.log(e); newModalOn(false)})
                            }
                        }}>
                        Confirm
                        </Button>
                    </Modal.Footer>
                </Modal>

                {/* deposit modal */}
                <Modal show={depositModal} onHide={()=>{depositModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Deposit</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <form>
                            <label>Deposit amount : 
                                <input type="text" value={newValue} style={{margin:'7px'}} onChange={(e) => {setNewValue(e.target.value)}}/>
                                eth
                            </label>
                        </form>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={()=>{depositModalOn(false)}}>
                        Close
                        </Button>
                        <Button variant="primary" onClick={()=>{
                            contract.methods.addToBalance().send({from : account, value : web3.utils.toWei(newValue)})
                            .then((reciept) => {
                                console.log(reciept)
                                depositModalOn(false)
                                setReset(false)
                                setReset(true)
                            })
                            .catch((err) => {
                                console.log(err)
                                depositModalOn(false)
                            })
                        }}>
                        Confirm
                        </Button>
                    </Modal.Footer>
                </Modal>

                {/* withdraw modal */}
                <Modal show={withdrawModal} onHide={()=>{withdrawModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Withdraw</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <p>
                            Would you like to withdraw?
                        </p>
                        <p>
                            Note that your whole balance will be withdrawn.
                        </p>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={()=>{withdrawModalOn(false)}}>
                        Close
                        </Button>
                        <Button variant="primary" onClick={()=>{
                            contract.methods.withdraw().send({from : account})
                            .then((reciept) => {
                                console.log(reciept)
                                withdrawModalOn(false)
                                setReset(false)
                                setReset(true)
                            })
                            .catch((err) => {
                                console.log(err)
                                withdrawModalOn(false)
                            })
                        }}>
                        Confirm
                        </Button>
                    </Modal.Footer>
                </Modal>

                {/* Cash out modal */}
                <Modal show={cashOutModal} onHide={()=>{cashOutModalOn(false)}}>
                    <Modal.Header closeButton>
                        <Modal.Title>Cash Out</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <p>
                            Would you like to cash out all your coins?
                        </p>
                        <p>
                            Note that both "Yes Coins"  and "No Coins" will all be cashed out.
                        </p>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={()=>{cashOutModalOn(false)}}>
                        Close
                        </Button>
                        <Button variant="primary" onClick={()=>{
                            contract.methods.exchange(id, ).send({from : account})
                            .then((reciept) => {
                                console.log(reciept)
                                cashOutModalOn(false)
                                setReset(false)
                                setReset(true)
                            })
                            .catch((err) => {
                                console.log(err)
                                cashOutModalOn(false)
                            })
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

export default Details
