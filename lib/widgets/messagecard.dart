import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;
  final IconData? userIcon;
  final Color? iconColor;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
    this.userIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Column(
        crossAxisAlignment:
            isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFromUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          //show the icon send by user
                          child: Icon(
                            userIcon,
                            color: iconColor,
                            size: 25,
                          ),
                        ),
                      Expanded(
                        child: MarkdownBody(
                          softLineBreak: true,
                          styleSheet: MarkdownStyleSheet(
                            blockquote: const TextStyle(
                              color: Colors.black,
                            ),
                            checkbox: const TextStyle(
                              color: Colors.black,
                            ),
                            h1: const TextStyle(
                              color: Colors.black,
                            ),
                            del: const TextStyle(
                              color: Colors.black,
                            ),
                            em: const TextStyle(
                              color: Colors.black,
                            ),
                            listBullet: const TextStyle(
                              color: Colors.black,
                            ),
                            strong: const TextStyle(
                              color: Colors.black,
                            ),
                            tableBody: const TextStyle(
                              color: Colors.black,
                            ),
                            a: TextStyle(
                              color: isFromUser
                                  ? const Color(0xFF242A38)
                                  : Colors.black,
                            ),
                            p: TextStyle(
                              color: isFromUser
                                  ? const Color(0xFF242A38)
                                  : Colors.black,
                            ),
                          ),
                          styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                          selectable: false,
                          data: text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
