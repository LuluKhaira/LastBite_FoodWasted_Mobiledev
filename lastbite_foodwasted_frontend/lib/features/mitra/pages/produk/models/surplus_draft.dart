import 'package:flutter/material.dart';

enum TargetSurplus { manusia, pakan }
enum TipeProduk { paketKejutan, satuan }

class SurplusDraft {
  final String nama;
  final String catatan;
  final String kategori;
  final TargetSurplus target;
  final TipeProduk tipe;
  final int hargaAsli;
  final int hargaRescue;
  final int stok;
  final TimeOfDay mulaiAmbil;
  final TimeOfDay batasMaksimal;
  final bool tutupOtomatis;

  SurplusDraft({
    required this.nama,
    required this.catatan,
    required this.kategori,
    required this.target,
    required this.tipe,
    required this.hargaAsli,
    required this.hargaRescue,
    required this.stok,
    required this.mulaiAmbil,
    required this.batasMaksimal,
    required this.tutupOtomatis,
  });
}