import React, { useState } from "react";
import BanModal from "./BanModal";
import WarnModal from "./WarnModal";
import KickModal from "./KickModal";
import { fetchNui } from "../utils/fetchNui";


interface Player {
    id: number;
    name: string;
}

interface permissions {
    isAllowed: boolean
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
    const [isExpanded, setIsExpanded] = useState(false)
    const [hasPermissions, setHasPermissions] = useState(false)



    const checkPermissions = (action: string) => {
        return fetchNui<{isAllowed: boolean}>('hasPermissions', { action})
        .then((data) => {
            if (!data.isAllowed) {
                setHasPermissions(false);
                return false;
            } else if (data.isAllowed) {
                setHasPermissions(true);
                return true;
            }
        })
    }
    
        
    if (!opened) return null;
    
    const handleAction = (action: string) => {
        checkPermissions(action).then((allowed) => {
            if (!allowed){
                console.log('Permission denied for action:', action);
                return;
            }
        })

        if (action === 'ban') {
            setIsExpanded(true)
            setShowBanModal(true)
            setShowWarnModal(false)
            setShowKickModal(false)
        } else if (action === 'kick'){
            setShowKickModal(true)
            setShowWarnModal(false)
            setShowBanModal(false)
        } else if (action === 'warn'){
            setShowWarnModal(true)
            setShowBanModal(false)
            setShowKickModal(false)
        } 
        else {
            onAction(action, player.id)
        }
    }

    const handleBanConfirm = (playerId:number, reason: string, duration:string, durationUnit:string) => {
        onAction('ban', playerId, reason, duration, durationUnit)
        setShowBanModal(false)
    }

    const handleWarnConfirm = (playerId: number, reason: string) => {
        onAction('warn', playerId, reason)
        setShowWarnModal(false)
    }

    const handleKickConfirm= (playerId: number, reason:string) => {
        onAction('kick', playerId, reason)
        setShowKickModal(false)
    }


    return (
        <div className='modal-overlay'>
            <div className={`modal-content ${isExpanded ? 'expanded' : 'collapsed'}`}>
                <div className="modal-header">
                <h3>Actions for {player.name}</h3>
                </div>
                <div className="player-info">
                    <p>Player ID: {player.id}</p>
                    <p>Name: {player.name}</p>
                </div>
                <div
                    className="action-buttons"
                    style={{
                        display: "grid",
                        gridTemplateColumns: "repeat(2, 1fr)",
                        gap: ".3vh",
                        alignContent:'center',
                    }}
                >
                    <button onClick={() => handleAction('kick')} className="action-button kick">
                        <i className="fa-solid fa-exclamation"></i> Kick Player
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
                    
                    <button onClick={() => handleAction('spectate')} className="action-button spectate">
                        <i className="fa-solid fa-eye"></i> Spectate
                    </button>
                </div>
                {
                    showBanModal && hasPermissions && (
                        <BanModal
                            playerId={player.id}
                            playerName={player.name}
                            onConfirm={handleBanConfirm}
                            onCancel={() => {
                                setIsExpanded(false);
                                setTimeout(()=> {
                                    setShowBanModal(false)
                                },300)
                            }}
                        />
                    )
                }
                {
                    showWarnModal && hasPermissions && (
                        <WarnModal
                            playerId={player.id}
                            playerName={player.name}
                            onConfirm={handleWarnConfirm}
                            onCancel={() => setShowWarnModal(false)}
                        />
                    )
                }
                {
                    showKickModal && hasPermissions && (
                        <KickModal
                            playerId={player.id}
                            playerName={player.name}
                            onConfirm={handleKickConfirm}
                            onCancel={()=> setShowKickModal(false)}
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
