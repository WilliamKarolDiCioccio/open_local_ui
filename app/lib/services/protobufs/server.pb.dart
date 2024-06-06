//
//  Generated code. Do not modify.
//  source: protobufs/server.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TTSRequest extends $pb.GeneratedMessage {
  factory TTSRequest({
    $core.String? text,
    $core.int? gender,
    $core.int? age,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    if (gender != null) {
      $result.gender = gender;
    }
    if (age != null) {
      $result.age = age;
    }
    return $result;
  }
  TTSRequest._() : super();
  factory TTSRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TTSRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TTSRequest', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'gender', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'age', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TTSRequest clone() => TTSRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TTSRequest copyWith(void Function(TTSRequest) updates) => super.copyWith((message) => updates(message as TTSRequest)) as TTSRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TTSRequest create() => TTSRequest._();
  TTSRequest createEmptyInstance() => create();
  static $pb.PbList<TTSRequest> createRepeated() => $pb.PbList<TTSRequest>();
  @$core.pragma('dart2js:noInline')
  static TTSRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TTSRequest>(create);
  static TTSRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get gender => $_getIZ(1);
  @$pb.TagNumber(2)
  set gender($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGender() => $_has(1);
  @$pb.TagNumber(2)
  void clearGender() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get age => $_getIZ(2);
  @$pb.TagNumber(3)
  set age($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAge() => $_has(2);
  @$pb.TagNumber(3)
  void clearAge() => clearField(3);
}

class TTSResponse extends $pb.GeneratedMessage {
  factory TTSResponse({
    $core.List<$core.int>? track,
  }) {
    final $result = create();
    if (track != null) {
      $result.track = track;
    }
    return $result;
  }
  TTSResponse._() : super();
  factory TTSResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TTSResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TTSResponse', createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'track', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TTSResponse clone() => TTSResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TTSResponse copyWith(void Function(TTSResponse) updates) => super.copyWith((message) => updates(message as TTSResponse)) as TTSResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TTSResponse create() => TTSResponse._();
  TTSResponse createEmptyInstance() => create();
  static $pb.PbList<TTSResponse> createRepeated() => $pb.PbList<TTSResponse>();
  @$core.pragma('dart2js:noInline')
  static TTSResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TTSResponse>(create);
  static TTSResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get track => $_getN(0);
  @$pb.TagNumber(1)
  set track($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTrack() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrack() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
