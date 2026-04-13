// lib/features/groups/group_member_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/data_objects.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/theme/app_theme.dart';
import 'package:quester_client/features/groups/quest_card_theme.dart';

// ─── Role metadata ────────────────────────────────────────────────────────────

class GroupMemberMeta {
  final Color color;
  final IconData icon;
  final String label;

  const GroupMemberMeta({
    required this.color,
    required this.icon,
    required this.label,
  });

  static GroupMemberMeta from(MemberRole role) => switch (role) {
    MemberRole.owner => const GroupMemberMeta(
      color: Color(0xFFD81B60), // raspberry red
      icon: Icons.star_outline,
      label: 'Owner',
    ),
    MemberRole.admin => const GroupMemberMeta(
      color: Color(0xFFFFB300), // sunlight orange
      icon: Icons.shield_outlined,
      label: 'Admin',
    ),
    MemberRole.member => const GroupMemberMeta(
      color: Color(0xFF4DD0E1), // pale cyan
      icon: Icons.person_outline,
      label: 'Member',
    ),
  };
}

// ─── Context menu actions ─────────────────────────────────────────────────────

enum MemberMenuAction { ping, call, setRole, kick }

// ─── Tile ────────────────────────────────────────────────────────────────────

class GroupMemberTile extends StatelessWidget {
  final GroupMemberWithUser memberWithUser;

  /// Ping is always enabled when true (pass true to enable).
  final bool canPing;

  /// Phone number to call — null disables the call action.
  final String? phoneNumber;

  /// Whether the "Set Role" action is available.
  final bool canSetRole;

  /// Whether the "Kick" action is available.
  final bool canKick;

  const GroupMemberTile({
    super.key,
    required this.memberWithUser,
    this.canPing = true,
    this.phoneNumber,
    this.canSetRole = false,
    this.canKick = false,
  });

  @override
  Widget build(BuildContext context) {
    final member = memberWithUser.groupMember;
    final user = memberWithUser.user;
    final meta = GroupMemberMeta.from(member.role);

    return Container(
      margin: QuestCardTheme.cardMargin,
      decoration: AppTheme.accentCard(accentColor: meta.color),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(QuestCardTheme.borderRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // — Left accent strip (role color) — already provided by accentCard border
              // — Main content —
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: QuestCardTheme.cardPadding,
                    child: Row(
                      children: [
                        // Role icon
                        Icon(meta.icon, color: meta.color, size: 22),
                        const SizedBox(width: 12),
                        // Text block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.username ?? user.publicId,
                                style: QuestCardTheme.titleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    meta.label,
                                    style: QuestCardTheme.subtitleStyle
                                        .copyWith(color: meta.color),
                                  ),
                                  if (user.phoneNumber != null) ...[
                                    Text(
                                      '  ·  ',
                                      style: QuestCardTheme.subtitleStyle,
                                    ),
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 11,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      user.phoneNumber!,
                                      style: QuestCardTheme.subtitleStyle
                                          .copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // — 3-dot menu button —
                        _MemberMenuButton(
                          memberWithUser: memberWithUser,
                          canPing: canPing,
                          phoneNumber: phoneNumber,
                          canSetRole: canSetRole,
                          canKick: canKick,
                        ),
                      ],
                    ),
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

// ─── Animated menu button ─────────────────────────────────────────────────────

class _MemberMenuButton extends ConsumerStatefulWidget {
  final GroupMemberWithUser memberWithUser;
  final bool canPing;
  final String? phoneNumber;
  final bool canSetRole;
  final bool canKick;

  const _MemberMenuButton({
    required this.memberWithUser,
    required this.canPing,
    required this.phoneNumber,
    required this.canSetRole,
    required this.canKick,
  });

  @override
  ConsumerState<_MemberMenuButton> createState() => _MemberMenuButtonState();
}

class _MemberMenuButtonState extends ConsumerState<_MemberMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuestCardTheme.menuPopDuration,
      vsync: this,
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    _controller.forward(from: 0);

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonTopLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final menuOrigin = buttonTopLeft.translate(-button.size.width - 10, 0);
    final RelativeRect position = RelativeRect.fromRect(
      menuOrigin & button.size,
      Offset.zero & overlay.size,
    );

    final MemberMenuAction? selected = await showMenu<MemberMenuAction>(
      context: context,
      position: position,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        PopupMenuItem(
          value: MemberMenuAction.ping,
          child: _MenuEntry(
            icon: Icons.notifications_outlined,
            label: 'Ping',
            isDisabled: !widget.canPing,
          ),
        ),
        PopupMenuItem(
          value: MemberMenuAction.call,
          child: _MenuEntry(
            icon: Icons.phone_outlined,
            label: 'Call',
            isDisabled: widget.phoneNumber == null,
          ),
        ),
        PopupMenuItem(
          value: MemberMenuAction.setRole,
          child: _MenuEntry(
            icon: Icons.manage_accounts_outlined,
            label: 'Set Role',
            isDisabled: !widget.canSetRole,
          ),
        ),
        PopupMenuItem(
          value: MemberMenuAction.kick,
          child: _MenuEntry(
            icon: Icons.person_remove_outlined,
            label: 'Kick',
            isDestructive: true,
            isDisabled: !widget.canKick,
          ),
        ),
      ],
    );

    if (selected != null && mounted) {
      _handleAction(selected);
    }
  }

  void _handleAction(MemberMenuAction action) {
    switch (action) {
      case MemberMenuAction.ping:
        if (widget.canPing) {
          // TODO: wire to notifier
        }
        break;
      case MemberMenuAction.call:
        if (widget.phoneNumber != null) {
          // TODO: wire to phone call intent
        }
        break;
      case MemberMenuAction.setRole:
        if (widget.canSetRole) {
          _showSetRoleDialog();
        }
        break;
      case MemberMenuAction.kick:
        if (widget.canKick) {
          // TODO: wire to notifier
        }
        break;
    }
  }

  void _showSetRoleDialog() {
    showDialog<MemberRole>(
      context: context,
      builder: (_) =>
          _SetRoleDialog(currentRole: widget.memberWithUser.groupMember.role),
    ).then((newRole) {
      if (newRole != null) {
        // TODO: wire to notifier with newRole
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: QuestCardTheme.menuButtonSize,
        height: QuestCardTheme.menuButtonSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.more_vert, size: QuestCardTheme.menuIconSize),
          onPressed: _openMenu,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Set Role Dialog ──────────────────────────────────────────────────────────

class _SetRoleDialog extends StatelessWidget {
  final MemberRole currentRole;

  const _SetRoleDialog({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: AppTheme.dialogDecoration(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Role',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _RoleOption(
              role: MemberRole.admin,
              meta: GroupMemberMeta.from(MemberRole.admin),
              isSelected: currentRole == MemberRole.admin,
              onTap: () => Navigator.of(context).pop(MemberRole.admin),
            ),
            const SizedBox(height: 8),
            _RoleOption(
              role: MemberRole.member,
              meta: GroupMemberMeta.from(MemberRole.member),
              isSelected: currentRole == MemberRole.member,
              onTap: () => Navigator.of(context).pop(MemberRole.member),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final MemberRole role;
  final GroupMemberMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.accentCard(accentColor: meta.color).copyWith(
        border: isSelected
            ? Border.all(color: meta.color, width: 2)
            : Border(left: BorderSide(color: meta.color, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(QuestCardTheme.borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(meta.icon, color: meta.color, size: 20),
                const SizedBox(width: 12),
                Text(
                  meta.label,
                  style: QuestCardTheme.titleStyle.copyWith(color: meta.color),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: meta.color, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Menu item row (mirrors _MenuEntry in quest_tile.dart) ───────────────────

class _MenuEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final bool isDisabled;

  const _MenuEntry({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    if (isDisabled) {
      color = color.withOpacity(0.38);
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
