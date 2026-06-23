import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';
import 'package:speehive_social/domain/entities/post_draft.dart';

class DraftStorageService {
  static const String _draftsKey = 'post_drafts';
  final SecureStorageService _storage;

  DraftStorageService(this._storage);

  Future<List<PostDraft>> getDrafts() async {
    final data = await _storage.readSecure(_draftsKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList
          .map((e) => PostDraft.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[DRAFTS] Failed to parse drafts: $e');
      return [];
    }
  }

  Future<void> saveDraft(PostDraft draft) async {
    final drafts = await getDrafts();
    final index = drafts.indexWhere((d) => d.id == draft.id);

    if (index >= 0) {
      drafts[index] = draft;
    } else {
      drafts.add(draft);
    }

    await _saveDrafts(drafts);
  }

  Future<void> deleteDraft(String draftId) async {
    final drafts = await getDrafts();
    drafts.removeWhere((d) => d.id == draftId);
    await _saveDrafts(drafts);
  }

  Future<void> updateDraftStatus(String draftId, DraftStatus status) async {
    final drafts = await getDrafts();
    final index = drafts.indexWhere((d) => d.id == draftId);

    if (index >= 0) {
      drafts[index] = drafts[index].copyWith(status: status);
      if (status == DraftStatus.published) {
        drafts[index] = drafts[index].copyWith(publishedAt: DateTime.now());
      }
      await _saveDrafts(drafts);
    }
  }

  Future<void> markAsPublished(String draftId, String linkedinPostId) async {
    final drafts = await getDrafts();
    final index = drafts.indexWhere((d) => d.id == draftId);

    if (index >= 0) {
      drafts[index] = drafts[index].copyWith(
        status: DraftStatus.published,
        linkedinPostId: linkedinPostId,
        publishedAt: DateTime.now(),
      );
      await _saveDrafts(drafts);
    }
  }

  Future<List<PostDraft>> getPendingDrafts() async {
    final drafts = await getDrafts();
    return drafts.where((d) => d.status == DraftStatus.pending).toList();
  }

  Future<int> getPendingCount() async {
    final pending = await getPendingDrafts();
    return pending.length;
  }

  Future<void> _saveDrafts(List<PostDraft> drafts) async {
    final jsonList = drafts.map((d) => d.toJson()).toList();
    await _storage.saveSecure(_draftsKey, json.encode(jsonList));
  }
}
