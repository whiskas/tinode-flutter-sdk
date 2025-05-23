import 'package:tinode/src/models/topic-subscription.dart';
import 'package:tinode/src/models/delete-transaction.dart';
import 'package:tinode/src/models/topic-description.dart';
import 'package:tinode/src/models/access-mode.dart';
import 'package:tinode/src/models/credential.dart';

class ServerMessage {
  final CtrlMessage? ctrl;
  final MetaMessage? meta;
  final DataMessage? data;
  final PresMessage? pres;
  final InfoMessage? info;

  ServerMessage({this.ctrl, this.meta, this.data, this.pres, this.info});

  static ServerMessage fromMessage(Map<String, dynamic> msg) {
    return ServerMessage(
      ctrl: msg['ctrl'] != null ? CtrlMessage.fromMessage(msg['ctrl']) : null,
      meta: msg['meta'] != null ? MetaMessage.fromMessage(msg['meta']) : null,
      data: msg['data'] != null ? DataMessage.fromMessage(msg['data']) : null,
      pres: msg['pres'] != null ? PresMessage.fromMessage(msg['pres']) : null,
      info: msg['info'] != null ? InfoMessage.fromMessage(msg['info']) : null,
    );
  }
}

class CtrlMessage {
  /// Message Id
  final String? id;

  /// Related topic
  final String? topic;

  /// Message code
  final int? code;

  /// Message text
  final String? text;

  /// Message timestamp
  final DateTime? ts;

  final dynamic params;
  CtrlMessage({
    this.id,
    this.topic,
    this.code,
    this.text,
    this.ts,
    this.params,
  });

  static CtrlMessage fromMessage(Map<String, dynamic> msg) {
    return CtrlMessage(
      id: msg['id'],
      code: msg['code'],
      text: msg['text'],
      topic: msg['topic'],
      params: msg['params'],
      ts: msg['ts'],
    );
  }
}

class MetaMessage {
  /// Message Id
  final String? id;

  /// Related topic
  final String? topic;

  /// Message timestamp
  final DateTime? ts;

  /// Topic description, optional
  final TopicDescription? desc;

  ///  topic subscribers or user's subscriptions, optional
  final List<TopicSubscription>? sub;

  /// Array of tags that the topic or user (in case of "me" topic) is indexed by
  final List<String>? tags;

  /// Array of user's credentials
  final List<Credential>? cred;

  /// Latest applicable 'delete' transaction
  final DeleteTransaction? del;

  MetaMessage({this.id, this.topic, this.ts, this.desc, this.sub, this.tags, this.cred, this.del});

  static MetaMessage fromMessage(Map<String, dynamic> msg) {
    List<dynamic>? sub = msg['sub'];

    return MetaMessage(
      id: msg['id'],
      topic: msg['topic'],
      ts: msg['ts'],
      desc: msg['desc'] != null ? TopicDescription.fromMessage(msg['desc']) : null,
      sub: sub != null && sub.length != null ? sub.map((sub) => TopicSubscription.fromMessage(sub)).toList() : [],
      tags: msg['tags']?.cast<String>(),
      cred: msg['cred'] != null && msg['cred'].length > 0
          ? msg['cred'].map((dynamic cred) => Credential.fromMessage(cred)).toList().cast<Credential>()
          : [],
      del: msg['del'] != null ? DeleteTransaction.fromMessage(msg['del']) : null,
    );
  }
}

class DataMessage {
  /// topic which distributed this message
  final String? topic;

  /// id of the user who published the message; could be missing if the message was generated by the server
  final String? from;

  /// set of string key-value pairs, passed unchanged from {pub}, optional
  final Map<String, dynamic>? head;

  /// Timestamp
  final DateTime? ts;

  /// Server-issued sequential Id
  int? seq;

  /// object, application-defined content exactly as published by the user in the {pub} message
  final dynamic? content;

  bool? noForwarding = false;

  int? hi;

  DataMessage({
    this.topic,
    this.from,
    this.head,
    this.ts,
    this.seq,
    this.content,
    this.noForwarding,
    this.hi,
  });

  static DataMessage fromMessage(Map<String, dynamic> msg) {
    return DataMessage(
      topic: msg['topic'],
      from: msg['from'],
      head: msg['head'],
      ts: msg['ts'],
      seq: msg['seq'],
      content: msg['content'],
      noForwarding: msg['noForwarding'] ?? false,
      hi: msg['hi'],
    );
  }
}

class PresMessage {
  /// Topic which receives the notification, always present
  final String? topic;

  /// Topic or user affected by the change, always present
  final String? src;

  /// what's changed, always present
  final String? what;

  /// "what" is "msg", a server-issued Id of the message, optional
  int? seq;

  /// "what" is "del", an update to the delete transaction Id.
  final int? clear;

  /// Array of ranges, "what" is "del", ranges of Ids of deleted messages, optional
  final List<DeleteTransactionRange>? delseq;

  /// A User Agent string identifying client
  final String? ua;

  /// User who performed the action, optional
  final String? act;

  /// User affected by the action, optional
  final String? tgt;

  /// Changes to access mode, "what" is "acs", optional
  final AccessMode? acs;

  final AccessMode? dacs;

  PresMessage({
    this.topic,
    this.src,
    this.what,
    this.seq,
    this.clear,
    this.delseq,
    this.ua,
    this.act,
    this.tgt,
    this.acs,
    this.dacs,
  });

  static PresMessage fromMessage(Map<String, dynamic> msg) {
    return PresMessage(
      topic: msg['msg'],
      src: msg['src'],
      what: msg['what'],
      seq: msg['seq'],
      clear: msg['clear'],
      delseq:
          msg['delseq'] != null && msg['delseq'].length != null ? msg['delseq'].map((seq) => DeleteTransactionRange.fromMessage(seq)).toList() : [],
      ua: msg['ua'],
      act: msg['act'],
      tgt: msg['tgt'],
      acs: msg['acs'] != null ? AccessMode(msg['acs']) : null,
      dacs: msg['dacs'] != null ? AccessMode(msg['dacs']) : null,
    );
  }
}

class InfoMessage {
  /// topic affected, always present
  final String? topic;

  /// id of the user who published the message, always present
  final String? from;

  /// string, one of "kp", "recv", "read", see client-side {note},
  final String? what;

  /// ID of the message that client has acknowledged,
  /// guaranteed 0 < read <= recv <= {ctrl.params.seq}; present for rcpt & read
  final int? seq;

  InfoMessage({
    this.topic,
    this.from,
    this.what,
    this.seq,
  });

  static InfoMessage fromMessage(Map<String, dynamic> msg) {
    return InfoMessage(
      topic: msg['topic'],
      from: msg['from'],
      what: msg['what'],
      seq: msg['seq'],
    );
  }
}
