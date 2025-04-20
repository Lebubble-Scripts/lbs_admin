import React, {useState, useEffect } from 'react'
import { useNuiEvent } from '../hooks/useNuiEvent'




export default function FreezeWarning(){
    const [visible, setVisible] = useState(false)
    const [timeLeft, setTimeLeft] = useState(10)
    const [reason, setReason] = useState('')

    useNuiEvent<{duration:number, reason?: string}>('showFreezeWarning', (data) => {
        setVisible(true);
        setTimeLeft(Math.floor(data.duration /1000))
        setReason(data.reason || 'No reason provided')
    })

    useNuiEvent('hideFreezeWarning', ()=>{
        setVisible(false)
    })

    useEffect(()=>{
        if (!visible) return;
        const timer = setInterval(()=>{
            setTimeLeft(prev => {
                if (prev <= 1) {
                    clearInterval(timer);
                    return 0;
                }
                return prev - 1;
            });
        },1000);

        return () => clearInterval(timer)
    }, [visible]);

    if (!visible) return null

    return (
        <div className='freeze-warning-container'>
            <div className='freeze-warning'>
                <h2>ADMINISTRATOR ACTION</h2>
                <p>You have been temporarily frozen by an administrator.</p>
                <p className='freeze-reason'>Reason: {reason}</p>
                <p>You will be unfrozen in {timeLeft} seconds</p>
                <p>Please re-read the server rules.</p>
            </div>
        </div>
    )
}