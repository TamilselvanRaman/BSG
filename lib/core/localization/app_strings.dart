import 'app_language.dart';

class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _translations = {
    // Navigation
    'smartboard': {
      AppLanguage.english: 'Smartboard',
      AppLanguage.tamil: 'ஸ்மார்ட்போர்டு',
      AppLanguage.hindi: 'स्मार्टबोर्ड',
    },
    'smartChart': {
      AppLanguage.english: 'Smart Chart',
      AppLanguage.tamil: 'ஸ்மார்ட் சார்ட்',
      AppLanguage.hindi: 'स्मार्ट चार्ट',
    },
    'sellBillBook': {
      AppLanguage.english: 'Sell Bill Book',
      AppLanguage.tamil: 'விற்பனை பில் புக்',
      AppLanguage.hindi: 'विक्रय बिल बुक',
    },
    'buyBillBook': {
      AppLanguage.english: 'Buy Bill Book',
      AppLanguage.tamil: 'கொள்முதல் பில் புக்',
      AppLanguage.hindi: 'क्रय बिल बुक',
    },
    'more': {
      AppLanguage.english: 'More',
      AppLanguage.tamil: 'மேலும்',
      AppLanguage.hindi: 'अधिक',
    },

    // Header & Greeting
    'goodMorning': {
      AppLanguage.english: 'Good Morning',
      AppLanguage.tamil: 'காலை வணக்கம்',
      AppLanguage.hindi: 'सुप्रभात',
    },
    'goodAfternoon': {
      AppLanguage.english: 'Good Afternoon',
      AppLanguage.tamil: 'மதிய வணக்கம்',
      AppLanguage.hindi: 'शुभ दोपहर',
    },
    'goodEvening': {
      AppLanguage.english: 'Good Evening',
      AppLanguage.tamil: 'மாலை வணக்கம்',
      AppLanguage.hindi: 'शुभ संध्या',
    },
    'bsgAgroMandi': {
      AppLanguage.english: 'BSG Agro Goods Mandi',
      AppLanguage.tamil: 'BSG அக்ரோ பொருட்கள் மண்டி',
      AppLanguage.hindi: 'BSG एग्रो गुड्स मंडी',
    },
    'demoModeNotice': {
      AppLanguage.english: 'Demo Mode: Live calculations powered by local in-memory records.',
      AppLanguage.tamil: 'மாதிரி முறை: நேரடி கணக்கீடுகள் உள்ளக நினைவக பதிவுகளால் இயக்கப்படுகின்றன.',
      AppLanguage.hindi: 'डेमो मोड: स्थानीय इन-मेमोरी रिकॉर्ड द्वारा संचालित लाइव गणना।',
    },

    // Dashboard KPIs
    'todaySales': {
      AppLanguage.english: "Today's Sales",
      AppLanguage.tamil: 'இன்றைய விற்பனை',
      AppLanguage.hindi: 'आज की बिक्री',
    },
    'collections': {
      AppLanguage.english: 'Collections',
      AppLanguage.tamil: 'வசூல் தொகை',
      AppLanguage.hindi: 'कुल वसूली',
    },
    'pendingDues': {
      AppLanguage.english: 'Pending Dues',
      AppLanguage.tamil: 'நிலுவைத் தொகை',
      AppLanguage.hindi: 'बकाया राशि',
    },
    'inwardLoads': {
      AppLanguage.english: 'Inward Loads',
      AppLanguage.tamil: 'உள்வரும் சரக்குகள்',
      AppLanguage.hindi: 'आवक माल (लोड्स)',
    },
    'weeklySalesTrend': {
      AppLanguage.english: 'Weekly Sales Trend',
      AppLanguage.tamil: 'வாராந்திர விற்பனை போக்கு',
      AppLanguage.hindi: 'साप्ताहिक बिक्री रुझान',
    },
    'fastMandiActions': {
      AppLanguage.english: 'Fast Mandi Actions',
      AppLanguage.tamil: 'விரைவு மண்டி செயல்கள்',
      AppLanguage.hindi: 'त्वरित मंडी कार्य',
    },
    'recentBills': {
      AppLanguage.english: 'Recent Bills',
      AppLanguage.tamil: 'சமீபத்திய பில்கள்',
      AppLanguage.hindi: 'हाल के बिल',
    },
    'quickBuyerAccounts': {
      AppLanguage.english: 'Quick Buyer Accounts',
      AppLanguage.tamil: 'விரைவு வியாபாரி கணக்குகள்',
      AppLanguage.hindi: 'त्वरित खरीदार खाते',
    },
    'viewAll': {
      AppLanguage.english: 'View All',
      AppLanguage.tamil: 'அனைத்தையும் பார்க்க',
      AppLanguage.hindi: 'सभी देखें',
    },

    // Actions & Buttons
    'quickEntry': {
      AppLanguage.english: 'Quick Mandi Entry',
      AppLanguage.tamil: 'விரைவு மண்டி பதிவு',
      AppLanguage.hindi: 'त्वरित मंडी प्रविष्टि',
    },
    'sellBill': {
      AppLanguage.english: 'Sell Bill',
      AppLanguage.tamil: 'விற்பனை பில்',
      AppLanguage.hindi: 'बिक्री बिल',
    },
    'buyBill': {
      AppLanguage.english: 'Buy Bill',
      AppLanguage.tamil: 'கொள்முதல் பில்',
      AppLanguage.hindi: 'खरीद बिल',
    },
    'addCustomer': {
      AppLanguage.english: 'Add Customer',
      AppLanguage.tamil: 'வாடிக்கையாளர் சேர்',
      AppLanguage.hindi: 'ग्राहक जोड़ें',
    },
    'recordPayment': {
      AppLanguage.english: 'Record Payment',
      AppLanguage.tamil: 'பணம் பதிவு செய்',
      AppLanguage.hindi: 'भुगतान दर्ज करें',
    },
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.tamil: 'சேமி',
      AppLanguage.hindi: 'सहेजें',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.tamil: 'ரத்து செய்',
      AppLanguage.hindi: 'रद्द करें',
    },
    'edit': {
      AppLanguage.english: 'Edit',
      AppLanguage.tamil: 'திருத்து',
      AppLanguage.hindi: 'संपादित करें',
    },
    'delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.tamil: 'நீக்கு',
      AppLanguage.hindi: 'हटाएं',
    },
    'search': {
      AppLanguage.english: 'Search',
      AppLanguage.tamil: 'தேடு',
      AppLanguage.hindi: 'खोजें',
    },
    'filter': {
      AppLanguage.english: 'Filter',
      AppLanguage.tamil: 'வடிகட்டி',
      AppLanguage.hindi: 'फ़िल्टर',
    },
    'printSlip': {
      AppLanguage.english: 'Print Slip',
      AppLanguage.tamil: 'சீட்டு அச்சிடுக',
      AppLanguage.hindi: 'रसीद प्रिंट करें',
    },
    'shareWhatsApp': {
      AppLanguage.english: 'WhatsApp Share',
      AppLanguage.tamil: 'வாட்ஸ்அப் பகிர்',
      AppLanguage.hindi: 'व्हाट्सएप साझा करें',
    },

    // Smart Chart & Auction
    'arrivalAuction': {
      AppLanguage.english: 'Arrival Auction',
      AppLanguage.tamil: 'வரத்து ஏலம்',
      AppLanguage.hindi: 'आवक नीलामी',
    },
    'liveChart': {
      AppLanguage.english: 'Smart Chart',
      AppLanguage.tamil: 'ஸ்மார்ட் சார்ட்',
      AppLanguage.hindi: 'स्मार्ट चार्ट',
    },
    'salesSummary': {
      AppLanguage.english: 'Sales Summary',
      AppLanguage.tamil: 'விற்பனை சுருக்கம்',
      AppLanguage.hindi: 'बिक्री सारांश',
    },
    'unsoldBags': {
      AppLanguage.english: 'Unsold Bags',
      AppLanguage.tamil: 'விற்பனையாகாத மூட்டைகள்',
      AppLanguage.hindi: 'बिना बिकी बोरियां',
    },
    'soldBags': {
      AppLanguage.english: 'Sold Bags',
      AppLanguage.tamil: 'விற்ற மூட்டைகள்',
      AppLanguage.hindi: 'बिकी बोरियां',
    },
    'totalBags': {
      AppLanguage.english: 'Total Bags',
      AppLanguage.tamil: 'மொத்த மூட்டைகள்',
      AppLanguage.hindi: 'कुल बोरियां',
    },
    'lotNumber': {
      AppLanguage.english: 'Lot No',
      AppLanguage.tamil: 'லாட் எண்',
      AppLanguage.hindi: 'लॉट नंबर',
    },
    'vehicleNumber': {
      AppLanguage.english: 'Vehicle No',
      AppLanguage.tamil: 'வாகன எண்',
      AppLanguage.hindi: 'वाहन संख्या',
    },
    'farmerName': {
      AppLanguage.english: 'Farmer / Seller',
      AppLanguage.tamil: 'விவசாயி / விற்பனையாளர்',
      AppLanguage.hindi: 'किसान / विक्रेता',
    },
    'sellLot': {
      AppLanguage.english: 'Sell / Bill Lot',
      AppLanguage.tamil: 'லாட் பில் போடுக',
      AppLanguage.hindi: 'लॉट बिल बनाएं',
    },

    // Billing Form & Invoicing
    'step1SelectBuyer': {
      AppLanguage.english: '1. Select Buyer',
      AppLanguage.tamil: '1. வியாபாரி தேர்வு',
      AppLanguage.hindi: '1. खरीदार चुनें',
    },
    'step2WeighingLot': {
      AppLanguage.english: '2. Lot & Weighing',
      AppLanguage.tamil: '2. லாட் & எடை விவரம்',
      AppLanguage.hindi: '2. लॉट और वजन',
    },
    'step3Settlement': {
      AppLanguage.english: '3. Settlement',
      AppLanguage.tamil: '3. கணக்கு தீர்வு',
      AppLanguage.hindi: '3. भुगतान निपटान',
    },
    'billNumber': {
      AppLanguage.english: 'Bill Number',
      AppLanguage.tamil: 'பில் எண்',
      AppLanguage.hindi: 'बिल संख्या',
    },
    'billDate': {
      AppLanguage.english: 'Bill Date',
      AppLanguage.tamil: 'பில் தேதி',
      AppLanguage.hindi: 'बिल तिथि',
    },
    'commodity': {
      AppLanguage.english: 'Commodity',
      AppLanguage.tamil: 'பொருட்கள் (காய்/கனி)',
      AppLanguage.hindi: 'कृषि उपज / वस्तु',
    },
    'gradeVariety': {
      AppLanguage.english: 'Grade / Variety',
      AppLanguage.tamil: 'தரம் / வகை',
      AppLanguage.hindi: 'ग्रेड / किस्म',
    },
    'grossWeight': {
      AppLanguage.english: 'Gross Weight (kg)',
      AppLanguage.tamil: 'மொத்த எடை (கிலோ)',
      AppLanguage.hindi: 'सकल वजन (किलो)',
    },
    'tareDeduction': {
      AppLanguage.english: 'Tare Deduction (kg)',
      AppLanguage.tamil: 'சாக்கு கழிவு (கிலோ)',
      AppLanguage.hindi: 'बोरी कटौती (किलो)',
    },
    'netWeight': {
      AppLanguage.english: 'Net Weight (kg)',
      AppLanguage.tamil: 'நிகர எடை (கிலோ)',
      AppLanguage.hindi: 'शुद्ध वजन (किलो)',
    },
    'sellingRate': {
      AppLanguage.english: 'Selling Rate (₹/kg)',
      AppLanguage.tamil: 'விற்பனை விலை (₹/கிலோ)',
      AppLanguage.hindi: 'बिक्री दर (₹/किलो)',
    },
    'labourCharge': {
      AppLanguage.english: 'Labour / Hamali (₹)',
      AppLanguage.tamil: 'கூலி / ஹமாலி (₹)',
      AppLanguage.hindi: 'मजदूरी / हमाली (₹)',
    },
    'mandiFee': {
      AppLanguage.english: 'Mandi Cess / Fee (₹)',
      AppLanguage.tamil: 'மண்டி கட்டணம் (₹)',
      AppLanguage.hindi: 'मंडी शुल्क (₹)',
    },
    'previousBalance': {
      AppLanguage.english: 'Previous Balance',
      AppLanguage.tamil: 'முந்தைய பாக்கி',
      AppLanguage.hindi: 'पिछला बकाया',
    },
    'currentBillTotal': {
      AppLanguage.english: 'Current Bill Total',
      AppLanguage.tamil: 'தற்போதைய பில் மொத்தம்',
      AppLanguage.hindi: 'वर्तमान बिल कुल',
    },
    'grossPayable': {
      AppLanguage.english: 'Gross Payable',
      AppLanguage.tamil: 'செலுத்த வேண்டிய மொத்தம்',
      AppLanguage.hindi: 'कुल देय राशि',
    },
    'advanceDeducted': {
      AppLanguage.english: 'Advance Deducted',
      AppLanguage.tamil: 'கழிக்கப்பட்ட முன் பணம்',
      AppLanguage.hindi: 'काटा गया अग्रिम',
    },
    'amountReceived': {
      AppLanguage.english: 'Amount Received (Paid)',
      AppLanguage.tamil: 'பெற்றுக் கொண்ட தொகை',
      AppLanguage.hindi: 'प्राप्त राशि (भुगतान)',
    },
    'remainingDue': {
      AppLanguage.english: 'Remaining Due',
      AppLanguage.tamil: 'மீதமுள்ள பாக்கி',
      AppLanguage.hindi: 'शेष बकाया',
    },
    'excessCredit': {
      AppLanguage.english: 'Excess Credit / Advance',
      AppLanguage.tamil: 'கூடுதல் இருப்பு / அட்வான்ஸ்',
      AppLanguage.hindi: 'अतिरिक्त जमा / एडवांस',
    },
    'generateBill': {
      AppLanguage.english: 'Generate & Save Bill',
      AppLanguage.tamil: 'பில் உருவாக்கி சேமி',
      AppLanguage.hindi: 'बिल बनाएं और सहेजें',
    },

    // Inventory & Stock
    'inventory': {
      AppLanguage.english: 'Stock & Inventory',
      AppLanguage.tamil: 'சரக்கு இருப்பு (ஸ்டாக்)',
      AppLanguage.hindi: 'स्टॉक और इन्वेंटरी',
    },
    'openingStock': {
      AppLanguage.english: 'Opening Stock',
      AppLanguage.tamil: 'தொடக்க இருப்பு',
      AppLanguage.hindi: 'प्रारंभिक स्टॉक',
    },
    'inwardPurchases': {
      AppLanguage.english: 'Inward Purchases',
      AppLanguage.tamil: 'உள்வந்த சரக்கு',
      AppLanguage.hindi: 'आवक खरीद',
    },
    'outwardSales': {
      AppLanguage.english: 'Outward Sales',
      AppLanguage.tamil: 'விற்ற சரக்கு',
      AppLanguage.hindi: 'बिक्री निकासी',
    },
    'closingStock': {
      AppLanguage.english: 'Closing Stock',
      AppLanguage.tamil: 'இறுதி இருப்பு',
      AppLanguage.hindi: 'अंतिम स्टॉक',
    },
    'productWiseStock': {
      AppLanguage.english: 'Commodity-Wise Stock Levels',
      AppLanguage.tamil: 'பொருட்கள் வாரியான இருப்பு',
      AppLanguage.hindi: 'वस्तुवार स्टॉक स्तर',
    },
    'stockMovementTable': {
      AppLanguage.english: 'Daily Stock Movement Register',
      AppLanguage.tamil: 'தினசரி சரக்கு நகர்வு ஏடு',
      AppLanguage.hindi: 'दैनिक स्टॉक रजिस्टर',
    },

    // More Menu & Modules
    'sellerLedger': {
      AppLanguage.english: 'Seller Ledger',
      AppLanguage.tamil: 'விவசாயி கணக்கு ஏடு',
      AppLanguage.hindi: 'विक्रेता खाता बही',
    },
    'buyerLedger': {
      AppLanguage.english: 'Buyer Ledger',
      AppLanguage.tamil: 'வியாபாரி கணக்கு ஏடு',
      AppLanguage.hindi: 'खरीदार खाता बही',
    },
    'reports': {
      AppLanguage.english: 'Reports',
      AppLanguage.tamil: 'அறிக்கைகள்',
      AppLanguage.hindi: 'रिपोर्ट्स',
    },
    'advances': {
      AppLanguage.english: 'Advances',
      AppLanguage.tamil: 'முன் பணம் (அட்வான்ஸ்)',
      AppLanguage.hindi: 'अग्रिम राशि',
    },
    'transporto': {
      AppLanguage.english: 'Transporto',
      AppLanguage.tamil: 'போக்குவரத்து (லாரிகள்)',
      AppLanguage.hindi: 'परिवहन (ट्रक)',
    },
    'partners': {
      AppLanguage.english: 'Partners',
      AppLanguage.tamil: 'கூட்டாளிகள்',
      AppLanguage.hindi: 'साझेदार',
    },
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.tamil: 'அமைப்புகள்',
      AppLanguage.hindi: 'सेटिंग्स',
    },

    // Auth & Staff Login
    'mandiStaffLogin': {
      AppLanguage.english: 'Mandi Staff Login',
      AppLanguage.tamil: 'மண்டி பணியாளர் உள்நுழைவு',
      AppLanguage.hindi: 'मंडी स्टाफ लॉगिन',
    },
    'enterPinOrMobile': {
      AppLanguage.english: 'Enter Staff PIN or Mobile',
      AppLanguage.tamil: 'பணியாளர் பின் அல்லது மொபைல் எண்',
      AppLanguage.hindi: 'स्टाफ पिन या मोबाइल दर्ज करें',
    },
    'selectRole': {
      AppLanguage.english: 'Select Mandi Role',
      AppLanguage.tamil: 'மண்டி பொறுப்பை தேர்ந்தெடுக்கவும்',
      AppLanguage.hindi: 'मंडी भूमिका चुनें',
    },
    'adminProprietor': {
      AppLanguage.english: 'Mandi Admin / Proprietor',
      AppLanguage.tamil: 'மண்டி நிர்வாகி / உரிமையாளர்',
      AppLanguage.hindi: 'मंडी एडमिन / मालिक',
    },
    'billingClerk': {
      AppLanguage.english: 'Billing & Weighing Clerk',
      AppLanguage.tamil: 'பில் & எடை எழுத்தர்',
      AppLanguage.hindi: 'बिलिंग और तौल क्लर्क',
    },
    'quickDemoLogin': {
      AppLanguage.english: 'Quick 1-Tap Login (Demo)',
      AppLanguage.tamil: 'உடனடி உள்நுழைவு (மாதிரி)',
      AppLanguage.hindi: 'त्वरित 1-टैप लॉगिन (डेमो)',
    },
    'switchLanguage': {
      AppLanguage.english: 'Language / மொழி / भाषा',
      AppLanguage.tamil: 'மொழி / Language / भाषा',
      AppLanguage.hindi: 'भाषा / Language / மொழி',
    },

    // Global Search
    'globalSearchHint': {
      AppLanguage.english: 'Search lots, bills, farmers or buyers...',
      AppLanguage.tamil: 'லாட், பில், விவசாயி அல்லது வியாபாரி தேடுக...',
      AppLanguage.hindi: 'लॉट, बिल, किसान या खरीदार खोजें...',
    },
    'allEntities': {
      AppLanguage.english: 'All',
      AppLanguage.tamil: 'அனைத்தும்',
      AppLanguage.hindi: 'सभी',
    },
    'lots': {
      AppLanguage.english: 'Lots',
      AppLanguage.tamil: 'லாட்டுகள்',
      AppLanguage.hindi: 'लॉट',
    },
    'bills': {
      AppLanguage.english: 'Bills',
      AppLanguage.tamil: 'பில்கள்',
      AppLanguage.hindi: 'बिल',
    },
    'buyers': {
      AppLanguage.english: 'Buyers',
      AppLanguage.tamil: 'வியாபாரிகள்',
      AppLanguage.hindi: 'खरीदार',
    },
    'sellers': {
      AppLanguage.english: 'Farmers',
      AppLanguage.tamil: 'விவசாயிகள்',
      AppLanguage.hindi: 'किसान',
    },

    // Reports Additional
    'grossProfitReport': {
      AppLanguage.english: 'Gross Profit & Margins',
      AppLanguage.tamil: 'மொத்த லாபம் & மார்ஜின்',
      AppLanguage.hindi: 'सकल लाभ और मार्जिन',
    },
    'rmcCessReport': {
      AppLanguage.english: 'RMC / Mandi Cess Report',
      AppLanguage.tamil: 'RMC / மண்டி செஸ் அறிக்கை',
      AppLanguage.hindi: 'आरएमसी / मंडी उपकर रिपोर्ट',
    },
    'tradeActivityFeed': {
      AppLanguage.english: 'Live Mandi Trade Feed',
      AppLanguage.tamil: 'நேரலை மண்டி வர்த்தக ஓட்டம்',
      AppLanguage.hindi: 'लाइव मंडी ट्रेड फ़ीड',
    },
    'dateRange': {
      AppLanguage.english: 'Date Range',
      AppLanguage.tamil: 'தேதி வரம்பு',
      AppLanguage.hindi: 'दिनांक सीमा',
    },
    'exportJson': {
      AppLanguage.english: 'Export Backup (JSON)',
      AppLanguage.tamil: 'காப்புப்பிரதி ஏற்றுமதி (JSON)',
      AppLanguage.hindi: 'बैकअप निर्यात करें (JSON)',
    },
    'whatsAppTemplate': {
      AppLanguage.english: 'WhatsApp Template Preview',
      AppLanguage.tamil: 'வாட்ஸ்அப் மாதிரி முன்னோட்டம்',
      AppLanguage.hindi: 'व्हाट्सएप टेम्पलेट पूर्वावलोकन',
    },
  };

  static String tr(String key, AppLanguage lang) {
    final entry = _translations[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.english] ?? key;
  }
}
