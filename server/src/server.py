import grpc
from concurrent import futures
import time
import pyttsx3
from pydub import AudioSegment
import io
import server_pb2
import server_pb2_grpc

class TTSService(server_pb2_grpc.TTSServicer):
    def Synthesize(self, request, context):
        engine = pyttsx3.init()
        voices = engine.getProperty('voices')
        engine.setProperty('voice', voices[1].id)
        engine.setProperty('rate', 150)
        
        # Save TTS output to a temporary WAV file
        temp_wav_file = 'temp.wav'
        engine.save_to_file(request.text, temp_wav_file)
        engine.runAndWait()
        
        # Convert WAV file to MP3 and load into byte stream
        audio = AudioSegment.from_wav(temp_wav_file)
        buffer = io.BytesIO()
        audio.export(buffer, format='mp3')
        buffer.seek(0)
        audio_bytes = buffer.read()
        
        return server_pb2.TTSResponse(track=audio_bytes)

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
