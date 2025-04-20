import React, { useState } from "react";
import { Textarea } from "@mantine/core";


interface WarnModalProps {
    playerId: number;
    playerName: string;
    onConfirm: (playerId: number, reason:string) => void;
    onCancel: () => void;
}


export default function WarnModal({playerId, playerName, onConfirm, onCancel}:WarnModalProps) {
    const [warnReason, setWarnReason] = useState("");

    const handleConfirm = () => {
        onConfirm(playerId, warnReason)
    };

    return (
        <div className="sub-modal-overlay">
            <div className="sub-modal-content">
                <h2>Warn Player: {playerName}</h2>
                <hr/>
                <div className='form-group'>
                    <label>Warning:</label>
                    {<Textarea
                        placeholder="Enter warning..."
                        value={warnReason}
                        onChange={(e) => setWarnReason(e.target.value)}
                    />}
                </div>
            </div>
            <div className="modal-actions">
            <button onClick={handleConfirm}><i className="fa-solid fa-triangle-exclamation"></i> Submit Warn</button>
            <button onClick={onCancel}><i className="fa-solid fa-xmark"></i> Cancel</button>
            </div>
        </div>
    )
}
