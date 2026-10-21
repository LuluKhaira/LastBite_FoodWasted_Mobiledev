class MitraModel {
  final int? id;
  final String? nama;
  final String? email;

  MitraModel({this.id, this.nama, this.email});

  factory MitraModel.fromJson(Map<String, dynamic> json) {
    return MitraModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
    );
  }
}