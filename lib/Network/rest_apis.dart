import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/BaseResponse.dart' as b;
import 'package:news_flutter/Model/BookmarkNewsResponse.dart';
import 'package:news_flutter/Model/CategoryModel.dart';
import 'package:news_flutter/Model/CategoryWiseResponse.dart';
import 'package:news_flutter/Model/LoginResponse.dart';
import 'package:news_flutter/Screens/DashboardScreen.dart';
import 'package:news_flutter/Utils/constant.dart';

import '../main.dart';
import 'NetworkUtils.dart';

Future<LoginResponse> login(Map request, {bool isSocialLogin = false}) async {
  Response response = await postRequest(isSocialLogin ? 'iqonic-api/api/v1/customer/social_login' : 'jwt-auth/v1/token', request);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      if (jsonDecode(response.body).containsKey('code')) {
        if (jsonDecode(response.body)['code'].toString().contains('invalid_username')) {
          throw 'invalid_username';
        }
      }
    }
  }

  return await handleResponse(response).then((res) async {
    if (res.containsKey('code')) {
      if (res['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }

    LoginResponse loginResponse = LoginResponse.fromJson(res);

    await setValue(USER_ID, loginResponse.userId);
    await setValue(FIRST_NAME, loginResponse.firstName);
    await setValue(LAST_NAME, loginResponse.lastName);
    await setValue(USER_EMAIL, loginResponse.userEmail);
    await setValue(USERNAME, loginResponse.userNiceName);
    await setValue(TOKEN, loginResponse.token);
    await setValue(USER_DISPLAY_NAME, loginResponse.userDisplayName);
    await setValue(USER_LOGIN, loginResponse.userLogin);
    await setValue(IS_SOCIAL_LOGIN, isSocialLogin.validate());
    await setValue(IS_LOGGED_IN, true);

    if (loginResponse.profileImage != null) {
      await setValue(PROFILE_IMAGE, loginResponse.profileImage);
    }

    appStore.setUserId(loginResponse.userId);
    appStore.setUserEmail(loginResponse.userEmail);
    appStore.setFirstName(loginResponse.firstName);
    appStore.setLastName(loginResponse.lastName);
    appStore.setUserLogin(loginResponse.userLogin);
    appStore.setLoggedIn(true);

    if (isSocialLogin) {
      FirebaseAuth.instance.signOut();
      await setValue(IS_REMEMBERED, true);
    } else {
      appStore.setUserProfile(loginResponse.profileImage);
    }
    return loginResponse;
  }).catchError((e) {
    log(e);
    throw e.toString();
  });
}

Future createUser(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/registration', request, requireToken: false));
}

Future updateUser(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/registration', request, requireToken: false));
}

Future getDashboardApi(Map request, int page) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/get-dashboard?paged=$page&posts_per_page=8', request, requireToken: true));
}

Future getBlogDetail(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/get-post-details', request, requireToken: appStore.isLoggedIn ? true : false));
}

Future saveProfileImage(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/save-profile-image', request, requireToken: true));
}

Future getCategories({int? page, int perPage = perPageCategory, int? parent}) async {
  return handleResponse(await getRequest('wp/v2/categories/?parent=${parent ?? 0}&page=${page ?? 1}&per_page=$perPage', requireToken: false));
}

Future<CategoryWiseResponse> getBlogList(Map request) async {
  return CategoryWiseResponse.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/get-blog-by-filter/?posts_per_page=10', request, requireToken: true)));
}

Future<List<CategoriesModel>> getSubCategoriesList(int id) async {
  Iterable subCat = await handleResponse(await getRequest('wp/v2/categories?parent=$id&per_page=100'));
  return subCat.map((model) => CategoriesModel.fromJson(model)).toList();
}

Future getSearchBlogList(Map request, int page) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/get-blog-by-filter?paged=$page', request));
}

Future<b.BaseResponse> addWishList(Map request) async {
  return b.BaseResponse.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/add-fav-list', request, requireToken: true)));
}

Future<BookmarkNewsResponse> getWishList(Map request, int page) async {
  return BookmarkNewsResponse.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/get-fav-list?paged=$page&posts_per_page=$perPageItemInCategory', request, requireToken: true)));
}

Future removeWishList(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/delete-fav-list', request, requireToken: true));
}

Future getCommentList(int id) async {
  return handleResponse(await getRequest('wp/v2/comments/?post=$id', requireToken: false));
}

Future postComment(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/post-comment', request, requireToken: true));
}

Future forgotPassword(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/forget-password', request));
}

Future getVideoList(Map request, int page) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/get-video-list?paged=$page', request, requireToken: false));
}

Future changePassword(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/change-password', request, requireToken: true));
}

Future<void> logout(BuildContext context) async {
  await removeKey(TOKEN);
  await removeKey(USER_ID);
  await removeKey(FIRST_NAME);
  await removeKey(LAST_NAME);
  await removeKey(USERNAME);
  await removeKey(USER_DISPLAY_NAME);
  await removeKey(USER_PASSWORD);
  await removeKey(PROFILE_IMAGE);
  await removeKey(USER_EMAIL);
  await removeKey(IS_LOGGED_IN);
  await removeKey(IS_SOCIAL_LOGIN);
  await removeKey(USER_LOGIN);
  await removeKey(bookmarkData);

  appStore.setLoggedIn(false);
  appStore.setUserId(0);
  appStore.setUserEmail('');
  appStore.setFirstName('');
  appStore.setLastName('');
  appStore.setUserLogin('');

  DashboardScreen().launch(context, isNewTask: true);
}
