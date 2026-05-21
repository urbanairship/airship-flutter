import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class ContactChannelRegistration extends StatefulWidget {
  const ContactChannelRegistration({super.key});

  @override
  State<ContactChannelRegistration> createState() =>
      _ContactChannelRegistrationState();
}

class _ContactChannelRegistrationState extends State<ContactChannelRegistration> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _senderIdController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _smsFocusNode = FocusNode();
  final FocusNode _senderIdFocusNode = FocusNode();

  bool _doubleOptIn = false;
  bool _isRegisteringEmail = false;
  bool _isRegisteringSms = false;

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Contact Channel Registration');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _smsController.dispose();
    _senderIdController.dispose();
    _emailFocusNode.dispose();
    _smsFocusNode.dispose();
    _senderIdFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterEmail() async {
    final address = _emailController.text.trim();
    if (address.isEmpty) {
      _showSnackBar('Please enter an email address', isWarning: true);
      return;
    }

    _emailFocusNode.unfocus();
    setState(() => _isRegisteringEmail = true);

    try {
      final options = EmailRegistrationOptions.options(
        transactionalOptedIn: DateTime.now().millisecondsSinceEpoch,
        properties: const {'source': 'flutter_example'},
        doubleOptIn: _doubleOptIn,
      );
      debugPrint('registerEmail: calling address=$address options=${options.toJson()}');
      await Airship.contact.registerEmail(address, options);
      debugPrint('registerEmail: success');

      if (mounted) {
        _showSnackBar('Email channel registered', isSuccess: true);
      }
    } catch (e) {
      debugPrint('registerEmail: error $e');
      if (mounted) {
        _showSnackBar('Failed to register email: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isRegisteringEmail = false);
      }
    }
  }

  Future<void> _handleRegisterSms() async {
    final msisdn = _smsController.text.trim();
    final senderId = _senderIdController.text.trim();

    if (msisdn.isEmpty) {
      _showSnackBar('Please enter a phone number (MSISDN)', isWarning: true);
      return;
    }
    if (senderId.isEmpty) {
      _showSnackBar('Please enter a sender ID', isWarning: true);
      return;
    }

    _smsFocusNode.unfocus();
    _senderIdFocusNode.unfocus();
    setState(() => _isRegisteringSms = true);

    try {
      final options = SmsRegistrationOptions(senderId: senderId);
      debugPrint('registerSms: calling msisdn=$msisdn options=${options.toJson()}');
      await Airship.contact.registerSms(msisdn, options);
      debugPrint('registerSms: success');

      if (mounted) {
        _showSnackBar('SMS channel registered', isSuccess: true);
      }
    } catch (e) {
      debugPrint('registerSms: error $e');
      if (mounted) {
        _showSnackBar('Failed to register SMS: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isRegisteringSms = false);
      }
    }
  }

  void _showSnackBar(
    String message, {
    bool isSuccess = false,
    bool isError = false,
    bool isWarning = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? backgroundColor;

    if (isSuccess) {
      backgroundColor = Colors.green.shade600;
    } else if (isError) {
      backgroundColor = colorScheme.error;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade700;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Contact Channels'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'EMAIL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegisterEmail(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Double opt-in'),
                        subtitle: const Text(
                          'Require double opt-in for this email registration',
                        ),
                        value: _doubleOptIn,
                        onChanged: _isRegisteringEmail
                            ? null
                            : (value) => setState(() => _doubleOptIn = value),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _isRegisteringEmail ||
                                _emailController.text.trim().isEmpty
                            ? null
                            : _handleRegisterEmail,
                        icon: _isRegisteringEmail
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.email, size: 20),
                        label: Text(
                          _isRegisteringEmail
                              ? 'Registering...'
                              : 'Register Email',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SMS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _smsController,
                        focusNode: _smsFocusNode,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone number (MSISDN)',
                          prefixIcon: Icon(
                            Icons.sms_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _senderIdController,
                        focusNode: _senderIdFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Sender ID',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegisterSms(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isRegisteringSms ||
                                _smsController.text.trim().isEmpty ||
                                _senderIdController.text.trim().isEmpty
                            ? null
                            : _handleRegisterSms,
                        icon: _isRegisteringSms
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.sms, size: 20),
                        label: Text(
                          _isRegisteringSms
                              ? 'Registering...'
                              : 'Register SMS',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Register email and SMS channels for the current contact. '
                          'Use values configured for your Airship project.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
