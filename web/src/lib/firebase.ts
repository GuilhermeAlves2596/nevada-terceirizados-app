import { initializeApp, getApps, getApp, type FirebaseApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import {
  getFirestore,
  initializeFirestore,
  persistentLocalCache,
  persistentMultipleTabManager,
  type Firestore,
} from "firebase/firestore";
import { getFunctions } from "firebase/functions";

// Config do Firebase lida de variáveis NEXT_PUBLIC_* (ver .env.local.example).
// Embora a config web do Firebase não seja segredo (vai pro bundle do cliente),
// mantemos fora do código-fonte para não disparar o secret-scanning do GitHub e
// facilitar apontar a outro projeto. A proteção real é feita pelas Security
// Rules + restrição da API key + App Check (abaixo).
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

if (!firebaseConfig.apiKey) {
  console.error(
    "Firebase config ausente. Crie web/.env.local a partir de .env.local.example.",
  );
}

const isBrowser = typeof window !== "undefined";

const app: FirebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);

// Firestore com cache offline (IndexedDB) no browser — reduz leituras e dá
// resiliência offline; multi-aba habilitado. No servidor (SSR/prerender) usa a
// instância simples, pois IndexedDB não existe lá.
export const db: Firestore = isBrowser
  ? initializeFirestore(app, {
      localCache: persistentLocalCache({
        tabManager: persistentMultipleTabManager(),
      }),
    })
  : getFirestore(app);

export const auth = getAuth(app);
// As Cloud Functions estão na região southamerica-east1 (ver functions/).
export const functions = getFunctions(app, "southamerica-east1");

// App Check (anti-abuso): atesta que a requisição vem do app real. Só no
// browser. Usa reCAPTCHA Enterprise (o v3 clássico está sendo descontinuado):
// crie a chave no Google Cloud (reCAPTCHA Enterprise) e preencha
// NEXT_PUBLIC_APPCHECK_SITE_KEY. Em dev/localhost, defina
// NEXT_PUBLIC_APPCHECK_DEBUG=true para gerar um token de debug (aparece no
// console do navegador) e registrá-lo em App Check → Tokens de debug.
// Sem site key, o App Check é ignorado (não quebra o app).
if (isBrowser) {
  const siteKey = process.env.NEXT_PUBLIC_APPCHECK_SITE_KEY;
  if (process.env.NEXT_PUBLIC_APPCHECK_DEBUG === "true") {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (self as any).FIREBASE_APPCHECK_DEBUG_TOKEN = true;
  }
  if (siteKey) {
    // Import dinâmico para não pesar o bundle quando o App Check não é usado.
    import("firebase/app-check")
      .then(({ initializeAppCheck, ReCaptchaEnterpriseProvider }) => {
        try {
          initializeAppCheck(app, {
            provider: new ReCaptchaEnterpriseProvider(siteKey),
            isTokenAutoRefreshEnabled: true,
          });
        } catch {
          /* já inicializado (ex.: HMR) */
        }
      })
      .catch(() => {
        /* ignore */
      });
  }
}

export { app };
