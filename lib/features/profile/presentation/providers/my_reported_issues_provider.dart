import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/reported_issue_case.dart';
import '../../domain/repositories/reported_issues_repository.dart';

class MyReportedIssuesProvider extends ChangeNotifier {
  MyReportedIssuesProvider({required this.repository});

  final ReportedIssuesRepository repository;

  StreamSubscription<List<ReportedIssueCase>>? _subscription;

  List<ReportedIssueCase> _issues = const <ReportedIssueCase>[];
  bool _loading = true;
  String? _error;
  String _search = '';
  final Set<String> _filters = <String>{'All'};

  List<ReportedIssueCase> get issues => _issues;
  bool get isLoading => _loading;
  String? get error => _error;
  String get search => _search;
  Set<String> get filters => _filters;

  void initialize(String userId) {
    _subscription?.cancel();
    _loading = true;
    _error = null;
    notifyListeners();

    _subscription = repository.watchByUser(userId).listen(
      (List<ReportedIssueCase> data) {
        _issues = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = 'Unable to load reported issues.';
        notifyListeners();
      },
    );
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleFilter(String filter) {
    if (filter == 'All') {
      _filters
        ..clear()
        ..add('All');
      notifyListeners();
      return;
    }

    _filters.remove('All');
    if (_filters.contains(filter)) {
      _filters.remove(filter);
    } else {
      _filters.add(filter);
    }

    if (_filters.isEmpty) {
      _filters.add('All');
    }
    notifyListeners();
  }

  List<ReportedIssueCase> get filteredIssues {
    Iterable<ReportedIssueCase> data = _issues;

    final String q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      data = data.where((ReportedIssueCase issue) {
        return issue.issueId.toLowerCase().contains(q) ||
            issue.category.toLowerCase().contains(q) ||
            issue.location.toLowerCase().contains(q) ||
            issue.department.toLowerCase().contains(q);
      });
    }

    if (!_filters.contains('All')) {
      data = data.where((ReportedIssueCase issue) {
        for (final String filter in _filters) {
          if (_matchesFilter(issue, filter)) {
            return true;
          }
        }
        return false;
      });
    }

    return data.toList(growable: false);
  }

  int get totalRequests => _issues.length;

  int get inProgressCount {
    return _issues.where((ReportedIssueCase e) {
      final String s = e.status.toLowerCase();
      return s == 'work started' || s == 'work in progress' || s == 'inspection';
    }).length;
  }

  int get resolvedCount {
    return _issues.where((ReportedIssueCase e) {
      final String s = e.status.toLowerCase();
      return s == 'completed' || s == 'citizen verified';
    }).length;
  }

  int get pendingCount {
    return _issues.where((ReportedIssueCase e) {
      final String s = e.status.toLowerCase();
      return s == 'issue created' || s == 'assigned';
    }).length;
  }

  bool _matchesFilter(ReportedIssueCase issue, String filter) {
    final String f = filter.toLowerCase();
    final String category = issue.category.toLowerCase();
    final String status = issue.status.toLowerCase();

    if (f == 'active') {
      return status != 'completed' && status != 'citizen verified';
    }
    if (f == 'completed') {
      return status == 'completed' || status == 'citizen verified';
    }

    return category.contains(f);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
