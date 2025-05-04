import React, { useState, useEffect } from 'react';
import { fetchNui } from '../utils/fetchNui';
import PlayerActionModal from '../components/PlayerActionModal';

// Define Player Interface
interface Player {
    id: number;
    name: string;
}

// Mock data for testing in browser
const mockPlayers: Player[] = [
    { id: 1, name: 'Player One' },
    { id: 2, name: 'Player Two' },
    { id: 3, name: 'Player Three' },
    { id: 4, name: 'Player Four' },
    { id: 5, name: 'Player Five' },
    { id: 6, name: 'Player Six' },
    { id: 7, name: 'Player Seven' },
    { id: 8, name: 'Player Eight' },
    { id: 9, name: 'Player Nine' },
    { id: 10, name: 'Player Ten' }
    // ... add more if needed
];

export default function PlayerManagement() {
    // FOR BROWSER DEVELOPMENT === CHANGE [] to mockPlayers
    const [players, setPlayers] = useState<Player[]>([]);

    useEffect(() => {
        //FOR BROWSER DEVELOPMENT === COMMENT OUT FETCH CALL BELOW
        fetchNui<Player[]>('getPlayerList')
          .then((data) => {
            setPlayers(data);
          })
          .catch((e) => {
            console.error('Error retrieving player list', e);
            setPlayers([]);
          });
    }, []);

    // Handle action on server
    const handleServerAction = (
        action: string,
        id: number,
        reason?: string,
        duration?: string,
        durationUnit?: string
    ) => {
        const payload = {
            action: action,
            target: id,
            reason: reason || "",
            duration: duration || "",
            durationUnit: durationUnit || ""
        };

        fetchNui('player_action', payload)
    };

    // Modal state for selected player
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
        <div className="player-management">
            <h2>Player Management</h2>
            <div
                style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
                    gap: '16px'
                }}
            >
                {players.map((player) => (
                    <div key={player.id} className="player-card">
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
