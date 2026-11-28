import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../models/contact.dart';

/// Small rounded square with an icon inside.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    this.background = AppColors.lightBlue,
    this.color = AppColors.deepBlue,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Round white icon button (44x44) used in headers.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color background;
  final Color color;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background = Colors.white,
    this.color = AppColors.deepBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

/// Page title block: small grey line + big bold title.
class PageHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.subtitle,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Round "done" indicator: green with a check, or an empty outlined circle.
class CheckDot extends StatelessWidget {
  final bool done;
  final double size;

  const CheckDot({super.key, required this.done, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.green : Colors.transparent,
        border: done ? null : Border.all(color: AppColors.deepBlue, width: 2),
      ),
      child: done
          ? Icon(Icons.check_rounded, color: Colors.white, size: size * 0.6)
          : null,
    );
  }
}

/// Contact photo, or their initials on a blue circle if there is no photo.
class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double size;
  final int colorIndex;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.size = 88,
    this.colorIndex = 0,
  });

  static const _bg = [AppColors.blue, AppColors.deepBlue, AppColors.lightBlue];
  static const _fg = [AppColors.ink, Colors.white, AppColors.deepBlue];

  @override
  Widget build(BuildContext context) {
    final i = colorIndex.abs() % _bg.length;

    // Supabase photo first, then a just-picked photo, otherwise initials
    ImageProvider? image;
    if (contact.photoUrl != null) {
      image = NetworkImage(contact.photoUrl!);
    } else if (contact.photoBytes != null) {
      image = MemoryImage(contact.photoBytes!);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _bg[i],
        border: Border.all(color: AppColors.softBlue, width: size > 50 ? 4 : 3),
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: image == null
          ? Text(
        contact.initials,
        style: TextStyle(
          color: _fg[i],
          fontWeight: FontWeight.w800,
          fontSize: size * 0.3,
        ),
      )
          : null,
    );
  }
}

/// Opens the phone dialer with this number.
Future<void> callNumber(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
  try {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the dialer for $phone')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the dialer for $phone')),
      );
    }
  }
}