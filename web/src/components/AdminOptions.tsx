import React, {useState, useEffect} from 'react';
import { fetchNui } from '../utils/fetchNui';
import CustomDropdown from './CustomDropdown';


type Vec3 = {
    x: number;
    y: number;
    z: number;
}

type Vec4 = {
    x: number;
    y: number;
    z: number;
    w: number;
}

type Vehicles = {
    model: number;
    name: string;
}


export default function AdminOptions() {
    const [vehicles, setVehicles] = useState<Vehicles[]>([])
    const [selectedVehicle, setSelectedVehicle] = useState<number | null>(null)

    const handleVehicleSelect = (model: number) => {
        setSelectedVehicle(model)
    }


    const handleVehicleSpawn = () => {
        if (selectedVehicle !== null) {
            console.log('Selected vehicle model:', selectedVehicle);
            fetchNui('spawnVehicle', {model: selectedVehicle})
            .then(() => {
                console.log(`Vehicle with model ${selectedVehicle} sent to lua`)
            })
            .catch((e) => {
                console.error('failed to send data to client', e)
            })
        }
    }

    const handleKeyboardCopy = (text: string) => {
        //keep this as a fallback just incase it doesn't get copied to the clipboard.
        console.log('Copied to clipboard: ', text)
        
        const textarea = document.createElement('textarea')
        textarea.value = text;
        textarea.setAttribute('readonly', "")
        textarea.style.position = 'absolute'
        textarea.style.left = '-9999px'
        document.body.appendChild(textarea)

        textarea.select()
        document.execCommand('copy')
        document.body.removeChild(textarea)
        
    }
    const handleGetVec3Coords = () => {
        fetchNui<Vec3>('get_vec3')
        .then(coords => {
            const coordString = `vector3(${coords.x.toFixed(2)},${coords.y.toFixed(2)},${coords.z.toFixed(2)})`
            handleKeyboardCopy(coordString)
        })
    }
    const handleGetVec4Coords = () => {
        fetchNui<Vec4>('get_vec4')
        .then(coords => {
            const coordString = `vector4(${coords.x.toFixed(2)},${coords.y.toFixed(2)},${coords.z.toFixed(2)},${coords.w.toFixed(2)})`
            handleKeyboardCopy(coordString)
        })
    }
    const handleTeleportWaypoint = () => {
        fetchNui('teleport_to_marker')
    }
    const handleGetHeading = () => {
        fetchNui<{heading: number}>('get_heading')
        .then(res => {
            const headingString = `${res.heading}`
            handleKeyboardCopy(headingString)
        })
    }
    const handleHealAction = () => {
        fetchNui('heal_self')
    }
    const handleReviveAction = () => {
        fetchNui('revive_self')
    }

    useEffect(() => {
        fetchNui<Vehicles[]>('getVehiclesList')
        .then((data) => {
            setVehicles(data);
        })
        .catch((e) => {
            console.error('Error retrieving vehicles list', e)
        })
    }, [])

    return (
        <div className='admin-options'>
            <div className='admin-content'>
                {/* <img src='./assets/images/LOGOSYNCRP.png' alt='Server Logo Image'></img> */}
                <h3>Admin</h3>
                <button onClick={handleHealAction}>
                    Heal Self
                </button>
                <button onClick={handleTeleportWaypoint}>
                    Teleport to Waypoint
                </button>
                <button onClick={handleReviveAction}>
                    Revive Self
                </button>
                <div className='vehicle-spawn-container'>
                <CustomDropdown
                        options={[
                            ...new Map(
                                vehicles.map((vehicle) => [vehicle.model, vehicle])
                            ).values(),
                        ].map((vehicle) => ({
                            value: vehicle.model,
                            label: vehicle.name 
                        }))
                        }
                        onSelect={handleVehicleSelect}
                        placeholder="Select a vehicle"
                    />
                    <button onClick={handleVehicleSpawn}>Spawn</button>
                </div>
                <h3>Dev</h3>
                <button onClick={handleGetVec3Coords}>Copy vec3 coords</button>
                <button onClick={handleGetVec4Coords}>Copy vec4 coords</button>
                <button onClick={handleGetHeading}>Copy Heading</button>
            </div>
        </div>

    )
}