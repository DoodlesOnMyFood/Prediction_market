export const SendNewExchange = (contract, account, question, date, nextId) => {
    const date1 = new Date('August 19, 1975 23:15:30 GMT+07:00')
    console.log(date)
    let deadLine = new Date(date).getTime()/1000 + (date1.getTimezoneOffset() * 60)
    return new Promise((resolve, reject)=>{
        contract.methods.set_market_id(nextId, question, deadLine).send({from : account, gas : 70000000})
            .then((reciept) => console.log(reciept))
            .then(() => {resolve()})
            .catch((e) => reject(e))
    })
}

export const LogDetail = (log) => {
    let timeStamp = "N/A"
    if(log.timeNo.length){
        const date1 = new Date('August 19, 1975 23:15:30 GMT+07:00')
        timeStamp = log.timeNo[log.priceNo.length-1].toNumber() > log.timeYes[log.priceYes.length-1].toNumber() ? log.timeNo[log.priceNo.length-1].toString : log.timeYes[log.priceYes.length-1].toString
        timeStamp = new Date(timeStamp).getTime()/1000 + (date1.getTimezoneOffset() * 60)
    }
    return {
        noPrice : log.priceNo.length === 0 ? 'N/A' : log.priceNo[log.priceNo.length-1].toString(),
        yesPrice : log.priceYes.length === 0 ? 'N/A' : log.priceYes[log.priceYes.length-1].toString(),
        recentTime : timeStamp
    }   
}