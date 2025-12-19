import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
            _buildIntro(),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              '''We collect the following types of information:

**Account Information:**
• Username and email address
• Password (encrypted)
• Date of birth (for age verification)
• Country of residence

**Profile Information:**
• Profile picture/avatar
• Game statistics and achievements
• Friend lists and social connections

**Payment Information:**
• Payment method details (processed by secure third-party providers)
• Withdrawal account information
• Transaction history

**Usage Data:**
• Game performance and match results
• Device information (type, OS version, unique identifiers)
• IP address and location data
• App usage patterns and preferences

**Communication Data:**
• Support tickets and customer service interactions
• In-app messages and chat history
• Push notification preferences''',
            ),
            _buildSection(
              '2. How We Use Your Information',
              '''We use your information to:
• Provide and maintain the App services
• Process purchases, stakes, and withdrawals
• Authenticate your identity and prevent fraud
• Personalize your gaming experience
• Match you with appropriate opponents
• Calculate and award winnings
• Send important notifications and updates
• Provide customer support
• Improve our services and develop new features
• Comply with legal obligations
• Enforce our Terms of Service''',
            ),
            _buildSection(
              '3. Information Sharing',
              '''We do not sell your personal information. We may share your data with:

**Service Providers:**
• Payment processors (Stripe, PayPal, crypto gateways)
• Cloud hosting services (AWS, Google Cloud)
• Analytics providers
• Customer support tools

**Legal Requirements:**
• Law enforcement or regulatory authorities when required
• To comply with legal processes
• To protect our rights and prevent fraud

**Business Transfers:**
• In the event of a merger, acquisition, or sale of assets

**With Your Consent:**
• When you explicitly authorize us to share your information''',
            ),
            _buildSection(
              '4. Data Security',
              '''We implement industry-standard security measures:
• Encryption of sensitive data in transit and at rest
• Secure authentication and password hashing
• Regular security audits and penetration testing
• Restricted access to personal information
• Secure payment processing through PCI-compliant providers
• Monitoring for suspicious activity and fraud prevention

However, no system is 100% secure. You are responsible for maintaining the confidentiality of your account credentials.''',
            ),
            _buildSection(
              '5. Data Retention',
              '''We retain your information for as long as:
• Your account remains active
• Required to provide our services
• Necessary for legal, tax, or regulatory purposes
• Required to resolve disputes or enforce agreements

When you close your account, we will delete or anonymize your personal data within 90 days, except where retention is required by law.''',
            ),
            _buildSection('6. Your Rights', '''You have the right to:
• Access your personal data
• Correct inaccurate information
• Request deletion of your data (subject to legal obligations)
• Object to processing of your data
• Request data portability
• Withdraw consent where applicable
• Opt-out of marketing communications
• Lodge a complaint with supervisory authorities

To exercise these rights, contact us at privacy@footballarena.com'''),
            _buildSection(
              "7. Children's Privacy",
              '''Football Arena is intended for users 18 years and older. We do not knowingly collect information from anyone under 18. If we discover that a minor has provided us with personal information, we will delete it immediately.

Parents or guardians who believe their child has provided us with information should contact us immediately.''',
            ),
            _buildSection(
              '8. International Data Transfers',
              '''Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy and applicable laws.

By using the App, you consent to the transfer of your information to countries that may have different data protection laws.''',
            ),
            _buildSection(
              '9. Cookies and Tracking',
              '''We use cookies and similar tracking technologies to:
• Maintain your login session
• Remember your preferences
• Analyze usage patterns
• Improve app performance

You can control cookies through your device settings, but disabling them may affect app functionality.''',
            ),
            _buildSection(
              '10. Third-Party Services',
              '''Our App integrates with third-party services:
• Google Sign-In / Apple Sign-In
• Facebook Authentication
• Payment processors
• Analytics providers
• Advertising networks

These services have their own privacy policies, and we are not responsible for their practices.''',
            ),
            _buildSection(
              '11. Changes to Privacy Policy',
              '''We may update this Privacy Policy from time to time. Changes will be posted in the App with an updated "Last Modified" date. Material changes will be notified through:
• In-app notifications
• Email notifications
• Prominent notice on our website

Continued use after changes constitutes acceptance of the updated policy.''',
            ),
            _buildSection(
              '12. California Privacy Rights (CCPA)',
              '''California residents have additional rights under the California Consumer Privacy Act:
• Right to know what personal information is collected
• Right to know if personal information is sold or disclosed
• Right to opt-out of the sale of personal information
• Right to deletion of personal information
• Right to non-discrimination for exercising privacy rights

We do not sell personal information.''',
            ),
            _buildSection(
              '13. European Privacy Rights (GDPR)',
              '''If you are in the European Economic Area, you have rights under the General Data Protection Regulation:
• Right to access your data
• Right to rectification
• Right to erasure ("right to be forgotten")
• Right to restrict processing
• Right to data portability
• Right to object to processing
• Rights related to automated decision-making

We process your data based on consent, contractual necessity, legal obligations, and legitimate interests.''',
            ),
            _buildSection(
              '14. Contact Us',
              '''For privacy-related questions or concerns:

Email: privacy@footballarena.com
Support: support@footballarena.com
Address: [Your Business Address]

Data Protection Officer: dpo@footballarena.com

We will respond to your inquiry within 30 days.''',
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
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.green.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.privacy_tip_outlined, color: Colors.green.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Last Updated: December 18, 2025',
              style: TextStyle(
                color: Colors.green.shade100,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        'Football Arena ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 14,
          height: 1.6,
        ),
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
