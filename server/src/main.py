import io
import time
from concurrent import futures
import pyttsx3
import grpc
from pydub import AudioSegment
from langdetect import detect
import server_pb2
import server_pb2_grpc


class TTSService(server_pb2_grpc.TTSServicer):
    def __init__(self):
        self.engine = pyttsx3.init()
    
    def detect_language(self, text):
        try:
            lang = detect(text)
            return lang
        except Exception as e:
            print(f"Error detecting language: {e}")
            return "en"

    def select_voice(self, engine, lang):
        voices = engine.getProperty('voices')
        for voice in voices:
            if lang in voice.id.lower():
                return voice.id
        return voices[0].id

    def Synthesize(self, request, context):
        detected_lang = self.detect_language(request.text)
        voice_id = self.select_voice(self.engine, detected_lang)
        
        self.engine.setProperty('voice', voice_id)
        self.engine.setProperty('rate', 150)
        
        temp_wav_file = 'temp.wav'
        self.engine.save_to_file(request.text, temp_wav_file)
        self.engine.runAndWait()
        
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
