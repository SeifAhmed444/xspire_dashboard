import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';

abstract class ImageRepo {
  Future<Either<Failure, String>> uploadImage(File image);
}
