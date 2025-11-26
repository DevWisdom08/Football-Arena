import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/withdrawal_service.dart';
import '../core/providers/user_provider.dart';
import '../shared/app_theme.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final WithdrawalService _withdrawalService = WithdrawalService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  
  String? _idPhotoUrl;
  String? _selfieUrl;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('🔐 KYC Verification'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Why KYC is Required',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'To comply with financial regulations and prevent fraud, we must verify your identity before processing withdrawals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step 1: Personal Information
              _buildStepHeader(1, 'Personal Information'),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Legal Name',
                  hintText: 'As shown on your ID',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  );
                  if (date != null) {
                    _dobController.text = date.toString().split(' ')[0];
                  }
                },
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _idNumberController,
                decoration: const InputDecoration(
                  labelText: 'ID / Passport Number',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ID number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Step 2: Upload ID Photo
              _buildStepHeader(2, 'Upload ID Document'),
              const SizedBox(height: 12),
              
              Card(
                child: InkWell(
                  onTap: () => _pickImage(isIdPhoto: true),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          _idPhotoUrl != null ? Icons.check_circle : Icons.photo_camera,
                          size: 64,
                          color: _idPhotoUrl != null ? AppTheme.successColor : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _idPhotoUrl != null 
                              ? 'ID Photo Uploaded ✓' 
                              : 'Tap to Upload ID Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _idPhotoUrl != null ? AppTheme.successColor : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Upload a clear photo of your ID or Passport',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step 3: Upload Selfie
              _buildStepHeader(3, 'Upload Selfie'),
              const SizedBox(height: 12),
              
              Card(
                child: InkWell(
                  onTap: () => _pickImage(isIdPhoto: false),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          _selfieUrl != null ? Icons.check_circle : Icons.photo_camera,
                          size: 64,
                          color: _selfieUrl != null ? AppTheme.successColor : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selfieUrl != null 
                              ? 'Selfie Uploaded ✓' 
                              : 'Tap to Upload Selfie',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selfieUrl != null ? AppTheme.successColor : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Take a selfie holding your ID next to your face',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is encrypted and secure. We only use it for age verification and fraud prevention.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _canSubmit() && !_isSubmitting ? _submitKyc : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit for Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verification typically takes 24-48 hours',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(int step, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage({required bool isIdPhoto}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // In a real app, you would upload this to your server/cloud storage
        // For now, we'll use the local path as a placeholder
        // TODO: Implement actual file upload to your backend
        
        setState(() {
          if (isIdPhoto) {
            _idPhotoUrl = image.path; // Replace with uploaded URL
          } else {
            _selfieUrl = image.path; // Replace with uploaded URL
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIdPhoto ? 'ID photo selected' : 'Selfie selected',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  bool _canSubmit() {
    return _fullNameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _idNumberController.text.isNotEmpty &&
        _idPhotoUrl != null &&
        _selfieUrl != null;
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';

      await _withdrawalService.submitKyc(
        userId: userId,
        fullName: _fullNameController.text,
        dateOfBirth: _dobController.text,
        idNumber: _idNumberController.text,
        idPhotoUrl: _idPhotoUrl!,
        selfieUrl: _selfieUrl!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ KYC submitted successfully! We will review within 24-48 hours.'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting KYC: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

