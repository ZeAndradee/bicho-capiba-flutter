import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import '../providers/animal_detail_provider.dart';
import '../widgets/photo_gallery.dart';

const _speciesLabels = <String, String>{
  'dog': 'Cachorro',
  'cat': 'Gato',
  'horse': 'Cavalo',
  'bird': 'Pássaro',
  'rabbit': 'Coelho',
  'rat': 'Roedor',
};

class AnimalDetailScreen extends ConsumerWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(animalDetailProvider(animalId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        data: (animal) => _DetailBody(animal: animal),
        loading: () =>
            const _Frame(child: Center(child: CircularProgressIndicator())),
        error: (_, _) => _Frame(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.dog,
                  size: 56,
                  color: AppColors.skeletonBase,
                ),
                const SizedBox(height: 12),
                const Text('Não foi possível carregar este animal.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(animalDetailProvider(animalId)),
                  child: const Text('Tentar de novo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  final Widget child;

  const _Frame({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: 8,
            left: 12,
            child: _CircleButton(
              icon: LucideIcons.arrowLeft,
              onTap: () => _back(context),
            ),
          ),
        ],
      ),
    );
  }
}

void _back(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/adote');
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  final Animal animal;

  const _DetailBody({required this.animal});

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  late bool _liked = widget.animal.isLiked;
  final ScrollController _scrollController = ScrollController();
  bool _adoptBarVisible = true;

  Animal get animal => widget.animal;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _adoptBarVisible) {
      setState(() => _adoptBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_adoptBarVisible) {
      setState(() => _adoptBarVisible = true);
    }
  }

  Future<void> _toggleFavorite() async {
    final service = ref.read(animalServiceProvider);
    final wasLiked = _liked;
    setState(() => _liked = !wasLiked);
    try {
      if (wasLiked) {
        await service.unlikeAnimal(animal.id);
      } else {
        await service.likeAnimal(animal.id);
      }
    } catch (_) {
      if (mounted) setState(() => _liked = wasLiked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = animal.fotos.isNotEmpty
        ? animal.fotos
        : (animal.imageUrl != null ? [animal.imageUrl!] : const <String>[]);

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: PhotoGallery(photos: photos)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: _content(context),
              ),
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleButton(
                  icon: LucideIcons.arrowLeft,
                  onTap: () => _back(context),
                ),
                _CircleButton(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  iconColor: _liked ? AppColors.orangeCapiba : null,
                  onTap: _toggleFavorite,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            offset: _adoptBarVisible ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _adoptBarVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _adoptBar(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleRow(),
        const SizedBox(height: 6),
        _metaRow(),
        const SizedBox(height: 16),
        _chips(),
        if (animal.historia != null && animal.historia!.isNotEmpty) ...[
          const SizedBox(height: 28),
          _sectionTitle('História'),
          const SizedBox(height: 8),
          Text(
            animal.historia!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.textColor,
            ),
          ),
        ],
        const SizedBox(height: 28),
        _ongCard(context),
      ],
    );
  }

  Widget _titleRow() {
    final isMale = animal.sexo == 'M';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            animal.nome,
            style: const TextStyle(
              fontFamily: AppFonts.title,
              fontWeight: FontWeight.w600,
              fontSize: 30,
              color: AppColors.foreground,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isMale ? Icons.male : Icons.female,
            size: 22,
            color: AppColors.orangeCapiba,
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    final species = _speciesLabels[animal.especie] ?? animal.especie;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          '$species · ${animal.raca}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
        const Text('·', style: TextStyle(color: AppColors.textColor)),
        Text(
          animal.idade,
          style: const TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
        if (animal.bairro != 'Não informado') ...[
          const Text('·', style: TextStyle(color: AppColors.textColor)),
          Text(
            '${animal.bairro}, ${animal.cidade}',
            style: const TextStyle(fontSize: 16, color: AppColors.textColor),
          ),
        ],
      ],
    );
  }

  Widget _chips() {
    final chips = <Widget>[];

    final status = animal.statusAnimal;
    if (status != null && status.isNotEmpty) {
      final available = status.toLowerCase().startsWith('dispon');
      chips.add(
        _chip(
          status,
          bg: available
              ? AppColors.greenCapiba.withValues(alpha: 0.12)
              : AppColors.backgroundSecondary,
          fg: available ? AppColors.greenCapiba : AppColors.textColor,
          icon: available ? LucideIcons.checkCircle : LucideIcons.info,
        ),
      );
    }
    if (animal.porte != null) {
      chips.add(_chip('Porte ${animal.porte}', icon: LucideIcons.ruler));
    }
    if (animal.castrado != null) {
      chips.add(
        _chip(
          animal.castrado! ? 'Castrado' : 'Não castrado',
          icon: LucideIcons.stethoscope,
        ),
      );
    }
    if (animal.sociavelAnimal == true) {
      chips.add(_chip('Sociável c/ animais', icon: LucideIcons.dog));
    }
    if (animal.sociavelPessoa == true) {
      chips.add(_chip('Sociável c/ pessoas', icon: LucideIcons.users));
    }
    if (animal.necessidadesEspeciais != null &&
        animal.necessidadesEspeciais!.isNotEmpty) {
      chips.add(
        _chip(
          animal.necessidadesEspeciais!,
          icon: LucideIcons.heart,
          bg: AppColors.yellowCapiba.withValues(alpha: 0.15),
          fg: AppColors.orangeCapiba,
        ),
      );
    }
    if (animal.corNome != null) {
      chips.add(_colorChip(animal.corNome!, animal.corHex));
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _chip(String label, {IconData? icon, Color? bg, Color? fg}) {
    final foreground = fg ?? AppColors.foreground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg ?? AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorChip(String label, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color ?? AppColors.skeletonBase,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderColor),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: AppFonts.title,
      fontWeight: FontWeight.w600,
      fontSize: 19,
      color: AppColors.foreground,
    ),
  );

  Widget _ongCard(BuildContext context) {
    final nome = animal.ongNome;
    if (nome == null || nome.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.greenCapiba.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.heartHandshake,
                  size: 22,
                  color: AppColors.greenCapiba,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Responsável',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      nome,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              if (animal.ongTelefone != null) ...[
                const SizedBox(width: 12),
                _whatsappIcon(onTap: () => _openWhatsApp(animal)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _whatsappIcon({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.greenCapiba,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          LucideIcons.messageCircle,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _adoptBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () => context.push('/adotar', extra: animal),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.greenCapiba,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text('Quero adotar ${animal.nome}'),
          ),
        ),
      ),
    );
  }
}

Future<void> _openWhatsApp(Animal animal) async {
  final phone = animal.ongTelefone;
  if (phone == null) return;
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (!digits.startsWith('55')) digits = '55$digits';
  final msg = Uri.encodeComponent(
    'Olá! Tenho interesse em adotar o ${animal.nome} que vi no Bicho Capiba.',
  );
  await _launch('https://wa.me/$digits?text=$msg');
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 22, color: iconColor ?? AppColors.foreground),
        ),
      ),
    );
  }
}
