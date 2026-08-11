import 'package:flutter/material.dart';
import '../app/app.dart';
import '../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final phone = TextEditingController(text: '+5493415550110'),
      otp = TextEditingController();
  bool codeSent = false;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 40, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            const Spacer(),
            const Text(
              'SOS Rural',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w600,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              codeSent
                  ? 'Ingresá el código que enviamos por SMS.'
                  : 'Tu teléfono es tu acceso seguro a la red de emergencias.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: phone,
              enabled: !codeSent,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            if (codeSent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Código de 6 dígitos',
                  counterText: '',
                  hintText: '123456',
                ),
              ),
            ],
            if (c.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                c.errorMessage!,
                style: const TextStyle(color: AppColors.medical, fontSize: 13),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: c.busy
                  ? null
                  : () async {
                      await c.login(phone.text, codeSent ? otp.text : '');
                      if (!codeSent && c.errorMessage == null) {
                        setState(() => codeSent = true);
                      }
                    },
              child: c.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(codeSent ? 'Ingresar' : 'Continuar'),
            ),
            if (codeSent)
              TextButton(
                onPressed: () => setState(() => codeSent = false),
                child: const Text(
                  'Cambiar teléfono',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
