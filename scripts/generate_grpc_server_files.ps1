$workspacePath = (Get-Location).Path
$protobufFilesPath = ".\protobufs"

# Change directory to the protobuf files path
Set-Location -Path $protobufFilesPath

# Define the name of the server protocol buffer file
$serverProtoFileName = "server.proto"

# Generate the gRPC code using the protoc compiler
python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. $serverProtoFileName

# Change directory back to the original workspace path
Set-Location -Path $workspacePath

# Move the generated Python files to the source directory
Move-Item -Path ".\protobufs\*.py" -Destination ".\server\src" -Force

# Output a message indicating that the code generation process is complete
Write-Output "Code generation complete. The executable has been moved to $targetDir"
