import React, {useState, useEffect, useRef} from "react"
import Card from "react-bootstrap/Card"

export default ({text, value, onClick}) => {
    return (
        <Card onClick={onClick}>
            <Card.Header>
                {text}
            </Card.Header>
        </Card>
    )
}