// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 2;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Loan(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      type: fields[4] as LoanType,
      isSettled: fields[5] as bool,
      settledDate: fields[6] as DateTime?,
      description: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isSettled)
      ..writeByte(6)
      ..write(obj.settledDate)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanTypeAdapter extends TypeAdapter<LoanType> {
  @override
  final int typeId = 3;

  @override
  LoanType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoanType.given;
      case 1:
        return LoanType.taken;
      default:
        return LoanType.given;
    }
  }

  @override
  void write(BinaryWriter writer, LoanType obj) {
    switch (obj) {
      case LoanType.given:
        writer.writeByte(0);
        break;
      case LoanType.taken:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
