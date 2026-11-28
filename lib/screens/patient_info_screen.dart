import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../data/app_data.dart';
import '../widgets/caregiver_widgets.dart';

/// Caregiver's view of the patient profile.
class PatientInfoScreen extends StatelessWidget {
  final VoidCallback? onOpenContacts;

  const PatientInfoScreen({super.key, this.onOpenContacts});

  static const _mainContact = '+212 6 25 34 52';

  @override
  Widget build(BuildContext context) {
    final contacts = AppData.contacts;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Blue header
        Container(
          decoration: const BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: -60,
                top: -80,
                child: _circle(220, const Color(0x4D8FAAC3)),
              ),
              Positioned(
                right: -50,
                bottom: -70,
                child: _circle(180, const Color(0x388FAAC3)),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 44,
                        child: Center(
                          child: Text('Patient profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 104,
                        height: 104,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blue, width: 4),
                        ),
                        child: const Text('JD',
                            style: TextStyle(
                                color: AppColors.deepBlue,
                                fontSize: 34,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 12),
                      const Text('John Doe',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _chip('72 years old'),
                          const SizedBox(width: 8),
                          _chip('Dementia'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              // Details
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.person_outline, 'Full name', 'John Doe'),
                    const Divider(height: 1, color: AppColors.softBlue),
                    _infoRow(Icons.cake_outlined, 'Age', '72 years old'),
                    const Divider(height: 1, color: AppColors.softBlue),
                    _infoRow(
                        Icons.favorite_border_rounded, 'Condition', 'Dementia'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Main contact
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Main contact',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greenText)),
                          SizedBox(height: 2),
                          Text(_mainContact,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                        ],
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.call_outlined,
                      tooltip: 'Call main contact',
                      background: AppColors.green,
                      color: Colors.white,
                      onPressed: () => callNumber(context, _mainContact),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Familiar faces
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onOpenContacts,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        if (contacts.isEmpty)
                          const IconBadge(
                            icon: Icons.people_outline,
                            background: AppColors.lightGreen,
                            color: AppColors.green,
                          )
                        else
                          SizedBox(
                            width: 38.0 + 26.0 * (contacts.length.clamp(1, 3) - 1).toDouble(),
                            height: 38,
                            child: Stack(
                              children: [
                                for (var i = 0; i < contacts.length && i < 3; i++)
                                  Positioned(
                                    left: 26.0 * i,
                                    child: ContactAvatar(
                                      contact: contacts[i],
                                      size: 38,
                                      colorIndex: i,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Familiar faces',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink)),
                              const SizedBox(height: 2),
                              Text(
                                contacts.isEmpty
                                    ? 'Add people John knows'
                                    : '${contacts.length} '
                                        '${contacts.length == 1 ? 'person' : 'people'} John knows',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.deepBlue),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  static Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x29FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      );

  static Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconBadge(icon: icon),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
              ],
            ),
          ],
        ),
      );
}
