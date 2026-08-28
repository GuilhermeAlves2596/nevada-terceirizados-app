import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/local_image/local_image.dart';
import '../../domain/entities/execution_photo.dart';

/// Faixa de fotos da execução.
///
/// Na Fase 3 a captura é **simulada** (a câmera real chega na Fase 6), mas a
/// regra de "foto obrigatória para finalizar" já vale.
class ExecutionPhotoStrip extends StatelessWidget {
  const ExecutionPhotoStrip({
    super.key,
    required this.photos,
    required this.editable,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ExecutionPhoto> photos;
  final bool editable;
  final bool busy;
  final VoidCallback onAdd;
  final void Function(String photoId) onRemove;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Fotos', style: AppTypography.title),
            const SizedBox(width: 6),
            Text('• obrigatória', style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          editable
              ? 'Registre uma foto do serviço concluído (câmera ou galeria).'
              : 'Registro fotográfico da execução.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final photo in photos)
              _Thumb(
                photo: photo,
                editable: editable,
                onRemove: () => onRemove(photo.id),
              ),
            if (editable) _AddTile(busy: busy, onTap: onAdd),
            if (!editable && photos.isEmpty)
              Text('Nenhuma foto registrada.', style: AppTypography.bodyMuted),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.photo,
    required this.editable,
    required this.onRemove,
  });

  final ExecutionPhoto photo;
  final bool editable;
  final VoidCallback onRemove;

  bool get _hasImage => photo.localPath != null && photo.localPath != 'mock';

  void _openFullScreen(BuildContext context) {
    if (!_hasImage) return;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: AppRadius.brLg,
            child: InteractiveViewer(child: localImage(photo.localPath!)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ExecutionPhotoStrip._size,
      height: ExecutionPhotoStrip._size,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _openFullScreen(context),
            child: Container(
              width: ExecutionPhotoStrip._size,
              height: ExecutionPhotoStrip._size,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: _hasImage
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: AppRadius.brMd,
              ),
              child: _hasImage
                  ? localImage(photo.localPath!)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined,
                            color: AppColors.white, size: 26),
                        const SizedBox(height: 4),
                        Text(
                          photo.createdAt.hhmm,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
            ),
          ),
          if (editable)
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.dark,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.close,
                      size: 14, color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: AppRadius.brMd,
      child: Container(
        width: ExecutionPhotoStrip._size,
        height: ExecutionPhotoStrip._size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: AppColors.border),
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary, size: 24),
                  const SizedBox(height: 4),
                  Text('Adicionar',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.primary)),
                ],
              ),
      ),
    );
  }
}
