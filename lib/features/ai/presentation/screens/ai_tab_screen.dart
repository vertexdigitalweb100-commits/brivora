import 'package:flutter/material.dart';

class AITabScreen extends StatefulWidget {
  const AITabScreen({super.key});

  @override
  State<AITabScreen> createState() => _AITabScreenState();
}

class _AITabScreenState extends State<AITabScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Привет! 👋\n\n'
          'Я ИИ-помощник Brivora. Помогу с расчётами, сметами, '
          'материалами и вопросами по ремонту.',
      isUser: false,
    ),
  ];

  final List<_QuickAction> _quickActions = const [
    _QuickAction(
      icon: Icons.calculate_outlined,
      title: 'Рассчитать материал',
      subtitle: 'Плитка, краска, обои',
    ),
    _QuickAction(
      icon: Icons.receipt_long_outlined,
      title: 'Создать смету',
      subtitle: 'Быстро составить расчёт',
    ),
    _QuickAction(
      icon: Icons.photo_camera_outlined,
      title: 'Анализ фото',
      subtitle: 'Найти проблемы на объекте',
    ),
    _QuickAction(
      icon: Icons.lightbulb_outline,
      title: 'Совет по ремонту',
      subtitle: 'Получить рекомендацию',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetMessage]) {
    final text = (presetMessage ?? _controller.text).trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));

      _controller.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(text: _generateDemoAnswer(text), isUser: false),
        );
      });

      _scrollToBottom();
    });
  }

  String _generateDemoAnswer(String question) {
    final lower = question.toLowerCase();

    if (lower.contains('плит')) {
      return 'Конечно. Для расчёта плитки мне понадобятся размеры помещения, '
          'размер одной плитки и желаемый запас. Обычно рекомендую закладывать '
          'около 10% на подрезку.';
    }

    if (lower.contains('смет')) {
      return 'Могу помочь составить смету. Укажи площадь объекта и список '
          'работ или материалов — я помогу структурировать расчёт.';
    }

    if (lower.contains('краск')) {
      return 'Для расчёта краски нужны площадь поверхности, количество слоёв '
          'и расход краски на 1 м².';
    }

    if (lower.contains('обои')) {
      return 'Для расчёта обоев нужны размеры помещения, высота потолка, '
          'ширина рулона и длина рулона.';
    }

    return 'Понял тебя 👍\n\n'
        'Я могу помочь с расчётами материалов, сметами, ремонтом и '
        'организацией работ. Попробуй сформулировать задачу подробнее.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = colors.surface;
    final primaryColor = colors.primary;
    final primaryContainer = colors.primaryContainer;
    final textPrimary = colors.onSurface;
    final textSecondary = colors.onSurfaceVariant;
    final borderColor = colors.outline.withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              borderColor: borderColor,
              primaryColor: primaryColor,
            ),
            Expanded(
              child: _messages.length == 1
                  ? _buildInitialState(
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      primaryContainer: primaryContainer,
                      isDark: isDark,
                    )
                  : _buildMessages(
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                    ),
            ),
            _buildInputArea(
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              borderColor: borderColor,
              primaryColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ИИ-помощник',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const _OnlineDot(),
                    const SizedBox(width: 6),
                    Text(
                      'Онлайн',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.more_horiz, color: textSecondary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState({
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
    required Color primaryContainer,
    required bool isDark,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primaryColor: primaryColor,
            borderColor: borderColor,
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          Text(
            'Что я могу сделать?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ..._quickActions.map(
            (action) => _buildQuickAction(
              action,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              borderColor: borderColor,
              primaryColor: primaryColor,
              primaryContainer: primaryContainer,
            ),
          ),

          const SizedBox(height: 18),

          _buildHint(
            textSecondary: textSecondary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard({
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final lightStart = isDark
        ? const Color(0xFF172554)
        : const Color(0xFFEFF6FF);

    final lightEnd = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    final cardBorder = isDark
        ? const Color(0xFF1E40AF)
        : const Color(0xFFDBEAFE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightStart, lightEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Чем могу помочь?',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Спроси меня о ремонте, материалах, расчётах '
            'или создании сметы.',
            style: TextStyle(fontSize: 14, height: 1.5, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    _QuickAction action, {
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
    required Color primaryContainer,
  }) {
    return GestureDetector(
      onTap: () => _sendMessage(action.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(action.icon, color: primaryColor, size: 21),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    action.subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint({
    required Color textSecondary,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: textSecondary),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Например: «Сколько плитки нужно для ванной 3×2 м?»',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages({
    required Color textPrimary,
    required Color textSecondary,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(
          _messages[index],
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          primaryColor: primaryColor,
        );
      },
    );
  }

  Widget _buildMessageBubble(
    _ChatMessage message, {
    required Color textPrimary,
    required Color textSecondary,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
  }) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 310),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF60A5FA)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 17,
              ),
            ),

            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea({
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 120),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: TextStyle(fontSize: 14, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Напиши сообщение...',
                  hintStyle: TextStyle(fontSize: 14, color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;

              return GestureDetector(
                onTap: hasText ? _sendMessage : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasText
                        ? primaryColor
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: hasText
                        ? Colors.white
                        : textSecondary.withValues(alpha: 0.55),
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}
