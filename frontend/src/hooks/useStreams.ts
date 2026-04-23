import { useState, useEffect } from 'react';
import { Stream, Stats, StreamFilter } from '../types';
import { getStreams, getStats } from '../utils/api';

export function useStreams() {
  const [streams, setStreams] = useState<Stream[]>([]);
  const [stats, setStats] = useState<Stats>({
    totalStreams: 0,
    activeStreams: 0,
    totalDeposited: '0',
    totalWithdrawn: '0',
  });
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<StreamFilter>('all');

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [streamsData, statsData] = await Promise.all([
          getStreams(filter),
          getStats(),
        ]);
        setStreams(streamsData);
        setStats(statsData);
      } catch (error) {
        console.error('Failed to fetch data', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [filter]);

  return { streams, stats, loading, filter, setFilter };
}
