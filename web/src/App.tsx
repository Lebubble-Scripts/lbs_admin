import React, { useState } from "react";
import "./index.scss";
import { debugData } from "./utils/debugData";
import PlayerManagement from "./components/PlayerManagement";
import AdminOptions from "./components/AdminOptions";
import "@fortawesome/fontawesome-free/css/all.min.css";
import { fetchNui } from "./utils/fetchNui";
import AdminReportMenu from "./components/AdminReportMenu";
import BanMenu from "./components/BanMenu"


// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: "setVisible",
    data: true,
  },
]);





export default function App(){
  type Tab = 'admin' | 'players' | 'reports' | 'bans';

  const [activeTab, setActiveTab] = useState<Tab>('admin')

  const handleCloseMenu = () => {
    fetchNui('hideAdminMenu')
  }

  return (
    <div className="nui-wrapper">
      <div className="tab-row">
        <button
          className={activeTab === 'admin' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('admin')}
        >
          Admin
        </button>
        <button
          className={activeTab === 'players' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('players')}
        >
          Players
        </button>
        <button
          className={activeTab === 'reports' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('reports')}
        >
          Reports
        </button>
        <button
          className={activeTab === 'bans' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('bans')}
        >
          Bans
        </button>
      </div>
      <div className='tab-content'>
        {activeTab === 'players' && (
          <PlayerManagement />
        )}
        {activeTab === 'admin' && (
          <AdminOptions/>
        )}
        {activeTab === 'reports' && (
          <AdminReportMenu/>
        )}
        {activeTab === 'bans' && (
          <BanMenu/>
        )}
      </div>
      <div className='footer'>
        <button className='close-menu' onClick={handleCloseMenu}><i className='fa-solid fa-xmark'></i></button>
      </div>
    </div>
  );
}
