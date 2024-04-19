import 'package:langchain/langchain.dart';

class LangchainHelpers {
  static RunnableSequence buildConversationChain(
      ChatPromptTemplate promptTemplate, BaseChatModel model, ConversationBufferMemory memory) {
    const stringOutputParser = StringOutputParser<ChatResult>();
    
    final chain = Runnable.fromMap({
      'input': Runnable.passthrough(),
      'history': Runnable.fromFunction(
        (final _, final __) async {
          final m = await memory.loadMemoryVariables();
          return m['history'];
        },
      ),
    }) |
    promptTemplate |
    model |
    stringOutputParser;

    return chain;
  }
}
