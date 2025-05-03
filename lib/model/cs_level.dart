class Level {
  int? levelId;
  String? levelName;
  String? levelIcon;
  bool? isVip;

  Level({this.levelId, this.levelName, this.levelIcon, this.isVip});

  Level.fromJson(Map<String, dynamic> json) {
    levelId = json['level_id'];
    levelName = json['level_name'];
    levelIcon = json['level_icon'];
    isVip = json['is_vip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['level_id'] = this.levelId;
    data['level_name'] = this.levelName;
    data['level_icon'] = this.levelIcon;
    data['is_vip'] = this.isVip;
    return data;
  }
}
