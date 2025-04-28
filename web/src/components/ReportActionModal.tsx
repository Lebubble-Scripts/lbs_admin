import React, {useState} from 'react';


interface Report {
    id: number,
    name: string,
    reason: string,
    status: string
}

interface ReportActionModalProps {
    opened: boolean;
    report: Report;
    onPlayerAction: (action: string, id:number) => (void);
    onReportAction: (action: string, id:number) => (void);
    onClose?:() => void;
}

export default function ReportActionModal({
    opened,
    report,
    onPlayerAction,
    onReportAction,
    onClose
}: ReportActionModalProps) {
    if (!opened) return null;

    const handlePlayerAction= (action: string) => {
        onPlayerAction(action, report.id)
    }

    const handleReportAction = (action: string) => {
        onReportAction(action, report.id)
    }


    return (
        <div className='modal-overlay'>
            <div className="modal-content">
                <div className="modal-header">
                    <h3>Actions for {report.name}'s report</h3>
                </div>
                <div className="report-info">
                    <p>Player ID: {report.id}</p>
                    <p>Reason: {report.reason}</p>
                </div>
                <div className='report-player-actions'>
                    <h4>Player Actions</h4>
                    <button onClick={() => handlePlayerAction('teleport')} className="action-button teleport">
                        <i className="fa-solid fa-location-arrow"></i> Teleport
                    </button>
                </div>
                <div className='report-action'>
                    <h4>Report Action</h4>
                    <button onClick={() => handleReportAction('close')} className='action-button close'>
                        Close Report
                    </button>
                </div>
                <div className='report-status'>
                    <h4>{report.status}</h4>
                </div>
                <button className="close-modal" onClick={onClose}>
                    <i className="fa-solid fa-xmark"></i>
                </button>
            </div>


        </div>
    )
}