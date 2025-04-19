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
import PlayerActionModal from '../components/PlayerActionModal'

//Define Player Interface
//i.e Defines shape of the player object
interface Player {
    id: number;
    name: string;
}

// // Mock data for testing
// const mockPlayers: Player[] = [
//     { id: 1, name: 'Player One' },
//     { id: 2, name: 'Player Two' },
//     { id: 3, name: 'Player Three' },
//     { id: 4, name: 'Player Four' },
//     { id: 5, name: 'Player Five' },
//     { id: 6, name: 'Player Six' },
//     { id: 7, name: 'Player Seven' },
//     { id: 8, name: 'Player Eight' },
//     { id: 9, name: 'Player Nine' },
//     { id: 10, name: 'Player Ten' },
//     { id: 11, name: 'Player Eleven' },
//     { id: 12, name: 'Player Twelve' },
//     { id: 13, name: 'Player Thirteen' },
//     { id: 14, name: 'Player Fourteen' },
//     { id: 15, name: 'Player Fifteen' },
//     { id: 16, name: 'Player Sixteen' },
//     { id: 17, name: 'Player Seventeen' },
//     { id: 18, name: 'Player Eighteen' },
//     { id: 19, name: 'Player Nineteen' },
//     { id: 20, name: 'Player Twenty' },
//     { id: 21, name: 'Player Twenty-One' },
//     { id: 22, name: 'Player Twenty-Two' },
//     { id: 23, name: 'Player Twenty-Three' },
//     { id: 24, name: 'Player Twenty-Four' },
//     { id: 25, name: 'Player Twenty-Five' },
//     { id: 26, name: 'Player Twenty-Six' },
//     { id: 27, name: 'Player Twenty-Seven' },
//     { id: 28, name: 'Player Twenty-Eight' },
//     { id: 29, name: 'Player Twenty-Nine' },
//     { id: 30, name: 'Player Thirty' },
//     { id: 31, name: 'Player Thirty-One' },
//     { id: 32, name: 'Player Thirty-Two' },
//     { id: 33, name: 'Player Thirty-Three' },
//     { id: 34, name: 'Player Thirty-Four' },
//     { id: 35, name: 'Player Thirty-Five' },
//     { id: 36, name: 'Player Thirty-Six' },
//     { id: 37, name: 'Player Thirty-Seven' },
//     { id: 38, name: 'Player Thirty-Eight' },
//     { id: 39, name: 'Player Thirty-Nine' },
//     { id: 40, name: 'Player Forty' }
// ];

export default function PlayerManagement() {
    const [players, setPlayers] = useState<Player[]>([]);
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
    }, [])

    // Handle Server Action
    const handleServerAction = (action: string, id: number) => {
        console.log(`Action: ${action}, Player ID: ${id}`);
        fetchNui('playerAction', { action, target: id })
            .catch((e) => {
                console.error('Error sending action', e)
            })
        }

        // New state for modal and selected player
        const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
        const [modalOpened, setModalOpened] = useState(false);

        const handleOpenModal = (player: Player) => {
          setSelectedPlayer(player);
          setModalOpened(true);
        };

        const handleCloseModal = () => {
          setModalOpened(false);
          setSelectedPlayer(null);
        };

        return (
        <div className='player-management'>
            <h2>Player Management</h2>
            <div
            style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
                gap: '16px'
            }}
            >
            {players.map((player) => (
                <div
                key={player.id}
                className="player-card"
                >
                <button onClick={() => handleOpenModal(player)}>
                  {player.name}
                </button>
                <p>ID: {player.id}</p>
                </div>
            ))}
            </div>
            {selectedPlayer && (
              <PlayerActionModal 
            opened={modalOpened} 
            player={selectedPlayer} 
            onAction={handleServerAction}
            onClose={handleCloseModal}
              />
            )}
        </div>
        );
    }
