class HabitRecommendationTemplate {
  final String title;
  final String description;
  final String category;
  final int defaultDuration;
  final String defaultTrigger;
  final String icon;

  const HabitRecommendationTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.defaultDuration,
    required this.defaultTrigger,
    required this.icon,
  });
}

const List<HabitRecommendationTemplate> habitRecommendations = [
  // MIND
  HabitRecommendationTemplate(
    title: 'Morning Gratitude',
    description: 'Write down 3 things you are grateful for.',
    category: 'MIND',
    defaultDuration: 5,
    defaultTrigger: 'AFTER_WAKEUP',
    icon: '🙏',
  ),
  HabitRecommendationTemplate(
    title: 'Mindfulness Meditation',
    description: 'Calm the mind and observe your thoughts.',
    category: 'MIND',
    defaultDuration: 10,
    defaultTrigger: 'AFTER_COFFEE',
    icon: '🧘',
  ),
  HabitRecommendationTemplate(
    title: 'Daily Journaling',
    description: 'Unload your thoughts and process the day.',
    category: 'MIND',
    defaultDuration: 10,
    defaultTrigger: 'BEFORE_SLEEP',
    icon: '✍️',
  ),
  HabitRecommendationTemplate(
    title: 'Positive Affirmations',
    description: 'Reinforce your self-belief with positive self-talk.',
    category: 'MIND',
    defaultDuration: 2,
    defaultTrigger: 'AFTER_WAKEUP',
    icon: '✨',
  ),
  HabitRecommendationTemplate(
    title: 'Deep Breathing',
    description: '5 minutes of box breathing.',
    category: 'MIND',
    defaultDuration: 5,
    defaultTrigger: 'WHEN_STRESSED',
    icon: '🌬️',
  ),
  // BODY
  HabitRecommendationTemplate(
    title: 'Morning Hydration',
    description: 'Drink a glass of water right after waking up.',
    category: 'BODY',
    defaultDuration: 1,
    defaultTrigger: 'AFTER_WAKEUP',
    icon: '💧',
  ),
  HabitRecommendationTemplate(
    title: 'HIIT Workout',
    description: 'High-intensity interval training for cardio.',
    category: 'BODY',
    defaultDuration: 20,
    defaultTrigger: 'AFTERNOON_BREAK',
    icon: '🔥',
  ),
  HabitRecommendationTemplate(
    title: 'Power Walk',
    description: 'A brisk walk to boost metabolism.',
    category: 'BODY',
    defaultDuration: 30,
    defaultTrigger: 'AFTER_LUNCH',
    icon: '🚶',
  ),
  HabitRecommendationTemplate(
    title: 'Strength Training',
    description: 'Build muscle and bone density.',
    category: 'BODY',
    defaultDuration: 45,
    defaultTrigger: 'START_OF_DAY',
    icon: '🏋️',
  ),
  HabitRecommendationTemplate(
    title: 'Sun Exposure',
    description: 'Get 10 mins of natural light for circadian health.',
    category: 'BODY',
    defaultDuration: 10,
    defaultTrigger: 'AFTER_WAKEUP',
    icon: '☀️',
  ),
  // FOCUS
  HabitRecommendationTemplate(
    title: 'Digital Detox',
    description: 'No screens for the first 30 minutes of the day.',
    category: 'FOCUS',
    defaultDuration: 30,
    defaultTrigger: 'AFTER_WAKEUP',
    icon: '📵',
  ),
  HabitRecommendationTemplate(
    title: 'Read 10 Pages',
    description: 'Daily reading to expand your mind.',
    category: 'FOCUS',
    defaultDuration: 20,
    defaultTrigger: 'AFTER_DINNER',
    icon: '📚',
  ),
  HabitRecommendationTemplate(
    title: 'Inbox Zero',
    description: 'Process and clear your communication.',
    category: 'FOCUS',
    defaultDuration: 15,
    defaultTrigger: 'END_OF_WORK',
    icon: '📧',
  ),
  HabitRecommendationTemplate(
    title: 'Deep Work Session',
    description: 'Uninterrupted time for cognitively demanding tasks.',
    category: 'FOCUS',
    defaultDuration: 90,
    defaultTrigger: 'START_OF_WORK',
    icon: '🧠',
  ),
  // RECOVERY
  HabitRecommendationTemplate(
    title: 'Nightly Reflection',
    description: 'Review your day and set intentions for tomorrow.',
    category: 'RECOVERY',
    defaultDuration: 10,
    defaultTrigger: 'BEFORE_SLEEP',
    icon: '🌙',
  ),
  HabitRecommendationTemplate(
    title: 'Evening Tea Ritual',
    description: 'Wind down with a calming herbal tea.',
    category: 'RECOVERY',
    defaultDuration: 10,
    defaultTrigger: 'BEFORE_SLEEP',
    icon: '☕',
  ),
  HabitRecommendationTemplate(
    title: 'Gratitude Journal',
    description: 'Record things you were thankful for today.',
    category: 'RECOVERY',
    defaultDuration: 5,
    defaultTrigger: 'BEFORE_SLEEP',
    icon: '📝',
  ),
  HabitRecommendationTemplate(
    title: 'Sleep Routine',
    description: 'Prepare for bed with a relaxing routine.',
    category: 'RECOVERY',
    defaultDuration: 20,
    defaultTrigger: 'BEFORE_SLEEP',
    icon: '💤',
  ),
];
