import React, { useState, useEffect } from "react";
//import "./index.css"
import "@fortawesome/fontawesome-free/css/all.min.css";
import { fetchNui } from "../utils/fetchNui";

export default function ReportMenu() {
    const [reportMessage, setReportMessage] = useState("")

    const handleCloseMenu = () => {
      fetchNui('hideFrame')
    }

    const handleSubmitReport = () => {
        if (reportMessage.trim() === "") return;

        fetchNui('submitReport', {message: reportMessage}).then(() => {
            alert('Report submitted successfully!');
            setReportMessage("");
        })
    }



    return (
        <div className="report-menu">
          <h2>Submit a Report </h2>
          <textarea
            value={reportMessage}
            onChange={(e) => setReportMessage(e.target.value)}
            placeholder="Describe the issue..."
          />
          <button onClick={handleSubmitReport}>Submit Report</button>
          <button onClick={handleCloseMenu}>X</button>
        </div>
      );
}