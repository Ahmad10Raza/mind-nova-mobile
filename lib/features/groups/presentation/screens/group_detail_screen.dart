import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/group_service.dart';
import '../../providers/group_provider.dart';
import '../widgets/group_post_card.dart';
import '../widgets/checkin_widget.dart';
import '../widgets/progress_card.dart';
import '../widgets/exit_bottom_sheet.dart';
import '../../data/group_chat_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/group_model.dart';
import '../widgets/group_create_post_sheet.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GroupChatService? _chatService;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoadingChat = false;
  final TextEditingController _messageController = TextEditingController();
  String _selectedFeedTab = 'FOR_YOU';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    // Initialize real-time service directly to bind it to widget lifecycle
    _chatService = GroupChatService(
      groupId: widget.groupId,
      onMessageReceived: (msg) {
        if (mounted) setState(() => _messages.add(msg));
      },
      onError: (err) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      },
      onFeedUpdate: () {
        ref.invalidate(groupFeedProvider(widget.groupId));
      },
      onReactionUpdate: (postId) {
        ref.invalidate(groupFeedProvider(widget.groupId));
      },
      onCommentUpdate: (postId) {
        ref.invalidate(groupFeedProvider(widget.groupId));
      },
    );
    
    // Load initial chat history
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoadingChat = true);
    try {
      final history = await ref.read(groupServiceProvider).getGroupChatHistory(widget.groupId);
      final mappedHistory = history.map((msg) {
        return {
          'userId': msg['userId'],
          'userName': msg['user']?['profile']?['firstName'] ?? 'Member',
          'content': msg['content'],
          'toneLabel': msg['isFlagged'] == true ? 'FLAGGED' : null,
          'createdAt': msg['createdAt'],
        };
      }).toList();
      
      // Backend returns desc (newest first). 
      // We need it in asc (oldest first) so that appending new messages to the end works correctly.
      final reversedHistory = mappedHistory.reversed.toList();
      
      if (mounted) {
        setState(() {
          // Add historical messages to the list
          _messages.addAll(reversedHistory);
          _isLoadingChat = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingChat = false);
        debugPrint('Failed to load chat history: $e');
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_tabController.index == 0) {
      if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 500) {
        ref.read(groupFeedProvider(widget.groupId).notifier).loadMore();
      }
    }
    return false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupDetail = ref.watch(groupDetailProvider(widget.groupId));
    final auth = ref.watch(authProvider);
    final currentUserId = auth.userId ?? '0';

    return groupDetail.when(
      data: (group) => Scaffold(
        backgroundColor: const Color(0xFF0F0F12),
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF0F0F12),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    ref.invalidate(groupDetailProvider(widget.groupId));
                    ref.invalidate(groupFeedProvider(widget.groupId));
                    ref.invalidate(groupStatsProvider(widget.groupId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feed refreshed'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
                if (group.isMember)
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white24, size: 20),
                    onPressed: () => _showExitSheet(),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1A1A1E),
                        const Color(0xFF0F0F12),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group.title,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            _buildMoodIndicator(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${group.memberCount} members · ${group.category}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFB388FF),
                labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
                unselectedLabelColor: Colors.white38,
                labelColor: Colors.white,
                tabs: const [
                  Tab(text: 'FEED'),
                  Tab(text: 'CHAT'),
                  Tab(text: 'CHECK-IN'),
                  Tab(text: 'STATS'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedTab(currentUserId),
              _buildChatTab(),
              _buildCheckInTab(),
              _buildStatsTab(),
            ],
          ),
        ),
        ),
        floatingActionButton: group.isMember && _tabController.index == 0
            ? FloatingActionButton(
                onPressed: () => _showCreatePostSheet(),
                backgroundColor: const Color(0xFFB388FF),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              )
            : null,
        bottomNavigationBar: !group.isMember || group.onboardingStatus == 'PENDING' 
            ? _buildJoinBar(group) 
            : null,
      ),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F0F12),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF0F0F12),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildJoinBar(group) {
    final isPending = group.isMember && group.onboardingStatus == 'PENDING';
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!group.isMember)
            Text(
              'Join this circle to share, chat, and progress together.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
          if (!group.isMember) const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              if (!group.isMember) {
                await ref.read(groupServiceProvider).joinGroup(group.id);
                if (mounted) {
                  context.push('/groups/${group.id}/onboarding');
                  ref.invalidate(groupDetailProvider(widget.groupId));
                }
              } else {
                context.push('/groups/${group.id}/onboarding');
              }
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB388FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isPending ? 'COMPLETE ONBOARDING' : 'JOIN THIS CIRCLE',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFB388FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFB388FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mood_rounded, color: Color(0xFFB388FF), size: 14),
          const SizedBox(width: 6),
          Text(
            'Calm',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB388FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(String currentUserId) {
    final feed = ref.watch(groupFeedProvider(widget.groupId));
    final isLoadingMore = ref.watch(groupFeedProvider(widget.groupId).notifier).isLoadingMore;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildAlertBanner(
                '1 people felt lonely today. You\'re not alone.',
                const Color(0xFF1E1B2E),
                const Color(0xFFB388FF),
                Icons.groups_rounded,
              ),
              const SizedBox(height: 16),
              _buildSharePrompt(),
              const SizedBox(height: 24),
              _buildFeedTabs(),
            ]),
          ),
        ),
        
        feed.when(
          data: (posts) {
            if (posts.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEmptyFeed(),
                ),
              );
            }
            final sortedPosts = _getSortedPosts(posts);
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: sortedPosts.length + (isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == sortedPosts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFFB388FF)),
                      ),
                    );
                  }
                  final post = sortedPosts[index];
                  return GroupPostCard(
                    post: post,
                    currentUserId: currentUserId,
                    onTap: () => context.push('/groups/posts/${post.id}'),
                    onComment: () => context.push('/groups/posts/${post.id}'),
                    onBookmark: () {},
                    onReport: () {},
                    onReact: (type) async {
                      ref.read(groupFeedProvider(widget.groupId).notifier).toggleReaction(post.id, type, currentUserId);
                    },
                  );
                },
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error loading feed'))),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAlertBanner(String text, Color bg, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharePrompt() {
    return GestureDetector(
      onTap: _showCreatePostSheet,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit_rounded, color: Color(0xFF2E7D32), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What made you smile today?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tap to share',
                    style: GoogleFonts.inter(
                      color: Colors.white24,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white10),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFeedTab = 'FOR_YOU'),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedFeedTab == 'FOR_YOU' ? const Color(0xFF0F2E2E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: _selectedFeedTab == 'FOR_YOU' ? Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)) : null,
                ),
                child: Center(
                  child: Text(
                    'For You',
                    style: GoogleFonts.inter(
                      color: _selectedFeedTab == 'FOR_YOU' ? const Color(0xFF2E7D32) : Colors.white24,
                      fontSize: 13,
                      fontWeight: _selectedFeedTab == 'FOR_YOU' ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFeedTab = 'TRENDING'),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedFeedTab == 'TRENDING' ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Trending',
                    style: GoogleFonts.inter(
                      color: _selectedFeedTab == 'TRENDING' ? Colors.white : Colors.white24,
                      fontSize: 13,
                      fontWeight: _selectedFeedTab == 'TRENDING' ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<GroupPostModel> _getSortedPosts(List<GroupPostModel> posts) {
    if (_selectedFeedTab == 'FOR_YOU') {
      return posts; // Backend already returns For You ordered
    } else {
      // Sort locally by engagement for Trending
      final sorted = List<GroupPostModel>.from(posts);
      sorted.sort((a, b) {
        final aScore = a.reactionCount + (a.commentCount * 2);
        final bScore = b.reactionCount + (b.commentCount * 2);
        if (bScore != aScore) return bScore.compareTo(aScore);
        return b.createdAt.compareTo(a.createdAt);
      });
      return sorted;
    }
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.forum_outlined, color: Colors.white10, size: 64),
          const SizedBox(height: 16),
          Text(
            'The circle is quiet...',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share a thought or reflection.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: _isLoadingChat && _messages.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB388FF)))
              : _messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Say hello!',
                        style: GoogleFonts.inter(color: Colors.white24),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        // The list is populated with history (descending order) and new messages.
                        // Wait, _messages.add(msg) appends to the end of the list.
                        // And history is returned in 'desc' order (newest first).
                        // If we use reverse: true, index 0 should be the newest message.
                        // So if we have history (newest to oldest), and we append new messages,
                        // new messages are at the END of the list.
                        // This means the list order is: [oldest... newest (history)] -> [newest (socket)].
                        // Let's just fix the _messages order mapping!
                        // Actually, we'll fix the index logic directly below.
                        final msg = _messages[_messages.length - 1 - index];
                        return _buildChatBubble(msg);
                      },
                    ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final auth = ref.watch(authProvider);
    final String currentUserId = auth.userId ?? '0';
    final bool isMe = msg['userId'] == currentUserId;
    final String userName = msg['userName'] ?? 'Member';
    final Color userColor = _getUserColor(msg['userId'] ?? '0');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFB388FF) : userColor.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: isMe ? null : Border.all(color: userColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  userName,
                  style: GoogleFonts.inter(
                    color: userColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Text(
              msg['content'],
              style: GoogleFonts.inter(
                color: isMe ? Colors.black : Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (msg['toneLabel'] != null && msg['toneLabel'] != 'SAFE')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'AI Warning: ${msg['toneLabel']}',
                  style: GoogleFonts.inter(
                    color: Colors.redAccent,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getUserColor(String userId) {
    final colors = [
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFFFB74D), // Orange
      const Color(0xFFBA68C8), // Purple
      const Color(0xFFF06292), // Pink
      const Color(0xFF4DB6AC), // Teal
    ];
    return colors[userId.hashCode % colors.length];
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share a thought...',
                hintStyle: GoogleFonts.inter(color: Colors.white12),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFFB388FF)),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                final auth = ref.read(authProvider);
                _chatService?.sendMessage(auth.userId ?? '0', _messageController.text);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showExitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExitBottomSheet(
        onConfirm: (reason) async {
          await ref.read(groupServiceProvider).leaveGroup(widget.groupId, reason);
          if (mounted) {
            Navigator.pop(context); // Close sheet
            Navigator.pop(context); // Leave screen
            ref.invalidate(recommendedGroupsProvider);
          }
        },
      ),
    );
  }

  Widget _buildCheckInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: CheckInWidget(
        groupId: widget.groupId,
        onCompleted: () {
          _tabController.animateTo(0); // Switch to FEED tab
        },
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = ref.watch(groupStatsProvider(widget.groupId));
    return stats.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ProgressCard(stats: data),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading stats: $e')),
    );
  }

  void _showCreatePostSheet() {
    showGroupCreatePostSheet(context, widget.groupId);
  }
}
