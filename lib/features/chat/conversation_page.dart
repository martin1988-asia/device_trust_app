import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/chat_service.dart';
import '../../models/conversation_model.dart';
import '../../models/device_model.dart';
import 'chat_page.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ prevent stretching
    final maxWidth = screenWidth > 650 ? 600.0 : screenWidth;

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: StreamBuilder<QuerySnapshot>(
            stream: ChatService.getConversations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No conversations yet",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              final conversations = snapshot.data!.docs.map((doc) {
                return ConversationModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];

                  return _conversationTile(context, convo);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ✅ CONVERSATION TILE (FULLY POLISHED)
  // =====================================================

  Widget _conversationTile(BuildContext context, ConversationModel convo) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              device: DeviceModel(
                id: convo.id,
                name: convo.deviceName,
                imei: "unknown",
                model: "",
                status: "Clean",
                trustScore: 50,
                ownerId: null,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            // ================= AVATAR =================
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blueAccent.withOpacity(0.15),
                  child: const Icon(Icons.phone_android),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ================= CONTENT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ TITLE
                  Text(
                    convo.deviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.lastMessage.isNotEmpty
                              ? convo.lastMessage
                              : "No messages yet",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  // ✅ TYPING INDICATOR
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(convo.id)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();

                      final data = snap.data!.data() as Map<String, dynamic>?;

                      if (data == null) return const SizedBox();

                      final typingUsers = List<String>.from(
                        data['typingUsers'] ?? [],
                      );

                      if (typingUsers.isEmpty) {
                        return const SizedBox();
                      }

                      return const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          "typing...",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ================= RIGHT SIDE =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(convo.lastTimestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(convo.id)
                      .collection('messages')
                      .where('seen', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();

                    final count = snap.data!.docs.length;

                    if (count == 0) return const SizedBox();

                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      constraints: const BoxConstraints(minWidth: 24),
                      child: Center(
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ✅ TIME FORMAT
  // =====================================================

  String _formatTime(int timestamp) {
    if (timestamp == 0) return "";

    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;

    if (isToday) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dt.day}/${dt.month}";
    }
  }
}
