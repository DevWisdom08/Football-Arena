# 🚀 Crypto Withdrawal Setup Guide

## ✅ What's Already Done

- ✅ CryptoPaymentService created (`crypto-payment.service.ts`)
- ✅ Withdrawal service updated for crypto
- ✅ API endpoints created
- ✅ Ethers.js installed

---

## 📋 Step-by-Step Setup

### **Step 1: Create a Crypto Wallet**

You need a wallet to send USDT/USDC to users.

**Option A: Use MetaMask (Easiest)**
1. Install MetaMask browser extension
2. Create a new wallet
3. **SAVE YOUR SEED PHRASE SECURELY!**
4. Export private key: Settings → Security & Privacy → Show Private Key
5. Copy the private key (starts with `0x`)

**Option B: Generate Programmatically**
```bash
node -e "const ethers = require('ethers'); const wallet = ethers.Wallet.createRandom(); console.log('Address:', wallet.address); console.log('Private Key:', wallet.privateKey);"
```

---

### **Step 2: Add Environment Variables**

Add these to your `.env` file:

```env
# Your wallet private key (KEEP SECRET!)
WALLET_PRIVATE_KEY=0xyour_private_key_here

# Polygon RPC URL (free)
POLYGON_RPC_URL=https://polygon-rpc.com

# Or use Alchemy (recommended for production)
# POLYGON_RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR_API_KEY
```

---

### **Step 3: Fund Your Wallet**

Your wallet needs:
1. **MATIC** (for gas fees) - ~$5-10 worth
2. **USDT** or **USDC** (for payments)

**How to get them:**

**Buy on Exchange → Transfer to Polygon**
1. Buy on Binance/Coinbase/Kraken
2. Withdraw to your wallet address
3. **IMPORTANT:** Select "Polygon Network" (not Ethereum!)

**Or use a Bridge**
- https://wallet.polygon.technology/polygon/bridge
- Bridge from Ethereum to Polygon

---

### **Step 4: Test on Mumbai Testnet First**

Before using real money, test on Mumbai (Polygon's testnet):

```env
# Use Mumbai testnet
POLYGON_RPC_URL=https://rpc-mumbai.maticvigil.com
```

**Get test tokens:**
- MATIC faucet: https://faucet.polygon.technology/
- Test USDT: Use Mumbai Uniswap to swap test MATIC

---

### **Step 5: Start the Backend**

```bash
cd football-arena-backend
npm install
npm run start:dev
```

---

### **Step 6: Test the Wallet API**

Test that your wallet is configured:

```bash
curl http://localhost:3000/withdrawals/wallet-info
```

Response should show:
```json
{
  "address": "0x...",
  "network": "Polygon",
  "balances": {
    "USDT": "1000.50",
    "USDC": "500.25"
  },
  "explorerUrl": "https://polygonscan.com/address/0x..."
}
```

---

### **Step 7: Process a Test Withdrawal**

1. Create a withdrawal request from Flutter app
2. Call the crypto processing endpoint:

```bash
curl -X POST http://localhost:3000/withdrawals/process-crypto \
  -H "Content-Type: application/json" \
  -d '{
    "withdrawalId": "uuid-here",
    "adminId": "admin-uuid"
  }'
```

---

## 💰 Cost Breakdown

### **Initial Setup:**
- Wallet creation: **FREE**
- Test on Mumbai: **FREE**

### **Production Costs:**

| Item | Cost | Notes |
|------|------|-------|
| MATIC for gas | $5-10 | ~100-200 transactions |
| USDT/USDC for payouts | Variable | Match your withdrawal needs |
| Withdrawal fee charged to users | $1 per withdrawal | Covers gas + small profit |

### **Per Transaction:**
- Gas cost: ~$0.01-0.50
- User pays: $1
- Your profit: ~$0.50-0.99 per withdrawal

---

## 🔐 Security Best Practices

1. **NEVER commit private key to Git**
   - Keep in `.env` file only
   - Add `.env` to `.gitignore`

2. **Use separate wallets**
   - Hot wallet: For daily operations (keep ~$1000)
   - Cold wallet: Store bulk funds offline

3. **Monitor wallet balance**
   - Set up alerts when balance is low
   - Auto-refill from cold wallet

4. **Enable 2FA on all accounts**
   - Alchemy/Infura accounts
   - Exchange accounts
   - Server access

---

## 📊 Recommended RPC Providers

### **Free (Good for Testing):**
- Polygon RPC: `https://polygon-rpc.com`
- Ankr: `https://rpc.ankr.com/polygon`

### **Paid (Better for Production):**
- **Alchemy** (Recommended): https://www.alchemy.com/
  - Free tier: 300M requests/month
  - Better reliability
  - Webhooks for notifications
  
- **Infura**: https://infura.io/
  - Free tier: 100K requests/day
  - Good reliability

---

## 🔍 Monitoring & Verification

### **Check Transaction on Blockchain:**
https://polygonscan.com/tx/TRANSACTION_HASH

### **Check Wallet Balance:**
https://polygonscan.com/address/YOUR_WALLET_ADDRESS

### **Set Up Alerts:**
Use Alchemy or QuickNode webhooks to get notified of:
- Low balance
- Failed transactions
- Large withdrawals

---

## 🐛 Troubleshooting

### **Error: "Insufficient funds"**
- Solution: Add more USDT/USDC to wallet

### **Error: "Insufficient gas"**
- Solution: Add more MATIC to wallet

### **Error: "Invalid private key"**
- Solution: Check that private key starts with `0x`

### **Transaction pending too long**
- Increase gas price in code
- Check Polygon network status: https://polygonscan.com/gastracker

---

## 📱 Flutter Integration

Update withdrawal screen to support crypto:

```dart
// In withdrawal_screen.dart
final methods = [
  {'id': 'crypto', 'name': 'Crypto (USDT/USDC)', 'icon': Icons.currency_bitcoin},
  // Remove PayPal, bank transfer options if you want crypto only
];

// Add wallet address input
TextField(
  controller: _walletAddressController,
  decoration: InputDecoration(
    labelText: 'Polygon Wallet Address',
    hintText: '0x...',
  ),
)
```

---

## 🚀 Go Live Checklist

- [ ] Tested on Mumbai testnet
- [ ] Wallet funded with MATIC (for gas)
- [ ] Wallet funded with USDT/USDC
- [ ] Environment variables set
- [ ] `.env` in `.gitignore`
- [ ] Admin dashboard can process withdrawals
- [ ] Monitoring/alerts set up
- [ ] Backup wallet created
- [ ] Seed phrase stored securely

---

## 💡 Pro Tips

1. **Use Polygon, not Ethereum**
   - Gas on Ethereum: $5-50
   - Gas on Polygon: $0.01-0.50

2. **Charge $1 flat fee**
   - Covers gas + profit
   - Much better than 5% (e.g., $5 on $100)

3. **Auto-process small withdrawals**
   - Withdrawals under $50: auto-approve
   - Withdrawals over $50: manual review

4. **Batch large withdrawals**
   - Process multiple at once
   - Save on gas fees

---

## 📞 Need Help?

- Ethers.js docs: https://docs.ethers.org/
- Polygon docs: https://docs.polygon.technology/
- Alchemy tutorials: https://docs.alchemy.com/

---

## ✅ Your Setup is Ready!

You now have a complete crypto withdrawal system that:
- ✅ Costs $0.01-0.50 per transaction
- ✅ Processes instantly (30 seconds)
- ✅ Works globally
- ✅ No account freezing risks
- ✅ Higher profit margins than PayPal

**Next: Fund your wallet and start testing!** 🚀

