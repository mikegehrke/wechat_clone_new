import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'card';
  
  // Card fields
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // PayPal fields
  final _paypalEmailController = TextEditingController();
  
  // Bank fields
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  
  bool _isDefault = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _paypalEmailController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Payment type selector
            const Text(
              'Select Payment Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTypeChip('card', 'Credit/Debit Card', Icons.credit_card),
                _buildTypeChip('paypal', 'PayPal', Icons.account_balance_wallet),
                _buildTypeChip('bank_transfer', 'Bank Account', Icons.account_balance),
                _buildTypeChip('apple_pay', 'Apple Pay', Icons.apple),
                _buildTypeChip('google_pay', 'Google Pay', Icons.g_mobiledata),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Form fields based on selected type
            if (_selectedType == 'card') _buildCardForm(),
            if (_selectedType == 'paypal') _buildPayPalForm(),
            if (_selectedType == 'bank_transfer') _buildBankForm(),
            if (_selectedType == 'apple_pay' || _selectedType == 'google_pay') 
              _buildDigitalWalletForm(),
            
            const SizedBox(height: 24),
            
            // Set as default
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: const Text('Set as default payment method'),
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF07C160),
            ),
            
            const SizedBox(height: 24),
            
            // Add button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _addPaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07C160),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = type);
        }
      },
      selectedColor: const Color(0xFF07C160).withOpacity(0.2),
      checkmarkColor: const Color(0xFF07C160),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Card number
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberInputFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            final digits = value.replaceAll(' ', '');
            if (digits.length < 13 || digits.length > 16) {
              return 'Invalid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Card holder name
        TextFormField(
          controller: _cardHolderController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Expiry and CVV
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!value.contains('/') || value.length != 5) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 3) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PayPal Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _paypalEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'PayPal Email',
            hintText: 'your@email.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PayPal email';
            }
            if (!value.contains('@')) {
              return 'Invalid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Account Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _accountHolderController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Account Number',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _routingNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: InputDecoration(
            labelText: 'Routing Number',
            prefixIcon: const Icon(Icons.numbers),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter routing number';
            }
            if (value.length != 9) {
              return 'Routing number must be 9 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDigitalWalletForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedType == 'apple_pay' ? 'Apple' : 'Google'} Pay Information',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                _selectedType == 'apple_pay' ? Icons.apple : Icons.g_mobiledata,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'To add ${_selectedType == 'apple_pay' ? 'Apple' : 'Google'} Pay, you\'ll be redirected to authorize this device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      PaymentMethod paymentMethod;

      switch (_selectedType) {
        case 'card':
          final expiry = _expiryController.text.split('/');
          paymentMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'card',
            cardNumber: _cardNumberController.text.replaceAll(' ', ''),
            cardHolderName: _cardHolderController.text,
            expiryMonth: expiry[0],
            expiryYear: expiry[1],
            cvv: _cvvController.text,
            cardBrand: _detectCardBrand(_cardNumberController.text),
            isDefault: _isDefault,
            createdAt: DateTime.now(),
          );
          break;

        case 'paypal':
          paymentMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'paypal',
            paypalEmail: _paypalEmailController.text,
            isDefault: _isDefault,
            createdAt: DateTime.now(),
          );
          break;

        case 'bank_transfer':
          paymentMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'bank_transfer',
            bankAccountNumber: _accountNumberController.text,
            bankRoutingNumber: _routingNumberController.text,
            bankName: _accountHolderController.text,
            isDefault: _isDefault,
            createdAt: DateTime.now(),
          );
          break;

        default:
          paymentMethod = PaymentMethod(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: _selectedType,
            isDefault: _isDefault,
            createdAt: DateTime.now(),
          );
      }

      await PaymentService.addPaymentMethod('demo_user_1', paymentMethod);

      if (mounted) {
        Navigator.pop(context, paymentMethod);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method added successfully'),
            backgroundColor: Color(0xFF07C160),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add payment method: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _detectCardBrand(String cardNumber) {
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.isEmpty) return 'unknown';

    if (digits.startsWith('4')) return 'visa';
    if (digits.startsWith(RegExp(r'5[1-5]'))) return 'mastercard';
    if (digits.startsWith(RegExp(r'3[47]'))) return 'amex';
    if (digits.startsWith('6')) return 'discover';

    return 'unknown';
  }
}

// Input formatter for card number
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Input formatter for expiry date
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
