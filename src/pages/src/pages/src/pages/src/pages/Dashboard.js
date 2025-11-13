import React from 'react';

export default function Dashboard() {
  const transactions = [
    { id: 1, date: '2025-11-01', description: 'Deposit', amount: 500 },
    { id: 2, date: '2025-11-05', description: 'Withdrawal', amount: -200 },
    { id: 3, date: '2025-11-10', description: 'Transfer to Savings', amount: -100 },
  ];

  return (
    <div>
      <h2>Dashboard</h2>
      <p>Here are your recent transactions:</p>
      <table border="1" cellPadding="8" style={{ marginTop: '1rem' }}>
        <thead>
          <tr>
            <th>Date</th>
            <th>Description</th>
            <th>Amount ($)</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map(tx => (
            <tr key={tx.id}>
              <td>{tx.date}</td>
              <td>{tx.description}</td>
              <td style={{ color: tx.amount < 0 ? 'red' : 'green' }}>
                {tx.amount}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
