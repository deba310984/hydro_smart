import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/krishi_theme.dart';
import 'live_sensor_providers.dart';

/// Bottom sheet for pairing an ESP32 by device id.
///
/// The id is just the Realtime Database key the firmware writes under, so
/// pairing is only a matter of both sides agreeing on the same string.
Future<void> showDevicePairingSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DevicePairingSheet(),
  );
}

class _DevicePairingSheet extends ConsumerStatefulWidget {
  const _DevicePairingSheet();

  @override
  ConsumerState<_DevicePairingSheet> createState() =>
      _DevicePairingSheetState();
}

class _DevicePairingSheetState extends ConsumerState<_DevicePairingSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(deviceIdProvider) ?? kDefaultDeviceId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = _controller.text.trim();
    await ref.read(deviceIdProvider.notifier).setDeviceId(id);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(id.isEmpty ? 'Device unpaired' : 'Paired with $id'),
        backgroundColor: KrishiTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(deviceIdProvider);
    final path = liveSensorPath(
        _controller.text.trim().isEmpty ? '<deviceId>' : _controller.text.trim());

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: KrishiTheme.parchment,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: KrishiTheme.monsoonSky.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.sensors_rounded,
                    color: KrishiTheme.primaryGreen, size: 22),
                const SizedBox(width: 10),
                Text('Pair ESP32 Sensor',
                    style: KrishiTheme.headlineSmall
                        .copyWith(color: KrishiTheme.deepSoil)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the same device id your ESP32 sketch publishes under. '
              'Both sides must use exactly the same string.',
              style: KrishiTheme.bodySmall
                  .copyWith(color: KrishiTheme.monsoonSky, fontSize: 12),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
              inputFormatters: [
                // RTDB keys cannot contain . $ # [ ] / or control chars.
                FilteringTextInputFormatter.deny(RegExp(r'[.$#\[\]/\s]')),
                LengthLimitingTextInputFormatter(64),
              ],
              decoration: InputDecoration(
                labelText: 'Device ID',
                hintText: kDefaultDeviceId,
                prefixIcon: const Icon(Icons.memory_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KrishiTheme.primaryGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: KrishiTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Firmware writes to',
                      style: KrishiTheme.labelStyle.copyWith(
                          color: KrishiTheme.monsoonSky, fontSize: 11)),
                  const SizedBox(height: 4),
                  SelectableText(
                    path,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: KrishiTheme.deepSoil,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (current != null && current.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(deviceIdProvider.notifier)
                            .setDeviceId('');
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KrishiTheme.alertRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Unpair'),
                    ),
                  ),
                if (current != null && current.isNotEmpty)
                  const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: KrishiTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save & Connect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
