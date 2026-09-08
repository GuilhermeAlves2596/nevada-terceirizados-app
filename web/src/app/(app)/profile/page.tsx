"use client";

import { useEffect, useState } from "react";
import { doc, getDoc, serverTimestamp, updateDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { Loader } from "@/components/spinner";

const ROLE_LABEL: Record<string, string> = {
  companyAdmin: "Gestor da empresa",
  platformAdmin: "Administrador da plataforma",
  supervisor: "Supervisor",
  employee: "Funcionário",
};

export default function ProfilePage() {
  const { user, profile, reloadProfile } = useAuth();
  const email = user?.email ?? profile?.email ?? "";

  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [jobTitle, setJobTitle] = useState("");
  const [companyName, setCompanyName] = useState<string | null>(null);

  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!profile) return;
    setName(profile.name ?? "");
    setPhone(profile.phone ?? "");
    setJobTitle(profile.jobTitle ?? "");
  }, [profile]);

  useEffect(() => {
    const cid = profile?.companyId;
    if (!cid) {
      setCompanyName(null);
      return;
    }
    (async () => {
      try {
        const s = await getDoc(doc(db, "companies", cid));
        setCompanyName(s.exists() ? ((s.data().name as string) ?? null) : null);
      } catch {
        setCompanyName(null);
      }
    })();
  }, [profile?.companyId]);

  if (!profile) return <Loader />;

  async function onSave(e: React.FormEvent) {
    e.preventDefault();
    if (!profile) return;
    if (!name.trim()) {
      setError("O nome é obrigatório.");
      return;
    }
    setError(null);
    setSaved(false);
    setSaving(true);
    try {
      await updateDoc(doc(db, "users", profile.uid), {
        name: name.trim(),
        phone: phone.trim() || null,
        jobTitle: jobTitle.trim() || null,
        updatedAt: serverTimestamp(),
      });
      await reloadProfile();
      setSaved(true);
    } catch {
      setError("Não foi possível salvar. Tente novamente.");
    } finally {
      setSaving(false);
    }
  }

  const initials = (profile.name ?? email ?? "?")
    .split(" ")
    .slice(0, 2)
    .map((s) => s[0]?.toUpperCase() ?? "")
    .join("");

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="text-2xl font-semibold">Meu perfil</h1>
      <p className="mt-1 text-sm text-muted">Suas informações de gestor.</p>

      <div className="mt-6 flex items-center gap-4 rounded-2xl border border-border bg-surface p-5">
        <div className="grid h-14 w-14 place-items-center rounded-full bg-brand-soft text-lg font-semibold text-brand-dark dark:text-fg">
          {initials}
        </div>
        <div className="min-w-0">
          <p className="truncate text-lg font-medium">{profile.name ?? "—"}</p>
          <p className="truncate text-sm text-muted">
            {ROLE_LABEL[profile.role] ?? profile.role}
            {companyName ? ` · ${companyName}` : ""}
          </p>
        </div>
      </div>

      <form
        onSubmit={onSave}
        className="mt-4 rounded-2xl border border-border bg-surface p-6"
      >
        <div className="grid gap-4 sm:grid-cols-2">
          <label className="block text-sm font-medium sm:col-span-2">
            Nome
            <input
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
            />
          </label>

          <label className="block text-sm font-medium">
            E-mail (login)
            <input
              value={email}
              disabled
              className="mt-1 w-full cursor-not-allowed rounded-lg border border-border bg-surface-2 px-3 py-2 text-sm text-muted"
            />
          </label>

          <label className="block text-sm font-medium">
            Telefone
            <input
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
            />
          </label>

          <label className="block text-sm font-medium sm:col-span-2">
            Cargo (opcional)
            <input
              value={jobTitle}
              onChange={(e) => setJobTitle(e.target.value)}
              placeholder="ex.: Gestor de Operações"
              className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
            />
          </label>
        </div>

        <p className="mt-3 text-xs text-muted">
          O e-mail é usado para entrar e não pode ser alterado aqui.
        </p>

        {error && <p className="mt-3 text-sm text-red-600">{error}</p>}
        {saved && !error && (
          <p className="mt-3 text-sm text-green-600">Perfil atualizado.</p>
        )}

        <div className="mt-6 flex justify-end">
          <button
            type="submit"
            disabled={saving}
            className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
          >
            {saving ? "Salvando…" : "Salvar alterações"}
          </button>
        </div>
      </form>
    </div>
  );
}
