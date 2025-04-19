import React, { useState } from "react";
import "./index.scss";
import { debugData } from "./utils/debugData";
import PlayerManagement from "./components/PlayerManagement";
import AdminOptions from "./components/AdminOptions";
import "@fortawesome/fontawesome-free/css/all.min.css";
import { fetchNui } from "./utils/fetchNui";



// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: "setVisible",
    data: true,
  },
]);





export default function App(){
  type Tab = 'admin' | 'players';

  const [activeTab, setActiveTab] = useState<Tab>('admin')

  const handleCloseMenu = () => {
    fetchNui('hideFrame')
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
      </div>
      <div className='tab-content'>
        {activeTab === 'players' && (
          <PlayerManagement />
        )}
        {activeTab === 'admin' && (
          <AdminOptions/>
        )}
      </div>
      <div className='footer'>
        <button className='close-menu' onClick={handleCloseMenu}><i className='fa-solid fa-xmark'></i></button>
      </div>
    </div>
  );
};
