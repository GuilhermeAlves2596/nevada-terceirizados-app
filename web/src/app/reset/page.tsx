"use client";

import { Suspense, useEffect, useState } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import {
  confirmPasswordReset,
  verifyPasswordResetCode,
} from "firebase/auth";
import { auth } from "@/lib/firebase";
import { Loader } from "@/components/spinner";

type Status = "checking" | "ready" | "invalid" | "done";

function ResetInner() {
  const params = useSearchParams();
  const mode = params.get("mode");
  const oobCode = params.get("oobCode");

  const [status, setStatus] = useState<Status>("checking");
  const [email, setEmail] = useState<string | null>(null);
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  // Ao carregar, só VALIDA o código (não consome). Assim, se um scanner de
  // e-mail pré-abrir o link, nada é redefinido — a troca só ocorre no submit.
  useEffect(() => {
    if (mode !== "resetPassword" || !oobCode) {
      setStatus("invalid");
      return;
    }
    let alive = true;
    verifyPasswordResetCode(auth, oobCode)
      .then((mail) => {
        if (!alive) return;
        setEmail(mail);
        setStatus("ready");
      })
      .catch(() => {
        if (alive) setStatus("invalid");
      });
    return () => {
      alive = false;
    };
  }, [mode, oobCode]);

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
    if (!oobCode) {
      setStatus("invalid");
      return;
    }
    setBusy(true);
    try {
      await confirmPasswordReset(auth, oobCode, password);
      setStatus("done");
    } catch (err) {
      const code = (err as { code?: string }).code;
      if (code === "auth/weak-password") {
        setError("Senha muito fraca. Use pelo menos 6 caracteres.");
      } else {
        // expired-action-code / invalid-action-code
        setStatus("invalid");
      }
    } finally {
      setBusy(false);
    }
  }

  const card =
    "w-full max-w-sm rounded-2xl border border-border bg-surface p-8 shadow-sm";

  if (status === "checking") {
    return <Loader full />;
  }

  if (status === "invalid") {
    return (
      <div className="flex min-h-screen items-center justify-center px-4">
        <div className={card}>
          <h1 className="text-xl font-semibold text-brand-dark dark:text-fg">
            Link inválido ou expirado
          </h1>
          <p className="mt-2 text-sm text-muted">
            Este link de redefinição não é mais válido. Solicite um novo — o
            link é de uso único e expira após algum tempo.
          </p>
          <Link
            href="/forgot-password"
            className="mt-6 block w-full rounded-lg bg-brand px-4 py-2 text-center text-sm font-medium text-white hover:bg-brand-dark"
          >
            Solicitar novo link
          </Link>
        </div>
      </div>
    );
  }

  if (status === "done") {
    return (
      <div className="flex min-h-screen items-center justify-center px-4">
        <div className={card}>
          <h1 className="text-xl font-semibold text-brand-dark dark:text-fg">
            Senha redefinida
          </h1>
          <p className="mt-2 text-sm text-muted">
            Sua senha foi alterada. Use a nova senha para entrar.
          </p>
          <Link
            href="/login"
            className="mt-6 block w-full rounded-lg bg-brand px-4 py-2 text-center text-sm font-medium text-white hover:bg-brand-dark"
          >
            Ir para o login
          </Link>
        </div>
      </div>
    );
  }

  // status === "ready"
  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <form onSubmit={onSubmit} className={card}>
        <div className="mb-6 text-center">
          <h1 className="text-xl font-semibold text-brand-dark dark:text-fg">
            Definir nova senha
          </h1>
          {email && (
            <p className="mt-1 text-sm text-muted">
              Conta: <span className="font-medium">{email}</span>
            </p>
          )}
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
      </form>
    </div>
  );
}

export default function ResetPage() {
  return (
    <Suspense fallback={<Loader full />}>
      <ResetInner />
    </Suspense>
  );
}
