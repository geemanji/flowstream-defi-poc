import React from 'react';
import { Stream } from '../types';
import { formatAddress, formatToken } from '../utils/format';

export function StreamDetail({ stream, onClose }: { 
    stream: Stream, 
    onClose: () => void 
}) {
  return (
    <div className="fixed inset-0 z-10 overflow-y-auto">
      <div className="flex min-h-screen items-end justify-center px-4 pb-20 pt-4 text-center sm:block sm:p-0">
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={onClose}></div>
        <div className="inline-block transform overflow-hidden rounded-lg bg-white text-left align-bottom shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:align-middle">
          <div className="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
            <div className="sm:flex sm:items-start">
              <div className="mt-3 w-full text-center sm:ml-4 sm:mt-0 sm:text-left">
                <h3 className="text-lg font-medium leading-6 text-gray-900">
                  Stream Details #{stream.streamId}
                </h3>
                <div className="mt-4 space-y-3">
                  <div className="flex justify-between border-b py-2">
                    <span className="text-gray-500">Sender</span>
                    <span className="font-mono">{formatAddress(stream.sender)}</span>
                  </div>
                  <div className="flex justify-between border-b py-2">
                    <span className="text-gray-500">Recipient</span>
                    <span className="font-mono">{formatAddress(stream.recipient)}</span>
                  </div>
                  <div className="flex justify-between border-b py-2">
                    <span className="text-gray-500">Total Deposit</span>
                    <span>{formatToken(stream.deposit)} TKN</span>
                  </div>
                   <div className="flex justify-between border-b py-2">
                    <span className="text-gray-500">Withdrawn</span>
                    <span className="text-green-600">{formatToken(stream.withdrawn)} TKN</span>
                  </div>
                  <div className="flex justify-between border-b py-2">
                    <span className="text-gray-500">Start Time</span>
                    <span>{new Date(stream.startTime * 1000).toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between border-b py-2">
                    <span className="text-gray-500">Stop Time</span>
                    <span>{new Date(stream.stopTime * 1000).toLocaleString()}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
            <button
              type="button"
              className="mt-3 inline-flex w-full justify-center rounded-md border border-gray-300 bg-white px-4 py-2 text-base font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none sm:ml-3 sm:mt-0 sm:w-auto sm:text-sm"
              onClick={onClose}
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
