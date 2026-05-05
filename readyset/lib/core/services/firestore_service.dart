



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_models.dart';


class WorkoutBuilder {
  String? _id;
  String? _title;
  String? _userId;
  List<WorkoutExercise> _exercises = [];
  DateTime? _scheduledAt;
  int _durationMinutes = 0;
  bool _isCompleted = false;

  WorkoutBuilder setId(String id) { _id = id; return this; }
  WorkoutBuilder setTitle(String title) { _title = title; return this; }
  WorkoutBuilder setUserId(String uid) { _userId = uid; return this; }
  WorkoutBuilder setScheduledAt(DateTime dt) { _scheduledAt = dt; return this; }
  WorkoutBuilder setDurationMinutes(int min) { _durationMinutes = min; return this; }
  WorkoutBuilder setCompleted(bool completed) { _isCompleted = completed; return this; }

  WorkoutBuilder addExercise(WorkoutExercise exercise) {
    _exercises.add(exercise);
    return this;
  }

  WorkoutBuilder addExercises(List<WorkoutExercise> exercises) {
    _exercises.addAll(exercises);
    return this;
  }

  WorkoutSession build() {
    assert(_title != null, 'Workout must have a title');
    assert(_userId != null, 'Workout must have a userId');
    return WorkoutSession(
      id: _id ?? '',
      title: _title!,
      userId: _userId!,
      exercises: _exercises,
      scheduledAt: _scheduledAt ?? DateTime.now(),
      durationMinutes: _durationMinutes,
      isCompleted: _isCompleted,
    );
  }
}



class FirestoreAdapter {
  static UserProfile userFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      totalWorkouts: data['totalWorkouts'] ?? 0,
      dayStreak: data['dayStreak'] ?? 0,
      currentLevel: data['currentLevel'] ?? 'Beginner',
      levelProgress: (data['levelProgress'] ?? 0.0).toDouble(),
    );
  }

  static Map<String, dynamic> userToDoc(UserProfile user) => {
    'name': user.name,
    'email': user.email,
    'avatarUrl': user.avatarUrl,
    'totalWorkouts': user.totalWorkouts,
    'dayStreak': user.dayStreak,
    'currentLevel': user.currentLevel,
    'levelProgress': user.levelProgress,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static WorkoutSession workoutFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final exercisesList = (data['exercises'] as List<dynamic>? ?? [])
        .map((e) => _exerciseEntryFromMap(e as Map<String, dynamic>))
        .toList();
    return WorkoutSession(
      id: doc.id,
      title: data['title'] ?? '',
      userId: data['userId'] ?? '',
      exercises: exercisesList,
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  static Map<String, dynamic> workoutToDoc(WorkoutSession session) => {
    'title': session.title,
    'userId': session.userId,
    'exercises': session.exercises.map(_exerciseEntryToMap).toList(),
    'scheduledAt': Timestamp.fromDate(session.scheduledAt),
    'durationMinutes': session.durationMinutes,
    'isCompleted': session.isCompleted,
    'createdAt': FieldValue.serverTimestamp(),
  };

  static WorkoutExercise _exerciseEntryFromMap(Map<String, dynamic> m) {
    return WorkoutExercise(
      exerciseId: m['exerciseId'] ?? '',
      exerciseName: m['exerciseName'] ?? '',
      sets: (m['sets'] as List<dynamic>? ?? [])
          .map((s) => ExerciseSet(
                reps: s['reps'] ?? 0,
                weight: (s['weight'] ?? 0).toDouble(),
                isCompleted: s['isCompleted'] ?? false,
              ))
          .toList(),
    );
  }

  static Map<String, dynamic> _exerciseEntryToMap(WorkoutExercise e) => {
    'exerciseId': e.exerciseId,
    'exerciseName': e.exerciseName,
    'sets': e.sets.map((s) => {
      'reps': s.reps,
      'weight': s.weight,
      'isCompleted': s.isCompleted,
    }).toList(),
  };

  static ProgressData progressFromDocs(List<QueryDocumentSnapshot> docs) {
    
    final completedDocs = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['isCompleted'] == true;
    }).toList();

    double totalVolume = 0;
    for (final doc in completedDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final exercises = (data['exercises'] as List<dynamic>? ?? []);
      for (final ex in exercises) {
        final sets = (ex['sets'] as List<dynamic>? ?? []);
        for (final s in sets) {
          totalVolume += (s['weight'] ?? 0) * (s['reps'] ?? 0);
        }
      }
    }

    return ProgressData(
      strengthData: [65, 70, 68, 75, 72, 80, 85, 82, 88, 92, 95, 100],
      strengthGainPercent: 14.5,
      avgSessionsPerWeek: completedDocs.length / 4.0,
      prsHit: (completedDocs.length * 0.3).round(),
      totalVolumeTons: (totalVolume / 1000).round(),
      streakDays: 7,
      weightKg: 78,
      recentMilestones: [
        Milestone(title: '100kg Squat', date: 'May 1', icon: '🏋️'),
        Milestone(title: '5 Day Streak', date: 'Apr 28', icon: '🔥'),
        Milestone(title: '50 Workouts', date: 'Apr 20', icon: '⭐'),
      ],
    );
  }

  static SocialPost socialPostFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      content: data['content'] ?? '',
      workoutTitle: data['workoutTitle'],
      likes: data['likes'] ?? 0,
      likedByCurrentUser: false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> socialPostToDoc(SocialPost post) => {
    'userId': post.userId,
    'userName': post.userName,
    'userAvatarUrl': post.userAvatarUrl,
    'content': post.content,
    'workoutTitle': post.workoutTitle,
    'likes': post.likes,
    'createdAt': FieldValue.serverTimestamp(),
  };
}


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  
  Future<void> createUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
      FirestoreAdapter.userToDoc(profile),
      SetOptions(merge: true),
    );
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return FirestoreAdapter.userFromDoc(snap);
    });
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).update(
      FirestoreAdapter.userToDoc(profile),
    );
  }

  
  Future<String> saveWorkout(WorkoutSession session) async {
    final doc = await _db.collection('workouts').add(
      FirestoreAdapter.workoutToDoc(session),
    );
    return doc.id;
  }

  Stream<List<WorkoutSession>> watchUserWorkouts() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('workouts')
        .where('userId', isEqualTo: _uid)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreAdapter.workoutFromDoc).toList());
  }

  Future<void> completeWorkout(String workoutId, int durationMinutes) async {
    await _db.collection('workouts').doc(workoutId).update({
      'isCompleted': true,
      'durationMinutes': durationMinutes,
      'completedAt': FieldValue.serverTimestamp(),
    });
    
    if (_uid != null) {
      await _db.collection('users').doc(_uid).update({
        'totalWorkouts': FieldValue.increment(1),
      });
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _db.collection('workouts').doc(workoutId).delete();
  }

  
  Stream<ProgressData> watchProgress() {
    if (_uid == null) return Stream.value(_defaultProgress());
    return _db
        .collection('workouts')
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snap) => FirestoreAdapter.progressFromDocs(snap.docs));
  }

  ProgressData _defaultProgress() => ProgressData(
    strengthData: [60, 65, 70, 68, 75, 80, 85],
    strengthGainPercent: 0,
    avgSessionsPerWeek: 0,
    prsHit: 0,
    totalVolumeTons: 0,
    streakDays: 0,
    weightKg: 0,
    recentMilestones: [],
  );

  
  Stream<List<SocialPost>> watchSocialFeed() {
    return _db
        .collection('social_posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreAdapter.socialPostFromDoc).toList());
  }

  Future<void> createPost(SocialPost post) async {
    await _db.collection('social_posts').add(FirestoreAdapter.socialPostToDoc(post));
  }

  Future<void> likePost(String postId) async {
    await _db.collection('social_posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> followUser(String targetUserId) async {
    if (_uid == null) return;
    final batch = _db.batch();
    batch.set(
      _db.collection('follows').doc('${_uid}_$targetUserId'),
      {'followerId': _uid, 'followingId': targetUserId, 'createdAt': FieldValue.serverTimestamp()},
    );
    batch.update(_db.collection('users').doc(targetUserId), {
      'followerCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  
  Future<void> saveTemplate(WorkoutTemplate template) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('templates').doc(template.id).set(
      _templateToDoc(template),
    );
  }

  Stream<List<WorkoutTemplate>> watchTemplates() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('templates')
        .snapshots()
        .map((snap) => snap.docs.map(_templateFromDoc).toList());
  }

  Future<void> deleteTemplate(String templateId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('templates').doc(templateId).delete();
  }

  WorkoutTemplate _templateFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final exercisesList = (data['exercises'] as List<dynamic>? ?? [])
        .map((e) => FirestoreAdapter._exerciseEntryFromMap(e as Map<String, dynamic>))
        .toList();
    return WorkoutTemplate(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      exercises: exercisesList,
      estimatedDurationMinutes: data['estimatedDurationMinutes'] ?? 0,
      targetFocus: data['targetFocus'] ?? 'All',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isDraft: data['isDraft'] ?? true,
    );
  }

  Map<String, dynamic> _templateToDoc(WorkoutTemplate template) => {
    'userId': template.userId,
    'name': template.name,
    'description': template.description,
    'exercises': template.exercises.map(FirestoreAdapter._exerciseEntryToMap).toList(),
    'estimatedDurationMinutes': template.estimatedDurationMinutes,
    'targetFocus': template.targetFocus,
    'createdAt': Timestamp.fromDate(template.createdAt),
    'updatedAt': Timestamp.fromDate(template.updatedAt ?? DateTime.now()),
    'isDraft': template.isDraft,
  };
}