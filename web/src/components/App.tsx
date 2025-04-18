import React, { useState } from "react";
import "./App.scss";
import { debugData } from "../utils/debugData";
import PlayerManagement from "./PlayerManagement";
import AdminOptions from "./AdminOptions";

// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: "setVisible",
    data: true,
  },
]);



const App: React.FC = () => {
  type Tab = 'admin' | 'server' | 'players';

  const [activeTab, setActiveTab] = useState<Tab>('admin')

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
          className={activeTab === 'server' ? 'tab active' : 'tab'}
          onClick={() => setActiveTab('server')}
        >
          Server
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
    </div>
  );
};

export default App;
