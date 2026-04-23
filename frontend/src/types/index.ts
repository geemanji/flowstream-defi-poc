export interface Stream {
    id: string;
    streamId: string;
    sender: string;
    recipient: string;
    token: string;
    deposit: string;
    ratePerSecond: string;
    startTime: number;
    stopTime: number;
    withdrawn: string;
    active: boolean;
    txHash: string;
    created_at: string;
}

export interface Stats {
    totalStreams: number;
    activeStreams: number;
    totalDeposited: string;
    totalWithdrawn: string;
}

export type StreamFilter = 'all' | 'active' | 'cancelled' | 'incoming' | 'outgoing';
