# Security Configuration Guide

## ✅ Implemented Security Measures

### 1. Rate Limiting
- **Global Rate Limit**: 100 requests per minute per IP
- **Auth Endpoints**:
  - Registration: 5 requests per minute
  - Login: 5 attempts per minute
  - Guest Login: 10 requests per minute
- **Payment Endpoints**:
  - Store Purchase: 10 requests per minute
  - Withdrawal Request: 5 requests per 5 minutes
  - KYC Submission: 3 requests per 5 minutes
- **Stake Match**:
  - Match Creation: 10 requests per minute

### 2. Security Headers (Helmet)
- XSS Protection
- Content Security Policy
- DNS Prefetch Control
- Frame Options (X-Frame-Options)
- HSTS (HTTP Strict Transport Security)
- IE No Open
- No Sniff (X-Content-Type-Options)
- Referrer Policy
- Hide Powered By header

### 3. CORS Configuration
- Development: Accepts all origins
- Production: Should be configured to specific domains only

### 4. Input Validation
- Global ValidationPipe with class-validator
- Whitelist mode: Strips non-whitelisted properties
- Transform mode: Auto-transforms payloads to DTO instances
- Custom DTOs for all endpoints with validation decorators

### 5. Password Security
- Passwords hashed with bcrypt (10 salt rounds)
- Never stored in plain text
- JWT tokens for authentication

### 6. Age Verification
- 18+ requirement enforced during registration
- Date of birth validated on backend

## 🔧 Environment Variables

Create a `.env` file in the backend root directory:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_NAME=football_arena

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# Server
PORT=3000
NODE_ENV=development

# CORS (Production)
CORS_ORIGIN=https://your-app.com,https://admin.your-app.com

# Rate Limiting
THROTTLE_TTL=60000
THROTTLE_LIMIT=100
```

## 🛡️ Additional Recommendations for Production

### 1. Database Security
- Use connection pooling
- Enable SSL/TLS for database connections
- Use read-only users for specific operations
- Regular database backups
- Encrypt sensitive data at rest

### 2. API Security
- Implement API keys for mobile apps
- Add request signing for sensitive operations
- Implement JWT token rotation
- Add token blacklisting for logout
- Use refresh tokens with short expiry

### 3. DDoS Protection
- Use CloudFlare or similar CDN
- Implement IP-based blocking
- Monitor unusual traffic patterns
- Set up alerts for rate limit violations

### 4. Monitoring & Logging
- Log all authentication attempts
- Log all financial transactions
- Monitor failed login attempts
- Set up alerts for suspicious activity
- Use structured logging (Winston/Pino)

### 5. Payment Security
- PCI DSS compliance for card payments
- Never store full card numbers
- Use payment gateway tokenization
- Implement 3D Secure for card payments
- Add transaction verification steps

### 6. Withdrawal Security
- Implement withdrawal cooldown periods
- Require email/SMS verification for withdrawals
- Flag large or unusual withdrawal patterns
- Manual review for high-value withdrawals
- Daily withdrawal limits per user

### 7. Data Protection
- GDPR compliance for EU users
- Implement data export functionality
- Implement data deletion on request
- Encrypt sensitive user data
- Regular security audits

### 8. Infrastructure Security
- Use HTTPS everywhere (TLS 1.3)
- Implement firewall rules
- Regular security patches
- Separate staging and production
- Use secrets management (AWS Secrets Manager, HashiCorp Vault)

## 🚨 Security Checklist for Launch

- [ ] Change all default secrets and passwords
- [ ] Configure CORS to specific domains
- [ ] Enable HTTPS with valid SSL certificate
- [ ] Set up database backups
- [ ] Configure production logging
- [ ] Set up monitoring and alerts
- [ ] Test rate limiting thoroughly
- [ ] Implement IP allowlisting for admin endpoints
- [ ] Add 2FA for admin accounts
- [ ] Set up WAF (Web Application Firewall)
- [ ] Conduct security audit/penetration testing
- [ ] Implement automated security scanning
- [ ] Set up incident response plan
- [ ] Document all security procedures

## 📊 Current Security Score: 7/10

**Strengths:**
- ✅ Rate limiting implemented
- ✅ Security headers configured
- ✅ Input validation
- ✅ Password hashing
- ✅ Age verification
- ✅ CORS configured
- ✅ JWT authentication

**Areas for Improvement:**
- ⚠️ Add email verification
- ⚠️ Implement 2FA for high-value accounts
- ⚠️ Add request signing
- ⚠️ Implement fraud detection
- ⚠️ Add comprehensive logging
- ⚠️ Set up monitoring dashboards
- ⚠️ Implement IP blocking for suspicious activity

## 🔐 Testing Rate Limits

You can test rate limits using curl:

```bash
# Test auth rate limiting (should block after 5 requests)
for i in {1..10}; do
  curl -X POST http://localhost:3000/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"test"}'
  echo "Request $i"
done

# Expected: First 5 succeed/fail normally, next 5 return 429 Too Many Requests
```

## 📞 Security Contact

For security issues, please contact:
- Email: security@footballarena.com
- Create a private security advisory on GitHub

**Do not** publicly disclose security vulnerabilities.

