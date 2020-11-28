import React, {useState, useEffect, useRef} from "react"

export default (details) => {
    let question, id, deadLine
    ({question, id, deadLine} = details)
    return (
        <>
            {`${question} ${id} ${deadLine}`}
        </>
    )
}