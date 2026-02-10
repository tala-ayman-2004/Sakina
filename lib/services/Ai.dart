import 'package:google_generative_ai/google_generative_ai.dart';

class IslamicAnswer {
  final String answer;
  final int confidence;
  final List<Source> sources;

  IslamicAnswer({
    required this.answer,
    required this.confidence,
    required this.sources,
  });
}

class Source {
  final String title;
  final String url;

  Source({required this.title, required this.url});
}

class IslamicAiService {
  late final GenerativeModel _model;

  static const String _apiKey = '// Your Google Generative AI API key here';

  IslamicAiService() {
    _model = GenerativeModel(
       model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      
      systemInstruction: Content.system('''
You are 'Nur', a wise and compassionate Islamic scholar assistant.

Rules:
1. Cite Qur’an as (Surah:Ayah) and ALWAYS include Arabic text.
2. Cite Sahih Hadith with source (Bukhari/Muslim).
3. If scholarly disagreement exists, mention it.
4. End every answer with: [CONFIDENCE: XX%]
5. Include a section called "Sources:" listing references.
6. If unsure, respond with "I do not have sufficient information to answer that question.
7. if the question is not related to Islam, politely decline to answer."
'''),
    );
  }

  Future<IslamicAnswer> askQuestion(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);

    final text = response.text ?? '';

    final confidence = _extractConfidence(text);
    final cleanText = _removeConfidence(text);
    final sources = _extractSources(text);

    return IslamicAnswer(
      answer: cleanText,
      confidence: confidence,
      sources: sources,
    );
  }

  int _extractConfidence(String text) {
    final match = RegExp(r'\[CONFIDENCE:\s*(\d+)%\]').firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 80;
  }

  String _removeConfidence(String text) {
    return text.replaceAll(RegExp(r'\[CONFIDENCE:\s*\d+%\]'), '').trim();
  }

  List<Source> _extractSources(String text) {
    final sources = <Source>[];
    final sourceSection = RegExp(
      r'Sources:(.*)',
      dotAll: true,
    ).firstMatch(text);

    if (sourceSection != null) {
      final lines = sourceSection.group(1)!.split('\n');
      for (var line in lines) {
        if (line.contains('http')) {
          sources.add(Source(title: line.trim(), url: line.trim()));
        }
      }
    }
    return sources;
  }
}
