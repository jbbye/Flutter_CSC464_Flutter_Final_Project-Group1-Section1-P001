import 'package:finalassignment/models/language_option.dart';
import 'package:flutter/material.dart';

class LanguageSelectorCard extends StatelessWidget {
  const LanguageSelectorCard({
    super.key,
    required this.options,
    required this.isBusy,
    required this.onSelect,
    required this.onCancel,
  });

  final List<LanguageOption> options;
  final bool isBusy;
  final ValueChanged<LanguageOption> onSelect;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          var crossAxisCount = 4;
          var ratio = 1.55;
          if (width < 980) {
            crossAxisCount = 3;
            ratio = 1.38;
          }
          if (width < 720) {
            crossAxisCount = 2;
            ratio = 1.12;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.translate_rounded, color: Color(0xFF5B63F6)),
                  const SizedBox(width: 10),
                  Text(
                    'Select a Language',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2A44),
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: isBusy ? null : onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Choose the language you would like to practice today.',
                style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 16),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: ratio,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return InkWell(
                    onTap: isBusy ? null : () => onSelect(option),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: LayoutBuilder(
                        builder: (context, tileConstraints) {
                          final compact = tileConstraints.maxHeight < 96;

                          if (compact) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    option.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          option.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          option.level,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blueGrey.shade400,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(option.flag, style: const TextStyle(fontSize: 30)),
                                const SizedBox(height: 10),
                                Text(
                                  option.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  option.level,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade400,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
            ],
          );
        },
      ),
    );
  }
}
