class CheckInStateResp {
  String? message;
  int? code;
  Data? data;

  CheckInStateResp({this.message, this.code, this.data});

  CheckInStateResp.fromJson(Map<String, dynamic> json) {
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
  bool? isCheckIn;

  Data({this.isCheckIn});

  Data.fromJson(Map<String, dynamic> json) {
    isCheckIn = json['is_check_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_check_in'] = this.isCheckIn;
    return data;
  }
}
