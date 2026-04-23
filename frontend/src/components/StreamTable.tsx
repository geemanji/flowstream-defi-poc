import React from 'react';
import { Stream } from '../types';
import { formatAddress, formatToken, calculateProgress } from '../utils/format';

export function StreamTable({ streams, onSelectStream }: { 
    streams: Stream[], 
    onSelectStream: (s: Stream) => void 
}) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">ID</th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Participants</th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Progress</th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Amount</th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Status</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 bg-white">
          {streams.map((stream) => (
            <tr 
                key={stream.id} 
                className="cursor-pointer hover:bg-gray-50"
                onClick={() => onSelectStream(stream)}
            >
              <td className="whitespace-nowrap px-6 py-4 text-sm font-medium text-gray-900">
                #{stream.streamId}
              </td>
              <td className="whitespace-nowrap px-6 py-4 text-sm text-gray-500">
                <div className="flex flex-col">
                  <span>From: {formatAddress(stream.sender)}</span>
                  <span>To: {formatAddress(stream.recipient)}</span>
                </div>
              </td>
              <td className="whitespace-nowrap px-6 py-4">
                <div className="w-full max-w-xs rounded-full bg-gray-200 h-2.5">
                  <div 
                    className="bg-blue-600 h-2.5 rounded-full" 
                    style={{ width: `${calculateProgress(stream.startTime, stream.stopTime)}%` }}
                  ></div>
                </div>
              </td>
              <td className="whitespace-nowrap px-6 py-4 text-sm text-gray-500">
                {formatToken(stream.deposit)} TKN
              </td>
              <td className="whitespace-nowrap px-6 py-4 text-sm">
                <span className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${ 
                  stream.active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' 
                }`}>
                  {stream.active ? 'Active' : 'Cancelled'}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
