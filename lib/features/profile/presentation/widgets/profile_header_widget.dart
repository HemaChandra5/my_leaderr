import 'package:flutter/material.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../domain/models/citizen_profile.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key, required this.profile});

  final CitizenProfile profile;

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.instance.language;
    final localizedRole = profile.role == 'Citizen'
        ? AppLocalizations.translate('citizen', language: language)
        : profile.role;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF5A623), width: 1.2),
          ),
          child: Hero(
            tag: 'citizen-profile-avatar',
            child: CircleAvatar(
              backgroundColor: Color(0xFF161B22),
              backgroundImage: (profile.profileImage ?? '').isNotEmpty
                  ? NetworkImage(profile.profileImage!)
                  : null,
              child: (profile.profileImage ?? '').isNotEmpty
                  ? null
                  : const Icon(
                      Icons.person_rounded,
                      size: 30,
                      color: Color(0xFFFFFFFF),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '$localizedRole • ${profile.location}',
                style: const TextStyle(
                  color: Color(0xFFB0B5BD),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x3322C55E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppLocalizations.translate(
                    'active_citizen',
                    language: language,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
