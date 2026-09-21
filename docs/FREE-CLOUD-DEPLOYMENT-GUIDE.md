# ফ্রি ক্লাউড ডিপ্লয়মেন্ট গাইড (Vercel + Render + Supabase)

এই গাইডের মাধ্যমে আপনি কোনো খরচ ছাড়াই সম্পূর্ণ সফটওয়্যারটি ইন্টারনেটে লাইভ করতে পারবেন।

---

## ধাপ ১: Supabase-এ সম্পূর্ণ ডাটাবেজ তৈরি (১ ক্লিকে)

1. [Supabase Dashboard](https://supabase.com/dashboard)-এ আপনার প্রজেক্টে যান।
2. বাম পাশের মেনু থেকে **SQL Editor** (`>_` আইকন) এ ক্লিক করুন।
3. **New Query** বাটনে ক্লিক করুন।
4. আমাদের প্রজেক্টের `magra_work_v81/database/full_database_setup.sql` ফাইলটির সব কোড কপি করে পেস্ট করুন।
5. **Run** বাটনে ক্লিক করুন।
   - *এর ফলে সব টেবিল, রিলেশন, রোল এবং ডেমো টেস্ট ডেটা একসাথে সেট হয়ে যাবে।*

---

## ধাপ ২: GitHub-এ কোড আপলোড করা

1. [github.com](https://github.com)-এ একটি নতুন **Public/Private Repository** তৈরি করুন (যেমন `magra-school-management`)।
2. এই ফোল্ডারের কোডগুলো গিটহাবে পুশ (Push) করুন।

---

## ধাপ ৩: Render-এ ব্যাকএন্ড (API) লাইভ করা (ফ্রি)

1. [render.com](https://render.com)-এ গিয়ে আপনার GitHub একাউন্ট দিয়ে Sign In করুন।
2. **New +** এ ক্লিক করে **Web Service** সিলেক্ট করুন।
3. আপনার GitHub রিপোজিটরি কানেক্ট করুন।
4. নিচের সেটিংসগুলো দিন:
   - **Name:** `magra-school-backend`
   - **Root Directory:** `magra_work_v81/backend` (বা রিপোর রুট অনুযায়ী `backend`)
   - **Runtime:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `node src/server.js`
   - **Instance Type:** `Free`
5. **Environment Variables** সেকশনে নিচের ভেরিয়েবলগুলো অ্যাড করুন:
   - `DATABASE_URL`: `postgresql://postgres.mdyhxfywqyhbuslozefc:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres`
   - `JWT_SECRET`: `super_secret_jwt_key_magra_school_management_2026`
   - `NODE_ENV`: `production`
   - `PILOT_DB_SSL`: `true`
   - `CORS_ORIGIN`: `*` (বা আপনার Vercel লিংক)
6. **Create Web Service** এ ক্লিক করুন।
7. ডিপ্লয় শেষ হলে Render আপনাকে একটি লাইভ API URL দিবে (যেমন: `https://magra-school-backend.onrender.com`)।

---

## ধাপ ৪: Vercel-এ ফ্রন্টএন্ড ওয়েবসাইট লাইভ করা (ফ্রি)

1. [vercel.com](https://vercel.com)-এ আপনার GitHub দিয়ে Sign In করুন।
2. **Add New...** -> **Project** এ গিয়ে আপনার রিপোজিটরি ইমপোর্ট করুন।
3. সেটিংস কনফিগার করুন:
   - **Framework Preset:** `Vite`
   - **Root Directory:** `magra_work_v81/frontend` (বা `frontend`)
4. **Environment Variables** এ যুক্ত করুন:
   - `VITE_API_URL`: Render থেকে পাওয়া লিঙ্ক + `/api` (যেমন: `https://magra-school-backend.onrender.com/api`)
5. **Deploy** বাটনে ক্লিক করুন।

🎉 অভিনন্দন! ১-২ মিনিটের মধ্যে আপনার ওয়েবসাইট লাইভ লিংক (যেমন `https://magra-school.vercel.app`) তৈরি হয়ে যাবে।
