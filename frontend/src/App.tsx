import React, { useState } from 'react';
import { StatsCards } from './components/StatsCards';
import { FilterBar } from './components/FilterBar';
import { StreamTable } from './components/StreamTable';
import { StreamDetail } from './components/StreamDetail';
import { useStreams } from './hooks/useStreams';
import { Stream } from './types';

function App() {
  const { streams, stats, loading, filter, setFilter } = useStreams();
  const [selectedStream, setSelectedStream] = useState<Stream | null>(null);

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="mx-auto max-w-7xl">
        <header className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">🌊 FlowStream</h1>
            <p className="text-gray-600">Decentralized Payment Streaming Protocol Dashboard</p>
          </div>
          <div className="flex items-center gap-4">
             <span className="inline-flex items-center rounded-full bg-green-100 px-3 py-0.5 text-sm font-medium text-green-800">
              <span className="mr-1.5 h-2 w-2 rounded-full bg-green-400"></span>
              Connected to Anvil
            </span>
          </div>
        </header>

        <StatsCards stats={stats} />

        <div className="mt-8 rounded-lg bg-white shadow">
          <div className="border-b border-gray-200 px-6 py-4">
            <FilterBar filter={filter} onFilterChange={setFilter} />
          </div>
          
          <div className="p-6">
            {loading ? (
              <div className="flex h-64 items-center justify-center">
                <p className="text-gray-500">Loading streams...</p>
              </div>
            ) : (
              <StreamTable 
                streams={streams} 
                onSelectStream={setSelectedStream} 
              />
            )}
          </div>
        </div>

        {selectedStream && (
          <StreamDetail 
            stream={selectedStream} 
            onClose={() => setSelectedStream(null)} 
          />
        )}
      </div>
    </div>
  );
}

export default App;
