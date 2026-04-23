export function formatAddress(address: string): string {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

export function formatToken(amount: string, decimals: number = 18): string {
  const num = parseFloat(amount) / Math.pow(10, decimals);
  return num.toLocaleString(undefined, { maximumFractionDigits: 4 });
}

export function calculateProgress(start: number, stop: number): number {
  const now = Math.floor(Date.now() / 1000);
  if (now <= start) return 0;
  if (now >= stop) return 100;
  return ((now - start) / (stop - start)) * 100;
}
