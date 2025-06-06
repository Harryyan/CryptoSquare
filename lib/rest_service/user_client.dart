import 'dart:io';

import 'package:cryptosquare/model/collected_post.dart';
import 'package:cryptosquare/model/cs_user.dart';
import 'package:cryptosquare/model/cs_user_profile_data.dart';
import 'package:cryptosquare/model/job_collect_list.dart';
import 'package:cryptosquare/model/post_action_resp.dart';
import 'package:cryptosquare/model/user_post.dart';
import 'package:cryptosquare/models/checkIn_states.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:retrofit/retrofit.dart';

part 'user_client.g.dart';

Dio? _dio;

@RestApi(baseUrl: "https://d3qx0f55wsubto.cloudfront.net/api")
abstract class UserRestClient {
  factory UserRestClient() {
    _dio ??= Dio();
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String token = GStorage().getToken();

          options.headers["platform"] = Platform.isAndroid ? "android" : "ios";

          if (token.isNotEmpty) {
            options.headers["x-user-secret"] = token;
          }

          options.headers["app-version"] = '2.0.0';

          return handler.next(options);
        },
      ),
    );
    // _dio?.httpClientAdapter =
    //     IOHttpClientAdapter()
    //       // ignore: deprecated_member_use
    //       ..onHttpClientCreate = (client) {
    //         // Config the client.
    //         client.findProxy = (uri) {
    //           // Forward all request to proxy "localhost:8888".
    //           return 'PROXY 192.168.1.124:9090';
    //         };
    //         // You can also create a new HttpClient for Dio instead of returning,
    //         // but a client must being returned here.
    //         return client;
    //       };

    return _UserRestClient(_dio!);
  }

  @POST("/user/phone_verify")
  Future<CSUserResp> phoneVerify(
    @Field() String phone,
    @Field("lang") int lang,
  );

  @POST("/user/phone_login")
  Future<CSUserLoginResp> phoneLogin(
    @Field("phone") String phone,
    @Field("verification_code") String code,
    @Field("invite_code") String? inviteCode,
  );

  @POST("/user/phone_destory")
  Future<CSUserLoginResp> phoneDestory(
    @Field("phone") String phone,
    @Field("verification_code") String code,
    @Field("invite_code") String? inviteCode,
  );

  @POST("/user/email_verify")
  Future<CSUserResp> emailVerify(@Field() String email);

  @POST("/user/email_login")
  Future<CSUserLoginResp> emailLogin(
    @Field("email") String email,
    @Field("verification_code") String code,
    @Field("invite_code") String? inviteCode,
  );

  @POST("/user/email_destory")
  Future<CSUserLoginResp> emailDestory(
    @Field("email") String email,
    @Field("verification_code") String code,
    @Field("invite_code") String? inviteCode,
  );

  @POST("/thirdlogin/google_login")
  Future<CSUserLoginResp> googleLogin(
    @Field("accessToken") String? accessToken,
    @Field("idToken") String? idToken,
  );

  @POST("/bbs/user_check_in")
  Future<CSUserResp> checkIn();

  @GET("/bbs/user_profile")
  Future<UserProfileResp> userProfile();

  @GET("/bbs/user_check_in_status")
  Future<CheckInStateResp> checkInStatus();

  @POST("/user/avatar")
  Future<CSUserAvatarResp> uploadAvatar(
    @Part(name: "avatar") File? imageFile,
    @Part(name: "imageName") String imgName,
    @Part(name: "nickname") String nickname,
    @Part(name: "lang") int lang,
  );

  @GET("/v3/my/job_collect_list")
  Future<JobCollectListResp> getJobCollectList();

  @GET("/bbs-article/center/metaed")
  Future<CollectedPostResp> getCollectedPosts({
    @Query("type") String type = "eye",
    @Query("page_size") int pageSize = 20,
    @Query("page") int page = 1,
  });

  @POST("/bbs-article/meta/{target_id}")
  Future<PostActionResp> doAction(
    @Path("target_id") String targetId,
    @Field("action") String action,
  );

  @GET("/bbs-article/center")
  Future<UserPostResp> getUserPosts({
    @Query("page_size") int pageSize = 20,
    @Query("page") int page = 1,
    @Query("lang") int lang = 1,
  });
}
