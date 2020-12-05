export const SendNewExchange = (contract, account, question, date, time, nextId) => {
    const date1 = new Date('August 19, 1975 23:15:30 GMT+07:00')
    console.log(date, time)
    let deadLine = new Date(`${date}T${time}+09:00`).getTime()/1000 
    return new Promise((resolve, reject)=>{
        contract.methods.set_market_id(nextId, question, deadLine).send({from : account})
            .then((reciept) => console.log(reciept))
            .then(() => {resolve()})
            .catch((e) => reject(e))
    })
}

export const LogDetail = (log) => {
    let timeStamp = "N/A"
    console.log(log.timeNo)
    if(log.timeNo.length){
        timeStamp = parseInt(log.timeNo[log.priceNo.length-1]) > parseInt(log.timeYes[log.priceYes.length-1]) ? log.timeNo[log.priceNo.length-1] : log.timeYes[log.priceYes.length-1]
        timeStamp = new Date(parseInt(timeStamp)*1000).toLocaleString()
    }
    return {
        noPrice : log.priceNo.length === 0 ? 'N/A' : log.priceNo[log.priceNo.length-1],
        yesPrice : log.priceYes.length === 0 ? 'N/A' : log.priceYes[log.priceYes.length-1],
        recentTime : timeStamp
    }   
}


export const chartifyLog = (prices, times, web3) => {
    let temp = []
    let i = 0
    for(; i < prices.length; i++){
        let next = new Date(parseInt(times[i]) * 1000)
        if(next == "Invalid Date"){
            continue
        }
        temp.push({t : new Date(parseInt(times[i]) * 1000), y : web3.utils.fromWei(prices[i])})
    }
    return temp
}