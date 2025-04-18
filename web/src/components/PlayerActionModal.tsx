import React from "react";


interface Player {
    id: number;
    name: string;
}


interface PlayerActionModalProps {
    opened: boolean;
    player: Player;
    onAction: (action: string, id:number) => (void);
    onClose?:() => void;
}

export default function PlayerActionModal({
    opened,
    player,
    onAction,
    onClose
}: PlayerActionModalProps) {
    if (!opened) return null;

    const handleAction = (action: string) => {
        onAction(action, player.id)
    }

    return (
        <div className='modal-overlay'>
            <div className="modal-content">
                <div className="modal-header">
                <h3>Actions for {player.name}</h3>
                </div>
                <div className="player-info">
                    <p>Player ID: {player.id}</p>
                    <p>Name: {player.name}</p>
                </div>
                <div className="action-buttons">
                <button onClick={() => handleAction('kick')} className="action-button kick">
                        <i className="fa-solid fa-boot"></i> Kick Player
                    </button>
                    
                    <button onClick={() => handleAction('ban')} className="action-button ban">
                        <i className="fa-solid fa-gavel"></i> Ban Player
                    </button>
                    
                    <button onClick={() => handleAction('teleport')} className="action-button teleport">
                        <i className="fa-solid fa-location-arrow"></i> Teleport
                    </button>
                    
                    <button onClick={() => handleAction('spectate')} className="action-button spectate">
                        <i className="fa-solid fa-eye"></i> Spectate
                    </button>
                </div>
            </div>
            <button className="close-button" onClick={onClose}>
                <i className="fa-solid fa-xmark"></i>
            </button>
        </div>
    )
}
