import 'package:equatable/equatable.dart';

class Coords extends Equatable {
  const Coords({required this.row, required this.column});

  final int row;
  final int column;

  @override
  String toString() => 'Coords(row: $row, column: $column)';

  @override
  List<Object?> get props => [row, column];
}
