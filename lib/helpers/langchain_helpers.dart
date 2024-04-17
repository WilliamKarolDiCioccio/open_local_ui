import 'package:langchain/langchain.dart';

class LangchainHelpers {
  static dynamic buildConversationChain(String text, BaseChatModel model ) {
    const stringOutputParser = StringOutputParser<ChatResult>();
    final chain = model.pipe(stringOutputParser);

    return chain;
  }
}
