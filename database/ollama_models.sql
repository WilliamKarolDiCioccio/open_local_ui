PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            url TEXT,
            capabilities INTEGER
        );
INSERT INTO models VALUES(1,'llama3.2','Meta''s Llama 3.2 goes small with 1B and 3B models.','https://ollama.com/library/llama3.2',2);
INSERT INTO models VALUES(2,'llama3.1','Llama 3.1 is a new state-of-the-art model from Meta available in 8B, 70B and 405B parameter sizes.','https://ollama.com/library/llama3.1',2);
INSERT INTO models VALUES(3,'gemma2','Google Gemma 2 is a high-performing and efficient model available in three sizes: 2B, 9B, and 27B.','https://ollama.com/library/gemma2',0);
INSERT INTO models VALUES(4,'qwen2.5','Qwen2.5 models are pretrained on Alibaba''s latest large-scale dataset, encompassing up to 18 trillion tokens. The model supports up to 128K tokens and has multilingual support.','https://ollama.com/library/qwen2.5',2);
INSERT INTO models VALUES(5,'phi3.5','A lightweight AI model with 3.8 billion parameters with performance overtaking similarly and larger sized models.','https://ollama.com/library/phi3.5',0);
INSERT INTO models VALUES(6,'nemotron-mini','A commercial-friendly small language model by NVIDIA optimized for roleplay, RAG QA, and function calling.','https://ollama.com/library/nemotron-mini',2);
INSERT INTO models VALUES(7,'mistral-small','Mistral Small is a lightweight model designed for cost-effective use in tasks like translation and summarization.','https://ollama.com/library/mistral-small',2);
INSERT INTO models VALUES(8,'mistral-nemo','A state-of-the-art 12B model with 128k context length, built by Mistral AI in collaboration with NVIDIA.','https://ollama.com/library/mistral-nemo',2);
INSERT INTO models VALUES(9,'deepseek-coder-v2','An open-source Mixture-of-Experts code language model that achieves performance comparable to GPT4-Turbo in code-specific tasks.','https://ollama.com/library/deepseek-coder-v2',8);
INSERT INTO models VALUES(10,'mistral','The 7B model released by Mistral AI, updated to version 0.3.','https://ollama.com/library/mistral',2);
INSERT INTO models VALUES(11,'mixtral','A set of Mixture of Experts (MoE) model with open weights by Mistral AI in 8x7b and 8x22b parameter sizes.','https://ollama.com/library/mixtral',2);
INSERT INTO models VALUES(12,'codegemma','CodeGemma is a collection of powerful, lightweight models that can perform a variety of coding tasks like fill-in-the-middle code completion, code generation, natural language understanding, mathematical reasoning, and instruction following.','https://ollama.com/library/codegemma',8);
INSERT INTO models VALUES(13,'command-r','Command R is a Large Language Model optimized for conversational interaction and long context tasks.','https://ollama.com/library/command-r',2);
INSERT INTO models VALUES(14,'command-r-plus','Command R+ is a powerful, scalable large language model purpose-built to excel at real-world enterprise use cases.','https://ollama.com/library/command-r-plus',2);
INSERT INTO models VALUES(15,'llava','≡ƒîï LLaVA is a novel end-to-end trained large multimodal model that combines a vision encoder and Vicuna for general-purpose visual and language understanding. Updated to version 1.6.','https://ollama.com/library/llava',1);
INSERT INTO models VALUES(16,'llama3','Meta Llama 3: The most capable openly available LLM to date','https://ollama.com/library/llama3',0);
INSERT INTO models VALUES(17,'gemma','Gemma is a family of lightweight, state-of-the-art open models built by Google DeepMind. Updated to version 1.1','https://ollama.com/library/gemma',0);
INSERT INTO models VALUES(18,'qwen','Qwen 1.5 is a series of large language models by Alibaba Cloud spanning from 0.5B to 110B parameters','https://ollama.com/library/qwen',0);
INSERT INTO models VALUES(19,'qwen2','Qwen2 is a new series of large language models from Alibaba group','https://ollama.com/library/qwen2',2);
INSERT INTO models VALUES(20,'phi3','Phi-3 is a family of lightweight 3B (Mini) and 14B (Medium) state-of-the-art open models by Microsoft.','https://ollama.com/library/phi3',0);
INSERT INTO models VALUES(21,'llama2','Llama 2 is a collection of foundation language models ranging from 7B to 70B parameters.','https://ollama.com/library/llama2',0);
INSERT INTO models VALUES(22,'codellama','A large language model that can use text prompts to generate and discuss code.','https://ollama.com/library/codellama',8);
INSERT INTO models VALUES(23,'nomic-embed-text','A high-performing open embedding model with a large token context window.','https://ollama.com/library/nomic-embed-text',4);
INSERT INTO models VALUES(24,'dolphin-mixtral','Uncensored, 8x7b and 8x22b fine-tuned models based on the Mixtral mixture of experts models that excels at coding tasks. Created by Eric Hartford.','https://ollama.com/library/dolphin-mixtral',0);
INSERT INTO models VALUES(25,'mxbai-embed-large','State-of-the-art large embedding model from mixedbread.ai','https://ollama.com/library/mxbai-embed-large',4);
INSERT INTO models VALUES(26,'phi','Phi-2: a 2.7B language model by Microsoft Research that demonstrates outstanding reasoning and language understanding capabilities.','https://ollama.com/library/phi',0);
INSERT INTO models VALUES(27,'llama2-uncensored','Uncensored Llama 2 model by George Sung and Jarrad Hope.','https://ollama.com/library/llama2-uncensored',0);
INSERT INTO models VALUES(28,'deepseek-coder','DeepSeek Coder is a capable coding model trained on two trillion code and natural language tokens.','https://ollama.com/library/deepseek-coder',8);
INSERT INTO models VALUES(29,'starcoder2','StarCoder2 is the next generation of transparently trained open code LLMs that comes in three sizes: 3B, 7B and 15B parameters.','https://ollama.com/library/starcoder2',8);
INSERT INTO models VALUES(30,'dolphin-mistral','The uncensored Dolphin model based on Mistral that excels at coding tasks. Updated to version 2.8.','https://ollama.com/library/dolphin-mistral',0);
INSERT INTO models VALUES(31,'zephyr','Zephyr is a series of fine-tuned versions of the Mistral and Mixtral models that are trained to act as helpful assistants.','https://ollama.com/library/zephyr',0);
INSERT INTO models VALUES(32,'dolphin-llama3','Dolphin 2.9 is a new model with 8B and 70B sizes by Eric Hartford based on Llama 3 that has a variety of instruction, conversational, and coding skills.','https://ollama.com/library/dolphin-llama3',0);
INSERT INTO models VALUES(33,'yi','Yi 1.5 is a high-performing, bilingual language model.','https://ollama.com/library/yi',0);
INSERT INTO models VALUES(34,'orca-mini','A general-purpose model ranging from 3 billion parameters to 70 billion, suitable for entry-level hardware.','https://ollama.com/library/orca-mini',0);
INSERT INTO models VALUES(35,'llava-llama3','A LLaVA model fine-tuned from Llama 3 Instruct with better scores in several benchmarks.','https://ollama.com/library/llava-llama3',1);
INSERT INTO models VALUES(36,'mistral-openorca','Mistral OpenOrca is a 7 billion parameter model, fine-tuned on top of the Mistral 7B model using the OpenOrca dataset.','https://ollama.com/library/mistral-openorca',0);
INSERT INTO models VALUES(37,'starcoder','StarCoder is a code generation model trained on 80+ programming languages.','https://ollama.com/library/starcoder',8);
INSERT INTO models VALUES(38,'tinyllama','The TinyLlama project is an open endeavor to train a compact 1.1B Llama model on 3 trillion tokens.','https://ollama.com/library/tinyllama',0);
INSERT INTO models VALUES(39,'vicuna','General use chat model based on Llama and Llama 2 with 2K to 16K context sizes.','https://ollama.com/library/vicuna',0);
INSERT INTO models VALUES(40,'codestral','Codestral is Mistral AIΓÇÖs first-ever code model designed for code generation tasks.','https://ollama.com/library/codestral',8);
INSERT INTO models VALUES(41,'llama2-chinese','Llama 2 based model fine tuned to improve Chinese dialogue ability.','https://ollama.com/library/llama2-chinese',0);
INSERT INTO models VALUES(42,'wizard-vicuna-uncensored','Wizard Vicuna Uncensored is a 7B, 13B, and 30B parameter model based on Llama 2 uncensored by Eric Hartford.','https://ollama.com/library/wizard-vicuna-uncensored',0);
INSERT INTO models VALUES(43,'codegeex4','A versatile model for AI software development scenarios, including code completion.','https://ollama.com/library/codegeex4',8);
INSERT INTO models VALUES(44,'granite-code','A family of open foundation models by IBM for Code Intelligence','https://ollama.com/library/granite-code',8);
INSERT INTO models VALUES(45,'nous-hermes2','The powerful family of models by Nous Research that excels at scientific discussion and coding tasks.','https://ollama.com/library/nous-hermes2',0);
INSERT INTO models VALUES(46,'qwen2.5-coder','The latest series of Code-Specific Qwen models, with significant improvements in code generation, code reasoning, and code fixing.','https://ollama.com/library/qwen2.5-coder',2);
INSERT INTO models VALUES(47,'openchat','A family of open-source models trained on a wide variety of data, surpassing ChatGPT on various benchmarks. Updated to version 3.5-0106.','https://ollama.com/library/openchat',0);
INSERT INTO models VALUES(48,'aya','Aya 23, released by Cohere, is a new family of state-of-the-art, multilingual models that support 23 languages.','https://ollama.com/library/aya',0);
INSERT INTO models VALUES(49,'wizardlm2','State of the art large language model from Microsoft AI with improved performance on complex chat, multilingual, reasoning and agent use cases.','https://ollama.com/library/wizardlm2',0);
INSERT INTO models VALUES(50,'all-minilm','Embedding models on very large sentence level datasets.','https://ollama.com/library/all-minilm',4);
INSERT INTO models VALUES(51,'codeqwen','CodeQwen1.5 is a large language model pretrained on a large amount of code data.','https://ollama.com/library/codeqwen',8);
INSERT INTO models VALUES(52,'tinydolphin','An experimental 1.1B parameter model trained on the new Dolphin 2.8 dataset by Eric Hartford and based on TinyLlama.','https://ollama.com/library/tinydolphin',0);
INSERT INTO models VALUES(53,'wizardcoder','State-of-the-art code generation model','https://ollama.com/library/wizardcoder',8);
INSERT INTO models VALUES(54,'stable-code','Stable Code 3B is a coding model with instruct and code completion variants on par with models such as Code Llama 7B that are 2.5x larger.','https://ollama.com/library/stable-code',8);
INSERT INTO models VALUES(55,'openhermes','OpenHermes 2.5 is a 7B model fine-tuned by Teknium on Mistral with fully open datasets.','https://ollama.com/library/openhermes',0);
INSERT INTO models VALUES(56,'snowflake-arctic-embed','A suite of text embedding models by Snowflake, optimized for performance.','https://ollama.com/library/snowflake-arctic-embed',4);
INSERT INTO models VALUES(57,'bakllava','BakLLaVA is a multimodal model consisting of the Mistral 7B base model augmented with the LLaVA  architecture.','https://ollama.com/library/bakllava',1);
INSERT INTO models VALUES(58,'qwen2-math','Qwen2 Math is a series of specialized math language models built upon the Qwen2 LLMs, which significantly outperforms the mathematical capabilities of open-source models and even closed-source models (e.g., GPT4o).','https://ollama.com/library/qwen2-math',0);
INSERT INTO models VALUES(59,'llama3-gradient','This model extends LLama-3 8B''s context length from 8k to over 1m tokens.','https://ollama.com/library/llama3-gradient',0);
INSERT INTO models VALUES(60,'stablelm2','Stable LM 2 is a state-of-the-art 1.6B and 12B parameter language model trained on multilingual data in English, Spanish, German, Italian, French, Portuguese, and Dutch.','https://ollama.com/library/stablelm2',0);
INSERT INTO models VALUES(61,'deepseek-llm','An advanced language model crafted with 2 trillion bilingual tokens.','https://ollama.com/library/deepseek-llm',0);
INSERT INTO models VALUES(62,'wizard-math','Model focused on math and logic problems','https://ollama.com/library/wizard-math',0);
INSERT INTO models VALUES(63,'neural-chat','A fine-tuned model based on Mistral with good coverage of domain and language.','https://ollama.com/library/neural-chat',0);
INSERT INTO models VALUES(64,'glm4','A strong multi-lingual general language model with competitive performance to Llama 3.','https://ollama.com/library/glm4',0);
INSERT INTO models VALUES(65,'llama3-chatqa','A model from NVIDIA based on Llama 3 that excels at conversational question answering (QA) and retrieval-augmented generation (RAG).','https://ollama.com/library/llama3-chatqa',0);
INSERT INTO models VALUES(66,'phind-codellama','Code generation model based on Code Llama.','https://ollama.com/library/phind-codellama',8);
INSERT INTO models VALUES(67,'nous-hermes','General use models based on Llama and Llama 2 from Nous Research.','https://ollama.com/library/nous-hermes',0);
INSERT INTO models VALUES(68,'xwinlm','Conversational model based on Llama 2 that performs competitively on various benchmarks.','https://ollama.com/library/xwinlm',0);
INSERT INTO models VALUES(69,'sqlcoder','SQLCoder is a code completion model fined-tuned on StarCoder for SQL generation tasks','https://ollama.com/library/sqlcoder',8);
INSERT INTO models VALUES(70,'moondream','moondream2 is a small vision language model designed to run efficiently on edge devices.','https://ollama.com/library/moondream',1);
INSERT INTO models VALUES(71,'reflection','A high-performing model trained with a new technique called Reflection-tuning that teaches a LLM to detect mistakes in its reasoning and correct course.','https://ollama.com/library/reflection',0);
INSERT INTO models VALUES(72,'dolphincoder','A 7B and 15B uncensored variant of the Dolphin model family that excels at coding, based on StarCoder2.','https://ollama.com/library/dolphincoder',8);
INSERT INTO models VALUES(73,'yarn-llama2','An extension of Llama 2 that supports a context of up to 128k tokens.','https://ollama.com/library/yarn-llama2',0);
INSERT INTO models VALUES(74,'mistral-large','Mistral Large 2 is Mistral''s new flagship model that is significantly more capable in code generation, mathematics, and reasoning with 128k context window and support for dozens of languages.','https://ollama.com/library/mistral-large',2);
INSERT INTO models VALUES(75,'wizardlm','General use model based on Llama 2.','https://ollama.com/library/wizardlm',0);
INSERT INTO models VALUES(76,'smollm','≡ƒ¬É A family of small models with 135M, 360M, and 1.7B parameters, trained on a new high-quality dataset.','https://ollama.com/library/smollm',0);
INSERT INTO models VALUES(77,'deepseek-v2','A strong, economical, and efficient Mixture-of-Experts language model.','https://ollama.com/library/deepseek-v2',0);
INSERT INTO models VALUES(78,'starling-lm','Starling is a large language model trained by reinforcement learning from AI feedback focused on improving chatbot helpfulness.','https://ollama.com/library/starling-lm',0);
INSERT INTO models VALUES(79,replace('falcon\n      \nArchive','\n',char(10)),'A large language model built by the Technology Innovation Institute (TII) for use in summarization, text generation, and chat bots.','https://ollama.com/library/falcon',0);
INSERT INTO models VALUES(80,'samantha-mistral','A companion assistant trained in philosophy, psychology, and personal relationships. Based on Mistral.','https://ollama.com/library/samantha-mistral',0);
INSERT INTO models VALUES(81,'solar','A compact, yet powerful 10.7B large language model designed for single-turn conversation.','https://ollama.com/library/solar',0);
INSERT INTO models VALUES(82,'orca2','Orca 2 is built by Microsoft research, and are a fine-tuned version of Meta''s Llama 2 models.  The model is designed to excel particularly in reasoning.','https://ollama.com/library/orca2',0);
INSERT INTO models VALUES(83,'stable-beluga','Llama 2 based model fine tuned on an Orca-style dataset. Originally called Free Willy.','https://ollama.com/library/stable-beluga',0);
INSERT INTO models VALUES(84,'dolphin-phi','2.7B uncensored Dolphin model by Eric Hartford, based on the Phi language model by Microsoft Research.','https://ollama.com/library/dolphin-phi',0);
INSERT INTO models VALUES(85,'hermes3','Hermes 3 is the latest version of the flagship Hermes series of LLMs by Nous Research','https://ollama.com/library/hermes3',2);
INSERT INTO models VALUES(86,'llava-phi3','A new small LLaVA model fine-tuned from Phi 3 Mini.','https://ollama.com/library/llava-phi3',1);
INSERT INTO models VALUES(87,'yi-coder','Yi-Coder is a series of open-source code language models that delivers state-of-the-art coding performance with fewer than 10 billion parameters.','https://ollama.com/library/yi-coder',8);
INSERT INTO models VALUES(88,'wizardlm-uncensored','Uncensored version of Wizard LM model','https://ollama.com/library/wizardlm-uncensored',0);
INSERT INTO models VALUES(89,'internlm2','InternLM2.5 is a 7B parameter model tailored for practical scenarios with outstanding reasoning capability.','https://ollama.com/library/internlm2',0);
INSERT INTO models VALUES(90,'yarn-mistral','An extension of Mistral to support context windows of 64K or 128K.','https://ollama.com/library/yarn-mistral',0);
INSERT INTO models VALUES(91,'llama-pro','An expansion of Llama 2 that specializes in integrating both general language understanding and domain-specific knowledge, particularly in programming and mathematics.','https://ollama.com/library/llama-pro',0);
INSERT INTO models VALUES(92,'medllama2','Fine-tuned Llama 2 model to answer medical questions based on an open source medical dataset.','https://ollama.com/library/medllama2',0);
INSERT INTO models VALUES(93,'meditron','Open-source medical large language model adapted from Llama 2 to the medical domain.','https://ollama.com/library/meditron',0);
INSERT INTO models VALUES(94,'nexusraven','Nexus Raven is a 13B instruction tuned model for function calling tasks.','https://ollama.com/library/nexusraven',0);
INSERT INTO models VALUES(95,'nous-hermes2-mixtral','The Nous Hermes 2 model from Nous Research, now trained over Mixtral.','https://ollama.com/library/nous-hermes2-mixtral',0);
INSERT INTO models VALUES(96,'codeup','Great code generation model based on Llama2.','https://ollama.com/library/codeup',8);
INSERT INTO models VALUES(97,'everythinglm','Uncensored Llama2 based model with support for a 16K context window.','https://ollama.com/library/everythinglm',0);
INSERT INTO models VALUES(98,'llama3-groq-tool-use','A series of models from Groq that represent a significant advancement in open-source AI capabilities for tool use/function calling.','https://ollama.com/library/llama3-groq-tool-use',2);
INSERT INTO models VALUES(99,'magicoder','≡ƒÄ⌐ Magicoder is a family of 7B parameter models trained on 75K synthetic instruction data using OSS-Instruct, a novel approach to enlightening LLMs with open-source code snippets.','https://ollama.com/library/magicoder',8);
INSERT INTO models VALUES(100,'stablelm-zephyr','A lightweight chat model allowing accurate, and responsive output without requiring high-end hardware.','https://ollama.com/library/stablelm-zephyr',0);
INSERT INTO models VALUES(101,'codebooga','A high-performing code instruct model created by merging two existing code models.','https://ollama.com/library/codebooga',8);
INSERT INTO models VALUES(102,'mistrallite','MistralLite is a fine-tuned model based on Mistral with enhanced capabilities of processing long contexts.','https://ollama.com/library/mistrallite',0);
INSERT INTO models VALUES(103,'falcon2','Falcon2 is an 11B parameters causal decoder-only model built by TII and trained over 5T tokens.','https://ollama.com/library/falcon2',0);
INSERT INTO models VALUES(104,'duckdb-nsql','7B parameter text-to-SQL model made by MotherDuck and Numbers Station.','https://ollama.com/library/duckdb-nsql',8);
INSERT INTO models VALUES(105,'wizard-vicuna','Wizard Vicuna is a 13B parameter model based on Llama 2 trained by MelodysDreamj.','https://ollama.com/library/wizard-vicuna',0);
INSERT INTO models VALUES(106,'megadolphin','MegaDolphin-2.2-120b is a transformation of Dolphin-2.2-70b created by interleaving the model with itself.','https://ollama.com/library/megadolphin',0);
INSERT INTO models VALUES(107,'minicpm-v','A series of multimodal LLMs (MLLMs) designed for vision-language understanding.','https://ollama.com/library/minicpm-v',1);
INSERT INTO models VALUES(108,'notux','A top-performing mixture of experts model, fine-tuned with high-quality data.','https://ollama.com/library/notux',0);
INSERT INTO models VALUES(109,'goliath','A language model created by combining two fine-tuned Llama 2 70B models into one.','https://ollama.com/library/goliath',0);
INSERT INTO models VALUES(110,'open-orca-platypus2','Merge of the Open Orca OpenChat model and the Garage-bAInd Platypus 2 model. Designed for chat and code generation.','https://ollama.com/library/open-orca-platypus2',0);
INSERT INTO models VALUES(111,'notus','A 7B chat model fine-tuned with high-quality data and based on Zephyr.','https://ollama.com/library/notus',0);
INSERT INTO models VALUES(112,'bge-m3','BGE-M3 is a new model from BAAI distinguished for its versatility in Multi-Functionality, Multi-Linguality, and Multi-Granularity.','https://ollama.com/library/bge-m3',4);
INSERT INTO models VALUES(113,'mathstral','Math╬útral: a 7B model designed for math reasoning and scientific discovery by Mistral AI.','https://ollama.com/library/mathstral',0);
INSERT INTO models VALUES(114,'dbrx','DBRX is an open, general-purpose LLM created by Databricks.','https://ollama.com/library/dbrx',0);
INSERT INTO models VALUES(115,'nuextract','A 3.8B model fine-tuned on a private high-quality synthetic dataset for information extraction, based on Phi-3.','https://ollama.com/library/nuextract',0);
INSERT INTO models VALUES(116,'alfred','A robust conversational model designed to be used for both chat and instruct use cases.','https://ollama.com/library/alfred',0);
INSERT INTO models VALUES(117,'solar-pro','Solar Pro Preview: an advanced large language model (LLM) with 22 billion parameters designed to fit into a single GPU','https://ollama.com/library/solar-pro',0);
INSERT INTO models VALUES(118,'firefunction-v2','An open weights function calling model based on Llama 3, competitive with GPT-4o function calling capabilities.','https://ollama.com/library/firefunction-v2',2);
INSERT INTO models VALUES(119,'reader-lm','A series of models that convert HTML content to Markdown content, which is useful for content conversion tasks.','https://ollama.com/library/reader-lm',0);
INSERT INTO models VALUES(120,'bge-large','Embedding model from BAAI mapping texts to vectors.','https://ollama.com/library/bge-large',4);
INSERT INTO models VALUES(121,'deepseek-v2.5','An upgraded version of DeekSeek-V2  that integrates the general and coding abilities of both DeepSeek-V2-Chat and DeepSeek-Coder-V2-Instruct.','https://ollama.com/library/deepseek-v2.5',8);
INSERT INTO models VALUES(122,'paraphrase-multilingual','Sentence-transformers model that can be used for tasks like clustering or semantic search.','https://ollama.com/library/paraphrase-multilingual',4);
INSERT INTO models VALUES(123,'bespoke-minicheck','A state-of-the-art fact-checking model developed by Bespoke Labs.','https://ollama.com/library/bespoke-minicheck',0);
CREATE TABLE releases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_id INTEGER,
            num_params TEXT,
            size REAL,
            FOREIGN KEY(model_id) REFERENCES models(id)
        );
INSERT INTO releases VALUES(1,1,'1b',1300000000.0);
INSERT INTO releases VALUES(2,1,'3b',2000000000.0);
INSERT INTO releases VALUES(3,2,'8b',4700000000.0);
INSERT INTO releases VALUES(4,2,'70b',40000000000.0);
INSERT INTO releases VALUES(5,2,'405b',229000000000.0);
INSERT INTO releases VALUES(6,3,'2b',1600000000.0);
INSERT INTO releases VALUES(7,3,'9b',5400000000.0);
INSERT INTO releases VALUES(8,3,'27b',16000000000.0);
INSERT INTO releases VALUES(9,4,'0.5b',398000000.0);
INSERT INTO releases VALUES(10,4,'1.5b',986000000.0);
INSERT INTO releases VALUES(11,4,'3b',1900000000.0);
INSERT INTO releases VALUES(12,4,'7b',4700000000.0);
INSERT INTO releases VALUES(13,4,'14b',9000000000.0);
INSERT INTO releases VALUES(14,4,'32b',20000000000.0);
INSERT INTO releases VALUES(15,4,'72b',47000000000.0);
INSERT INTO releases VALUES(16,5,'3.8b',2200000000.0);
INSERT INTO releases VALUES(17,6,'4b',2700000000.0);
INSERT INTO releases VALUES(18,7,'22b',13000000000.0);
INSERT INTO releases VALUES(19,8,'12b',7100000000.0);
INSERT INTO releases VALUES(20,9,'16b',8900000000.0);
INSERT INTO releases VALUES(21,9,'236b',133000000000.0);
INSERT INTO releases VALUES(22,10,'7b',4099999999.999999523);
INSERT INTO releases VALUES(23,11,'8x7b',26000000000.0);
INSERT INTO releases VALUES(24,11,'8x22b',80000000000.0);
INSERT INTO releases VALUES(25,12,'2b',1600000000.0);
INSERT INTO releases VALUES(26,12,'7b',5000000000.0);
INSERT INTO releases VALUES(27,13,'35b',19000000000.0);
INSERT INTO releases VALUES(28,14,'104b',59000000000.0);
INSERT INTO releases VALUES(29,15,'7b',4700000000.0);
INSERT INTO releases VALUES(30,15,'13b',8000000000.0);
INSERT INTO releases VALUES(31,15,'34b',20000000000.0);
INSERT INTO releases VALUES(32,16,'8b',4700000000.0);
INSERT INTO releases VALUES(33,16,'70b',40000000000.0);
INSERT INTO releases VALUES(34,17,'2b',1700000000.0);
INSERT INTO releases VALUES(35,17,'7b',5000000000.0);
INSERT INTO releases VALUES(36,18,'0.5b',395000000.0);
INSERT INTO releases VALUES(37,18,'1.8b',1100000000.0);
INSERT INTO releases VALUES(38,18,'4b',2300000000.0);
INSERT INTO releases VALUES(39,18,'7b',4500000000.0);
INSERT INTO releases VALUES(40,18,'14b',8199999999.999999046);
INSERT INTO releases VALUES(41,18,'32b',18000000000.0);
INSERT INTO releases VALUES(42,18,'72b',41000000000.0);
INSERT INTO releases VALUES(43,18,'110b',63000000000.0);
INSERT INTO releases VALUES(44,19,'0.5b',352000000.0);
INSERT INTO releases VALUES(45,19,'1.5b',935000000.0);
INSERT INTO releases VALUES(46,19,'7b',4400000000.0);
INSERT INTO releases VALUES(47,19,'72b',41000000000.0);
INSERT INTO releases VALUES(48,20,'3.8b',2200000000.0);
INSERT INTO releases VALUES(49,20,'14b',7900000000.0);
INSERT INTO releases VALUES(50,21,'7b',3800000000.0);
INSERT INTO releases VALUES(51,21,'13b',7400000000.0);
INSERT INTO releases VALUES(52,21,'70b',39000000000.0);
INSERT INTO releases VALUES(53,22,'7b',3800000000.0);
INSERT INTO releases VALUES(54,22,'13b',7400000000.0);
INSERT INTO releases VALUES(55,22,'34b',19000000000.0);
INSERT INTO releases VALUES(56,22,'70b',39000000000.0);
INSERT INTO releases VALUES(57,23,'v1.5',274000000.0);
INSERT INTO releases VALUES(58,24,'8x7b',26000000000.0);
INSERT INTO releases VALUES(59,24,'8x22b',80000000000.0);
INSERT INTO releases VALUES(60,25,'335m',670000000.0);
INSERT INTO releases VALUES(61,26,'2.7b',1600000000.0);
INSERT INTO releases VALUES(62,27,'7b',3800000000.0);
INSERT INTO releases VALUES(63,27,'70b',39000000000.0);
INSERT INTO releases VALUES(64,28,'1.3b',776000000.0);
INSERT INTO releases VALUES(65,28,'6.7b',3800000000.0);
INSERT INTO releases VALUES(66,28,'33b',19000000000.0);
INSERT INTO releases VALUES(67,29,'3b',1700000000.0);
INSERT INTO releases VALUES(68,29,'7b',4000000000.0);
INSERT INTO releases VALUES(69,29,'15b',9100000000.0);
INSERT INTO releases VALUES(70,30,'7b',4099999999.999999523);
INSERT INTO releases VALUES(71,31,'7b',4099999999.999999523);
INSERT INTO releases VALUES(72,31,'141b',80000000000.0);
INSERT INTO releases VALUES(73,32,'8b',4700000000.0);
INSERT INTO releases VALUES(74,32,'70b',40000000000.0);
INSERT INTO releases VALUES(75,33,'6b',3500000000.0);
INSERT INTO releases VALUES(76,33,'9b',5000000000.0);
INSERT INTO releases VALUES(77,33,'34b',19000000000.0);
INSERT INTO releases VALUES(78,34,'3b',2000000000.0);
INSERT INTO releases VALUES(79,34,'7b',3800000000.0);
INSERT INTO releases VALUES(80,34,'13b',7400000000.0);
INSERT INTO releases VALUES(81,34,'70b',39000000000.0);
INSERT INTO releases VALUES(82,35,'8b',5500000000.0);
INSERT INTO releases VALUES(83,36,'7b',4099999999.999999523);
INSERT INTO releases VALUES(84,37,'1b',726000000.0);
INSERT INTO releases VALUES(85,37,'3b',1800000000.0);
INSERT INTO releases VALUES(86,37,'7b',4300000000.0);
INSERT INTO releases VALUES(87,37,'15b',9000000000.0);
INSERT INTO releases VALUES(88,38,'1.1b',638000000.0);
INSERT INTO releases VALUES(89,39,'7b',3800000000.0);
INSERT INTO releases VALUES(90,39,'13b',7400000000.0);
INSERT INTO releases VALUES(91,39,'33b',18000000000.0);
INSERT INTO releases VALUES(92,40,'22b',13000000000.0);
INSERT INTO releases VALUES(93,41,'7b',3800000000.0);
INSERT INTO releases VALUES(94,41,'13b',7400000000.0);
INSERT INTO releases VALUES(95,42,'7b',3800000000.0);
INSERT INTO releases VALUES(96,42,'13b',7400000000.0);
INSERT INTO releases VALUES(97,42,'30b',18000000000.0);
INSERT INTO releases VALUES(98,43,'9b',5500000000.0);
INSERT INTO releases VALUES(99,44,'3b',2000000000.0);
INSERT INTO releases VALUES(100,44,'8b',4600000000.0);
INSERT INTO releases VALUES(101,44,'20b',12000000000.0);
INSERT INTO releases VALUES(102,44,'34b',19000000000.0);
INSERT INTO releases VALUES(103,45,'10.7b',6100000000.0);
INSERT INTO releases VALUES(104,45,'34b',19000000000.0);
INSERT INTO releases VALUES(105,46,'1.5b',986000000.0);
INSERT INTO releases VALUES(106,46,'7b',4700000000.0);
INSERT INTO releases VALUES(107,47,'7b',4099999999.999999523);
INSERT INTO releases VALUES(108,48,'8b',4800000000.0);
INSERT INTO releases VALUES(109,48,'35b',20000000000.0);
INSERT INTO releases VALUES(110,49,'7b',4099999999.999999523);
INSERT INTO releases VALUES(111,49,'8x22b',80000000000.0);
INSERT INTO releases VALUES(112,50,'22m',46000000.0);
INSERT INTO releases VALUES(113,50,'33m',67000000.0);
INSERT INTO releases VALUES(114,51,'7b',4200000000.0);
INSERT INTO releases VALUES(115,52,'1.1b',637000000.0);
INSERT INTO releases VALUES(116,53,'33b',19000000000.0);
INSERT INTO releases VALUES(117,53,'python',3800000000.0);
INSERT INTO releases VALUES(118,54,'3b',1600000000.0);
INSERT INTO releases VALUES(119,55,'v2.5',4099999999.999999523);
INSERT INTO releases VALUES(120,56,'22m',46000000.0);
INSERT INTO releases VALUES(121,56,'33m',67000000.0);
INSERT INTO releases VALUES(122,56,'110m',219000000.0);
INSERT INTO releases VALUES(123,56,'137m',274000000.0);
INSERT INTO releases VALUES(124,56,'335m',669000000.0);
INSERT INTO releases VALUES(125,57,'7b',4700000000.0);
INSERT INTO releases VALUES(126,58,'1.5b',935000000.0);
INSERT INTO releases VALUES(127,58,'7b',4400000000.0);
INSERT INTO releases VALUES(128,58,'72b',41000000000.0);
INSERT INTO releases VALUES(129,59,'1048k',4700000000.0);
INSERT INTO releases VALUES(130,59,'8b',4700000000.0);
INSERT INTO releases VALUES(131,59,'70b',40000000000.0);
INSERT INTO releases VALUES(132,60,'1.6b',983000000.0);
INSERT INTO releases VALUES(133,60,'12b',7000000000.0);
INSERT INTO releases VALUES(134,61,'7b',4000000000.0);
INSERT INTO releases VALUES(135,61,'67b',38000000000.0);
INSERT INTO releases VALUES(136,62,'7b',4099999999.999999523);
INSERT INTO releases VALUES(137,62,'13b',7400000000.0);
INSERT INTO releases VALUES(138,62,'70b',39000000000.0);
INSERT INTO releases VALUES(139,63,'7b',4099999999.999999523);
INSERT INTO releases VALUES(140,64,'9b',5500000000.0);
INSERT INTO releases VALUES(141,65,'8b',4700000000.0);
INSERT INTO releases VALUES(142,65,'70b',40000000000.0);
INSERT INTO releases VALUES(143,66,'34b',19000000000.0);
INSERT INTO releases VALUES(144,67,'7b',3800000000.0);
INSERT INTO releases VALUES(145,67,'13b',7400000000.0);
INSERT INTO releases VALUES(146,68,'7b',3800000000.0);
INSERT INTO releases VALUES(147,68,'13b',7400000000.0);
INSERT INTO releases VALUES(148,69,'7b',4099999999.999999523);
INSERT INTO releases VALUES(149,69,'15b',9000000000.0);
INSERT INTO releases VALUES(150,70,'1.8b',1700000000.0);
INSERT INTO releases VALUES(151,71,'70b',40000000000.0);
INSERT INTO releases VALUES(152,72,'7b',4200000000.0);
INSERT INTO releases VALUES(153,72,'15b',9100000000.0);
INSERT INTO releases VALUES(154,73,'7b',3800000000.0);
INSERT INTO releases VALUES(155,73,'13b',7400000000.0);
INSERT INTO releases VALUES(156,74,'123b',69000000000.0);
INSERT INTO releases VALUES(157,76,'135m',92000000.0);
INSERT INTO releases VALUES(158,76,'360m',229000000.0);
INSERT INTO releases VALUES(159,76,'1.7b',991000000.0);
INSERT INTO releases VALUES(160,77,'16b',8900000000.0);
INSERT INTO releases VALUES(161,77,'236b',133000000000.0);
INSERT INTO releases VALUES(162,78,'7b',4099999999.999999523);
INSERT INTO releases VALUES(163,79,'7b',4200000000.0);
INSERT INTO releases VALUES(164,79,'40b',24000000000.0);
INSERT INTO releases VALUES(165,79,'180b',101000000000.0);
INSERT INTO releases VALUES(166,80,'7b',4099999999.999999523);
INSERT INTO releases VALUES(167,81,'10.7b',6100000000.0);
INSERT INTO releases VALUES(168,82,'7b',3800000000.0);
INSERT INTO releases VALUES(169,82,'13b',7400000000.0);
INSERT INTO releases VALUES(170,83,'7b',3800000000.0);
INSERT INTO releases VALUES(171,83,'13b',7400000000.0);
INSERT INTO releases VALUES(172,83,'70b',39000000000.0);
INSERT INTO releases VALUES(173,84,'2.7b',1600000000.0);
INSERT INTO releases VALUES(174,85,'8b',4700000000.0);
INSERT INTO releases VALUES(175,85,'70b',40000000000.0);
INSERT INTO releases VALUES(176,85,'405b',229000000000.0);
INSERT INTO releases VALUES(177,86,'3.8b',2900000000.0);
INSERT INTO releases VALUES(178,87,'1.5b',866000000.0);
INSERT INTO releases VALUES(179,87,'9b',5000000000.0);
INSERT INTO releases VALUES(180,88,'13b',7400000000.0);
INSERT INTO releases VALUES(181,89,'1m',4500000000.0);
INSERT INTO releases VALUES(182,89,'1.8b',1100000000.0);
INSERT INTO releases VALUES(183,89,'7b',4500000000.0);
INSERT INTO releases VALUES(184,89,'20b',11000000000.0);
INSERT INTO releases VALUES(185,90,'7b',4099999999.999999523);
INSERT INTO releases VALUES(186,91,'instruct',4700000000.0);
INSERT INTO releases VALUES(187,92,'7b',3800000000.0);
INSERT INTO releases VALUES(188,93,'7b',3800000000.0);
INSERT INTO releases VALUES(189,93,'70b',39000000000.0);
INSERT INTO releases VALUES(190,94,'13b',7400000000.0);
INSERT INTO releases VALUES(191,95,'8x7b',26000000000.0);
INSERT INTO releases VALUES(192,96,'13b',7400000000.0);
INSERT INTO releases VALUES(193,97,'13b',7400000000.0);
INSERT INTO releases VALUES(194,98,'8b',4700000000.0);
INSERT INTO releases VALUES(195,98,'70b',40000000000.0);
INSERT INTO releases VALUES(196,99,'7b',3800000000.0);
INSERT INTO releases VALUES(197,100,'3b',1600000000.0);
INSERT INTO releases VALUES(198,101,'34b',19000000000.0);
INSERT INTO releases VALUES(199,102,'7b',4099999999.999999523);
INSERT INTO releases VALUES(200,103,'11b',6400000000.0);
INSERT INTO releases VALUES(201,104,'7b',3800000000.0);
INSERT INTO releases VALUES(202,105,'13b',7400000000.0);
INSERT INTO releases VALUES(203,106,'120b',68000000000.0);
INSERT INTO releases VALUES(204,107,'8b',5500000000.0);
INSERT INTO releases VALUES(205,108,'8x7b',26000000000.0);
INSERT INTO releases VALUES(206,109,'120b-q4_0',66000000000.0);
INSERT INTO releases VALUES(207,110,'13b',7400000000.0);
INSERT INTO releases VALUES(208,111,'7b',4099999999.999999523);
INSERT INTO releases VALUES(209,112,'567m',1200000000.0);
INSERT INTO releases VALUES(210,113,'7b',4099999999.999999523);
INSERT INTO releases VALUES(211,114,'132b',74000000000.0);
INSERT INTO releases VALUES(212,115,'3.8b',2200000000.0);
INSERT INTO releases VALUES(213,116,'40b',24000000000.0);
INSERT INTO releases VALUES(214,117,'22b',13000000000.0);
INSERT INTO releases VALUES(215,118,'70b',40000000000.0);
INSERT INTO releases VALUES(216,119,'0.5b',352000000.0);
INSERT INTO releases VALUES(217,119,'1.5b',935000000.0);
INSERT INTO releases VALUES(218,120,'335m',671000000.0);
INSERT INTO releases VALUES(219,121,'236b',133000000000.0);
INSERT INTO releases VALUES(220,122,'278m',563000000.0);
INSERT INTO releases VALUES(221,123,'7b',4700000000.0);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('models',123);
INSERT INTO sqlite_sequence VALUES('releases',221);
CREATE INDEX idx_model_name ON models (name);
CREATE INDEX idx_model_capabilities ON models (capabilities);
COMMIT;
