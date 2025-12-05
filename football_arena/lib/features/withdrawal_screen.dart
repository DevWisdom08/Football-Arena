import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/models/user_model.dart';
import '../shared/models/withdrawal_model.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'crypto'; // Default to crypto

  // Payment details controllers
  final TextEditingController _paypalEmailController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _routingNumberController =
      TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _walletAddressController =
      TextEditingController();

  final double _conversionRate = 1000; // 1000 coins = $1
  final double _withdrawalFeeFlat = 1.0; // $1 flat fee for crypto
  final int _minWithdrawal = 10000; // $10 minimum

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _paypalEmailController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _accountHolderController.dispose();
    _phoneNumberController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from storage
    final userData = StorageService.instance.getUserData();
    // Helper to safely parse commissionRate
    double parseCommissionRate(dynamic value) {
      if (value == null) return 10.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 10.0;
      return 10.0;
    }

    final user = userData != null
        ? UserModel(
            id: userData['id'] ?? '',
            username: userData['username'] ?? 'Guest',
            email: userData['email'] ?? '',
            country: userData['country'] ?? 'Unknown',
            level: userData['level'] ?? 1,
            xp: userData['xp'] ?? 0,
            coins: userData['coins'] ?? 0,
            withdrawableCoins: userData['withdrawableCoins'] ?? 0,
            purchasedCoins: userData['purchasedCoins'] ?? 0,
            commissionRate: parseCommissionRate(userData['commissionRate']),
            kycVerified: userData['kycVerified'] ?? false,
            kycStatus: userData['kycStatus'],
            createdAt: DateTime.now(),
            lastPlayedAt: DateTime.now(),
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          '💰 Withdraw to Crypto Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'New Withdrawal'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWithdrawalForm(user),
                _buildWithdrawalHistory(user),
              ],
            ),
    );
  }

  Widget _buildWithdrawalForm(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KYC Status Banner
          if (!user.kycVerified) _buildKycBanner() else _buildBalanceCard(user),

          const SizedBox(height: 24),

          if (user.kycVerified) ...[
            // Withdrawal Method Selection
            _buildSectionTitle('Select Withdrawal Method'),
            const SizedBox(height: 12),
            _buildMethodSelector(),

            const SizedBox(height: 24),

            // Amount Input
            _buildSectionTitle('Withdrawal Amount'),
            const SizedBox(height: 12),
            _buildAmountInput(user),

            const SizedBox(height: 24),

            // Payment Details
            _buildSectionTitle('Payment Details'),
            const SizedBox(height: 12),
            _buildPaymentDetails(),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _submitWithdrawal(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Request Withdrawal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Important Notes
            _buildImportantNotes(),
          ],
        ],
      ),
    );
  }

  Widget _buildKycBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'KYC Verification Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You must verify your identity before withdrawing winnings.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showKycDialog(),
              icon: const Icon(Icons.verified_user),
              label: const Text('Verify Identity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Available for Withdrawal',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '${user.withdrawableCoins} coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '≈ \$${(user.withdrawableCoins / _conversionRate).toStringAsFixed(2)} USD',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Coins', user.totalCoins.toString()),
                Container(width: 1, height: 40, color: Colors.white38),
                _buildStatColumn(
                  'Purchased',
                  user.purchasedCoins.toString(),
                  subtitle: 'Non-withdrawable',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {String? subtitle}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMethodSelector() {
    final methods = [
      {'id': 'crypto', 'name': 'Crypto (USDT/USDC)', 'icon': Icons.currency_bitcoin},
      // Other methods disabled - Crypto only!
      // {'id': 'paypal', 'name': 'PayPal', 'icon': Icons.payment},
      // {'id': 'bank_transfer', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
      // {'id': 'mobile_money', 'name': 'Mobile Money', 'icon': Icons.phone_android},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((method) {
        final isSelected = _selectedMethod == method['id'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                method['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(method['name'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedMethod = method['id'] as String;
            });
          },
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.cardBackground,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput(UserModel user) {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Amount in coins',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText:
                'Minimum $_minWithdrawal coins (\$${(_minWithdrawal / _conversionRate).toStringAsFixed(0)})',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(
              Icons.monetization_on,
              color: Colors.yellowAccent,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
        if (_amountController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildCalculationRow(
                  'Amount:',
                  _amountController.text + ' coins',
                ),
                _buildCalculationRow(
                  'USD Value:',
                  '\$${((int.tryParse(_amountController.text) ?? 0) / _conversionRate).toStringAsFixed(2)}',
                ),
                _buildCalculationRow(
                  'Withdrawal Fee (flat):',
                  '\$${_withdrawalFeeFlat.toStringAsFixed(2)}',
                  isNegative: true,
                ),
                const Divider(color: Colors.white24),
                _buildCalculationRow(
                  'You receive (USDT):',
                  '\$${(((int.tryParse(_amountController.text) ?? 0) / _conversionRate) - _withdrawalFeeFlat).toStringAsFixed(2)}',
                  highlight: true,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool isNegative = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.greenAccent : Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isNegative
                  ? Colors.redAccent
                  : highlight
                  ? Colors.greenAccent
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    switch (_selectedMethod) {
      case 'paypal':
        return _buildPayPalForm();
      case 'bank_transfer':
        return _buildBankTransferForm();
      case 'mobile_money':
        return _buildMobileMoneyForm();
      case 'crypto':
        return _buildCryptoForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPayPalForm() {
    return TextField(
      controller: _paypalEmailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'PayPal Email',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.email, color: Colors.white70),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      children: [
        TextField(
          controller: _accountHolderController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.person, color: Colors.white70),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Account Number',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(
              Icons.account_balance,
              color: Colors.white70,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _routingNumberController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Routing Number / SWIFT',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.code, color: Colors.white70),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMoneyForm() {
    return TextField(
      controller: _phoneNumberController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Mobile Money Phone Number',
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: '+1234567890',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.phone, color: Colors.white70),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCryptoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _walletAddressController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Polygon Wallet Address (USDT/USDC)',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: '0x...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.currency_bitcoin, color: Colors.white70),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade700),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.greenAccent, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ Instant withdrawal (30 seconds)\n'
                  '✅ Low fee (\$1 flat fee)\n'
                  '✅ Make sure you use Polygon network!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '⚠️ Important Notes:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Minimum withdrawal: \$10 (10,000 coins)\n'
            '• Withdrawal fee: \$1 flat fee (not percentage!)\n'
            '• Processing time: 30 seconds (instant!) ⚡\n'
            '• Network: Polygon (low gas fees)\n'
            '• Only withdrawable coins can be withdrawn\n'
            '• Purchased coins are NOT withdrawable\n'
            '• KYC verification required (18+ only)',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalHistory(UserModel user) {
    // Mock data - replace with actual API call
    final List<WithdrawalModel> history = [];

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No withdrawal history',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final withdrawal = history[index];
        return _buildWithdrawalCard(withdrawal);
      },
    );
  }

  Widget _buildWithdrawalCard(WithdrawalModel withdrawal) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${withdrawal.netAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getWithdrawalStatusColor(withdrawal.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    withdrawal.statusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Method: ${withdrawal.withdrawalMethod}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Date: ${withdrawal.createdAt.toString().substring(0, 10)}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWithdrawalStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showKycDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'KYC Verification',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'To withdraw your winnings, you need to verify your identity.\n\n'
          'Required documents:\n'
          '• Government-issued ID\n'
          '• Selfie with ID\n'
          '• Proof of address\n\n'
          'You must be 18+ to withdraw.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to KYC verification screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Start Verification'),
          ),
        ],
      ),
    );
  }

  void _submitWithdrawal(UserModel user) {
    final amount = int.tryParse(_amountController.text) ?? 0;

    // Validation
    if (amount < _minWithdrawal) {
      _showError(
        'Minimum withdrawal is $_minWithdrawal coins (\$${(_minWithdrawal / _conversionRate).toStringAsFixed(0)})',
      );
      return;
    }

    if (amount > user.withdrawableCoins) {
      _showError('Insufficient withdrawable coins');
      return;
    }

    if (!_validatePaymentDetails()) {
      _showError('Please provide valid payment details');
      return;
    }

    // Confirm withdrawal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Confirm Withdrawal',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Withdraw $amount coins (\$${(amount / _conversionRate).toStringAsFixed(2)})?\n\n'
          'Withdrawal Method: Crypto (USDT on Polygon)\n'
          'Fee: \$${_withdrawalFeeFlat.toStringAsFixed(2)} flat fee\n'
          'You will receive: \$${((amount / _conversionRate) - _withdrawalFeeFlat).toStringAsFixed(2)} USDT\n\n'
          '⚡ Processing time: 30 seconds (instant!)',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement API call to create withdrawal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdrawal request submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  bool _validatePaymentDetails() {
    switch (_selectedMethod) {
      case 'paypal':
        return _paypalEmailController.text.isNotEmpty &&
            _paypalEmailController.text.contains('@');
      case 'bank_transfer':
        return _accountHolderController.text.isNotEmpty &&
            _accountNumberController.text.isNotEmpty &&
            _routingNumberController.text.isNotEmpty;
      case 'mobile_money':
        return _phoneNumberController.text.isNotEmpty;
      case 'crypto':
        return _walletAddressController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
