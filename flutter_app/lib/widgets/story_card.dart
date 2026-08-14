import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/cuento.dart';
import '../theme/willpig_colors.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({required this.cuento, super.key});

  final Cuento cuento;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: WillpigColors.storyCardWidth,
      decoration: BoxDecoration(
        color: WillpigColors.surface,
        borderRadius: BorderRadius.circular(WillpigColors.radiusMd),
        border: Border.all(color: WillpigColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _cover()),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 6),
            child: Text(
              cuento.titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 22 / 15,
                color: WillpigColors.textDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: WillpigColors.primarySalmonMuted,
                  backgroundImage: cuento.autorAvatarUrl != null
                      ? NetworkImage(cuento.autorAvatarUrl!)
                      : null,
                  child: cuento.autorAvatarUrl == null
                      ? SvgPicture.asset(
                          'assets/images/default-avatar.svg',
                          width: 16,
                          height: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cuento.autor == null ? '@autor' : '@${cuento.autor}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: WillpigColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/vistas-icon.svg',
                  width: 15,
                  height: 15,
                  colorFilter: ColorFilter.mode(
                    WillpigColors.textMuted.withValues(alpha: 0.8),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${cuento.vistas}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WillpigColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cover() {
    const fallback = ColoredBox(
      color: WillpigColors.brandPink,
      child: Center(
        child: Icon(
          Icons.auto_stories,
          size: 42,
          color: WillpigColors.inkBlack,
        ),
      ),
    );

    final url = cuento.portadaUrl;
    if (url == null || url.isEmpty) return fallback;

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
