import 'package:flutter/material.dart';
import 'package:remote_demo/model/post.dart';
import 'package:remote_demo/repository/post_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Demo',
      theme: ThemeData(
        primarySwatch: const Color.fromARGB(255, 61, 92, 118),
        useMaterial3: true,
      ),
      home: const PostScreen(),
    );
  }
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostRepository _repository = PostRepository();
  late Future<List<Post>> _posts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _posts = _repository.fetchPosts();
  }

  void _refreshPosts() {
    setState(() {
      _posts = _repository.fetchPosts();
    });
  }

  // FIXED: No BuildContext across async gaps
  void _sendPost() async {
    // Store context in local variable before async operation
    final currentContext = context;

    setState(() {
      _isLoading = true;
    });

    Post newPost = Post(
      title: "Hello Flutter API",
      body: "This is a test to see if it works",
      userId: 1,
    );

    try {
      Post createdPost = await _repository.createPost(newPost);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Success! Created Post ID: ${createdPost.id}"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      _refreshPosts();
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating post: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demo API"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPosts,
            tooltip: 'Refresh posts',
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Color.fromARGB(255, 58, 28, 26)),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Color.fromARGB(255, 125, 41, 35)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshPosts,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            if (posts.isEmpty) {
              return const Center(
                child: Text("No posts available"),
              );
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                Post post = posts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: const Color.fromARGB(255, 118, 134, 156),
                      child: Text(
                        post.id?.toString() ?? '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Post ID: ${post.id}"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("No posts available"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _sendPost,
        tooltip: 'Create new post',
        backgroundColor: _isLoading ? Colors.grey : const Color.fromARGB(255, 222, 226, 229),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.pink,
            strokeWidth: 3,
          ),
        )
            : const Icon(Icons.add),
      ),
    );
  }
}