import React, { useState } from "react";
import { Dialog, DialogTitle, DialogContent, TextField, Button } from "@mui/material";

export default function TransferDialog({ open, onClose, onSuccess, type }) {
  const [form, setForm] = useState({ amount: "", otp: "" });

  const handleSubmit = async () => {
    const res = await fetch(`${process.env.REACT_APP_API}/tx/${type.toLowerCase()}`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${localStorage.getItem("accessToken")}` },
      body: JSON.stringify(form)
    });
    if (res.ok) onSuccess();
  };

  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle>{type} Transfer</DialogTitle>
      <DialogContent>
        <TextField label="Amount" fullWidth onChange={e => setForm({...form, amount: e.target.value})} />
        <TextField label="OTP" fullWidth onChange={e => setForm({...form, otp: e.target.value})} />
        <Button onClick={handleSubmit}>Confirm</Button>
      </DialogContent>
    </Dialog>
  );
}
