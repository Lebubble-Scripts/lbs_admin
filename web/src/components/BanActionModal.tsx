import { fetchNui } from "../utils/fetchNui"

interface Ban {
    id: string,
    name: string,
    license: string,
    discord: string,
    ip: string,
    reason: string,
    expire: number,
    bannedby: string
}

interface BanActionModalProps {
    opened: boolean,
    ban: Ban;
    onClose?:()=>void;
}




export default function BanActionModal({
    opened,
    ban,
    onClose
}:BanActionModalProps){
    if (!opened) return null;

    const handleUnban = (banId: string) => {
        const payload = {
            id: banId
        }
        fetchNui('unbanPlayer', payload)
        onClose?.()
    }
    

    return (
        <div className='modal-overlay'>
        <div className="modal-content">
            <div className="modal-header">
                <h3>Actions for {ban.name}'s Ban</h3>
            </div>
            <div className="report-info">
                <p>ID | {ban.id}</p>
                <p>Name | {ban.name}</p>
                <p>License | {ban.license}</p>
                <p>Discord | {ban.discord}</p>
                <p>IP Address | {ban.ip}</p>
                <p>Reason | {ban.reason}</p>
                <p>Expires | {ban.expire ? new Date(ban.expire).toLocaleString() : 'Permanent'}</p>
                <p>Banned by | {ban.bannedby}</p>
            </div>

            <button className='button-unban' onClick={() => handleUnban(ban.id)}>
                Unban
            </button>

            <button className="close-modal" onClick={onClose}>
                <i className="fa-solid fa-xmark"></i>
            </button>
        </div>


    </div>
    )
}