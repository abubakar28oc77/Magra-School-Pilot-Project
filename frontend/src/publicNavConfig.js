// V77 final-candidate audit: public reference structure remains locked.
// Final reference-driven public navigation. The user has consolidated the original 7 screenshots into 4 final reference sections (1→2→3→4).
export const publicNavConfig = [
  {label:'হোম', href:'#home'},
  {label:'প্রাতিষ্ঠানিক তথ্য', children:[
    ['বিদ্যালয় পরিচিতি','#school-info'],['পরিচালনা কমিটি','#committee'],['নিয়ম-কানুন','#rules'],['লাইব্রেরি','#library'],['পাঠ্যক্রম ও বই','#curriculum']
  ]},
  {label:'ক্রীড়া ও সংস্কৃতি', children:[
    ['ক্রীড়া','#sports'],['সাংস্কৃতিক কার্যক্রম','#culture'],['শিক্ষা সফর','#tour'],['ক্লাব ও সংগঠন','#clubs'],['অর্জন','#achievements']
  ]},
  {label:'শিক্ষক ও কর্মচারী', children:[
    ['প্রধান শিক্ষক','#headteacher'],['সহকারী প্রধান শিক্ষক','#assistant-headteacher'],['শিক্ষকবৃন্দ','#teachers'],['কর্মচারীবৃন্দ','#staff']
  ]},
  {label:'শিক্ষার্থীর তথ্য', children:[
    ['শিক্ষার্থী তালিকা','#students'],['বৃত্তি','#scholarship'],['কৃতি শিক্ষার্থী','#distinguished'],['ভর্তি','#admission']
  ]},
  {label:'পরীক্ষার ফলাফল', children:[
    ['সকল ফলাফল','#results'],['SSC ফলাফল','#ssc-results'],['ফলাফল বিশ্লেষণ','#result-analysis']
  ]},
  {label:'শিক্ষার্থীর গাইড', children:[
    ['সিলেবাস','#syllabus'],['ডিজিটাল লার্নিং','#learning'],['প্রশ্নব্যাংক','#question-bank'],['অনলাইন পরীক্ষা','#online-exam'],['AI শিক্ষা সহকারী','#ai']
  ]},
  {label:'নোটিশ', href:'#notice'},
  {label:'গ্যালারি', href:'#gallery'},
  {label:'যোগাযোগ', href:'#contact'},
  {label:'লগইন', href:'/login', emphasis:true}
];
