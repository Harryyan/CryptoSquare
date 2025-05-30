class PostActionResp {
  String? message;
  int? code;
  Data? data;

  PostActionResp({this.message, this.code, this.data});

  PostActionResp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? rsType;
  String? rsId;
  int? value;
  int? userId;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.rsType,
    this.rsId,
    this.value,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rsType = json['rs_type'];
    rsId = json['rs_id'];
    value = json['value'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['rs_type'] = this.rsType;
    data['rs_id'] = this.rsId;
    data['value'] = this.value;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
