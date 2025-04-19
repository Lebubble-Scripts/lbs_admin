import React, { useState } from 'react'
import { Textarea } from '@mantine/core';

interface BanModalProps {
    playerId: number;
    playerName: string;
    onConfirm: (playerId: number, reason:string, duration:string, durationUnit:string) => void;
    onCancel: () => void;
}

export default function BanModal({playerId, playerName, onConfirm, onCancel}: BanModalProps){
    const [banReason, setBanReason] = useState("")
    const [durationValue, setDurationValue] = useState("1")
    const [durationUnit, setDurationUnit] = useState('s')

    const handleConfirm = () => {
        console.log('BanModal -- Submitting: ', {playerId, banReason, durationValue, durationUnit})
        onConfirm(playerId, banReason, durationValue, durationUnit)
    };
    return (
        <div className='sub-modal-overlay'>
            <div className='sub-modal-content'>
                <h2>Ban Player: {playerName}</h2>
                <hr/>
                <div className='form-group'>
                    {/* <input
                        type='text'
                        value={banReason}
                        onChange={(e) => setBanReason(e.target.value)}
                        placeholder='Enter ban reason...'
                    /> */}
                    <label>Ban Reason: </label>
                    {<Textarea 
                        placeholder='Enter ban reason...'
                        value={banReason}
                        onChange={(e) => setBanReason(e.target.value)}
                    />}
                </div>
                <div className='form-group duration-input'>
                    <label>Duration:</label>
                    <br/>
                    <div className='duration-controls'>
                        <input 
                            type='number'
                            min='1'
                            value={durationValue}
                            onChange={(e) => setDurationValue(e.target.value)}
                            className='duration-value0'
                        />
                        <br/>
                        <select 
                            value={durationUnit}
                            onChange={(e) => setDurationUnit(e.target.value)}
                            className='duration-unit'
                        >
                            <option value="s">Seconds</option>
                            <option value="m">Minutes</option>
                            <option value="h">Hours</option>
                            <option value="d">Days</option>
                            <option value="M">Months</option>
                            <option value="y">Years</option>
                        </select>
                    </div>
                </div>
                <div className='modal-actions'>
                    <button onClick={handleConfirm}><i className="fa-solid fa-gavel"></i> Submit Ban</button>
                    <button onClick={onCancel}><i className="fa-solid fa-xmark"></i> Cancel</button>
                </div>
            </div>
        </div>
    )
}