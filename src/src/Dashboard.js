import React, { useEffect, useState } from "react";
import { Container, Typography, Card, CardContent, List, ListItem, ListItemText, Grid, Button } from "@mui/material";
import TransferDialog from "./TransferDialog";
import TransactionHistory from "./TransactionHistory";

export default function Dashboard() {
  const [balances, setBalances] = useState({ transferable: 0, savings: 0, savingsHold: 0, creditLimit: 0 });
  const [dialogOpen, setDialogOpen] = useState(false);
  const [transferType, setTransferType] = useState("");

  const fetchBalances = async () => {
    const res = await fetch(`${process.env.REACT_APP_API}/accounts/balances`, {
      headers: { Authorization: `Bearer ${localStorage.getItem("accessToken")}` }
    });
    const data = await res.json();
    setBalances(data);
  };

  useEffect(() => { fetchBalances(); }, []);

  const handleSuccess = () => { setDialogOpen(false); fetchBalances(); };

  return (
    <Container maxWidth="md" sx={{ mt: 4 }}>
      <Typography variant="h4">Welcome, Ruth Allen</Typography>
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant="h6">Account Balances</Typography>
          <List>
            <ListItem><ListItemText primary={`Transferable: $${balances.transferable}`} /></ListItem>
            <ListItem><ListItemText primary={`Savings: $${balances.savings}`} /></ListItem>
            <ListItem><ListItemText primary={`Savings Hold: $${balances.savingsHold}`} /></ListItem>
            <ListItem><ListItemText primary={`Credit Limit: $${balances.creditLimit}`} /></ListItem>
          </List>
        </CardContent>
      </Card>
      <Card>
        <CardContent>
          <Typography variant="h6">Transfer Options</Typography>
          <Grid container spacing={2}>
            <Grid item xs={12}><Button onClick={() => {setTransferType("Interbank"); setDialogOpen(true);}}>Interbank Transfer</Button></Grid>
            <Grid item xs={12}><Button onClick={() => {setTransferType("Wire"); setDialogOpen(true);}}>Wire Transfer</Button></Grid>
          </Grid>
        </CardContent>
      </Card>
      <TransactionHistory />
      <TransferDialog open={dialogOpen} type={transferType} onSuccess={handleSuccess} onClose={() => setDialogOpen(false)} />
    </Container>
  );
}
