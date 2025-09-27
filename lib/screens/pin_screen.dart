import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final List<String> _pinDigits = List.generate(6, (index) => '');
  String _currentPin = '';
  String? _storedPin;
  bool _isSetupMode = false;
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('app_pin');
    
    if (storedPin == null) {
      // No PIN set, go to setup mode
      setState(() {
        _isSetupMode = true;
      });
    } else {
      // PIN exists, go to verification mode
      setState(() {
        _storedPin = storedPin;
      });
    }
  }

  void _onDigitPressed(String digit) {
    if (_currentPin.length < 6) {
      setState(() {
        _currentPin += digit;
        _pinDigits[_currentPin.length - 1] = digit;
        _showError = false;
      });

      if (_currentPin.length == 6) {
        _handlePinComplete();
      }
    }
  }

  void _handlePinComplete() async {
    if (_isSetupMode) {
      if (_storedPin == null) {
        // First time setup - store the PIN
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_pin', _currentPin);
        setState(() {
          _storedPin = _currentPin;
          _isSetupMode = false;
          _currentPin = '';
          for (int i = 0; i < 6; i++) {
            _pinDigits[i] = '';
          }
        });
        _showSuccessMessage('PIN set successfully!');
      } else {
        // Confirm PIN for setup
        if (_currentPin == _storedPin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_pin', _currentPin);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          _showError = true;
          _errorMessage = 'PINs do not match. Please try again.';
          _clearPin();
        }
      }
    } else {
      // Verification mode
      if (_currentPin == _storedPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showError = true;
        _errorMessage = 'Incorrect PIN. Please try again.';
        _clearPin();
      }
    }
  }

  void _clearPin() {
    setState(() {
      _currentPin = '';
      for (int i = 0; i < 6; i++) {
        _pinDigits[i] = '';
      }
    });
  }

  void _backspace() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        _pinDigits[_currentPin.length] = '';
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Title
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.blue,
              ),
            ),
            
            // Title
            Text(
              _isSetupMode && _storedPin == null
                  ? 'Set PIN'
                  : _isSetupMode && _storedPin != null
                      ? 'Confirm PIN'
                      : 'Enter PIN',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _showError ? Colors.red : Colors.grey,
                      width: 2,
                    ),
                    color: _pinDigits[index].isNotEmpty ? Colors.blue : Colors.transparent,
                  ),
                  child: _pinDigits[index].isNotEmpty
                      ? const Icon(
                          Icons.circle,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Error Message
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            
            // PIN Pad
            _buildPinPad(),
            
            const SizedBox(height: 30),
            
            // Forgot PIN Option
            if (!_isSetupMode)
              TextButton(
                onPressed: _resetPin,
                child: const Text(
                  'Forgot PIN?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinPad() {
    return Column(
      children: [
        // First Row
        _buildPinRow(['1', '2', '3']),
        _buildPinRow(['4', '5', '6']),
        _buildPinRow(['7', '8', '9']),
        _buildPinRow(['', '0', '⌫']), // Empty for first button, backspace for last
      ],
    );
  }

  Widget _buildPinRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((digit) {
        if (digit.isEmpty) {
          return const SizedBox(width: 80); // Empty space
        }
        
        return Container(
          margin: const EdgeInsets.all(8),
          width: 80,
          height: 80,
          child: digit == '⌫'
              ? ElevatedButton(
                  onPressed: _backspace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.backspace),
                )
              : ElevatedButton(
                  onPressed: () => _onDigitPressed(digit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    digit,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      }).toList(),
    );
  }

  Future<void> _resetPin() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text('Are you sure you want to reset your PIN? You will need to set a new one.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_pin');
      setState(() {
        _storedPin = null;
        _isSetupMode = true;
        _currentPin = '';
        for (int i = 0; i < 6; i++) {
          _pinDigits[i] = '';
        }
      });
    }
  }
}