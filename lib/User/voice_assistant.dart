import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class VoiceAssistant {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool isVoiceEnabled = true;
  String selectedLanguage = 'en-US'; // Default language is enflish

  // Available languages
  final Map<String, String> languages = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Marathi': 'mr-IN',
    'Telugu': 'te-IN',
  };

  // Predefined questions based on selected language
  Map<String, List<String>> predefinedQuestions = {
    'en-US': [
      'Hello',
      'What services do you offer?',
      'How much does it cost?',
      'How do I book a maid?',
      'What is the cancellation policy?',
      'Do you provide same-day services?',
      'Are your maids verified?',
      'Can I schedule recurring bookings?',
      'How do I contact customer support?',
      'Do you offer deep cleaning services?'
    ],
    'hi-IN': [
      'नमस्ते',
      'आप कौन-कौन सी सेवाएँ प्रदान करते हैं?',
      'इसकी कीमत कितनी है?',
      'मैं मेड कैसे बुक कर सकता हूँ?',
      'रद्द करने की नीति क्या है?',
      'क्या आप उसी दिन सेवाएँ प्रदान करते हैं?',
      'क्या आपकी मेड्स सत्यापित हैं?',
      'क्या मैं पुनरावृत्ति बुकिंग शेड्यूल कर सकता हूँ?',
      'मैं ग्राहक सहायता से कैसे संपर्क करूँ?',
      'क्या आप गहरी सफाई सेवाएँ प्रदान करते हैं?'
    ],
    'mr-IN': [
      'नमस्कार',
      'तुम्ही कोणत्या सेवा पुरवता?',
      'त्याची किंमत किती आहे?',
      'मी मेड कशी बुक करू शकतो?',
      'रद्द करण्याची पद्धत काय आहे?',
      'तुम्ही त्याच दिवशी सेवा देता का?',
      'तुमच्या मेड्स प्रमाणित आहेत का?',
      'मी पुनरावृत्ती बुकिंग करू शकतो का?',
      'मी ग्राहक सहाय्य कसे मिळवू?',
      'तुम्ही डीप क्लिनिंग सेवा देता का?'
    ],
    'te-IN': [
      'నమస్తే',
      'మీరు ఏ సేవలను అందిస్తారు?',
      'దీనికి ఖర్చు ఎంత?',
      'నేను మైద్ ఎలా బుక్ చేసుకోవచ్చు?',
      'రద్దు విధానం ఏమిటి?',
      'మీరు అదే రోజు సేవలను అందిస్తారా?',
      'మీ మైద్స్ ధృవీకరించబడిందా?',
      'నేను పునరావృత బుకింగ్‌లను షెడ్యూల్ చేయవచ్చా?',
      'కస్టమర్ సపోర్ట్‌ను ఎలా సంప్రదించాలి?',
      'మీరు డీప్ క్లీనింగ్ సేవలను అందిస్తారా?'
    ]
  };

  void startListening(Function(String) onResult) async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    }
  }

  void processCommand(String command, BuildContext context) {
    String response = getResponse(command);
    if (isVoiceEnabled) {
      _tts.speak(response);
    }
  }

  String getResponse(String command) {
    Map<String, Map<String, String>> responses = {
      'en-US': {
        'hello': 'Hello! How can I assist you?',
        'what services do you offer?': 'We offer maid services, child care, elder care, and more.',
        'how much does it cost?': 'Our services start at ₹100 per hour.',
        'how do i book a maid?': 'You can book a maid through the bookings tab.',
        'what is the cancellation policy?': 'You can cancel your booking within 24 hours for a full refund.',
        'do you provide same-day services?': 'Yes, we provide same-day services based on availability.',
        'are your maids verified?': 'Yes, all our maids go through strict background verification.',
        'can i schedule recurring bookings?': 'Yes, you can schedule weekly or monthly bookings.',
        'how do i contact customer support?': 'You can contact support via in-app chat or helpline.',
        'do you offer deep cleaning services?': 'Yes, we offer deep cleaning services for homes and offices.',
      },
      'hi-IN': {
        'नमस्ते': 'नमस्ते! कैसे मदद कर सकता हूँ?',
        'आप कौन-कौन सी सेवाएँ प्रदान करते हैं?': 'हम मेड सेवाएँ, बच्चों की देखभाल, बुजुर्गों की देखभाल और अधिक प्रदान करते हैं।',
        'इसकी कीमत कितनी है?': 'हमारी सेवाएँ ₹100 प्रति घंटे से शुरू होती हैं।',
        'मैं मेड कैसे बुक कर सकता हूँ?': 'आप बुकिंग्स टैब के माध्यम से मेड बुक कर सकते हैं।',
        'रद्द करने की नीति क्या है?': 'आप अपनी बुकिंग को 24 घंटे के भीतर रद्द कर सकते हैं और पूरी राशि वापसी पा सकते हैं।',
        'क्या आप उसी दिन सेवाएँ प्रदान करते हैं?': 'हाँ, हम उपलब्धता के आधार पर समान दिन सेवाएँ प्रदान करते हैं।',
        'क्या आपकी मेड्स सत्यापित हैं?': 'हाँ, हमारी सभी मेड्स कड़ी पृष्ठभूमि सत्यापन प्रक्रिया से गुजरती हैं।',
        'क्या मैं पुनरावृत्ति बुकिंग शेड्यूल कर सकता हूँ?': 'हाँ, आप साप्ताहिक या मासिक बुकिंग्स शेड्यूल कर सकते हैं।',
        'मैं ग्राहक सहायता से कैसे संपर्क करूँ?': 'आप इन-एप चैट या हेल्पलाइन के माध्यम से सहायता से संपर्क कर सकते हैं।',
        'क्या आप गहरी सफाई सेवाएँ प्रदान करते हैं?': 'हाँ, हम घरों और ऑफिसों के लिए डीप क्लीनिंग सेवाएँ प्रदान करते हैं।',
      },
      'mr-IN': {
        'नमस्कार': 'नमस्कार! मी तुम्हाला कशी मदत करू शकतो?',
        'तुम्ही कोणत्या सेवा पुरवता?': 'आम्ही मेड सेवा, बालकांची काळजी, वृद्धांची काळजी आणि अधिक सेवा पुरवतो.',
        'त्याची किंमत किती आहे?': 'आमच्या सेवा प्रति तास ₹100 पासून सुरू होतात.',
        'मी मेड कशी बुक करू शकतो?': 'तुम्ही बुकिंग टॅबद्वारे मेड बुक करू शकता.',
        'रद्द करण्याची पद्धत काय आहे?': 'तुम्ही 24 तासांच्या आत बुकिंग रद्द करू शकता आणि संपूर्ण परतावा मिळवू शकता.',
        'तुम्ही त्याच दिवशी सेवा देता का?': 'होय, आम्ही उपलब्धतेच्या आधारे त्याच दिवशी सेवा पुरवतो.',
        'तुमच्या मेड्स प्रमाणित आहेत का?': 'होय, आमच्या सर्व मेड्स कडक पार्श्वभूमी सत्यापन प्रक्रियेतून जातात.',
        'मी पुनरावृत्ती बुकिंग करू शकतो का?': 'होय, तुम्ही साप्ताहिक किंवा मासिक बुकिंग करू शकता.',
        'मी ग्राहक सहाय्य कसे मिळवू?': 'तुम्ही इन-ऍप चॅट किंवा हेल्पलाइनद्वारे ग्राहक सहाय्य मिळवू शकता.',
        'तुम्ही डीप क्लिनिंग सेवा देता का?': 'होय, आम्ही घरे आणि कार्यालयांसाठी डीप क्लिनिंग सेवा देतो.',
      },
      'te-IN': {
        'నమస్తే': 'నమస్తే! నేను మీకు ఎలా సహాయపడగలను?',
        'మీరు ఏ సేవలను అందిస్తారు?': 'మేము మైద్ సేవలు, పిల్లల సంరక్షణ, వృద్ధ సంరక్షణ మరియు మరిన్ని అందిస్తాము.',
        'దీనికి ఖర్చు ఎంత?': 'మా సేవలు గంటకు ₹100 నుండి ప్రారంభమవుతాయి.',
        'నేను మైద్ ఎలా బుక్ చేసుకోవచ్చు?': 'మీరు బుకింగ్ ట్యాబ్ ద్వారా మైద్ బుక్ చేయవచ్చు.',
        'రద్దు విధానం ఏమిటి?': 'మీరు 24 గంటలలోపు బుకింగ్ రద్దు చేసుకోవచ్చు మరియు పూర్తిగా రీఫండ్ పొందవచ్చు.',
        'మీరు అదే రోజు సేవలను అందిస్తారా?': 'అవును, మా అందుబాటులో ఉన్న ఆధారంగా అదే రోజు సేవలను అందిస్తాము.',
        'మీ మైద్స్ ధృవీకరించబడిందా?': 'అవును, మా అన్ని మైద్స్ కఠినమైన నేపథ్య ధృవీకరణ ప్రక్రియ ద్వారా వెళతాయి.',
        'నేను పునరావృత బుకింగ్‌లను షెడ్యూల్ చేయవచ్చా?': 'అవును, మీరు వారపు లేదా నెలసరి బుకింగ్‌లను షెడ్యూల్ చేయవచ్చు.',
        'కస్టమర్ సపోర్ట్‌ను ఎలా సంప్రదించాలి?': 'మీరు యాప్ చాట్ లేదా హెల్ప్‌లైన్ ద్వారా మాకు సంప్రదించవచ్చు.',
        'మీరు డీప్ క్లీనింగ్ సేవలను అందిస్తారా?': 'అవును, మేము ఇళ్లకు మరియు కార్యాలయాలకు డీప్ క్లీనింగ్ సేవలను అందిస్తాము.',
      }
    };


    return responses[selectedLanguage]?[command.toLowerCase()] ?? 'मुझे समझ नहीं आया। कृपया पुनः प्रयास करें।';
  }

  Future<void> initializeTTS() async {
    await _tts.setLanguage(selectedLanguage);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  void toggleVoice() {
    isVoiceEnabled = !isVoiceEnabled;
  }

  void changeLanguage(String languageCode) {
    selectedLanguage = languageCode;
    initializeTTS();
  }

  List<String> getQuestions() {
    return predefinedQuestions[selectedLanguage] ?? [];
  }
}