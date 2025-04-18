import React, { useState, useEffect } from 'react'
import {
    Container,
    Table,
    ScrollArea,
    TextInput,
    Group,
    Button,
    Title,
    Loader,
    Space
} from '@mantine/core';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';

//Define Player Interface
//i.e Defines shape of the player object
interface Player {
    id: number;
    name: string;
}

// Mock data for testing
const mockPlayers: Player[] = [
    { id: 1, name: 'Player One' },
    { id: 2, name: 'Player Two' },
    { id: 3, name: 'Player Three' },
    { id: 4, name: 'Player Four' },
    { id: 5, name: 'Player Five' },
    { id: 6, name: 'Player Six' }
];

export default function PlayerManagement() {
    const [players, setPlayers] = useState<Player[]>(mockPlayers); // Initialize with mock data

    // Commented out the actual fetch for now
    // useEffect(() => {
    //     fetchNui<Player[]>('getPlayerList')
    //         .then((data) => {
    //             console.log('received player list')
    //             console.dir(data)
    //             setPlayers(data)
    //         })
    //         .catch((e) => {
    //             console.error('Error retrieving player list', e)
    //             setPlayers([])
    //         })
    // }, [])

    // Handle Server Action
    const handleServerAction = (action: string, id: number) => {
        console.log(`Action: ${action}, Player ID: ${id}`);
        // Commented out actual API call
        // fetchNui('playerAction', { action, target: id })
        //     .catch((e) => {
        //         console.error('Error sending action', e)
        //     })
    }

    return (
        <div className='player-management'>
            <h2>Player Management</h2>
            <div>
                <div className="player-grid">
                    {players.map((player) => (
                        <div key={player.id} className="player-card">
                            <h3>{player.name}</h3>
                            <p>ID: {player.id}</p>
                            <div className="player-actions">
                                <button onClick={() => handleServerAction('teleport', player.id)}>Teleport</button>
                                <button onClick={() => handleServerAction('heal', player.id)}>Heal</button>
                                <button onClick={() => handleServerAction('revive', player.id)}>Revive</button>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}
