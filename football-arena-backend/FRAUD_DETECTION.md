# Fraud Detection System

## Overview

The Football Arena platform includes a comprehensive fraud detection system to protect both the business and legitimate users. This system monitors user behavior and automatically flags suspicious activities.

## 🚨 Fraud Alert Types

### 1. **RAPID_BETTING**
- **Trigger**: User plays 10+ games within 5 minutes
- **Severity**: Medium
- **Action**: Flagged for review

### 2. **SUSPICIOUS_WITHDRAWAL**
- **Trigger**: User attempts to withdraw >90% of total balance
- **Severity**: Medium
- **Action**: Flagged for review

### 3. **LARGE_TRANSACTION**
- **Trigger**: Withdrawal amount ≥ 50,000 coins ($50)
- **Severity**: High
- **Action**: Flagged for manual review

### 4. **WIN_RATE_ANOMALY**
- **Trigger**: Win rate ≥ 85% after 20+ games
- **Severity**: High
- **Action**: Flagged for investigation

### 5. **UNUSUAL_ACTIVITY**
- **Trigger**: Exceeds daily withdrawal limit (5 per day)
- **Severity**: High
- **Action**: Withdrawal blocked, flagged for review

### 6. **MULTIPLE_ACCOUNTS**
- **Trigger**: Multiple accounts from same IP/device
- **Severity**: High
- **Action**: Accounts flagged for review
- **Status**: Requires IP tracking implementation

### 7. **ACCOUNT_TAKEOVER**
- **Trigger**: Sudden change in behavior patterns
- **Severity**: Critical
- **Action**: Account temporarily restricted

## 📊 Detection Thresholds

```typescript
// Rapid Betting
RAPID_BETTING_THRESHOLD = 10 games
RAPID_BETTING_WINDOW = 5 minutes

// Withdrawals
LARGE_WITHDRAWAL_THRESHOLD = 50,000 coins ($50)
MAX_DAILY_WITHDRAWALS = 5
SUSPICIOUS_WITHDRAWAL_RATIO = 0.9 (90%)

// Win Rate
HIGH_WIN_RATE_THRESHOLD = 0.85 (85%)
MIN_GAMES_FOR_WIN_RATE_CHECK = 20
```

## 🔄 Automatic Detection Flow

### Stake Match Creation
```
User creates match → Check rapid betting → Flag if threshold exceeded
```

### Stake Match Completion
```
Match completes → Determine winner → Check win rate → Flag if suspicious
```

### Withdrawal Request
```
User requests withdrawal → Check:
  1. Large transaction threshold
  2. Withdrawal ratio (% of balance)
  3. Daily withdrawal limit
  → Block if limits exceeded or flag for review
```

## 🛡️ API Endpoints

### Get All Fraud Alerts (Admin)
```http
GET /fraud-detection/alerts?status=pending&severity=high
```

**Query Parameters:**
- `status`: pending | reviewing | resolved | false_positive | confirmed
- `severity`: low | medium | high | critical

**Response:**
```json
[
  {
    "id": "uuid",
    "userId": "user-uuid",
    "type": "WIN_RATE_ANOMALY",
    "severity": "high",
    "status": "pending",
    "description": "Abnormally high win rate: 87.5%",
    "metadata": {
      "totalGames": 40,
      "wins": 35,
      "winRate": 0.875
    },
    "createdAt": "2025-12-19T10:30:00Z"
  }
]
```

### Get User's Fraud Alerts
```http
GET /fraud-detection/alerts/user/:userId
```

### Review Fraud Alert (Admin)
```http
POST /fraud-detection/alerts/:alertId/review
Content-Type: application/json

{
  "status": "resolved",
  "reviewedBy": "admin-user-id",
  "reviewNotes": "Legitimate high-skill player. No fraud detected."
}
```

### Check if User is Flagged
```http
GET /fraud-detection/check/:userId
```

**Response:**
```json
{
  "userId": "user-uuid",
  "isFlagged": false
}
```

### Get Fraud Statistics (Admin Dashboard)
```http
GET /fraud-detection/stats
```

**Response:**
```json
{
  "totalAlerts": 45,
  "pendingAlerts": 12,
  "criticalAlerts": 3,
  "alertsByType": [
    { "type": "RAPID_BETTING", "count": 15 },
    { "type": "WIN_RATE_ANOMALY", "count": 8 },
    { "type": "LARGE_TRANSACTION", "count": 12 }
  ]
}
```

### Run Manual Fraud Check
```http
POST /fraud-detection/check/:userId
Content-Type: application/json

{
  "ipAddress": "192.168.1.1"
}
```

## 📈 Alert Severity Levels

### **LOW**
- Minor suspicious activity
- Automatic monitoring
- No user impact

### **MEDIUM**
- Moderately suspicious patterns
- Flagged for review
- User can continue playing

### **HIGH**
- Highly suspicious activity
- Manual review required
- May restrict certain features

### **CRITICAL**
- Confirmed fraud or severe violations
- Immediate action required
- Account may be suspended

## 🔍 Alert Statuses

- **PENDING**: Newly created, awaiting review
- **REVIEWING**: Admin is investigating
- **RESOLVED**: Investigation complete, no fraud found
- **FALSE_POSITIVE**: Alert was incorrect
- **CONFIRMED**: Fraud confirmed, action taken

## 🎯 Integration Points

### 1. Withdrawal Service
```typescript
// Check before creating withdrawal
const fraudCheck = await fraudDetectionService.checkWithdrawal(userId, amount);
if (!fraudCheck.allowed) {
  throw new BadRequestException(fraudCheck.reason);
}
```

### 2. Stake Match Service
```typescript
// Check on match creation
await fraudDetectionService.checkRapidBetting(userId);

// Check on match completion
await fraudDetectionService.checkWinRate(winnerId);
```

## 📱 Database Schema

### FraudAlert Entity
```sql
CREATE TABLE fraud_alerts (
  id UUID PRIMARY KEY,
  userId UUID NOT NULL,
  type VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL DEFAULT 'low',
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  description TEXT NOT NULL,
  metadata JSONB,
  reviewedBy UUID,
  reviewedAt TIMESTAMP,
  reviewNotes TEXT,
  actionTaken BOOLEAN DEFAULT FALSE,
  actionDescription TEXT,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_fraud_alerts_user ON fraud_alerts(userId);
CREATE INDEX idx_fraud_alerts_status ON fraud_alerts(status);
CREATE INDEX idx_fraud_alerts_severity ON fraud_alerts(severity);
CREATE INDEX idx_fraud_alerts_created ON fraud_alerts(createdAt DESC);
```

## 🚀 Future Enhancements

### Planned Features
1. **IP Tracking**
   - Track user IP addresses
   - Detect multiple accounts from same IP
   - VPN/proxy detection

2. **Device Fingerprinting**
   - Unique device identification
   - Detect multiple accounts on same device

3. **Machine Learning**
   - Pattern recognition for fraud detection
   - Predictive modeling for risk scoring
   - Behavioral analysis

4. **Chargeback Monitoring**
   - Track payment chargebacks
   - Flag users with chargeback history

5. **Social Network Analysis**
   - Detect collusion between accounts
   - Identify betting rings

6. **Real-time Risk Scoring**
   - Calculate user risk score in real-time
   - Dynamic transaction limits based on risk

7. **Geolocation Verification**
   - Detect impossible travel patterns
   - Country-based restrictions

## 🔧 Configuration

### Environment Variables
```env
# Fraud Detection Thresholds
RAPID_BETTING_THRESHOLD=10
RAPID_BETTING_WINDOW=300000  # 5 minutes in ms
LARGE_WITHDRAWAL_THRESHOLD=50000
HIGH_WIN_RATE_THRESHOLD=0.85
MAX_DAILY_WITHDRAWALS=5
```

### Customization
Thresholds can be adjusted in `fraud-detection.service.ts`:

```typescript
private readonly RAPID_BETTING_THRESHOLD = 10;
private readonly LARGE_WITHDRAWAL_THRESHOLD = 50000;
private readonly HIGH_WIN_RATE_THRESHOLD = 0.85;
```

## 📊 Monitoring & Alerts

### Key Metrics to Monitor
- Total fraud alerts per day
- Pending alerts count
- Critical alerts requiring immediate attention
- False positive rate
- Time to resolution

### Alert Notifications
- Email admin when critical alerts are created
- Dashboard notifications for high-severity alerts
- Daily summary reports

## 🛠️ Testing Fraud Detection

### Test Rapid Betting
```bash
# Create 10 stake matches quickly
for i in {1..10}; do
  curl -X POST http://localhost:3000/stake-matches \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user-id","stakeAmount":1000,"numberOfQuestions":5}'
  sleep 1
done

# Check for fraud alert
curl http://localhost:3000/fraud-detection/alerts/user/test-user-id
```

### Test Large Withdrawal
```bash
curl -X POST http://localhost:3000/withdrawals \
  -H "Content-Type: application/json" \
  -d '{
    "userId":"test-user-id",
    "amount":60000,
    "withdrawalMethod":"crypto",
    "paymentDetails":{"address":"0x123..."}
  }'

# Should create high-severity fraud alert
```

## 📞 Support

For fraud-related issues or questions:
- Email: fraud@footballarena.com
- Admin Dashboard: `/admin/fraud-alerts`

## ⚖️ Legal Compliance

This fraud detection system helps maintain compliance with:
- Anti-Money Laundering (AML) regulations
- Know Your Customer (KYC) requirements
- Gaming/gambling regulations
- Consumer protection laws

---

**Last Updated**: December 19, 2025
**Version**: 1.0.0

