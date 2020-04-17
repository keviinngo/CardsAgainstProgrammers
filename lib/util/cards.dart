import 'dart:async';
import 'dart:convert';

import 'dart:io';

const apiRoot = 'https://cap.thebirk.net';

/// A cards and its [id] and [text]
class Card {
  final int id;
  final String text;
  final int blanks;

  bool get isQuestion {
    return blanks > 0;
  }

  /// Create a new card with [id] and [text]
  Card(this.id, this.text, this.blanks);

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(json['id'], json['text'], json['blanks']);
  }
}

class Deck {
  final int id;
  final String title;
  final String description;

  Deck(this.id, this.title, this.description);

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(json['id'], json['title'], json['description']);
  }
}

Future<Map<String, dynamic>> fetchJson(Uri url) async {
  Completer<Map<String, dynamic>> completer = new Completer();
  HttpClient()
    .getUrl(url)
    .then((req) => req.close())
    .then((resp) {
      if (!resp.headers.contentType.toString().startsWith('application/json')) {
        completer.complete(null);
        throw "fetchJson() for " + url.toString() + " did not return a Json contentType. Got " + resp.headers.contentType.toString();
      }
      StringBuffer sb = StringBuffer();
      resp.transform(Utf8Decoder()).listen((value) {
        sb.write(value);
      }, onDone: () {
        completer.complete(jsonDecode(sb.toString()));
      });
    })
    .catchError((obj) {
      return null;
    });

    return completer.future;
}

Future<List<Deck>> getAllDecks() async {
  List<Deck> result = [];

  var json = await fetchJson(Uri.parse(apiRoot+'/deck/alldecks/'));

  for (var card in json['decks']) {
    result.add(Deck.fromJson(card));
  }

  return result;
}

Future<List<Card>> getAllCardsInDeck(Deck deck) async {
  List<Card> result = [];

  var json = await fetchJson(Uri.parse(apiRoot+'/deck/'+deck.id.toString()));

  for (var card in json['cards']) {
    result.add(Card.fromJson(card));
  }

  return result;
}

Future<Deck> getDeckFromId(int id) async {
  var json = await fetchJson(Uri.parse(apiRoot+'/deck/' + id.toString()));
  if (json == null || json.containsKey("detail")) {
    return null;
  }

  Deck result = Deck.fromJson(json);
  return result;
}