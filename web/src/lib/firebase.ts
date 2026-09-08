import { initializeApp, getApps, getApp, type FirebaseApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getFunctions } from "firebase/functions";

// Config PÚBLICA do Firebase (a mesma que os apps Flutter embutem — ver
// lib/firebase_options.dart; valores de config web não são segredo). Pode ser
// sobrescrita por variáveis NEXT_PUBLIC_* para apontar a outro projeto.
const firebaseConfig = {
  apiKey:
    process.env.NEXT_PUBLIC_FIREBASE_API_KEY ??
    "AIzaSyAyNA4Iop4ZWYPcqPfB_JC3xAliZXAFLT8",
  authDomain:
    process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN ?? "nevada-dev.firebaseapp.com",
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID ?? "nevada-dev",
  storageBucket:
    process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET ??
    "nevada-dev.firebasestorage.app",
  messagingSenderId:
    process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID ?? "689985021305",
  appId:
    process.env.NEXT_PUBLIC_FIREBASE_APP_ID ??
    "1:689985021305:web:f8db086e1cbbedd43e7ba8",
};

const app: FirebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
// As Cloud Functions estão na região southamerica-east1 (ver functions/).
export const functions = getFunctions(app, "southamerica-east1");
export { app };
