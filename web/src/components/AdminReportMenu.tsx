import React, {useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'


interface Reports {
    id: number,
    name: string,
    reason: string,
    status: string
}

const mockReports: Reports[] = [
    { id: 1, name: 'user1', reason: 'This is a test reason that goes well past fifty characters to ensure proper display.', status: 'open' },
    { id: 2, name: 'user2', reason: 'test reason 2', status: 'open' },
    { id: 3, name: 'user3', reason: 'test reason 3', status: 'open' },
    { id: 4, name: 'user4', reason: 'test reason 4', status: 'open' },
    { id: 5, name: 'user5', reason: 'test reason 5', status: 'open' },
    { id: 6, name: 'user6', reason: 'test reason 6', status: 'open' },
    { id: 7, name: 'user7', reason: 'test reason 7', status: 'open' },
    { id: 8, name: 'user8', reason: 'test reason 8', status: 'open' },
    { id: 9, name: 'user9', reason: 'test reason 9', status: 'open' },
    { id: 10, name: 'user10', reason: 'test reason 10', status: 'open' },
    { id: 11, name: 'user11', reason: 'test reason 11', status: 'open' }
]


export default function AdminReportMenu() {
    const [reports, setReports] = useState<Reports[]>(mockReports)

    useEffect(() => {
        // fetchNui<Reports[]>('getReportList')
        // .then((data) => {
        //     setReports(data);
        // })
        // .catch((e)=> {
        //     console.error('Error retrieving reports list ', e);
        //     setReports([])
        // });
    }, []);

    const statusColors = {
        open: 'green'
    }


    return (
        <div className='report-management'>
        <h2>Reports</h2>
        <div className='report-grid' style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
            gap: '16px'
        }}
        >
            {
                reports.map((report) => {
                    // Define background colors for statuses
                    const statusColors = {
                        open: 'yellow',
                        resolved: 'green',
                        rejected: 'red',
                        default: 'gray'
                    };

                    // Determine background color based on report status
                    const color = statusColors[report.status] || statusColors.default;

                    return (
                        <div 
                            key={report.id} 
                            className='player-card' 
                        >
                            <button>{report.name}</button>
                            <p>{report.reason.slice(0, 50)}...</p>
                            <p style={{color}}>{report.status}</p>
                        </div>
                    );
                })
            }
        </div>
    </div>
    )
}