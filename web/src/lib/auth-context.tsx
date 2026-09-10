"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import {
  onAuthStateChanged,
  signOut as fbSignOut,
  type User,
} from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "./firebase";

export type Profile = {
  uid: string;
  name?: string;
  role: string;
  companyId?: string | null;
  email?: string | null;
  phone?: string | null;
  jobTitle?: string | null;
  mustChangePassword?: boolean;
  contractIds?: string[];
  clientIds?: string[];
};

type AuthState = {
  user: User | null;
  profile: Profile | null;
  /** Assinatura da empresa do usuário ativa? null = sem empresa/indefinido. */
  subscriptionActive: boolean | null;
  loading: boolean;
  signOut: () => Promise<void>;
  reloadProfile: () => Promise<void>;
};

const AuthContext = createContext<AuthState>({
  user: null,
  profile: null,
  subscriptionActive: null,
  loading: true,
  signOut: async () => {},
  reloadProfile: async () => {},
});

/** Provider global: observa o Auth e carrega o perfil de /users/{uid}. */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [subscriptionActive, setSubscriptionActive] = useState<boolean | null>(
    null,
  );

  const [loading, setLoading] = useState(true);

  const loadProfile = useCallback(async (uid: string) => {
    try {
      const snap = await getDoc(doc(db, "users", uid));
      const p = snap.exists()
        ? ({ uid, ...(snap.data() as Omit<Profile, "uid">) } as Profile)
        : null;
      setProfile(p);

      // Carrega o status da assinatura da empresa do usuário (se houver).
      if (p?.companyId) {
        try {
          const cSnap = await getDoc(doc(db, "companies", p.companyId));
          const status = cSnap.data()?.subscriptionStatus as string | undefined;
          setSubscriptionActive(status === "active" || status === "trial");
        } catch {
          setSubscriptionActive(null);
        }
      } else {
        setSubscriptionActive(null);
      }
    } catch {
      setProfile(null);
      setSubscriptionActive(null);
    }
  }, []);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (u) => {
      setUser(u);
      if (u) {
        await loadProfile(u.uid);
      } else {
        setProfile(null);
        setSubscriptionActive(null);
      }
      setLoading(false);
    });
    return () => unsub();
  }, [loadProfile]);

  const reloadProfile = useCallback(async () => {
    const uid = auth.currentUser?.uid;
    if (uid) await loadProfile(uid);
  }, [loadProfile]);

  const signOut = async () => {
    await fbSignOut(auth);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        profile,
        subscriptionActive,
        loading,
        signOut,
        reloadProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
