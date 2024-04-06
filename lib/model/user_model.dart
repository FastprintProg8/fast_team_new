// To parse this JSON data, do
//
//     final dataAccountModel = dataAccountModelFromJson(jsonString);

import 'dart:convert';

DataAccountModel dataAccountModelFromJson(String str) =>
    DataAccountModel.fromJson(json.decode(str));

class DataAccountModel {
  int? idUser;
  int? empoloyeeId;
  String? email;
  String? nama;
  String? fullname;
  String? imgProf;
  String? imgUrl;
  String? divisiName;
  String? namaLokasi;
  String? shiftName;
  String? masukAwal;
  String? masukAkhir;
  String? keluarAwal;
  String? keluarAkhir;
  String? shift;
  

  //personal info

  String? jenisKelamin;
  String? tempatLahir;
  String? tanggalLahir;
  String? noHp;
  String? statusPerinkahan;
  String? agama;
  int? nomorID;
  String? alamatIdentitas;
  String? alamatTinggal;

  DataAccountModel({
    this.idUser,
    this.empoloyeeId,
    this.email,
    this.nama,
    this.fullname,
    this.imgProf,
    this.imgUrl,
    this.divisiName,
    this.namaLokasi,
    this.shift,
    
    this.shiftName,
    this.masukAkhir,
    this.masukAwal,
    this.keluarAkhir,
    this.keluarAwal,

    //personal info
    this.jenisKelamin,
    this.tempatLahir,
    this.tanggalLahir,
    this.noHp,
    this.statusPerinkahan,
    this.agama,
    this.nomorID,
    this.alamatIdentitas,
    this.alamatTinggal,
  });

  factory DataAccountModel.fromJson(Map<String, dynamic> json) =>
      DataAccountModel(
        idUser: json['id_user'],
        divisiName: json['divisi']['name'],
        email: json['email'],
        nama: json['nama'],
        fullname: "${json['nama_awal']} ${json['nama_akhir']}",
        imgProf: json['img_prof'],
        imgUrl: json['img_url'],
        namaLokasi: json['nama_lokasi'],
        shiftName: json['shift']['name'] ?? '',
        masukAkhir: json['clock_in']['max'] ?? '',
        masukAwal: json['clock_in']['min'] ?? '',
        keluarAkhir: json['clock_out']['max'] ?? '',
        keluarAwal: json['clock_out']['min'] ?? '',

        //personal info
        jenisKelamin: json['gender']['name'],
        tempatLahir: json['tempat_lahir'],
        tanggalLahir: json['tanggal_lahir'],
        noHp: json['nomor_hp'],
        statusPerinkahan: json['status_kawin']['name'],
        agama: json['agama']['name'],
        nomorID: json['nomor_ktp'],
        alamatIdentitas: json['alamat_ktp'],
        alamatTinggal: json['alamat_tinggal'],
      );
}
