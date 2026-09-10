"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { updatePassword } from "firebase/auth";
import { doc, serverTimestamp, updateDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { Loader } from "@/components/spinner";

export default function ChangePasswordPage() {
  const router = useRouter();
  const { user, profile, loading, reloadProfile, signOut } = useAuth();

  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  // Sem sessão → login. Já trocou (flag falsa) → segue pro painel.
  useEffect(() => {
    if (loading) return;
    if (!user) {
      router.replace("/login");
    } else if (profile && !profile.mustChangePassword) {
      router.replace("/dashboard");
    }
  }, [user, profile, loading, router]);

  if (loading || !user || (profile && !profile.mustChangePassword)) {
    return <Loader full />;
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (password.length < 6) {
      setError("A senha deve ter pelo menos 6 caracteres.");
      return;
    }
    if (password !== confirm) {
      setError("As senhas não conferem.");
      return;
    }
    const current = auth.currentUser;
    if (!current) {
      router.replace("/login");
      return;
    }
    setBusy(true);
    try {
      await updatePassword(current, password);
      await updateDoc(doc(db, "users", current.uid), {
        mustChangePassword: false,
        updatedAt: serverTimestamp(),
      });
      await reloadProfile();
      router.replace("/dashboard");
    } catch (err) {
      const code = (err as { code?: string }).code;
      if (code === "auth/requires-recent-login") {
        setError(
          "Sua sessão expirou. Entre novamente e troque a senha logo após o login.",
        );
      } else if (code === "auth/weak-password") {
        setError("Senha muito fraca. Use pelo menos 6 caracteres.");
      } else {
        setError("Não foi possível alterar a senha. Tente novamente.");
      }
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <form
        onSubmit={onSubmit}
        className="w-full max-w-sm rounded-2xl border border-border bg-surface p-8 shadow-sm"
      >
        <div className="mb-6 text-center">
          <h1 className="text-xl font-semibold text-brand-dark dark:text-fg">
            Defina uma nova senha
          </h1>
          <p className="mt-1 text-sm text-muted">
            No primeiro acesso é obrigatório trocar a senha temporária.
          </p>
        </div>

        <label className="block text-sm font-medium text-fg">
          Nova senha
          <input
            type="password"
            autoComplete="new-password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
          />
        </label>

        <label className="mt-4 block text-sm font-medium text-fg">
          Confirmar nova senha
          <input
            type="password"
            autoComplete="new-password"
            required
            value={confirm}
            onChange={(e) => setConfirm(e.target.value)}
            className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
          />
        </label>

        {error && <p className="mt-3 text-sm text-red-600">{error}</p>}

        <button
          type="submit"
          disabled={busy}
          className="mt-6 w-full rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
        >
          {busy ? "Salvando…" : "Salvar nova senha"}
        </button>

        <button
          type="button"
          onClick={() => signOut()}
          className="mt-3 w-full rounded-lg px-4 py-2 text-sm font-medium text-muted hover:bg-surface-2"
        >
          Sair
        </button>
      </form>
    </div>
  );
}
