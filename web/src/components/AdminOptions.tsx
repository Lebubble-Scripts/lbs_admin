import React from 'react';
import { fetchNui } from '../utils/fetchNui';


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

type Heading = {
    heading: number;
}


export default function AdminOptions() {

    const handleKeyboardCopy = (text: string) => {
        const textarea = document.createElement('textarea')
        textarea.value = text;
        textarea.setAttribute('readonly', "")
        textarea.style.position = 'absolute'
        textarea.style.left = '-9999px'
        document.body.appendChild(textarea)

        textarea.select()
        document.execCommand('copy')
        document.body.removeChild(textarea)

        console.log('Copied to clipboard: ', text)
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

    return (
        <div className='admin-options'>
            <div className='buttons'>
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
                <h3>Dev</h3>
                <button onClick={handleGetVec3Coords}>Copy vec3 coords</button>
                <button onClick={handleGetVec4Coords}>Copy vec4 coords</button>
                <button onClick={handleGetHeading}>Copy Heading</button>
            </div>
        </div>

    )
}