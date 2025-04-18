import React from 'react';


export default function AdminOptions() {
    return (
        <div className='admin-options'>
            <div className='buttons'>
                <h3>Admin</h3>
                <button>
                    Heal Self
                </button>
                <button>
                    Teleport to Waypoint
                </button>
                <button>
                    Revive Self
                </button>
                <h3>Dev</h3>
                <button>Copy vec3 coords</button>
                <button>Copy vec4 coords</button>
                <button>Copy Heading</button>
            </div>
        </div>

    )
}