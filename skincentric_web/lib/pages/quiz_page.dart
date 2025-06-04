import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// SPM-6 SCORING  (no other imports required)
/// ------------------------------------------------------------
class Spm6Scorer {
  static String generate(Map<String, dynamic> a) {
    final sebum      = _calcSebum(a);
    final barrier    = _calcBarrier(a);
    final react      = _calcReactivity(a, barrier);
    final pigment    = _calcPigment(a);
    final elasticity = _calcElasticity(a);
    final inflam     = _calcInflam(a);
    final mods       = _getModifiers(a);

    final base = "$sebum-$barrier-$react-$pigment-$elasticity-$inflam";
    return mods.isEmpty ? base : "$base+${mods.join()}";
  }

  // ① Sebum Axis -----------------------------------------------------------
  static String _calcSebum(Map<String, dynamic> a) {
    double score = 0;
    switch (a['middayFeel']) {
      case 'Looks shiny/feels greasy': score += 2; break;
      case 'Dry on cheeks but oily T zone': score += 1; break;
      case 'Feels tight or flaky': score -= 2; break;
    }
    switch (a['postWashTight']) {
      case 'Always': score -= 1; break;
      case 'Sometimes': score -= .5; break;
    }
    final age = a['age'] as int;
    if (age < 14) score -= .5;
    if (age >= 14 && age <= 24) score += 1;
    final dairy = a['dairy'] as String;
    if (dairy == '1 2' || dairy == '>2') score += .5;

    if (score >= 1.5) return 'O';
    if (score <= -1) return 'D';
    return 'C';
  }

  // ② Barrier Axis ---------------------------------------------------------
  static String _calcBarrier(Map<String, dynamic> a) {
    int pts = 0;
    if (a['cracksMonthly'] == true) pts++;
    if (a['postWashTight'] == 'Always' || a['postWashTight'] == 'Sometimes') pts++;
    if ((a['diagnoses'] as List).any((d) => d == 'Eczema/Atopic dermatitis' || d == 'Psoriasis')) pts++;
    if ((a['age'] as int) >= 60) pts++;
    if (a['sunResponse'] == 'Always burns/never tans') pts++;
    return pts >= 2 ? 'B' : 'I';
  }

  // ③ Reactivity Axis ------------------------------------------------------
  static String _calcReactivity(Map<String, dynamic> a, String barrier) {
    double sens = 0;
    switch (a['sensitivity']) {
      case 'Always': sens += 2; break;
      case 'Often': sens += 1; break;
    }
    final diag = a['diagnoses'] as List;
    if (diag.contains('Rosacea')) sens += 1;
    if (diag.contains('Urticaria(Hives)')) sens += 1;
    if (diag.contains('Seborrheic dermatitis')) sens += 1;
    if (a['allergies'] == true) sens += 1;
    if (barrier == 'B') sens += .5;
    return sens >= 2 ? 'S' : 'R';
  }

  // ④ Pigment Axis ---------------------------------------------------------
  static String _calcPigment(Map<String, dynamic> a) {
    final tone = a['skinTone'];
    final sun  = a['sunResponse'];
    final pih  = a['pih'] == true;
    final diag = a['diagnoses'] as List;
    const highTone = ['Light Brown', 'Brown', 'Deep Brown'];
    if (highTone.contains(tone) ||
        sun == 'Rarely burns/tans easily' ||
        sun == 'Almost never burns/tans deeply' ||
        pih ||
        diag.contains('Melasma')) {
      return 'H';
    }
    return 'L';
  }

  // ⑤ Elasticity Axis ------------------------------------------------------
  static String _calcElasticity(Map<String, dynamic> a) {
    int ageScore = 0;
    switch (a['wrinkles']) {
      case 'Moderate': ageScore += 1; break;
      case 'Pronounced': ageScore += 2; break;
    }
    final age = a['age'] as int;
    if (age >= 30 && age <= 49) ageScore += 1;
    if (age >= 50) ageScore += 2;
    final smoking = a['smoking'] as String;
    if (smoking == '<10 cigarettes/day') ageScore += 1;
    if (smoking == '≥10 cigarettes/day') ageScore += 2;
    if (a['tanningBeds'] == true) ageScore += 1;
    if (age < 18) return 'F';
    return ageScore >= 3 ? 'W' : 'F';
  }

  // ⑥ Inflammation Axis ----------------------------------------------------
  static String _calcInflam(Map<String, dynamic> a) {
    double pts = 0;
    switch (a['pimpleCount']) {
      case '1 3': pts += 1; break;
      case '4 10': pts += 2; break;
      case '11 20':
      case '>20': pts += 3; break;
    }
    final diag = a['diagnoses'] as List;
    if (diag.contains('Acne')) pts += 1;
    if (diag.contains('Rosacea')) pts += 1;
    if (diag.contains('Seborrheic dermatitis')) pts += 1;
    final highGi = a['highGI'] as String;
    if (highGi == '4 6 times/week' || highGi == 'Daily') pts += 1;
    if ((a['stress'] as int) >= 7) pts += .5;
    return pts >= 3 ? 'I' : 'Q';
  }

  // Modifiers --------------------------------------------------------------
  static List<String> _getModifiers(Map<String, dynamic> a) {
    final mods = <String>[];
    final diag = a['diagnoses'] as List;
    if (diag.contains('Keloids') || a['keloids'] == true) mods.add('K');
    if (diag.contains('Eczema/Atopic dermatitis')) mods.add('E');
    if (diag.contains('Melasma')) mods.add('M');
    if (diag.contains('Psoriasis')) mods.add('P');
    if (diag.contains('Vitiligo')) mods.add('V');
    if (diag.contains('Rosacea')) mods.add('R');
    if (diag.contains('Seborrheic dermatitis')) mods.add('S');
    if (diag.contains('Urticaria(Hives)')) mods.add('U');
    if (diag.contains('Pseudofolliculitis Barbae (PFB)')) mods.add('B');
    return mods;
  }
}

/// ==========================================================================
///  QUIZ  – one question per screen with fade transitions
/// ==========================================================================
class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);
  @override State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Map<String, dynamic> _ans = {
    'diagnoses': <String>[],
    'familyHistory': <String>[],
    'breakoutAreas': <String>[]
  };
  int _index = 0;

  // --- All Questions ------------------------------------------------------
  late final List<_Question> _questions = [
    const _Question(key: 'age', prompt: 'How old are you?', type: QType.number),
    const _Question(
        key: 'sexAtBirth',
        prompt: 'What is your sex assigned at birth?',
        options: ['Male', 'Female', 'Prefer not to say']),
    const _Question(
        key: 'genderIdentity',
        prompt: 'Do you currently identify as…?',
        options: [
          'Male','Female','Non-binary','Another gender','Prefer not to say'
        ]),
    const _Question(
        key: 'skinTone',
        prompt: 'Which best describes your natural skin tone?',
        options: ['Very Light','Light','Olive','Light Brown','Brown','Deep Brown']),
    const _Question(
        key: 'sunResponse',
        prompt: 'When unprotected in strong sun for 30 min, what happens?',
        options: [
          'Always burns/never tans','Usually burns/light tan','Sometimes burns/tans slowly',
          'Rarely burns/tans easily','Almost never burns/tans deeply','Not sure'
        ]),
    const _Question(
        key: 'pregnancyStatus',
        prompt: 'Are you currently pregnant or breastfeeding?',
        options: ['Yes','No','Not applicable']),
    const _Question(
        key: 'cycleStage',
        prompt: 'If you menstruate, where are you in your cycle today?',
        options: ['Follicular','Ovulation','Luteal','Menstruation','I do not menstruate']),
    const _Question(
        key: 'familyHistory',
        prompt: 'Do first-degree relatives have any of these?',
        options: ['Acne','Eczema','Psoriasis','Keloids','Vitiligo','Melanoma','None'],
        multi: true),
    const _Question(
        key: 'diagnoses',
        prompt: 'Have you been formally diagnosed with any skin conditions?',
        options: [
          'Acne','Rosacea','Eczema/Atopic dermatitis','Psoriasis','Seborrheic dermatitis',
          'Vitiligo','Keloids','Melasma','Pseudofolliculitis Barbae (PFB)','Urticaria(Hives)','None'
        ],
        multi: true),
    const _Question(
        key: 'pih',
        prompt: 'Do dark marks last >3 months after pimples, cuts or bites?',
        options: ['Yes','No']),
    const _Question(
        key: 'allergies',
        prompt: 'Do you have any known skincare/cosmetic/metal/med allergies?',
        options: ['Yes','No']),
    const _Question(
        key: 'middayFeel',
        prompt: 'By midday, how does your face feel?',
        options: [
          'Feels tight or flaky','Comfortable/neutral','Looks shiny/feels greasy',
          'Dry on cheeks but oily T zone'
        ]),
    const _Question(
        key: 'postWashTight',
        prompt: 'Does your skin feel tight within 5 min of cleansing?',
        options: ['Always','Sometimes','Rarely','Never']),
    const _Question(
        key: 'sensitivity',
        prompt: 'How often do you get stinging/burning/redness from products?',
        options: ['Always','Often','Occasionally','Never']),
    const _Question(
        key: 'pimpleCount',
        prompt: 'How many inflammatory pimples in the last 30 days?',
        options: ['None','1 3','4 10','11 20','>20']),
    const _Question(
        key: 'breakoutAreas',
        prompt: 'Which areas break out most?',
        options: ['Forehead','Cheeks','Nose','Chin/jaw','Back/chest','Rarely breakout'],
        multi: true),
    const _Question(
        key: 'cracksMonthly',
        prompt: 'Does your skin crack/bleed at least once a month?',
        options: ['Yes','No']),
    const _Question(
        key: 'wrinkles',
        prompt: 'How visible are fine lines and wrinkles?',
        options: ['None','Mild','Moderate','Pronounced']),
    const _Question(
        key: 'keloids',
        prompt: 'After cuts or piercings, do you get raised thick scars (keloids)?',
        options: ['Yes','No','Unsure']),
    const _Question(
        key: 'alcohol',
        prompt: 'Avg alcoholic drinks per week?',
        options: ['0','1 4','5 8','>8']),
    const _Question(
        key: 'smoking',
        prompt: 'Do you smoke or vape nicotine products?',
        options: ['Never','Former smoker','<10 cigarettes/day','≥10 cigarettes/day']),
    const _Question(
        key: 'sleepHours',
        prompt: 'How many hours of quality sleep per night?',
        options: ['<5','5 6','7 8','>8']),
    const _Question(
        key: 'stress',
        prompt: 'Rate your average stress level (1 very low – 10 very high)',
        type: QType.slider),
    const _Question(
        key: 'exercise',
        prompt: 'Days per week with ≥30 min moderate exercise?',
        options: ['0 1','2 3','4 5','6 7']),
    const _Question(
        key: 'dairy',
        prompt: 'Daily servings of dairy?',
        options: ['0','<1','1 2','>2']),
    const _Question(
        key: 'highGI',
        prompt: 'How often do you eat high-glycemic foods?',
        options: ['Rarely','1 3 times/week','4 6 times/week','Daily']),
    const _Question(
        key: 'fruitsVeg',
        prompt: 'Servings of fruits & vegetables per day?',
        options: ['<2','2 3','4 5','>5']),
    const _Question(
        key: 'waterIntake',
        prompt: 'Cups of water/non-sugary fluids per day?',
        options: ['<3','3 5','6 8','>8']),
    const _Question(
        key: 'sunHours',
        prompt: 'Hours per week in direct sun (no shade)?',
        options: ['<1','1 3','4 7','>7']),
    const _Question(
        key: 'spfUse',
        prompt: 'Do you apply broad-spectrum SPF 30+ on most days?',
        options: ['Always','Often','Sometimes','Rarely/Never']),
    const _Question(
        key: 'tanningBeds',
        prompt: 'Used tanning beds or deliberate sunbathing >12× last year?',
        options: ['Yes','No']),
  ];

  // ---------------------- UI ----------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // progress bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                minHeight: 8,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF9C7E65)),
                backgroundColor: const Color(0xFF3B2E25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // question body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _buildQuestion(_questions[_index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(_Question q) {
    return Column(
      key: ValueKey(q.key),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _questionBody(q),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // back
              if (_index > 0)
                _navCircle(
                  icon: Icons.arrow_back,
                  onTap: () => setState(() => _index--),
                )
              else
                const SizedBox(width: 60),

              // forward / finish
              _navCircle(
                icon: _index == _questions.length - 1 ? Icons.check : Icons.arrow_forward,
                onTap: () {
                  if (_validateAnswer(q)) {
                    goNext();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please answer the question.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- helper widgets & logic ----------------
  Widget _navCircle({required IconData icon, required VoidCallback onTap}) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.black,
      radius: 30,
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }

  Widget _questionBody(_Question q) {
    switch (q.type) {
      case QType.number:
        return _NumberQuestion(
          prompt: q.prompt,
          initial: _ans[q.key]?.toString(),
          onSaved: (v) => _ans[q.key] = int.tryParse(v) ?? 0,
        );
      case QType.slider:
        return _SliderQuestion(
          prompt: q.prompt,
          initial: (_ans[q.key] as int?) ?? 5,
          onChanged: (v) => _ans[q.key] = v,
        );
      default:
        return _OptionQuestion(
          prompt: q.prompt,
          options: q.options!,
          multi: q.multi,
          initial: _ans[q.key],
          onChanged: (val) => _ans[q.key] = val,
        );
    }
  }

  bool _validateAnswer(_Question q) =>
      _ans[q.key] != null &&
      (_ans[q.key] is List ? (_ans[q.key] as List).isNotEmpty : true);

  void goNext() {
    if (_index < _questions.length - 1) {
      setState(() => _index++);
    } else {
      final code = Spm6Scorer.generate(_ans);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Your Skin Profile Code'),
          content: Text(code, style: Theme.of(context).textTheme.displaySmall),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
          ],
        ),
      );
    }
  }

  // expose for auto-advance
  static _QuizPageState? of(BuildContext context) => context.findAncestorStateOfType<_QuizPageState>();
  void incrementIndex() => goNext();
}

// -----------------------------------------------------------------------------
//  Support classes & widgets
// -----------------------------------------------------------------------------
enum QType { single, multi, number, slider }

class _Question {
  final String key, prompt;
  final List<String>? options;
  final bool multi;
  final QType type;
  const _Question({required this.key, required this.prompt, this.options, this.multi = false, this.type = QType.single});
}

class _OptionQuestion extends StatefulWidget {
  final String prompt; final List<String> options; final bool multi; final dynamic initial; final ValueChanged<dynamic> onChanged;
  const _OptionQuestion({super.key, required this.prompt, required this.options, required this.multi, this.initial, required this.onChanged});
  @override State<_OptionQuestion> createState() => _OptionQuestionState();
}

class _OptionQuestionState extends State<_OptionQuestion> {
  late dynamic _value = widget.initial;

  void _handleSingle(String? s) {
    setState(() => _value = s);
    widget.onChanged(s);
    Future.delayed(const Duration(seconds: 1), () {
      _QuizPageState.of(context)?.incrementIndex();
    });
  }

  void _handleMulti(String o, bool? sel) {
    final list = List<String>.from(_value ?? <String>[]);
    sel! ? list.add(o) : list.remove(o);
    setState(() => _value = list);
    widget.onChanged(list);
  }

  @override Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.headlineMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.prompt, style: t),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.multi
                  ? widget.options.map((o) => CheckboxListTile(
                        title: Text(o),
                        value: (_value ?? <String>[]).contains(o),
                        onChanged: (v) => _handleMulti(o, v),
                      )).toList()
                  : widget.options.map((o) => RadioListTile<String>(
                        title: Text(o), value: o, groupValue: _value as String?, onChanged: _handleSingle,
                      )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberQuestion extends StatelessWidget {
  final String prompt; final String? initial; final ValueChanged<String> onSaved;
  const _NumberQuestion({super.key, required this.prompt, this.initial, required this.onSaved});

  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(prompt, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      TextField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        controller: TextEditingController(text: initial),
        onChanged: onSaved,
      ),
    ],
  );
}

class _SliderQuestion extends StatefulWidget {
  final String prompt; final int initial; final ValueChanged<int> onChanged;
  const _SliderQuestion({super.key, required this.prompt, required this.initial, required this.onChanged});
  @override State<_SliderQuestion> createState() => _SliderQuestionState();
}

class _SliderQuestionState extends State<_SliderQuestion> {
  late double _val = widget.initial.toDouble();
  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.prompt, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      Slider(
        value: _val, min: 1, max: 10, divisions: 9, label: _val.round().toString(),
        onChanged: (v) => setState(() => _val = v),
        onChangeEnd: (v) => widget.onChanged(v.round()),
      ),
    ],
  );
}
