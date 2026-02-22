import 'package:flutter/material.dart';
import '../../models.dart';

class GroupHeader extends StatelessWidget {
  final DeckGroup group;
  final int deckCount;
  final bool isExpanded;
  final bool isHovering;
  final VoidCallback onToggleExpand;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onPlay;
  final String renameTooltip;
  final String deleteTooltip;
  final bool canPlay;

  const GroupHeader({
    super.key,
    required this.group,
    required this.deckCount,
    required this.isExpanded,
    this.isHovering = false,
    required this.onToggleExpand,
    required this.onRename,
    required this.onDelete,
    required this.onPlay,
    required this.renameTooltip,
    required this.deleteTooltip,
    required this.canPlay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: isHovering
            ? Colors.purple.shade100
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: isHovering
            ? Border.all(color: Colors.purple.shade400, width: 2)
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _buildExpandableHeader()),
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableHeader() {
    return InkWell(
      onTap: onToggleExpand,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_more : Icons.chevron_right,
              color: Colors.black87,
            ),
            const SizedBox(width: 8),
            Icon(Icons.folder, color: Colors.purple.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${group.name} ($deckCount)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
              onPressed: onRename,
              tooltip: renameTooltip,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.black54,
              ),
              onPressed: onDelete,
              tooltip: deleteTooltip,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.purple.shade400,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: InkWell(
        onTap: canPlay ? onPlay : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.play_arrow,
            size: 32,
            color: canPlay ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}
