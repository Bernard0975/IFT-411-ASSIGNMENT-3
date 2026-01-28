import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:remote_demo/model/post.dart';

class PostRepository {
  final String baseUrl = "https://jsonplaceholder.typicode.com";

  // GET Request - Fetch all posts
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Post.fromJson(item)).toList();
    } else {
      throw Exception("Post unable to load");
    }
  }

  // POST Request - Create a new post
  Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create post");
    }
  }
}