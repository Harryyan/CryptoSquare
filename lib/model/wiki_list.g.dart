// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WikiListResponse _$WikiListResponseFromJson(Map<String, dynamic> json) =>
    WikiListResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => WikiItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$WikiListResponseToJson(WikiListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

WikiItem _$WikiItemFromJson(Map<String, dynamic> json) => WikiItem(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  intro: json['intro'] as String?,
  slug: json['slug'] as String?,
  img: json['img'] as String?,
);

Map<String, dynamic> _$WikiItemToJson(WikiItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'intro': instance.intro,
  'slug': instance.slug,
  'img': instance.img,
};

WikiDetailResponse _$WikiDetailResponseFromJson(Map<String, dynamic> json) =>
    WikiDetailResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          json['data'] == null
              ? null
              : WikiDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WikiDetailResponseToJson(WikiDetailResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

WikiDetailData _$WikiDetailDataFromJson(Map<String, dynamic> json) =>
    WikiDetailData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      lang: (json['lang'] as num?)?.toInt(),
      intro: json['intro'] as String?,
      img: json['img'] as String?,
      description: json['description'] as String?,
      webSite: json['web_site'] as String?,
      logoUrl: json['logo_url'] as String?,
      portfolio:
          (json['portfolio'] as List<dynamic>?)
              ?.map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      investors:
          (json['investors'] as List<dynamic>?)
              ?.map(
                (e) => InvestorDetailItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => MemberDetailItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      social:
          json['social'] == null
              ? null
              : SocialLinks.fromJson(json['social'] as Map<String, dynamic>),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => TagItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      slug: json['slug'] as String?,
    );

Map<String, dynamic> _$WikiDetailDataToJson(WikiDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lang': instance.lang,
      'intro': instance.intro,
      'img': instance.img,
      'description': instance.description,
      'web_site': instance.webSite,
      'logo_url': instance.logoUrl,
      'portfolio': instance.portfolio,
      'investors': instance.investors,
      'members': instance.members,
      'social': instance.social,
      'tags': instance.tags,
      'slug': instance.slug,
    };

PortfolioItem _$PortfolioItemFromJson(Map<String, dynamic> json) =>
    PortfolioItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      webSite: json['web_site'] as String?,
      intro: json['intro'] as String?,
      slug: json['slug'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'web_site': instance.webSite,
      'intro': instance.intro,
      'slug': instance.slug,
      'img': instance.img,
    };

InvestorDetailItem _$InvestorDetailItemFromJson(Map<String, dynamic> json) =>
    InvestorDetailItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      webSite: json['web_site'] as String?,
      intro: json['intro'] as String?,
      slug: json['slug'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$InvestorDetailItemToJson(InvestorDetailItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'web_site': instance.webSite,
      'intro': instance.intro,
      'slug': instance.slug,
      'img': instance.img,
    };

MemberDetailItem _$MemberDetailItemFromJson(Map<String, dynamic> json) =>
    MemberDetailItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      webSite: json['web_site'] as String?,
      intro: json['intro'] as String?,
      slug: json['slug'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$MemberDetailItemToJson(MemberDetailItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'web_site': instance.webSite,
      'intro': instance.intro,
      'slug': instance.slug,
      'img': instance.img,
    };

SocialLinks _$SocialLinksFromJson(Map<String, dynamic> json) => SocialLinks(
  twitter: json['twitter'] as String?,
  medium: json['medium'] as String?,
  linkedin: json['linkedin'] as String?,
  github: json['github'] as String?,
  telegram: json['telegram'] as String?,
  youtube: json['youtube'] as String?,
  reddit: json['reddit'] as String?,
  facebook: json['facebook'] as String?,
  weibo: json['weibo'] as String?,
);

Map<String, dynamic> _$SocialLinksToJson(SocialLinks instance) =>
    <String, dynamic>{
      'twitter': instance.twitter,
      'medium': instance.medium,
      'linkedin': instance.linkedin,
      'github': instance.github,
      'telegram': instance.telegram,
      'youtube': instance.youtube,
      'reddit': instance.reddit,
      'facebook': instance.facebook,
      'weibo': instance.weibo,
    };

TagItem _$TagItemFromJson(Map<String, dynamic> json) => TagItem(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  slug: json['slug'] as String?,
);

Map<String, dynamic> _$TagItemToJson(TagItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
};

WikiSearchResponse _$WikiSearchResponseFromJson(Map<String, dynamic> json) =>
    WikiSearchResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          json['data'] == null
              ? null
              : WikiSearchData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WikiSearchResponseToJson(WikiSearchResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

WikiSearchData _$WikiSearchDataFromJson(Map<String, dynamic> json) =>
    WikiSearchData(
      total: (json['total'] as num?)?.toInt(),
      currentPage: (json['current_page'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => WikiSearchItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$WikiSearchDataToJson(WikiSearchData instance) =>
    <String, dynamic>{
      'total': instance.total,
      'current_page': instance.currentPage,
      'data': instance.data,
    };

WikiSearchItem _$WikiSearchItemFromJson(Map<String, dynamic> json) =>
    WikiSearchItem(
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      descs: json['descs'] as String?,
      intro: json['intro'] as String?,
      img: json['img'] as String?,
      url: json['url'] as String?,
      category: (json['category'] as num?)?.toInt(),
      lang: (json['lang'] as num?)?.toInt(),
      link: json['link'] as String?,
    );

Map<String, dynamic> _$WikiSearchItemToJson(WikiSearchItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'descs': instance.descs,
      'intro': instance.intro,
      'img': instance.img,
      'url': instance.url,
      'category': instance.category,
      'lang': instance.lang,
      'link': instance.link,
    };
