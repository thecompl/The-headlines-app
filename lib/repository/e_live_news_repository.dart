import 'dart:convert';
import 'dart:io';
import 'package:blog_app/models/e_news.dart';
import 'package:blog_app/models/live_news.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<List<ENews>> gewENews() async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}e-news-list';
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
  );
  if (response.statusCode == 200) {
    List<ENews> eNews = [];
    json.decode(response.body)['data']['data'].forEach((e) {
      eNews.add(ENews.fromJson(e));
    });
    return eNews;
  }
  return [];
}

Future<List<LiveNewsModel>> getliveNews() async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}live-news-list';
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
  );
  if (response.statusCode == 200) {
    List<LiveNewsModel> eNews = [];
    json.decode(response.body)['data']['data'].forEach((e) {
      eNews.add(LiveNewsModel.fromJson(e));
    });
    return eNews;
  }
  return [];
}
