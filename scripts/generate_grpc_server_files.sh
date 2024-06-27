#!/bin/bash

# Save the current directory (workspace path)
workspacePath=$(pwd)
protobufFilesPath="./protobufs"

# Change directory to the protobuf files path
cd "$protobufFilesPath"

# Define the name of the server protocol buffer file
serverProtoFileName="server.proto"

# Generate the gRPC code using the protoc compiler
python3 -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. "$serverProtoFileName"

# Change directory back to the original workspace path
cd "$workspacePath"

# Move the generated Python files to the source directory
mv "$protobufFilesPath"/*.py ./server/src/

# Output a message indicating that the code generation process is complete
echo "Code generation complete. The executable has been moved to ./server/src"
