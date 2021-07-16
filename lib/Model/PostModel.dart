class PostModel {
  String? humanTimeDiff;
  int? id;
  String? image;
  bool? isFav;
  var noOfComments;
  String? postContent;
  String? postDate;
  String? postDateGmt;
  String? postExcerpt;
  String? postTitle;
  String? readableDate;
  String? shareUrl;
  String? postAuthorName;

  PostModel(
      {this.humanTimeDiff, this.id, this.image, this.isFav, this.noOfComments, this.postContent, this.postDate, this.postDateGmt, this.postExcerpt, this.postTitle, this.readableDate, this.shareUrl, this.postAuthorName});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      humanTimeDiff: json['human_time_diff'],
      id: json['ID'],
      image: json['image'],
      isFav: json['is_fav'],
      noOfComments: json['no_of_comments'],
      postContent: json['post_content'],
      postDate: json['post_date'],
      postDateGmt: json['post_date_gmt'],
      postExcerpt: json['post_excerpt'],
      postTitle: json['post_title'],
      readableDate: json['readable_date'],
      shareUrl: json['share_url'],
      postAuthorName: json['post_author_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['human_time_diff'] = this.humanTimeDiff;
    data['ID'] = this.id;
    data['image'] = this.image;
    data['is_fav'] = this.isFav;
    data['no_of_comments'] = this.noOfComments;
    data['post_content'] = this.postContent;
    data['post_date'] = this.postDate;
    data['post_date_gmt'] = this.postDateGmt;
    data['post_excerpt'] = this.postExcerpt;
    data['post_title'] = this.postTitle;
    data['readable_date'] = this.readableDate;
    data['share_url'] = this.shareUrl;
    data['post_author_name'] = this.postAuthorName;
    return data;
  }
}
