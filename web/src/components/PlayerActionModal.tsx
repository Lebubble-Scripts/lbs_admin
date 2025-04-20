import React, { useState } from "react";
import BanModal from "./BanModal";
import WarnModal from "./WarnModal";


interface Player {
    id: number;
    name: string;
}


interface PlayerActionModalProps {
    opened: boolean;
    player: Player;
    onAction: (action: string, id:number, reason?:string, duration?:string, durationUnit?:string) => (void);
    onClose?:() => void;
}

export default function PlayerActionModal({
    opened,
    player,
    onAction,
    onClose
}: PlayerActionModalProps) {
    const [showBanModal, setShowBanModal] = useState(false)
    const [showKickModal, setShowKickModal] = useState(false)
    const [showWarnModal, setShowWarnModal] = useState(false)
    
    if (!opened) return null;

    const handleAction = (action: string) => {
        if (action === 'ban'){
            setShowBanModal(true)
        } else if (action === 'kick'){
            setShowKickModal(true)
        } else if (action === 'warn'){
            setShowWarnModal(true)
        }
        else {
            onAction(action, player.id)
        }
    }

    const handleBanConfirm = (playerId:number, reason: string, duration:string, durationUnit:string) => {
        console.log('PlayerActionModal - Ban Confirm: ', {action: 'ban', playerId, reason, duration, durationUnit})
        onAction('ban', playerId, reason, duration, durationUnit)
        setShowBanModal(false)
    }

    const handleWarnConfirm = (playerId: number, reason: string) => {
        onAction('warn', playerId, reason)
        setShowWarnModal(false)
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

                    <button onClick={() => handleAction('bring')} className="action-button bring">
                        <i className="fa-solid fa-arrow-down"></i> Bring
                    </button>
                    {/* <button onClick={() => handleAction('warn')} className="action-button warn">
                        <i className="fa-solid fa-triangle-exclamation"></i> Warn
                    </button> */}
                    
                    <button onClick={() => handleAction('spectate')} className="action-button spectate">
                        <i className="fa-solid fa-eye"></i> Spectate
                    </button>
                </div>
                {
                    showBanModal && (
                        <BanModal
                            playerId={player.id}
                            playerName={player.name}
                            onConfirm={handleBanConfirm}
                            onCancel={() => setShowBanModal(false)}
                        />
                    )
                }
                {
                    showWarnModal && (
                        <WarnModal
                            playerId={player.id}
                            playerName={player.name}
                            onConfirm={handleWarnConfirm}
                            onCancel={() => setShowWarnModal(false)}
                        />
                    )
                }
                <button className="close-modal" onClick={onClose}>
                    <i className="fa-solid fa-xmark"></i>
                </button>
            </div>

            
        </div>
    )
}
