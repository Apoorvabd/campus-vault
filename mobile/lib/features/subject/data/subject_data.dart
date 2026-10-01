import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_chip.dart';

enum ResourceCategory {
  pyq('PYQ', 'PYQ', StatusChipVariant.pyq),
  notes('Notes', 'NOTES', StatusChipVariant.notes),
  labManual('Lab Manual', 'LAB MANUAL', StatusChipVariant.labManual),
  syllabus('Syllabus', 'SYLLABUS', StatusChipVariant.syllabus),
  reference('Reference Book', 'REFERENCE', StatusChipVariant.reference);

  const ResourceCategory(this.label, this.badge, this.variant);
  final String label;
  final String badge;
  final StatusChipVariant variant;
}

/// How the user holds a resource: downloaded PDF, bookmarked post/link,
/// or saved locally in the private vault.
enum ResourceSource {
  downloaded('Downloaded'),
  bookmarked('Bookmarked'),
  local('Locally Saved');

  const ResourceSource(this.label);
  final String label;
}

class SubjectResource {
  const SubjectResource(
    this.category,
    this.title,
    this.meta,
    this.uploader,
    this.source, {
    this.verified = false,
  });
  final ResourceCategory category;
  final String title;
  final String meta;
  final String uploader;
  final ResourceSource source;
  final bool verified;
}

class SubjectInfo {
  const SubjectInfo({
    required this.name,
    required this.shortName,
    required this.code,
    required this.type,
    required this.semester,
    required this.course,
    required this.icon,
    required this.color,
    required this.resources,
  });

  final String name;
  final String shortName;
  final String code;
  final String type;
  final int semester;
  final String course;
  final IconData icon;
  final Color color;
  final List<SubjectResource> resources;

  int countOf(ResourceSource source) =>
      resources.where((r) => r.source == source).length;

  String get tileSubtitle =>
      '${resources.length} items · ${countOf(ResourceSource.downloaded)} downloaded · '
      '${countOf(ResourceSource.bookmarked)} bookmarked · ${countOf(ResourceSource.local)} local';
}

const _course = 'B.Voc Software Development';

/// Mock catalog of the user's own items per subject (downloaded, bookmarked
/// or locally saved) — replace with real data once the backend is wired.
class SubjectCatalog {
  SubjectCatalog._();

  static const _d = ResourceSource.downloaded;
  static const _b = ResourceSource.bookmarked;
  static const _l = ResourceSource.local;

  static const all = [
    SubjectInfo(
      name: 'Database Management Systems',
      shortName: 'DBMS',
      code: 'CS501',
      type: 'DSC',
      semester: 5,
      course: _course,
      icon: Icons.storage_rounded,
      color: AppColors.primary,
      resources: [
        SubjectResource(
          ResourceCategory.pyq,
          'DBMS Regular Examination Question Paper (Dec 2024)',
          '12 pages · 2.4 MB · 2024 · ⭐ 4.9',
          'Priya Sharma',
          _d,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.notes,
          'DBMS Mid-Term Solved Question Bank (Revised Syllabus)',
          '18 pages · 3.8 MB · 2024 · ⭐ 5.0',
          'CS Toppers Circle',
          _b,
        ),
        SubjectResource(
          ResourceCategory.labManual,
          'DBMS Lab Manual: SQL Queries & PL/SQL Programs',
          '30 pages · 4.6 MB · 2023 · ⭐ 4.7',
          'Rohit M.',
          _l,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.syllabus,
          'DBMS Official Syllabus & Unit Plan (DU 2023 Scheme)',
          '4 pages · 0.6 MB · 2023 · ⭐ 4.6',
          'Dept. Vault Official',
          _d,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.reference,
          'Database System Concepts — Silberschatz (Summary)',
          '64 pages · 9.2 MB · ⭐ 4.9',
          'Ananya S.',
          _b,
        ),
      ],
    ),
    SubjectInfo(
      name: 'Web Technology & Frameworks',
      shortName: 'Web Tech',
      code: 'CS503',
      type: 'DSE',
      semester: 5,
      course: _course,
      icon: Icons.language_rounded,
      color: AppColors.accentTeal,
      resources: [
        SubjectResource(
          ResourceCategory.labManual,
          'React & Node Practical File Solutions (Full)',
          '24 pages · 5.1 MB · 2024 · ⭐ 4.9',
          'Aditya K.',
          _l,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.notes,
          'Express.js & REST API Handwritten Notes',
          '20 pages · 6.3 MB · 2024 · ⭐ 4.8',
          'Sneha R.',
          _b,
        ),
        SubjectResource(
          ResourceCategory.pyq,
          'Web Technology End-Sem Paper (Dec 2023)',
          '8 pages · 1.4 MB · 2023 · ⭐ 4.6',
          'Academic Archive Team',
          _d,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.reference,
          'Full-Stack React Cheatsheet Bundle',
          '16 pages · 2.9 MB · ⭐ 4.7',
          'Aditya K.',
          _l,
        ),
      ],
    ),
    SubjectInfo(
      name: 'Computer Networks',
      shortName: 'CN',
      code: 'CS505',
      type: 'DSC',
      semester: 5,
      course: _course,
      icon: Icons.hub_rounded,
      color: AppColors.accentPurple,
      resources: [
        SubjectResource(
          ResourceCategory.notes,
          'Complete Computer Networks Unit 3 & 4 Handwritten Notes',
          '38 pages · 18.6 MB · 2024 · ⭐ 4.9',
          'Ananya S.',
          _d,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.pyq,
          'Computer Networks End-Sem Paper (Dec 2024)',
          '10 pages · 1.9 MB · 2024 · ⭐ 4.8',
          'Academic Archive Team',
          _d,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.labManual,
          'Packet Tracer Lab Manual & Viva Questions',
          '28 pages · 7.4 MB · 2024 · ⭐ 4.7',
          'Vikram T.',
          _l,
        ),
        SubjectResource(
          ResourceCategory.reference,
          'Computer Networking: A Top-Down Approach (Key Chapters)',
          '52 pages · 11.2 MB · ⭐ 4.8',
          'Ananya S.',
          _b,
        ),
      ],
    ),
    SubjectInfo(
      name: 'Software Engineering',
      shortName: 'SE',
      code: 'CS507',
      type: 'DSC',
      semester: 5,
      course: _course,
      icon: Icons.integration_instructions_rounded,
      color: AppColors.accentOrange,
      resources: [
        SubjectResource(
          ResourceCategory.notes,
          'Agile, Scrum & SDLC Models — Quick Revision Notes',
          '14 pages · 2.2 MB · 2024 · ⭐ 4.7',
          'Neha G.',
          _b,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.pyq,
          'Software Engineering End-Sem Paper (Dec 2024)',
          '8 pages · 1.3 MB · 2024 · ⭐ 4.6',
          'Academic Archive Team',
          _d,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.reference,
          'UML Diagrams Cheat Sheet with Examples',
          '10 pages · 3.1 MB · ⭐ 4.8',
          'Karan V.',
          _l,
        ),
      ],
    ),
    SubjectInfo(
      name: 'Cloud Computing & DevOps',
      shortName: 'Cloud & DevOps',
      code: 'CS509',
      type: 'DSE',
      semester: 5,
      course: _course,
      icon: Icons.cloud_outlined,
      color: AppColors.accentPink,
      resources: [
        SubjectResource(
          ResourceCategory.labManual,
          'Docker & Kubernetes Practical Lab Manual',
          '26 pages · 5.8 MB · 2024 · ⭐ 4.8',
          'Aditya K.',
          _l,
          verified: true,
        ),
        SubjectResource(
          ResourceCategory.notes,
          'AWS Core Services Notes (EC2, S3, IAM)',
          '22 pages · 4.0 MB · 2024 · ⭐ 4.7',
          'Meera P.',
          _b,
        ),
        SubjectResource(
          ResourceCategory.reference,
          'CI/CD Pipeline Guide with GitHub Actions',
          '12 pages · 2.4 MB · ⭐ 4.9',
          'Sneha R.',
          _d,
        ),
      ],
    ),
  ];
}
