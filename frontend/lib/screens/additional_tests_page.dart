import 'package:flutter/material.dart';
import 'static_test_screen.dart';

class AdditionalTestsPage extends StatelessWidget {
  const AdditionalTestsPage({super.key});

  final Map<String, List<String>> testQuestions = const {
    'DEPRESSION TEST': [
      "In the past 2 weeks, have you felt sad, empty, or hopeless most of the day?",
      "Have you lost interest or pleasure in activities you usually enjoy?",
      "Have you experienced significant changes in appetite or weight?",
      "Have you had trouble sleeping (too much or too little)?",
      "Do you feel tired or low on energy nearly every day?",
      "Do you feel worthless or excessively guilty?",
      "Do you have difficulty concentrating or making decisions?",
      "Have others noticed that you are moving or speaking slower than usual (or more restless)?",
      "Have you had thoughts that life is not worth living?",
      "Have you had thoughts of harming yourself?"
    ],
    'ADHD TEST': [
      "Do you frequently have difficulty sustaining attention in tasks?",
      "Do you often make careless mistakes in work or studies?",
      "Do you struggle to organize tasks or manage time?",
      "Do you avoid tasks that require sustained mental effort?",
      "Do you frequently lose things necessary for tasks?",
      "Are you easily distracted by unrelated thoughts or external stimuli?",
      "Do you often fidget or feel restless?",
      "Do you interrupt others while they are speaking?",
      "Do you find it hard to wait your turn?",
      "Have these symptoms been present since childhood?"
    ],
    'ANXIETY TEST': [
      "Do you feel excessive worry more days than not?",
      "Do you find it difficult to control your worry?",
      "Do you feel restless or on edge?",
      "Do you get easily fatigued?",
      "Do you have muscle tension?",
      "Do you experience difficulty concentrating due to worry?",
      "Do you have trouble sleeping because of racing thoughts?",
      "Do you feel irritable?",
      "Do you anticipate the worst even in normal situations?",
      "Has this worry persisted for 6 months or more?"
    ],
    'OCD TEST': [
      "Do you experience intrusive, unwanted thoughts?",
      "Do these thoughts cause significant anxiety or distress?",
      "Do you perform repetitive behaviors to reduce anxiety?",
      "Do you feel compelled to check things repeatedly?",
      "Do you excessively wash or clean?",
      "Do you count, arrange, or repeat actions in a ritualistic way?",
      "Do you recognize that these thoughts or behaviors are excessive?",
      "Do these behaviors take more than 1 hour per day?",
      "Do they interfere with daily functioning?",
      "Have you tried to resist but found it very difficult?"
    ],
    'BIPOLAR TEST': [
      "Have you experienced periods of unusually elevated or irritable mood?",
      "During those periods, did you feel more energetic than usual?",
      "Did you need less sleep but still feel energized?",
      "Were you more talkative or felt pressured to keep talking?",
      "Did your thoughts race or jump quickly?",
      "Did you engage in risky behaviors (spending, sex, driving)?",
      "Did others notice a clear change in your behavior?",
      "Have you also experienced depressive episodes?",
      "Did mood episodes last several days or more?",
      "Did these mood shifts impair work or relationships?"
    ],
    'PSYCHOSIS & SCHIZOPHRENIA TEST': [
      "Have you heard voices others cannot hear?",
      "Do you see things others do not see?",
      "Do you believe others are trying to harm or monitor you?",
      "Do you feel your thoughts are being controlled?",
      "Do you feel your thoughts are being broadcast?",
      "Do you struggle to organize your thoughts while speaking?",
      "Have you withdrawn socially?",
      "Have you experienced reduced emotional expression?",
      "Has your work or academic performance declined significantly?",
      "Have symptoms lasted more than 1 month?"
    ],
    'EATING DISORDER TEST': [
      "Are you preoccupied with body weight or shape?",
      "Do you restrict food intake intentionally?",
      "Do you binge eat large amounts of food?",
      "Do you feel loss of control during eating?",
      "Do you induce vomiting after eating?",
      "Do you misuse laxatives or diuretics?",
      "Do you exercise excessively to control weight?",
      "Do you feel intense guilt after eating?",
      "Has your weight changed significantly?",
      "Has eating behavior affected your health?"
    ],
    'PTSD TEST': [
      "Have you experienced a traumatic event?",
      "Do you have intrusive memories of the event?",
      "Do you have nightmares related to it?",
      "Do you avoid reminders of the trauma?",
      "Do you feel emotionally numb?",
      "Are you easily startled?",
      "Do you feel constantly on guard?",
      "Do you experience irritability or anger outbursts?",
      "Do you feel detached from others?",
      "Have symptoms lasted more than 1 month?"
    ],
    'ADDICTION TEST': [
      "Do you use substances more than intended?",
      "Have you tried unsuccessfully to cut down?",
      "Do you spend significant time obtaining or using substances?",
      "Do you experience cravings?",
      "Has substance use affected work or relationships?",
      "Do you continue despite physical harm?",
      "Do you need increasing amounts for the same effect?",
      "Do you experience withdrawal symptoms?",
      "Have you given up important activities?",
      "Has use caused legal or financial issues?"
    ],
    'GAMBLING ADDICTION TEST': [
      "Do you feel restless when trying to stop gambling?",
      "Do you gamble to escape problems?",
      "Do you chase losses?",
      "Have you lied about gambling?",
      "Have you jeopardized relationships?",
      "Have you borrowed money to gamble?",
      "Do you think about gambling constantly?",
      "Have you tried unsuccessfully to stop?",
      "Has gambling affected work?",
      "Has it caused financial distress?"
    ],
    'SOCIAL ANXIETY TEST': [
      "Do you fear social situations?",
      "Are you afraid of being judged?",
      "Do you avoid speaking in public?",
      "Do you avoid meeting new people?",
      "Do you experience physical symptoms in social settings?",
      "Do you blush or sweat excessively?",
      "Do you rehearse conversations mentally?",
      "Do you fear embarrassment?",
      "Has this lasted 6 months or more?",
      "Does it interfere with life?"
    ],
    'POSTPARTUM DEPRESSION TEST (NEW & EXPECTING PARENTS)': [
      "Have you felt persistent sadness after childbirth?",
      "Do you feel disconnected from your baby?",
      "Do you feel like a bad parent?",
      "Do you cry frequently?",
      "Do you feel overwhelmed?",
      "Have you lost interest in activities?",
      "Do you have trouble sleeping even when baby sleeps?",
      "Do you feel hopeless?",
      "Have you had thoughts of harming yourself?",
      "Have you had thoughts of harming the baby?"
    ],
    'PARENT TEST: YOUR CHILD\'S MENTAL HEALTH': [
      "Has your child shown mood changes?",
      "Has your child become withdrawn?",
      "Are there sleep disturbances?",
      "Has appetite changed?",
      "Has school performance declined?",
      "Is your child unusually irritable?",
      "Has your child expressed hopelessness?",
      "Has your child mentioned self-harm?",
      "Has there been a traumatic event?",
      "Are teachers reporting behavioral concerns?"
    ],
    'YOUTH MENTAL HEALTH TEST': [
      "Has your mood changed significantly recently?",
      "Are you withdrawing from friends?",
      "Has school performance declined?",
      "Do you feel hopeless?",
      "Do you have trouble sleeping?",
      "Are you irritable often?",
      "Do you feel anxious frequently?",
      "Have you experienced bullying?",
      "Have you had thoughts of self-harm?",
      "Do you feel safe at home?"
    ],
    'TEST DE DEPRESIÓN': [
      "¿Se ha sentido triste o sin esperanza la mayor parte del día?",
      "¿Ha perdido el interés en actividades que suele disfrutar?",
      "¿Ha tenido cambios significativos en el apetito?",
      "¿Ha tenido problemas para dormir?",
      "¿Se siente cansado casi todos los días?",
      "¿Se siente inútil o excesivamente culpable?",
      "¿Tiene dificultad para concentrarse?",
      "¿Otros han notado que se mueve más lento de lo habitual?",
      "¿Ha tenido pensamientos de que la vida no vale la pena?",
      "¿Ha tenido pensamientos de hacerse daño?"
    ],
    'TEST DE ANSIEDAD': [
      "¿Se siente excesivamente preocupado la mayoría de los días?",
      "¿Le resulta difícil controlar su preocupación?",
      "¿Se siente inquieto o nervioso?",
      "¿Se fatiga con facilidad?",
      "¿Tiene tensión muscular?",
      "¿Tiene dificultad para concentrarse debido a la preocupación?",
      "¿Tiene problemas para dormir debido a pensamientos acelerados?",
      "¿Se siente irritable?",
      "¿Anticipa lo peor incluso en situaciones normales?",
      "¿Esta preocupación ha persistido durante 6 meses o más?"
    ],
    'SURVEY: WHAT MAKES A GOOD DAY?': [
      "Did you feel productive today?",
      "Did you experience positive emotions?",
      "Did you connect socially?",
      "Did you feel physically healthy?",
      "Did you experience stress?",
      "Did you sleep well?",
      "Did you engage in meaningful activity?",
      "Did you feel grateful?",
      "Did you manage challenges well?",
      "Would you rate today as good overall?"
    ],
    'PSYCHEDELICS & MENTAL HEALTH SURVEY': [
      "Have you used psychedelic substances?",
      "For what purpose?",
      "Did you experience mood improvement?",
      "Did you experience anxiety or paranoia?",
      "Did symptoms worsen afterward?",
      "Were substances medically supervised?",
      "Have you experienced hallucinations afterward?",
      "Did it affect daily functioning?",
      "Would you use again?",
      "Have you discussed it with a doctor?"
    ],
    'AI & MENTAL HEALTH SURVEY': [
      "Do you use AI for emotional support?",
      "Do you trust AI advice?",
      "Does AI make you feel understood?",
      "Do you prefer AI over humans?",
      "Has AI reduced loneliness?",
      "Do you rely heavily on AI?",
      "Do you verify AI suggestions?",
      "Has AI improved coping skills?",
      "Do you share personal details with AI?",
      "Would you recommend AI mental support?"
    ],
    'SELF-INJURY SURVEY': [
      "Have you intentionally hurt yourself?",
      "How often does this occur?",
      "What triggers the behavior?",
      "Do you feel relief after self-injury?",
      "Do you hide injuries?",
      "Have you needed medical treatment?",
      "Do you feel unable to stop?",
      "Do you feel shame afterward?",
      "Have you told anyone?",
      "Have you had suicidal thoughts?"
    ],
  };

  final List<Map<String, dynamic>> tests = const [
    {'title': 'DEPRESSION TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'ADHD TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'ANXIETY TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'OCD TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'BIPOLAR TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'PSYCHOSIS & SCHIZOPHRENIA TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'EATING DISORDER TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'PTSD TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'ADDICTION TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'GAMBLING ADDICTION TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'SOCIAL ANXIETY TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'POSTPARTUM DEPRESSION TEST (NEW & EXPECTING PARENTS)', 'color': Color(0xFF2AB5B4)},
    {'title': 'PARENT TEST: YOUR CHILD\'S MENTAL HEALTH', 'color': Color(0xFF2AB5B4)},
    {'title': 'YOUTH MENTAL HEALTH TEST', 'color': Color(0xFF2AB5B4)},
    {'title': 'TEST DE DEPRESIÓN', 'color': Color(0xFF2AB5B4)},
    {'title': 'TEST DE ANSIEDAD', 'color': Color(0xFF2AB5B4)},
    {'title': 'SURVEY: WHAT MAKES A GOOD DAY?', 'color': Color(0xFF81386A)},
    {'title': 'PSYCHEDELICS & MENTAL HEALTH SURVEY', 'color': Color(0xFF81386A)},
    {'title': 'AI & MENTAL HEALTH SURVEY', 'color': Color(0xFF81386A)},
    {'title': 'SELF-INJURY SURVEY', 'color': Color(0xFF81386A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Additional Assessments", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "⚠️ Important: These are screening questions, not a medical diagnosis. Only a licensed psychiatrist can diagnose.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns for better readability on mobile
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return GestureDetector(
                    onTap: () {
                      final questions = testQuestions[test['title']] ?? [];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaticTestScreen(
                            title: test['title'],
                            questions: questions,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: test['color'],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 20,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                test['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
