import { useState, useEffect } from 'react'
import "../index.scss"
import { fetchNui } from '../utils/fetchNui'
import BanActionModal from './BanActionModal';

interface Bans {
    id: number,
    name: string,
    license: string,
    discord: string,
    ip: string,
    reason: string,
    expire: number,
    bannedby: string
}

type Ban = {
    id: number,
    name: string,
    license: string,
    discord: string,
    ip: string,
    reason: string,
    expire: number,
    bannedby: string
}


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
            setBans(data)
        })
        .catch((e) => {
            console.error("Error retrieving bans list ", e)
            setBans([])
        })
    }

    useEffect(() => {
        // const dummyData = [
        //     {
        //         id: 1,
        //         name: 'Test Player',
        //         license: 'license:12345',
        //         discord: 'discord:67890',
        //         ip: '127.0.0.1',
        //         reason: 'Testing',
        //         expire: 123456789,
        //         bannedby: 'Admin'
        //     }
        // ];
        // setBans(dummyData);
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
 
