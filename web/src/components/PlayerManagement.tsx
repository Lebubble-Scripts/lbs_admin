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

const PlayerManagement: React.FC = () => {
    const [players, setPlayers] = useState<Player[]>([]);
    const [loading, setLoading] = useState<boolean>(true)

    // Fetch player list on mount (load)
    useEffect(() => {
        fetchNui<Player[]>('getPlayerList')
            .then((data) => {
                console.log('received player list')
                console.dir(data)
                setPlayers(data)
            })
            .catch((e) => {
                console.error('Error retrieving player list', e)
                setPlayers([])
            })
            .finally(() => setLoading(false))
    }, [])

    // Handle Server Action
    const handleServerAction = (action: string, id: number) => {
        fetchNui('playerAction', { action, target: id })
            .catch((e) => {
                console.error('Error sending action', e)
            })
    }

    // Show loading state
    if (loading) {
        return <Loader color="violet" size="xl" type="bars" />;
    }

    return (
        <div className='player-management'>
            <h2>Player Management</h2>
            <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr)',
                gap: '16px'
            }}>
                {players.map((player) => (
                    <div
                        key={player.id}
                        style={{
                            border: '1px solid #ddd',
                            borderRadius: '8px',
                            padding: '16px',
                            boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
                            display: 'flex',
                            flexDirection: 'column',
                        }}
                    >
                        <h3 style={{ margin: 0, marginBottom: '8px' }}>{player.name}</h3>
                        <p style={{ margin: 0, marginBottom: '16px' }}>ID: {player.id}</p>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 'auto' }}>
                            <button onClick={() => handleServerAction('teleport', player.id)}>Teleport</button>
                            <button onClick={() => handleServerAction('heal', player.id)}>Heal</button>
                            <button onClick={() => handleServerAction('revive', player.id)}>Revive</button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    )

}


export default PlayerManagement