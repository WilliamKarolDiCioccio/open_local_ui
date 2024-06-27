# Define the source directory for the protobuf files
$protobufFilesPath = ".\protobufs"
$serverProtoFileName = "server.proto"

# Generate the gRPC code using the protoc compiler
protoc --dart_out=grpc:./app/lib/backend/services "$protobufFilesPath\$serverProtoFileName"

# Output a message indicating that the code generation process is complete
Write-Output "Code generation complete. The executable has been moved to $targetDir"
