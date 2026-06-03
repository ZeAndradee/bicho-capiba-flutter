import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../models/adoption_process.dart';
import 'adoption_card_shared.dart';

class ActiveAdoptionCard extends StatelessWidget {
  final AdoptionProcess process;
  final VoidCallback onDetails;

  const ActiveAdoptionCard({
    super.key,
    required this.process,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final animal = process.animal;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onDetails,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 8,
                    child: _CyclingAnimalImage(urls: animal.fotos),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: StatusBadge(process: process),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _nameRow(animal),
          const SizedBox(height: 5),
          adoptionMetaRow(animal),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  animal.ongNome ?? 'ONG não informada',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.mapPin,
                size: 14,
                color: AppColors.orangeCapiba,
              ),
              const SizedBox(width: 3),
              Text(
                animal.distancia,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nameRow(Animal animal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: onDetails,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    animal.nome,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.title,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  animal.idade,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (process.status == AdoptionStatus.aprovado)
          Icon(
            LucideIcons.badgeCheck,
            size: 24,
            color: process.statusColor,
          )
        else
          CompletionCircle(
            value: process.completion,
            color: process.statusColor,
          ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final AdoptionProcess process;

  const StatusBadge({super.key, required this.process});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: process.statusColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        process.statusLabel,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CompletionCircle extends StatelessWidget {
  final double value;
  final Color color;

  const CompletionCircle({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 3,
        strokeCap: StrokeCap.round,
        backgroundColor: color.withValues(alpha: 0.18),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _CyclingAnimalImage extends StatefulWidget {
  final List<String> urls;

  const _CyclingAnimalImage({required this.urls});

  @override
  State<_CyclingAnimalImage> createState() => _CyclingAnimalImageState();
}

class _CyclingAnimalImageState extends State<_CyclingAnimalImage> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.urls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % widget.urls.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return const AdoptionAnimalImage(url: null);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: AdoptionAnimalImage(
            key: ValueKey(_index),
            url: widget.urls[_index],
          ),
        ),
        if (widget.urls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.urls.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
