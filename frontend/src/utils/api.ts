import { Stream, Stats, StreamFilter } from '../types';

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

export async function getStreams(filter: StreamFilter): Promise<Stream[]> {
  // In a real app, this would be an actual API call
  // For the POC, we return demo data if the API is not available
  try {
    const response = await fetch(`${API_BASE}/streams?filter=${filter}`);
    if (response.ok) return await response.json();
  } catch (e) {}

  return DEMO_STREAMS.filter(s => {
    if (filter === 'active') return s.active;
    if (filter === 'cancelled') return !s.active;
    return true;
  });
}

export async function getStats(): Promise<Stats> {
  try {
    const response = await fetch(`${API_BASE}/stats`);
    if (response.ok) return await response.json();
  } catch (e) {}

  return DEMO_STATS;
}

const DEMO_STREAMS: Stream[] = [
    {
        id: '1',
        streamId: '101',
        sender: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
        recipient: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
        token: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eb48', // USDC
        deposit: '5000000000',
        ratePerSecond: '19290',
        startTime: Math.floor(Date.now() / 1000) - 86400,
        stopTime: Math.floor(Date.now() / 1000) + 172800,
        withdrawn: '1200000000',
        active: true,
        txHash: '0x123...abc',
        created_at: new Date().toISOString(),
    },
    {
        id: '2',
        streamId: '102',
        sender: '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
        recipient: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
        token: '0x6B175474E89094C44Da98b954EedeAC495271d0F', // DAI
        deposit: '1000000000000000000000',
        ratePerSecond: '3858024691358', 
        startTime: Math.floor(Date.now() / 1000) - 43200,
        stopTime: Math.floor(Date.now() / 1000) + 216000,
        withdrawn: '0',
        active: true,
        txHash: '0x456...def',
        created_at: new Date().toISOString(),
    }
];

const DEMO_STATS: Stats = {
    totalStreams: 15,
    activeStreams: 8,
    totalDeposited: '15400.50',
    totalWithdrawn: '4200.25',
};
