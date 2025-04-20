import React, {useState} from 'react'
import { Textarea } from '@mantine/core'

interface KickModalProps {
    playerId:number;
    playerName:string;
    onConfirm: (playerId: number, reason:string) => void;
    onCancel: ()=>void;
}


export default function KickModal({playerId, playerName, onConfirm, onCancel}: KickModalProps){
    const [kickReason, setKickReason] = useState("")

    const handleConfirm = () => {
        onConfirm(playerId, kickReason)
    }

    return (
         <div className='sub-modal-overlay'>
                    <div className='sub-modal-content'>
                        <h2>Kick Player: {playerName}</h2>
                        <hr/>
                        <div className='form-group'>
                            <label>Kick Reason: </label>
                            {<Textarea 
                                placeholder='Enter kick reason...'
                                value={kickReason}
                                onChange={(e) => setKickReason(e.target.value)}
                            />}
                        </div>
                        <div className='modal-actions'>
                            <button onClick={handleConfirm}><i className="fa-solid fa-exclamation"></i> Submit Kick</button>
                            <button onClick={onCancel}><i className="fa-solid fa-xmark"></i> Cancel</button>
                        </div>
                    </div>
                </div>
    )
}