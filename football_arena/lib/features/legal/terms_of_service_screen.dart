import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using Football Arena ("the App"), you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
            ),
            _buildSection(
              '2. Eligibility',
              'You must be at least 18 years old to use this App. By using the App, you represent and warrant that you are of legal age to form a binding contract.',
            ),
            _buildSection(
              '3. User Accounts',
              '''• You are responsible for maintaining the confidentiality of your account credentials
• You agree to provide accurate, current information during registration
• You may not use another user's account without permission
• You must notify us immediately of any unauthorized access to your account
• We reserve the right to suspend or terminate accounts that violate these terms''',
            ),
            _buildSection(
              '4. Virtual Currency and Real Money',
              '''• Football Arena uses a virtual currency system (Coins)
• Coins can be purchased with real money through in-app purchases
• Earned coins through gameplay can be withdrawn as real money, subject to withdrawal policies
• All purchases are final and non-refundable unless required by law
• Coin balances have no cash value and cannot be transferred or sold
• We reserve the right to modify coin values, pricing, and withdrawal policies with notice''',
            ),
            _buildSection(
              '5. Stake Matches',
              '''• Stake matches involve wagering virtual coins
• Both players must agree to the stake amount before starting
• Match results are final and binding
• Commission fees apply to winnings as disclosed before match creation
• We reserve the right to investigate and void suspicious matches
• Match abandonment or cheating may result in stake forfeiture''',
            ),
            _buildSection(
              '6. Withdrawals',
              '''• Withdrawal requests are processed within 3-7 business days
• Minimum withdrawal amount: 1000 coins
• Withdrawal fees vary by payment method and are disclosed before confirmation
• You must provide valid payment information
• We reserve the right to verify your identity before processing withdrawals
• Suspicious or fraudulent activity may result in withdrawal suspension''',
            ),
            _buildSection('7. Prohibited Activities', '''You agree not to:
• Use cheats, exploits, bots, or automation tools
• Create multiple accounts for fraudulent purposes
• Manipulate game results or engage in match-fixing
• Harass, threaten, or abuse other users
• Share or sell your account
• Violate any applicable laws or regulations
• Reverse engineer or attempt to extract source code
• Use the App for money laundering or illegal activities'''),
            _buildSection(
              '8. Intellectual Property',
              '''• All content, including graphics, text, logos, and software, is owned by Football Arena
• You are granted a limited, non-exclusive, non-transferable license to use the App
• You may not copy, modify, distribute, or create derivative works
• User-generated content remains your property, but you grant us a license to use it''',
            ),
            _buildSection(
              '9. Disclaimers',
              '''• THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND
• We do not guarantee uninterrupted or error-free service
• We are not responsible for losses due to technical issues, server downtime, or third-party failures
• Game outcomes are based on player skill and knowledge
• We do not guarantee any specific earnings or winnings''',
            ),
            _buildSection(
              '10. Limitation of Liability',
              '''• To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages
• Our total liability shall not exceed the amount you paid to us in the past 12 months
• Some jurisdictions do not allow limitation of liability, so these limits may not apply to you''',
            ),
            _buildSection(
              '11. Account Termination',
              '''• You may close your account at any time
• We may suspend or terminate your account for violations of these terms
• Upon termination, you may request withdrawal of your remaining balance
• Terminated accounts cannot be reactivated''',
            ),
            _buildSection(
              '12. Changes to Terms',
              '''• We reserve the right to modify these terms at any time
• Changes will be effective immediately upon posting
• Continued use of the App constitutes acceptance of modified terms
• Material changes will be notified through the App or email''',
            ),
            _buildSection(
              '13. Dispute Resolution',
              '''• Any disputes shall be resolved through binding arbitration
• You waive your right to participate in class action lawsuits
• Arbitration shall be conducted in accordance with applicable arbitration rules
• Small claims court remains available for qualifying disputes''',
            ),
            _buildSection(
              '14. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law provisions.',
            ),
            _buildSection(
              '15. Contact Information',
              '''For questions about these Terms, please contact us at:
Email: support@footballarena.com
Address: [Your Business Address]''',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2024 Football Arena. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Last Updated: December 18, 2025',
              style: TextStyle(
                color: Colors.blue.shade100,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
