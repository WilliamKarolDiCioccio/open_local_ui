//
//  Generated code. Do not modify.
//  source: protobufs/server.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use tTSRequestDescriptor instead')
const TTSRequest$json = {
  '1': 'TTSRequest',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'gender', '3': 2, '4': 1, '5': 5, '10': 'gender'},
    {'1': 'age', '3': 3, '4': 1, '5': 5, '10': 'age'},
  ],
};

/// Descriptor for `TTSRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tTSRequestDescriptor = $convert.base64Decode(
    'CgpUVFNSZXF1ZXN0EhIKBHRleHQYASABKAlSBHRleHQSFgoGZ2VuZGVyGAIgASgFUgZnZW5kZX'
    'ISEAoDYWdlGAMgASgFUgNhZ2U=');

@$core.Deprecated('Use tTSResponseDescriptor instead')
const TTSResponse$json = {
  '1': 'TTSResponse',
  '2': [
    {'1': 'track', '3': 1, '4': 1, '5': 12, '10': 'track'},
  ],
};

/// Descriptor for `TTSResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tTSResponseDescriptor = $convert.base64Decode(
    'CgtUVFNSZXNwb25zZRIUCgV0cmFjaxgBIAEoDFIFdHJhY2s=');

