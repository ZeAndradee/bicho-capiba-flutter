import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';

Future<bool?> showRemoveFavoriteSheet({
  required BuildContext context,
  required Animal animal,
  required Future<void> Function() onConfirm,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RemoveFavoriteSheet(animal: animal, onConfirm: onConfirm),
  );
}

enum _Stage { confirm, deleting, success }

class _RemoveFavoriteSheet extends StatefulWidget {
  final Animal animal;
  final Future<void> Function() onConfirm;

  const _RemoveFavoriteSheet({required this.animal, required this.onConfirm});

  @override
  State<_RemoveFavoriteSheet> createState() => _RemoveFavoriteSheetState();
}

class _RemoveFavoriteSheetState extends State<_RemoveFavoriteSheet> {
  _Stage _stage = _Stage.confirm;

  Future<void> _remove() async {
    setState(() => _stage = _Stage.deleting);
    try {
      await widget.onConfirm();
    } catch (_) {
      if (!mounted) return;
      setState(() => _stage = _Stage.confirm);
      return;
    }
    if (!mounted) return;
    setState(() => _stage = _Stage.success);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 232,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _stage == _Stage.success
                    ? const _SuccessContent()
                    : _confirmContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmContent() {
    final deleting = _stage == _Stage.deleting;
    return Column(
      key: const ValueKey('confirm'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.orangeCapiba.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.heart_broken_rounded,
            size: 32,
            color: AppColors.orangeCapiba,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Remover dos favoritos',
          style: TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remover ${widget.animal.nome} dos favoritos?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppColors.textColor),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: deleting
                    ? null
                    : () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.backgroundSecondary,
                  foregroundColor: AppColors.foreground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: deleting ? null : _remove,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.orangeCapiba,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Remover',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: value.clamp(0.0, 1.0),
            child: child,
          ),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.greenCapiba,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Removido dos favoritos',
          style: TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
