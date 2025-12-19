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
  final int _minWithdrawal = 10000; // $10 minimum
  
  // Withdrawal fees by payment method
  final Map<String, double> _withdrawalFees = {
    'crypto': 1.0,          // $1 flat fee for crypto (covers gas costs)
    'paypal': 1.5,          // $1.50 for PayPal
    'bank_transfer': 2.0,   // $2 for bank transfer
    'mobile_money': 1.0,    // $1 for mobile money
  };
  
  // Get current withdrawal fee based on selected method
  double get _withdrawalFee => _withdrawalFees[_selectedMethod] ?? 1.0;

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
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
         title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primaryDark.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Text(
            '💰 Withdraw Winnings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
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
          // Balance Card
          _buildBalanceCard(user),

          const SizedBox(height: 24),

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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _submitWithdrawal(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Request Withdrawal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Important Notes
          _buildImportantNotes(),
        ],
      ),
    );
  }


  Widget _buildBalanceCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primaryDark.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
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
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
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
      {'id': 'paypal', 'name': 'PayPal', 'icon': Icons.payment},
      {'id': 'bank_transfer', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
      {'id': 'mobile_money', 'name': 'Mobile Money', 'icon': Icons.phone_android},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((method) {
        final isSelected = _selectedMethod == method['id'];
        return Container(
          decoration: isSelected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
          child: ChoiceChip(
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
            selectedColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput(UserModel user) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.5), width: 1.5),
          ),
          child: TextField(
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
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        if (_amountController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.1),
                  Colors.blue.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
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
                   'Withdrawal Fee:',
                   '\$${_withdrawalFee.toStringAsFixed(2)}',
                   isNegative: true,
                 ),
                 const Divider(color: Colors.white24),
                 _buildCalculationRow(
                   'You receive:',
                   '\$${(((int.tryParse(_amountController.text) ?? 0) / _conversionRate) - _withdrawalFee).toStringAsFixed(2)}',
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.indigo.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1.5),
      ),
      child: TextField(
        controller: _paypalEmailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'PayPal Email',
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.email, color: Colors.white70),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.withOpacity(0.5), width: 1.5),
          ),
          child: TextField(
            controller: _accountHolderController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.withOpacity(0.5), width: 1.5),
          ),
          child: TextField(
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
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.withOpacity(0.5), width: 1.5),
          ),
          child: TextField(
            controller: _routingNumberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Routing Number / SWIFT',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.code, color: Colors.white70),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMoneyForm() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.5), width: 1.5),
      ),
      child: TextField(
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
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.1),
                Colors.deepPurple.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.5), width: 1.5),
          ),
          child: TextField(
            controller: _walletAddressController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Polygon Wallet Address (USDT/USDC)',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: '0x...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.currency_bitcoin, color: Colors.white70),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.15),
                Colors.teal.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
             child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.greenAccent, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ Instant withdrawal (30 seconds)\n'
                    '✅ Low fee (\$1.00 flat fee)\n'
                    '✅ Use Polygon network (MATIC)\n'
                    '✅ USDT or USDC supported',
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
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.15),
            Colors.indigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
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
             '• Withdrawal fees:\n'
             '  - Crypto: \$1.00 (instant! 30 sec) ⚡\n'
             '  - PayPal: \$1.50 (1-2 hours)\n'
             '  - Bank Transfer: \$2.00 (1-3 days)\n'
             '  - Mobile Money: \$1.00 (instant!)\n'
             '• Only withdrawable coins can be withdrawn\n'
             '• Purchased coins are NOT withdrawable\n'
             '• You must be 18+ to withdraw',
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
    final statusColor = _getWithdrawalStatusColor(withdrawal.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
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
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1F3A).withOpacity(0.98),
                const Color(0xFF0F1525).withOpacity(0.98),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primaryDark.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'CONFIRM WITHDRAWAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Withdrawal details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.withOpacity(0.15),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildConfirmRow('Amount:', '$amount coins'),
                    const Divider(color: Colors.white24),
                    _buildConfirmRow('USD Value:', '\$${(amount / _conversionRate).toStringAsFixed(2)}'),
                    const Divider(color: Colors.white24),
                    _buildConfirmRow('Method:', 'Crypto (USDT)'),
                    const Divider(color: Colors.white24),
                    _buildConfirmRow('Network:', 'Polygon'),
                    const Divider(color: Colors.white24),
                    _buildConfirmRow('Fee:', '\$${_withdrawalFee.toStringAsFixed(2)}', isNegative: true),
                    const Divider(color: Colors.white24),
                    _buildConfirmRow(
                      'You Receive:',
                      '\$${((amount / _conversionRate) - _withdrawalFee).toStringAsFixed(2)}',
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Processing time badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.2),
                      Colors.teal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _getProcessingTimeText(),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement API call to create withdrawal
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Withdrawal request submitted successfully!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'CONFIRM WITHDRAWAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  String _getProcessingTimeText() {
    switch (_selectedMethod) {
      case 'crypto':
        return 'Processing time: 30 seconds (instant!)';
      case 'mobile_money':
        return 'Processing time: Instant';
      case 'paypal':
        return 'Processing time: 1-2 hours';
      case 'bank_transfer':
        return 'Processing time: 1-3 business days';
      default:
        return 'Processing time varies by method';
    }
  }

  Widget _buildConfirmRow(
    String label,
    String value, {
    bool isNegative = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.greenAccent : Colors.white70,
              fontSize: 13,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
