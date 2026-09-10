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
  loading: boolean;
  signOut: () => Promise<void>;
  reloadProfile: () => Promise<void>;
};

const AuthContext = createContext<AuthState>({
  user: null,
  profile: null,
  loading: true,
  signOut: async () => {},
  reloadProfile: async () => {},
});

/** Provider global: observa o Auth e carrega o perfil de /users/{uid}. */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  const loadProfile = useCallback(async (uid: string) => {
    try {
      const snap = await getDoc(doc(db, "users", uid));
      setProfile(
        snap.exists()
          ? { uid, ...(snap.data() as Omit<Profile, "uid">) }
          : null,
      );
    } catch {
      setProfile(null);
    }
  }, []);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (u) => {
      setUser(u);
      if (u) {
        await loadProfile(u.uid);
      } else {
        setProfile(null);
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
      value={{ user, profile, loading, signOut, reloadProfile }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
