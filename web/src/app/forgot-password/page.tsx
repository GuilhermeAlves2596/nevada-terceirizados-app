"use client";

import { useState } from "react";
import Link from "next/link";
import { sendPasswordResetEmail } from "firebase/auth";
import { auth } from "@/lib/firebase";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [busy, setBusy] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!email.trim()) {
      setError("Informe o e-mail.");
      return;
    }
    setError(null);
    setBusy(true);
    try {
      await sendPasswordResetEmail(auth, email.trim());
      setSent(true);
    } catch (err) {
      const code = (err as { code?: string }).code;
      // Por privacidade, não revelamos se o e-mail existe: só e-mail inválido
      // vira erro; user-not-found (e o resto) mostra a mesma confirmação.
      if (code === "auth/invalid-email") {
        setError("E-mail inválido.");
      } else {
        setSent(true);
      }
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <div className="w-full max-w-sm rounded-2xl border border-border bg-surface p-8 shadow-sm">
        <div className="mb-6 text-center">
          <h1 className="text-xl font-semibold text-brand-dark dark:text-fg">
            Recuperar senha
          </h1>
          <p className="mt-1 text-sm text-muted">
            Enviaremos um link de redefinição para o seu e-mail.
          </p>
        </div>

        {sent ? (
          <div>
            <div className="rounded-lg border border-green-300 bg-green-50 p-4 text-sm text-green-800 dark:border-green-900 dark:bg-green-950 dark:text-green-200">
              Se houver uma conta com esse e-mail, enviamos um link para
              redefinir a senha. Verifique sua caixa de entrada e o spam.
            </div>
            <Link
              href="/login"
              className="mt-6 block w-full rounded-lg bg-brand px-4 py-2 text-center text-sm font-medium text-white hover:bg-brand-dark"
            >
              Voltar ao login
            </Link>
          </div>
        ) : (
          <form onSubmit={onSubmit}>
            <label className="block text-sm font-medium text-fg">
              E-mail
              <input
                type="email"
                autoComplete="username"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
              />
            </label>

            {error && <p className="mt-3 text-sm text-red-600">{error}</p>}

            <button
              type="submit"
              disabled={busy}
              className="mt-6 w-full rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
            >
              {busy ? "Enviando…" : "Enviar link"}
            </button>

            <Link
              href="/login"
              className="mt-3 block text-center text-sm text-muted hover:text-fg"
            >
              Voltar ao login
            </Link>
          </form>
        )}
      </div>
    </div>
  );
}
