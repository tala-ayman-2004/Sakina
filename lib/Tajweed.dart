import 'package:flutter/material.dart';

class QuranRulesPage extends StatelessWidget {
  const QuranRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        elevation: 0,
        title: const Text(
          'Tajweed & Quran Signs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('أحكام التجويد · Tajweed Rules'),
          _rule(
            ar: 'الإظهار',
            en: 'Izhar',
            symbol: 'ء هـ ع ح غ خ',
            arDesc: 'إظهار النون الساكنة أو التنوين بدون غنة',
            enDesc: 'Clear pronunciation of Noon Saakin or Tanween',
          ),
          _rule(
            ar: 'الإدغام',
            en: 'Idgham',
            symbol: 'يرملون',
            arDesc: 'إدخال النون الساكنة أو التنوين في الحرف التالي',
            enDesc: 'Merging Noon Saakin or Tanween',
          ),
          _rule(
            ar: 'الإقلاب',
            en: 'Iqlab',
            symbol: 'ب → م',
            arDesc: 'قلب النون الساكنة أو التنوين ميماً عند الباء',
            enDesc: 'Changing Noon Saakin to Meem before Baa',
          ),
          _rule(
            ar: 'الإخفاء',
            en: 'Ikhfa',
            symbol: '15 حرفاً',
            arDesc: 'إخفاء النون الساكنة أو التنوين مع غنة',
            enDesc: 'Concealment with nasal sound',
          ),

          _sectionTitle('علامات الوقف · Stop Signs'),
          _rule(
            ar: 'وقف لازم',
            en: 'Mandatory Stop',
            symbol: 'م',
            arDesc: 'يجب الوقوف ولا يجوز الوصل',
            enDesc: 'Stopping is mandatory',
          ),
          _rule(
            ar: 'لا وقف',
            en: 'No Stop',
            symbol: 'لا',
            arDesc: 'لا يجوز الوقوف',
            enDesc: 'Stopping is not allowed',
          ),
          _rule(
            ar: 'وقف جائز',
            en: 'Permissible Stop',
            symbol: 'ج',
            arDesc: 'يجوز الوقف أو الوصل',
            enDesc: 'Stopping or continuing is allowed',
          ),
          _rule(
            ar: 'سكت',
            en: 'Saktah',
            symbol: 'س',
            arDesc: 'سكتة خفيفة بدون تنفس',
            enDesc: 'Brief pause without breathing',
          ),

          _sectionTitle('علامات خاصة · Special Signs'),
          _rule(
            ar: 'سجدة تلاوة',
            en: 'Prostration (Sajdah)',
            symbol: '۩',
            arDesc: 'يستحب السجود عند هذه الآية',
            enDesc: 'Recommended prostration',
          ),

          _sectionTitle('المدود · Madd Rules'),
          _rule(
            ar: 'مد طبيعي',
            en: 'Natural Madd',
            symbol: 'ا و ي',
            arDesc: 'مد بمقدار حركتين',
            enDesc: 'Two counts extension',
          ),
          _rule(
            ar: 'مد لازم',
            en: 'Mandatory Madd',
            symbol: '~',
            arDesc: 'ست حركات وجوباً',
            enDesc: 'Six counts extension',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF229B91),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _rule({
    required String ar,
    required String en,
    required String symbol,
    required String arDesc,
    required String enDesc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$ar · $en',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Symbol: $symbol',
            style: const TextStyle(color: Color(0xFF229B91)),
          ),
          const SizedBox(height: 10),
          Text(
            arDesc,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            enDesc,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
