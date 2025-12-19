# Admin Dashboard Guide

## 🎯 Overview

The Football Arena Admin Dashboard is a comprehensive web-based management interface for monitoring and managing the platform. It provides real-time insights into users, transactions, fraud alerts, and more.

## 🔗 Access

**URL**: `http://localhost:3000/admin-dashboard.html`

For production: `https://your-domain.com/admin-dashboard.html`

## 📊 Dashboard Sections

### 1. **Overview Tab** (Home)

**Key Metrics:**
- **Total Users**: Number of registered accounts
- **Total Revenue**: All-time earnings from fees
- **Pending Withdrawals**: Number of withdrawal requests awaiting approval
- **Fraud Alerts**: Number of pending fraud alerts

**Features:**
- Real-time statistics
- Quick access to all metrics
- API status indicator (Online/Offline)
- Refresh button for manual updates

---

### 2. **Withdrawals Tab** 💰

**Purpose**: Manage user withdrawal requests

**Features:**
- View all withdrawal requests
- Filter by status (Pending, Approved, Completed, Rejected)
- View detailed withdrawal information
- Approve or reject withdrawals
- See payment method and details

**Withdrawal Details:**
- Withdrawal ID
- User ID
- Amount (coins and USD)
- Fee charged
- Net amount to user
- Payment method (crypto, PayPal, bank, mobile money)
- Payment details (wallet address, email, etc.)
- Status and creation date

**Actions:**
- ✅ **Approve**: Approve withdrawal for processing
- ❌ **Reject**: Reject withdrawal and refund user

**Workflow:**
1. User requests withdrawal from app
2. Request appears in "Pending" status
3. Admin reviews request details
4. Admin approves or rejects
5. If approved, process payment manually (or auto with integration)
6. Mark as "Completed" after payment sent

---

### 3. **Fraud Alerts Tab** 🚨

**Purpose**: Monitor and review suspicious activities

**Alert Types:**
- **RAPID_BETTING**: User playing too many games too quickly
- **SUSPICIOUS_WITHDRAWAL**: Attempting to withdraw large % of balance
- **LARGE_TRANSACTION**: High-value withdrawal
- **WIN_RATE_ANOMALY**: Abnormally high win rate
- **UNUSUAL_ACTIVITY**: Multiple withdrawal attempts

**Severity Levels:**
- 🔴 **Critical**: Immediate action required
- 🟠 **High**: Review within 24 hours
- 🟡 **Medium**: Review when possible
- 🔵 **Low**: Monitoring only

**Features:**
- Filter by status and severity
- View alert details and metadata
- Review and update alert status
- Add review notes

**Actions:**
- ✅ **Resolve**: No fraud detected, dismiss alert
- ⚠️ **Confirm Fraud**: Fraud confirmed, take action
- ❌ **False Positive**: Incorrectly flagged

**Review Process:**
1. Alert is automatically created by system
2. Admin reviews user history and activity
3. Admin investigates the specific incident
4. Admin makes decision: Resolve, Confirm, or False Positive
5. Admin adds notes explaining decision
6. System updates alert status

---

### 4. **Users Tab** 👥

**Purpose**: View and manage user accounts

**User Information:**
- Username and email
- Total coins (all types)
- Games played
- Win rate percentage
- Account creation date

**Features:**
- View all registered users
- Search and filter (coming soon)
- View user details
- User action history (coming soon)

**Planned Actions:**
- Suspend/Ban user
- Add/Remove coins
- View user's transaction history
- View user's match history

---

### 5. **Matches Tab** 🎮

**Purpose**: Monitor stake match activity

**Match Information:**
- Match ID
- Creator and opponent user IDs
- Stake amount
- Match status
- Winner (if completed)
- Creation date

**Match Statuses:**
- **Waiting**: Created, waiting for opponent
- **Active**: Both players joined, game in progress
- **Completed**: Match finished
- **Cancelled**: Creator cancelled before opponent joined

**Features:**
- View all stake matches
- Monitor active games
- Review completed matches
- Track platform activity

---

## 🔒 Security Features

### Built-in Protection
- Rate limiting on all API endpoints
- CORS protection
- Input validation
- No sensitive data exposed in frontend

### Recommended Additions
1. **Admin Authentication**
   - Add login system for admins
   - JWT token authentication
   - Role-based access control

2. **IP Whitelisting**
   - Restrict dashboard access to specific IPs
   - VPN requirement for remote access

3. **Audit Logging**
   - Log all admin actions
   - Track who approved/rejected withdrawals
   - Monitor admin activity

4. **Two-Factor Authentication**
   - Require 2FA for sensitive actions
   - SMS or authenticator app verification

---

## 📱 API Endpoints Used

### Overview
- `GET /users` - Get all users
- `GET /fraud-detection/stats` - Get fraud statistics
- `GET /withdrawals` - Get all withdrawals
- `GET /withdrawals/pending` - Get pending withdrawals

### Withdrawals
- `GET /withdrawals` - List all withdrawals
- `GET /withdrawals?status=pending` - Filter by status
- `GET /withdrawals/:id` - Get withdrawal details
- `POST /withdrawals/:id/process` - Approve/reject withdrawal

### Fraud Detection
- `GET /fraud-detection/alerts` - List all fraud alerts
- `GET /fraud-detection/alerts?status=pending` - Filter by status
- `GET /fraud-detection/alerts?severity=high` - Filter by severity
- `POST /fraud-detection/alerts/:id/review` - Review fraud alert

### Users
- `GET /users` - List all users
- `GET /users/:id` - Get user details

### Matches
- `GET /stake-matches/available` - List all matches
- `GET /stake-matches/:id` - Get match details

---

## 🛠️ Configuration

### API Base URL

Edit the `API_BASE_URL` constant in the HTML file:

```javascript
const API_BASE_URL = 'http://localhost:3000'; // Development
// const API_BASE_URL = 'https://api.footballarena.com'; // Production
```

### Admin ID

Currently hardcoded as `'admin-user-id'`. Replace with actual admin authentication:

```javascript
// TODO: Get from login session
const adminId = localStorage.getItem('adminId') || 'admin-user-id';
```

---

## 🚀 Deployment

### Option 1: Same Server as API
1. Place `admin-dashboard.html` in `/public` folder
2. NestJS serves it automatically
3. Access at: `https://yourdomain.com/admin-dashboard.html`

### Option 2: Separate Hosting (Recommended)
1. Host on separate subdomain: `admin.footballarena.com`
2. Update API_BASE_URL to main API domain
3. Configure CORS to allow admin subdomain
4. Add IP whitelist in production

### Environment Variables

```env
# Admin Dashboard
ADMIN_DASHBOARD_ENABLED=true
ADMIN_IP_WHITELIST=192.168.1.1,10.0.0.1
ADMIN_AUTH_REQUIRED=true

# CORS for admin dashboard
CORS_ORIGIN=https://admin.footballarena.com,https://api.footballarena.com
```

---

## 📊 Usage Examples

### Approve a Withdrawal

1. Go to **Withdrawals** tab
2. Click **View** on pending withdrawal
3. Review details carefully:
   - Check user's account history
   - Verify payment details
   - Check for fraud alerts
4. Click **✅ Approve** if legitimate
5. Process payment via:
   - Crypto: Send to wallet address
   - PayPal: Send to email
   - Bank: Process transfer
6. Mark as **Completed** after payment sent

### Handle Fraud Alert

1. Go to **Fraud Alerts** tab
2. Filter by **Critical** or **High** severity
3. Click **Review** on alert
4. Check alert details and metadata
5. Investigate user's activity:
   - View their matches
   - Check win rate
   - Review withdrawal history
6. Make decision:
   - **Resolve**: Normal behavior
   - **Confirm Fraud**: Take action (suspend, ban)
   - **False Positive**: System error

### Monitor Platform Health

1. Go to **Overview** tab
2. Check key metrics:
   - User growth
   - Revenue trends
   - Pending actions
   - Fraud alerts
3. Set up daily routine:
   - Morning: Check pending withdrawals
   - Afternoon: Review fraud alerts
   - Evening: Monitor match activity

---

## 🔔 Best Practices

### Daily Tasks
- [ ] Review all pending withdrawals
- [ ] Check critical fraud alerts
- [ ] Monitor revenue metrics
- [ ] Review new user signups

### Weekly Tasks
- [ ] Analyze fraud patterns
- [ ] Review user growth trends
- [ ] Check for platform issues
- [ ] Export transaction reports

### Monthly Tasks
- [ ] Audit all admin actions
- [ ] Review and update fraud thresholds
- [ ] Analyze revenue and costs
- [ ] Plan platform improvements

---

## 🆘 Troubleshooting

### API Status Shows "Offline"
1. Check if backend server is running
2. Verify API_BASE_URL is correct
3. Check CORS configuration
4. Check network connectivity

### Withdrawals Not Loading
1. Check browser console for errors
2. Verify API endpoint is accessible
3. Check network tab in DevTools
4. Ensure backend has withdrawal data

### Can't Approve Withdrawal
1. Check admin permissions
2. Verify withdrawal is in "pending" status
3. Check backend logs for errors
4. Ensure API endpoint is working

---

## 📝 Future Enhancements

### Planned Features
- [ ] Real-time notifications
- [ ] Bulk actions (approve multiple withdrawals)
- [ ] Advanced filtering and search
- [ ] Data export (CSV, PDF)
- [ ] Charts and graphs
- [ ] User activity timeline
- [ ] Automated fraud scoring
- [ ] Email notifications for critical alerts
- [ ] Mobile-responsive design improvements
- [ ] Dark/light theme toggle

### Integration Opportunities
- [ ] Stripe/PayPal direct integration
- [ ] Crypto payment gateway automation
- [ ] Email service (SendGrid, Mailgun)
- [ ] SMS alerts (Twilio)
- [ ] Analytics (Google Analytics, Mixpanel)
- [ ] Customer support chat
- [ ] Knowledge base integration

---

## 🔐 Security Checklist

Before going live:
- [ ] Add admin authentication
- [ ] Implement role-based access control
- [ ] Set up IP whitelisting
- [ ] Enable HTTPS only
- [ ] Add audit logging
- [ ] Implement 2FA for sensitive actions
- [ ] Set up rate limiting for admin endpoints
- [ ] Regular security audits
- [ ] Backup procedures in place
- [ ] Incident response plan documented

---

## 📞 Support

For dashboard issues:
- **Email**: admin@footballarena.com
- **Documentation**: See backend README
- **API Docs**: See API documentation

---

**Version**: 1.0.0  
**Last Updated**: December 19, 2025  
**Compatible with**: Football Arena Backend v1.0.0

