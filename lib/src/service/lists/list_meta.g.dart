// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'list_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ListMeta _$$_ListMetaFromJson(Map json) => $checkedCreate(
      r'_$_ListMeta',
      json,
      ($checkedConvert) {
        final val = _$_ListMeta(
          resultCount: $checkedConvert('result_count', (v) => v as int?),
        );
        return val;
      },
      fieldKeyMap: const {'resultCount': 'result_count'},
    );

Map<String, dynamic> _$$_ListMetaToJson(_$_ListMeta instance) =>
    <String, dynamic>{
      'result_count': instance.resultCount,
    };
