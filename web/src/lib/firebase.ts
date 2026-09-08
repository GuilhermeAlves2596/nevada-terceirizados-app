import { initializeApp, getApps, getApp, type FirebaseApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getFunctions } from "firebase/functions";

// Config do Firebase lida de variáveis NEXT_PUBLIC_* (ver .env.local.example).
// Embora a config web do Firebase não seja segredo (vai pro bundle do cliente
// de qualquer jeito), mantemos fora do código-fonte para não disparar o
// secret-scanning do GitHub e facilitar apontar a outro projeto. A proteção
// real é feita pelas Security Rules + restrição da API key no Google Cloud.
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

if (!firebaseConfig.apiKey) {
  // Ajuda a diagnosticar quando o .env.local não foi criado.
  console.error(
    "Firebase config ausente. Crie web/.env.local a partir de .env.local.example.",
  );
}

const app: FirebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
// As Cloud Functions estão na região southamerica-east1 (ver functions/).
export const functions = getFunctions(app, "southamerica-east1");
export { app };
