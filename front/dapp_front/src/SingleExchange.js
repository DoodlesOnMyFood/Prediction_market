import React, {useState, useEffect, useRef} from "react"
import Accordion from "react-bootstrap/Accordion"
import Button from "react-bootstrap/Button"
import Card from "react-bootstrap/Card"
import Table from "react-bootstrap/Table"
import arrowVector from './Images/arrow.svg'
import { useAccordionToggle } from 'react-bootstrap/AccordionToggle'
import Spinner from "react-bootstrap/Spinner"
import {LogDetail} from "./Helpers"



export default ( { question, id, deadLine, account, contract, openDetails } ) => {
    const [open, setOpen] = useState(null)
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


    useEffect(() => {
        if(open){
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
            })
        }

    }, [open])

    const ArrowHead = () => {
        const decoratedOnClick = useAccordionToggle('0', () =>
            console.log('totally custom!'),
        )
        let arrowClass = "initArrow"
        if (open !== null){
            arrowClass = open ? "downArrow" : "rightArrow"
        }
                
        return(
            <img src={arrowVector} className={arrowClass} onClick={(e)=>{setOpen((prev)=> {
                decoratedOnClick(e)
                if(prev === null){
                    return true
                }
                return !prev
            })}}/>
        )
    }
    const spinny = () => {
        return (
            <Spinner animation="border" role="status" >
                <span className="sr-only">Loading...</span>
            </Spinner> 
        )
    }
    const details = () =>{
        console.log(date)
        let hours = date.getHours()
        let minutes = date.getMinutes()
        let seconds = date.getSeconds()
        let month = date.getMonth() + 1
        let _date = date.getDate()
        if(hours < 10){
            hours = '0' + `${hours}`
            console.log(hours)
        }
        if(minutes < 10){
            minutes = '0' + `${minutes}`
        }
        if(seconds < 10){
            seconds = '0' + `${seconds}`
        }
        if(month < 10){
            month = '0' + `${month}`
        }
        if(_date < 10){
            _date = '0' + `${_date}`
        }
        const _deadline = `${date.getFullYear()}-${month}-${_date} ${hours}:${minutes}:${seconds}`
        const logDetails = LogDetail(log)
        return (
            <>
               <Table style={{fontSize : '1.4rem'}}>
                    <thead>
                        <tr>
                        <th>User Info</th>
                        <th>Yes Coins : {yesCoin}</th>
                        <th>No Coins : {noCoin}</th>
                        <th>Balance : {balance}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td rowSpan="3" style={{ display :"table-cell", verticalAlign : 'middle', }}>Market Info</td>
                            <td>Market Cap : {1000 - minted}</td>
                            <td>Deadline : {_deadline}</td>
                            <td rowSpan="3"><Button style={{width:'100%', height: '100%'}} onClick={() => {openDetails({
                                question : question,
                                id : id,
                                deadLine : _deadline
                            })}}>More Details</Button></td>
                        </tr>
                        <tr>
                            <td>Yes Coin Price : N/A</td>
                            <td>No Coin Price : N/A</td>
                        </tr>
                        <tr>
                            <td>Activity : {suggestYes.length + suggestNo.length + requestYes.length + requestNo.length} </td>
                            <td>Recent Trade : N/A</td>
                        </tr>
                    </tbody>
               </Table>
            </>
        )
    }
    const bodyStyle = spin ? {display:'flex', justifyContent: "center", marginTop: "60px", marginBottom: "60px"} : {fontSize : "1.5rem"}
    return (
        <Accordion >
            <Card>
                <Card.Header style={{position : "relative"}}>
                {question}
                <ArrowHead />
                </Card.Header>
                <Accordion.Collapse eventKey="0">
                    <Card.Body >
                        <div style={bodyStyle}>
                            {spin ? spinny() : details()}
                        </div>
                    </Card.Body>         
                </Accordion.Collapse>
            </Card>
        </Accordion>
    )
}