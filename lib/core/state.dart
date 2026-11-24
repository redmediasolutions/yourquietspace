import 'dart:async';

import 'package:flutter/foundation.dart';


import 'widgets.dart';

// ───────────────────────────── Models ─────────────────────────────

class Therapist {
  final String id;
  final String name;
  final String short; // "Dr. Maya"
  final String title;
  final List<String> focus;
  final int years;
  final List<String> languages;
  final String intro;
  final String bio;
  final String approach;
  final String response;
  Presence presence;
  final String lastActive;
  final int activeClients;
  bool enabled;

  Therapist({
    required this.id,
    required this.name,
    required this.short,
    required this.title,
    required this.focus,
    required this.years,
    required this.languages,
    required this.intro,
    required this.bio,
    required this.approach,
    required this.response,
    required this.presence,
    required this.lastActive,
    required this.activeClients,
    this.enabled = true,
  });

  String get initials {
    final n = name.replaceAll('Dr. ', '').split(' ');
    return n.length > 1 ? '${n[0][0]}${n[1][0]}' : n[0][0];
  }
}

enum MsgStatus { sending, sent, delivered, read, failed }

class Msg {
  final String id;
  final String text;
  final bool mine;
  final DateTime at;
  MsgStatus status;
  final bool system;

  Msg({required this.id, required this.text, required this.mine, required this.at, this.status = MsgStatus.read, this.system = false});
}

enum ConvState { empty, active, ending, closed, reassigned }

class MoodEntry {
  final DateTime at;
  final int value; // 0..4
  final String? note;

  const MoodEntry(this.at, this.value, [this.note]);
}

const moodLabels = ['Very low', 'Low', 'Okay', 'Good', 'Very good'];

class JournalEntry {
  final String id;
  String title;
  String body;
  final DateTime created;
  DateTime edited;

  JournalEntry({required this.id, required this.title, required this.body, required this.created, required this.edited});
}

class Note {
  final String client;
  final String text;
  final DateTime at;

  const Note(this.client, this.text, this.at);
}

enum ClientStatus { waiting, active, closed }

class ClientConv {
  final String nickname;
  final String last;
  final String time;
  int unread;
  ClientStatus status;
  final bool priority;
  final List<String> concerns;
  final String ageRange;
  final String since;
  final String assignedTo;

  ClientConv({
    required this.nickname,
    required this.last,
    required this.time,
    this.unread = 0,
    this.status = ClientStatus.active,
    this.priority = false,
    required this.concerns,
    required this.ageRange,
    required this.since,
    required this.assignedTo,
  });
}

enum ReportStatus { fresh, reviewing, resolved }

class Report {
  final String id;
  final String reporter;
  final String subject;
  final String reason;
  final String when;
  ReportStatus status;

  Report(this.id, this.reporter, this.subject, this.reason, this.when, this.status);
}

class AppNotification {
  final String kind; // message | available | mood | journal | system
  final String title;
  final String body;
  final String time;
  final bool unread;

  const AppNotification(this.kind, this.title, this.body, this.time, {this.unread = false});
}

// ───────────────────────────── Config ─────────────────────────────

/// Emergency information is configurable (set by admins per region).
class EmergencyConfig {
  static const region = 'India';
  static const primaryName = 'Emergency services';
  static const primaryNumber = '112';
  static const lines = [
    ('Tele-MANAS', '14416', '24×7 · Free · Government mental health helpline'),
    ('Tele-MANAS (toll-free)', '1-800-891-4416', 'Same service, alternate number'),
  ];
}

// ───────────────────────────── App state ─────────────────────────────

/// Single in-memory store for the demo. Frontend only — no backend.
class AppState extends ChangeNotifier {
  AppState._() {
    _seed();
  }

  static final AppState I = AppState._();

  // Client identity
  String nickname = 'QuietMind55';
  String? ageRange = '25–34';
  final Set<String> concerns = {'Stress', 'Sleep'};
  String story = '';

  // Matching / conversation
  late final List<Therapist> therapists;
  late Therapist assigned;
  final List<Msg> messages = [];
  final List<Msg> _history = [];
  ConvState conv = ConvState.active;
  bool networkOnline = true;
  bool therapistTyping = false;
  int unreadFromTherapist = 0;

  // Wellbeing
  final List<MoodEntry> moods = [];
  final List<JournalEntry> journal = [];

  // Notifications
  bool notifyMessages = true;
  bool notifyMood = true;
  bool notifyJournal = false;
  bool hidePreviews = true;
  bool appLock = false;

  // Therapist side
  Presence myPresence = Presence.online;
  final List<ClientConv> clients = [];
  final List<Note> notes = [];
  final List<Msg> therapistThread = [];

  // Admin side
  final List<Report> reports = [];

  final notifications = const <AppNotification>[
    AppNotification('message', 'New message from Dr. Maya', 'Message preview hidden for privacy', '2m', unread: true),
    AppNotification('available', 'Dr. Maya is available', 'Your therapist is online now.', '18m', unread: true),
    AppNotification('mood', 'A gentle check-in', 'How are you feeling this evening?', '1h'),
    AppNotification('journal', 'Journal reminder', 'A few lines can help settle the day.', 'Yesterday'),
    AppNotification('system', 'Privacy update', 'Messages now auto-lock when the app is in the background.', 'Mon'),
  ];

  int _id = 0;
  String _next() => 'm${_id++}';

  void _seed() {
    therapists = [
      Therapist(
        id: 't1',
        name: 'Dr. Maya Raman',
        short: 'Dr. Maya',
        title: 'Licensed Therapist',
        focus: ['Stress', 'Anxiety', 'Sleep'],
        years: 9,
        languages: ['English', 'Hindi', 'Kannada'],
        intro: 'I help people slow down racing thoughts and find steadier ground — at whatever pace feels right.',
        bio:
            'I\'ve spent nine years working with adults through stress, anxious thinking and disrupted sleep. Before private practice I worked in a university counselling centre, which taught me how much it helps to simply be listened to without judgement.',
        approach:
            'Warm and practical. I draw on CBT and acceptance-based approaches, and we\'ll always start with what matters most to you right now. No homework you didn\'t agree to.',
        response: 'Usually within a few minutes',
        presence: Presence.online,
        lastActive: 'Active now',
        activeClients: 8,
      ),
      Therapist(
        id: 't2',
        name: 'Dr. Ishaan Varma',
        short: 'Dr. Ishaan',
        title: 'Counselling Psychologist',
        focus: ['Relationships', 'Family', 'Loneliness'],
        years: 12,
        languages: ['English', 'Hindi'],
        intro: 'Relationships shape how we feel about ourselves. I help untangle the patterns that keep repeating.',
        bio: 'Twelve years supporting individuals through family conflict, breakups and isolation.',
        approach: 'Relational and reflective, with space to think out loud.',
        response: 'Usually within an hour',
        presence: Presence.away,
        lastActive: '24 min ago',
        activeClients: 11,
      ),
      Therapist(
        id: 't3',
        name: 'Leah Fernandes',
        short: 'Leah',
        title: 'Licensed Therapist',
        focus: ['Work', 'Confidence', 'Stress'],
        years: 6,
        languages: ['English', 'Konkani'],
        intro: 'For when work feels like everything. Let\'s find some room to breathe.',
        bio: 'Former HR professional turned therapist, focused on burnout and self-doubt.',
        approach: 'Solution-focused, gently direct.',
        response: 'Usually within 30 minutes',
        presence: Presence.online,
        lastActive: 'Active now',
        activeClients: 6,
      ),
      Therapist(
        id: 't4',
        name: 'Dr. Arun Nair',
        short: 'Dr. Arun',
        title: 'Clinical Psychologist',
        focus: ['Anxiety', 'Family', 'Grief'],
        years: 15,
        languages: ['English', 'Malayalam', 'Tamil'],
        intro: 'Steady, patient support through the harder chapters.',
        bio: 'Fifteen years in clinical and community settings.',
        approach: 'Integrative and paced by you.',
        response: 'Usually within a few hours',
        presence: Presence.offline,
        lastActive: '3 h ago',
        activeClients: 9,
      ),
      Therapist(
        id: 't5',
        name: 'Sana Qureshi',
        short: 'Sana',
        title: 'Licensed Therapist',
        focus: ['Sleep', 'Loneliness', 'Confidence'],
        years: 5,
        languages: ['English', 'Urdu', 'Hindi'],
        intro: 'Small, kind steps. Especially for the 2 a.m. thoughts.',
        bio: 'Specialises in sleep and evening anxiety.',
        approach: 'Mindfulness-informed and practical.',
        response: 'Usually within 30 minutes',
        presence: Presence.online,
        lastActive: 'Active now',
        activeClients: 5,
      ),
    ];
    assigned = therapists.first;

    final now = DateTime.now();
    DateTime ago(int days, int h, int m) =>
        DateTime(now.year, now.month, now.day, h, m).subtract(Duration(days: days));

    _history.addAll([
      Msg(id: _next(), text: 'Hi, I\'m Maya. Thank you for reaching out — that takes something. There\'s no rush here. What\'s been on your mind lately?', mine: false, at: ago(1, 21, 4)),
      Msg(id: _next(), text: 'Hi. I don\'t really know where to start. Work has been a lot and I haven\'t been sleeping properly for a few weeks.', mine: true, at: ago(1, 21, 9)),
      Msg(id: _next(), text: 'That makes sense as a starting point. When you say not sleeping properly — is it hard to fall asleep, or do you wake up during the night?', mine: false, at: ago(1, 21, 11)),
      Msg(id: _next(), text: 'Falling asleep. My mind just keeps replaying the day. Things I said in meetings, things I forgot.', mine: true, at: ago(1, 21, 15)),
      Msg(id: _next(), text: 'A lot of people describe that exact loop. Your mind is trying to "finish" the day before it lets you rest. We can work on giving it somewhere else to put those thoughts.', mine: false, at: ago(1, 21, 18)),
      Msg(id: _next(), text: 'Tonight, if you\'d like, try writing down three things from the day — just a line each — before you get into bed. Let me know how it goes. 🌙', mine: false, at: ago(1, 21, 19)),
      Msg(id: _next(), text: 'I tried it. Fell asleep a bit faster, I think. Still woke up at 4 though.', mine: true, at: ago(0, 18, 2)),
      Msg(id: _next(), text: 'That\'s genuinely a good sign — noticing a change at all matters. Let\'s talk about the 4 a.m. part. What usually happens when you wake up?', mine: false, at: ago(0, 18, 21)),
    ]);
    messages.addAll(_history.map(_copy));
    unreadFromTherapist = 1;

    moods.addAll([
      MoodEntry(ago(13, 21, 0), 1), MoodEntry(ago(12, 21, 0), 1), MoodEntry(ago(11, 21, 0), 2),
      MoodEntry(ago(10, 21, 0), 1), MoodEntry(ago(9, 21, 0), 2), MoodEntry(ago(8, 21, 0), 2),
      MoodEntry(ago(7, 21, 0), 1), MoodEntry(ago(6, 21, 0), 1, 'Long day. Deadline moved up.'),
      MoodEntry(ago(5, 21, 0), 2), MoodEntry(ago(4, 21, 0), 2), MoodEntry(ago(3, 21, 0), 3, 'Walked home instead of the bus.'),
      MoodEntry(ago(2, 21, 0), 2), MoodEntry(ago(1, 21, 0), 3, 'Talked to Maya. Felt lighter.'),
    ]);

    journal.addAll([
      JournalEntry(
        id: 'j1',
        title: 'Three things from today',
        body:
            'The review meeting went fine. I spent all morning dreading it and it took twelve minutes.\n\nI forgot to reply to Anjali. I\'ll do it tomorrow — it\'s not urgent, even though my brain says it is.\n\nThe chai at the corner place was good. I want to notice more things like that.',
        created: ago(1, 23, 12),
        edited: ago(1, 23, 12),
      ),
      JournalEntry(
        id: 'j2',
        title: '',
        body:
            'Couldn\'t sleep again. Wrote this at 4 a.m. Everything feels heavier at this hour. Reminding myself that it usually looks different by lunchtime.',
        created: ago(3, 4, 6),
        edited: ago(3, 4, 6),
      ),
      JournalEntry(
        id: 'j3',
        title: 'Why I signed up',
        body:
            'I\'ve been telling myself I\'m fine for months. I\'m not in crisis, I just feel tired all the time and a bit far away from everyone. Maybe talking to someone who doesn\'t know me will be easier.',
        created: ago(6, 22, 40),
        edited: ago(6, 22, 40),
      ),
    ]);

    clients.addAll([
      ClientConv(nickname: 'QuietMind55', last: 'I\'ve been unable to sleep again…', time: '2 min', unread: 2, priority: false, concerns: ['Stress', 'Sleep'], ageRange: '25–34', since: '6 days', assignedTo: 'Dr. Maya Raman'),
      ClientConv(nickname: 'NightOwl_08', last: 'Can we talk tonight? It\'s been a hard day.', time: '9 min', unread: 1, status: ClientStatus.waiting, priority: true, concerns: ['Anxiety', 'Loneliness'], ageRange: '18–24', since: 'New', assignedTo: 'Dr. Maya Raman'),
      ClientConv(nickname: 'StillWater21', last: 'Thank you. That helped more than I expected.', time: '1 h', concerns: ['Work'], ageRange: '35–44', since: '3 weeks', assignedTo: 'Dr. Maya Raman'),
      ClientConv(nickname: 'PaperBoat3', last: 'You: Let\'s pick this up on Thursday.', time: '3 h', concerns: ['Relationships', 'Family'], ageRange: '25–34', since: '2 weeks', assignedTo: 'Dr. Maya Raman'),
      ClientConv(nickname: 'GreyFog12', last: 'Hi, I\'m not sure how this works.', time: '4 h', unread: 1, status: ClientStatus.waiting, concerns: ['Something else'], ageRange: 'Prefer not to say', since: 'New', assignedTo: 'Dr. Maya Raman'),
      ClientConv(nickname: 'Ember_Lane', last: 'Session closed', time: 'Mon', status: ClientStatus.closed, concerns: ['Confidence'], ageRange: '18–24', since: '2 months', assignedTo: 'Dr. Maya Raman'),
    ]);

    therapistThread.addAll(_history.map((m) => Msg(id: _next(), text: m.text, mine: !m.mine, at: m.at)));
    therapistThread.add(Msg(id: _next(), text: 'Usually around 4. I just lie there and start planning the next day.', mine: false, at: ago(0, 18, 40)));
    therapistThread.add(Msg(id: _next(), text: 'I\'ve been unable to sleep again…', mine: false, at: ago(0, 18, 41)));

    notes.addAll([
      Note('QuietMind55', 'Client mentioned difficulty falling asleep — rumination about work interactions. Suggested 3-line evening offload. Follow up on early waking (~4 a.m.).', ago(1, 21, 30)),
      Note('QuietMind55', 'Reported slight improvement with sleep onset. Early waking persists. Explore pre-sleep routine next session.', ago(0, 18, 25)),
    ]);

    reports.addAll([
      Report('R-1042', 'PaperBoat3', 'Conversation · Dr. Ishaan Varma', 'Felt responses were dismissive', '12 min ago', ReportStatus.fresh),
      Report('R-1041', 'Dr. Leah Fernandes', 'Client · Ember_Lane', 'Abusive language in chat', '2 h ago', ReportStatus.reviewing),
      Report('R-1038', 'NightOwl_08', 'Conversation · Dr. Arun Nair', 'Therapist unresponsive for 2 days', 'Yesterday', ReportStatus.reviewing),
      Report('R-1031', 'StillWater21', 'App · Notifications', 'Message preview showed on lock screen', 'Mon', ReportStatus.resolved),
      Report('R-1027', 'GreyFog12', 'Conversation · Sana Qureshi', 'Wanted a different therapist', '28 Oct', ReportStatus.resolved),
    ]);
  }

  // ── Client actions ──

  /// Index in [messages] where the "New messages" divider sits (null = none).
  int? unreadDividerAt;

  void markRead() {
    if (unreadFromTherapist != 0) {
      unreadDividerAt = (messages.length - unreadFromTherapist).clamp(0, messages.length);
      unreadFromTherapist = 0;
      notifyListeners();
    }
  }

  void setNetwork(bool online) {
    networkOnline = online;
    notifyListeners();
  }

  void setConv(ConvState s) {
    conv = s;
    if (s == ConvState.empty) {
      messages.clear();
    }
    notifyListeners();
  }

  void setTherapistPresence(Presence p) {
    assigned.presence = p;
    notifyListeners();
  }

  Timer? _replyTimer;

  void send(String text) {
    final m = Msg(id: _next(), text: text, mine: true, at: DateTime.now(), status: MsgStatus.sending);
    messages.add(m);
    unreadDividerAt = null;
    if (conv == ConvState.empty || conv == ConvState.reassigned) conv = ConvState.active;
    notifyListeners();
    _deliver(m);
  }

  void retry(Msg m) {
    m.status = MsgStatus.sending;
    notifyListeners();
    _deliver(m);
  }

  void _deliver(Msg m) {
    if (!networkOnline) {
      Future.delayed(const Duration(milliseconds: 900), () {
        m.status = MsgStatus.failed;
        notifyListeners();
      });
      return;
    }
    Future.delayed(const Duration(milliseconds: 600), () {
      m.status = MsgStatus.sent;
      notifyListeners();
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      m.status = MsgStatus.delivered;
      notifyListeners();
    });
    if (assigned.presence != Presence.online) return;
    Future.delayed(const Duration(milliseconds: 2300), () {
      m.status = MsgStatus.read;
      therapistTyping = true;
      notifyListeners();
    });
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 5200), () {
      therapistTyping = false;
      messages.add(Msg(
        id: _next(),
        text: _replies[_replyIndex++ % _replies.length],
        mine: false,
        at: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  int _replyIndex = 0;
  static const _replies = [
    'Thank you for telling me that. Take your time — I\'m here.',
    'That sounds really tiring. What does the rest of your evening usually look like?',
    'I hear you. Would it help to try something small together tonight?',
    'It makes sense that you\'d feel that way. You\'re not doing anything wrong by struggling with this.',
  ];

  void addMood(int value, String? note) {
    moods.add(MoodEntry(DateTime.now(), value, note));
    notifyListeners();
  }

  MoodEntry? get todayMood {
    final now = DateTime.now();
    for (final m in moods.reversed) {
      if (m.at.year == now.year && m.at.month == now.month && m.at.day == now.day) return m;
    }
    return null;
  }

  JournalEntry saveJournal({String? id, required String title, required String body}) {
    if (id != null) {
      final e = journal.firstWhere((j) => j.id == id);
      e.title = title;
      e.body = body;
      e.edited = DateTime.now();
      notifyListeners();
      return e;
    }
    final e = JournalEntry(id: 'j${DateTime.now().microsecondsSinceEpoch}', title: title, body: body, created: DateTime.now(), edited: DateTime.now());
    journal.insert(0, e);
    notifyListeners();
    return e;
  }

  void deleteJournal(String id) {
    journal.removeWhere((j) => j.id == id);
    notifyListeners();
  }

  Msg _copy(Msg m) => Msg(id: _next(), text: m.text, mine: m.mine, at: m.at, status: m.status);

  /// Demo: restore the long seeded conversation.
  void loadHistory() {
    messages
      ..clear()
      ..addAll(_history.map(_copy));
    conv = ConvState.active;
    notifyListeners();
  }

  Timer? _greetTimer;

  /// A brand-new conversation after matching: empty, then the therapist says hello.
  void startFresh(Therapist t) {
    assigned = t;
    messages.clear();
    conv = ConvState.empty;
    unreadFromTherapist = 0;
    notifyListeners();
    if (t.presence != Presence.online) return;
    _greetTimer?.cancel();
    _greetTimer = Timer(const Duration(milliseconds: 1800), () {
      therapistTyping = true;
      notifyListeners();
      _greetTimer = Timer(const Duration(milliseconds: 2600), () {
        therapistTyping = false;
        messages.add(Msg(
          id: _next(),
          text: 'Hi $nickname, I\'m ${t.short.replaceAll('Dr. ', '')}. Thank you for reaching out — I\'ve read what you shared. There\'s no rush here. Where would you like to begin?',
          mine: false,
          at: DateTime.now(),
        ));
        if (conv == ConvState.empty) conv = ConvState.active;
        unreadFromTherapist++;
        notifyListeners();
      });
    });
  }

  Therapist? previous;

  /// Conversation moved to another therapist (by admin or on request).
  void reassignTo(Therapist t) {
    previous = assigned;
    assigned = t;
    messages.clear();
    unreadDividerAt = null;
    conv = ConvState.reassigned;
    notifyListeners();
  }

  void update() => notifyListeners();

  // ── Therapist actions ──

  void setMyPresence(Presence p) {
    myPresence = p;
    notifyListeners();
  }

  void addNote(String client, String text) {
    notes.add(Note(client, text, DateTime.now()));
    notifyListeners();
  }

  final Map<String, List<Msg>> _threads = {};

  /// Therapist-side thread for a client (QuietMind55 mirrors the client demo).
  List<Msg> threadFor(String nickname) {
    if (nickname == demoClient && therapistThread.isNotEmpty) return therapistThread;
    return _threads.putIfAbsent(nickname, () {
      final c = clients.firstWhere((x) => x.nickname == nickname);
      final now = DateTime.now();
      final last = c.last.startsWith('You: ');
      return [
        Msg(id: _next(), text: 'Hi, I\'m ${c.nickname}. I\'ve been dealing with ${c.concerns.first.toLowerCase()} and wanted to talk to someone.', mine: false, at: now.subtract(const Duration(hours: 5))),
        if (c.status != ClientStatus.waiting)
          Msg(id: _next(), text: 'Thank you for reaching out. I\'m glad you\'re here. Tell me a little about what\'s been happening.', mine: true, at: now.subtract(const Duration(hours: 4, minutes: 50))),
        Msg(id: _next(), text: last ? c.last.substring(5) : c.last, mine: last, at: now.subtract(const Duration(minutes: 9))),
      ];
    });
  }

  static const demoClient = 'QuietMind55';

  void therapistSend(String text, [String client = demoClient]) {
    final m = Msg(id: _next(), text: text, mine: true, at: DateTime.now(), status: MsgStatus.sending);
    threadFor(client).add(m);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 600), () {
      m.status = MsgStatus.delivered;
      notifyListeners();
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      m.status = MsgStatus.read;
      notifyListeners();
    });
  }

  void closeClient(String nickname) {
    for (final c in clients) {
      if (c.nickname == nickname) {
        c.status = ClientStatus.closed;
        c.unread = 0;
      }
    }
    notifyListeners();
  }
}

/// Convenience accessor.
AppState get app => AppState.I;
