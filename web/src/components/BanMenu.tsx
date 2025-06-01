import { useState, useEffect } from 'react'
import "../index.scss"
import { fetchNui } from '../utils/fetchNui'
import BanActionModal from './BanActionModal';

interface Bans {
    id: string,
    name: string,
    license: string,
    discord: string,
    ip: string,
    reason: string,
    expire: number,
    bannedby: string
}

type Ban = {
    id: string,
    name: string,
    license: string,
    discord: string,
    ip: string,
    reason: string,
    expire: number,
    bannedby: string
}

const mockBans: Bans[] = [
  {
    id: "1",
    name: "John Doe",
    license: "license:1234567890abcdef",
    discord: "JohnDoe#1234",
    ip: "192.168.1.10",
    reason: "Cheating",
    expire: 1719878400, // Example timestamp
    bannedby: "AdminOne"
  },
  {
    id: "2",
    name: "Jane Smith",
    license: "license:abcdef1234567890",
    discord: "JaneSmith#5678",
    ip: "192.168.1.20",
    reason: "Toxic behavior",
    expire: 0, // Permanent ban
    bannedby: "AdminTwo"
  },
  {
    id: "3",
    name: "PlayerThree",
    license: "license:fedcba0987654321",
    discord: "PlayerThree#9999",
    ip: "10.0.0.5",
    reason: "Exploiting bugs",
    expire: 1722470400,
    bannedby: "AdminThree"
  }
];

export default function AdminReportMenu() {
    const [bans, setBans] = useState<Bans[]>([]);
    const [selectedBan, setSelectedBan] = useState<Ban | null>(null);
    const [modalOpened, setModalOpened] = useState(false)

    const handleOpenModal = (ban: Ban) => {
        setSelectedBan(ban);
        setModalOpened(true);
    }

    const handleCloseModal = () => {
        setModalOpened(false);
        setSelectedBan(null);
        fetchBans()
    }

    const fetchBans= () => {
        fetchNui<Bans[]>('getBansList')
        .then((data) => {
            if (!data){
                setBans(data)
            }
            else {
                setBans(mockBans)
            }
        })
        .catch((e) => {
            console.error("Error retrieving bans list ", e)
            setBans(mockBans)
        })
    }

    useEffect(() => {
        fetchBans()
    }, [])

    return (
        <div className='ban-management'>
            <h2>Bans</h2>
            <div className='ban-grid' style={{
                display:'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(300px,1fr))',
                gap:"16px"
            }}>
                {
                    bans.map((ban) => {
                        return (
                            <div key={ban.id} className='ban-card'>
                                <button onClick={() => handleOpenModal(ban)}>{ban.name}</button>
                                <p>{ban.reason.slice(0,50)}</p>
                                <p>Banned by: {ban.bannedby}</p>
                            </div>
                        )
                    })
                }
                {selectedBan && (
                    <BanActionModal
                        opened={modalOpened}
                        ban={selectedBan}
                        onClose={handleCloseModal}/>
                )}
            </div>
        </div>
    )
}
 
