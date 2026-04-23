import React from 'react';
import { Stats } from '../types';

export function StatsCards({ stats }: { stats: Stats }) {
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <div className="rounded-lg bg-white p-6 shadow">
        <p className="text-sm font-medium text-gray-500">Total Streams</p>
        <p className="mt-2 text-3xl font-semibold text-gray-900">{stats.totalStreams}</p>
      </div>
      <div className="rounded-lg bg-white p-6 shadow">
        <p className="text-sm font-medium text-gray-500">Active Streams</p>
        <p className="mt-2 text-3xl font-semibold text-green-600">{stats.activeStreams}</p>
      </div>
      <div className="rounded-lg bg-white p-6 shadow">
        <p className="text-sm font-medium text-gray-500">Total TVL</p>
        <p className="mt-2 text-3xl font-semibold text-gray-900">${stats.totalDeposited}</p>
      </div>
       <div className="rounded-lg bg-white p-6 shadow">
        <p className="text-sm font-medium text-gray-500">Total Streamed</p>
        <p className="mt-2 text-3xl font-semibold text-blue-600">${stats.totalWithdrawn}</p>
      </div>
    </div>
  );
}
