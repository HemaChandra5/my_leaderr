class IssueCategory {
  const IssueCategory({
    required this.id,
    required this.title,
    required this.iconAssetPath,
    required this.semanticLabel,
  });

  final String id;
  final String title;
  final String iconAssetPath;
  final String semanticLabel;
}

class IssueCategoryCatalog {
  static const List<IssueCategory> all = <IssueCategory>[
    IssueCategory(
      id: 'roads',
      title: 'Roads',
      iconAssetPath: 'assets/issue_categories/roads.svg',
      semanticLabel: 'Road related issue',
    ),
    IssueCategory(
      id: 'water',
      title: 'Water',
      iconAssetPath: 'assets/issue_categories/water.svg',
      semanticLabel: 'Water related issue',
    ),
    IssueCategory(
      id: 'electricity',
      title: 'Electricity',
      iconAssetPath: 'assets/issue_categories/electricity.svg',
      semanticLabel: 'Electricity related issue',
    ),
    IssueCategory(
      id: 'drainage',
      title: 'Drainage',
      iconAssetPath: 'assets/issue_categories/drainage.svg',
      semanticLabel: 'Drainage related issue',
    ),
    IssueCategory(
      id: 'garbage',
      title: 'Garbage',
      iconAssetPath: 'assets/issue_categories/garbage.svg',
      semanticLabel: 'Garbage related issue',
    ),
    IssueCategory(
      id: 'health',
      title: 'Health',
      iconAssetPath: 'assets/issue_categories/health.svg',
      semanticLabel: 'Health related issue',
    ),
    IssueCategory(
      id: 'education',
      title: 'Education',
      iconAssetPath: 'assets/issue_categories/education.svg',
      semanticLabel: 'Education related issue',
    ),
    IssueCategory(
      id: 'real_estate',
      title: 'Real Estate',
      iconAssetPath: 'assets/issue_categories/real_estate.svg',
      semanticLabel: 'Real estate related issue',
    ),
    IssueCategory(
      id: 'traffic',
      title: 'Traffic',
      iconAssetPath: 'assets/issue_categories/traffic.svg',
      semanticLabel: 'Traffic related issue',
    ),
    IssueCategory(
      id: 'street_lights',
      title: 'Street Lights',
      iconAssetPath: 'assets/issue_categories/street_lights.svg',
      semanticLabel: 'Street lights related issue',
    ),
    IssueCategory(
      id: 'environment',
      title: 'Environment',
      iconAssetPath: 'assets/issue_categories/environment.svg',
      semanticLabel: 'Environment related issue',
    ),
    IssueCategory(
      id: 'public_safety',
      title: 'Public Safety',
      iconAssetPath: 'assets/issue_categories/public_safety.svg',
      semanticLabel: 'Public safety related issue',
    ),
    IssueCategory(
      id: 'other',
      title: 'Other',
      iconAssetPath: 'assets/issue_categories/other.svg',
      semanticLabel: 'Other issue category',
    ),
  ];
}
