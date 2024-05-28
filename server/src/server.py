import grpc
from concurrent import futures
import time
import server_pb2
import server_pb2_grpc
import pyttsx3
import io

class TTSService(server_pb2_grpc.TTSServicer):
    def Synthesize(self, request, context):
        engine = pyttsx3.init() 
        engine.say(request.text)
        engine.runAndWait()
        
        return server_pb2.TTSResponse(finished=True)

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    server_pb2_grpc.add_TTSServicer_to_server(TTSService(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("Server started on port 50051.")
    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        server.stop(0)
        print("Server stopped.")

if __name__ == '__main__':
    serve()
