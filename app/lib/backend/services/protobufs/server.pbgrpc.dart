//
//  Generated code. Do not modify.
//  source: protobufs/server.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'server.pb.dart' as $0;

export 'server.pb.dart';

@$pb.GrpcServiceName('TTS')
class TTSClient extends $grpc.Client {
  static final _$synthesize = $grpc.ClientMethod<$0.TTSRequest, $0.TTSResponse>(
      '/TTS/Synthesize',
      ($0.TTSRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TTSResponse.fromBuffer(value));

  TTSClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.TTSResponse> synthesize($0.TTSRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$synthesize, request, options: options);
  }
}

@$pb.GrpcServiceName('TTS')
abstract class TTSServiceBase extends $grpc.Service {
  $core.String get $name => 'TTS';

  TTSServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TTSRequest, $0.TTSResponse>(
        'Synthesize',
        synthesize_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TTSRequest.fromBuffer(value),
        ($0.TTSResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.TTSResponse> synthesize_Pre($grpc.ServiceCall call, $async.Future<$0.TTSRequest> request) async {
    return synthesize(call, await request);
  }

  $async.Future<$0.TTSResponse> synthesize($grpc.ServiceCall call, $0.TTSRequest request);
}
