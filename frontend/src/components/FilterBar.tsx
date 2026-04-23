import React from 'react';
import { StreamFilter } from '../types';

export function FilterBar({ filter, onFilterChange }: { 
    filter: StreamFilter, 
    onFilterChange: (f: StreamFilter) => void 
}) {
  const filters: { label: string, value: StreamFilter }[] = [
    { label: 'All Streams', value: 'all' },
    { label: 'Active', value: 'active' },
    { label: 'Cancelled', value: 'cancelled' },
  ];

  return (
    <div className="flex gap-2">
      {filters.map((f) => (
        <button
          key={f.value}
          onClick={() => onFilterChange(f.value)}
          className={`rounded-md px-3 py-2 text-sm font-medium ${ 
            filter === f.value 
              ? 'bg-blue-100 text-blue-700' 
              : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50' 
          }`}
        >
          {f.label}
        </button>
      ))}
    </div>
  );
}
