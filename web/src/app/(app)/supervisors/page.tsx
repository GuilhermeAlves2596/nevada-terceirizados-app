"use client";

import { useCallback, useEffect, useState } from "react";
import { collection, getDocs, query, where } from "firebase/firestore";
import { httpsCallable, type FunctionsError } from "firebase/functions";
import { db, functions } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";

type Supervisor = {
  id: string;
  name?: string;
  email?: string | null;
  phone?: string | null;
  contractIds?: string[];
  active?: boolean;
  createdAt?: { toDate?: () => Date } | null;
};

type CreatedCreds = { email: string; temporaryPassword: string };

const createSupervisor = httpsCallable<
  { name: string; email: string; phone?: string },
  { uid: string; temporaryPassword: string }
>(functions, "createSupervisor");

const deleteUserAccount = httpsCallable<{ userId: string }, { ok: boolean }>(
  functions,
  "deleteUserAccount",
);

function formatDate(ts?: { toDate?: () => Date } | null): string {
  if (!ts?.toDate) return "—";
  try {
    return ts.toDate().toLocaleDateString("pt-BR");
  } catch {
    return "—";
  }
}

export default function SupervisorsPage() {
  const { profile } = useAuth();
  const companyId = profile?.companyId ?? null;

  const [list, setList] = useState<Supervisor[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [created, setCreated] = useState<CreatedCreds | null>(null);

  const [viewing, setViewing] = useState<Supervisor | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<Supervisor | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!companyId) {
      setList([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const q = query(
        collection(db, "users"),
        where("companyId", "==", companyId),
        where("role", "==", "supervisor"),
      );
      const snap = await getDocs(q);
      const rows = snap.docs
        .map((d) => ({ id: d.id, ...(d.data() as Omit<Supervisor, "id">) }))
        .sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""));
      setList(rows);
    } catch {
      setLoadError("Não foi possível carregar os supervisores.");
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  function resetForm() {
    setName("");
    setEmail("");
    setPhone("");
    setFormError(null);
  }

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    setSubmitting(true);
    try {
      const res = await createSupervisor({
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim() || undefined,
      });
      setCreated({
        email: email.trim(),
        temporaryPassword: res.data.temporaryPassword,
      });
      setShowForm(false);
      resetForm();
      await load();
    } catch (err) {
      const fe = err as FunctionsError;
      setFormError(fe?.message ?? "Falha ao cadastrar o supervisor.");
    } finally {
      setSubmitting(false);
    }
  }

  async function onDelete(s: Supervisor) {
    setActionError(null);
    setDeleting(true);
    try {
      await deleteUserAccount({ userId: s.id });
      setConfirmDelete(null);
      setViewing(null);
      await load();
    } catch (err) {
      const fe = err as FunctionsError;
      setActionError(fe?.message ?? "Falha ao excluir o supervisor.");
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Supervisores</h1>
          <p className="mt-1 text-sm text-slate-500">
            Contas de supervisor da sua empresa.
          </p>
        </div>
        {companyId && (
          <button
            onClick={() => {
              setShowForm((v) => !v);
              setFormError(null);
            }}
            className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
          >
            {showForm ? "Cancelar" : "Novo supervisor"}
          </button>
        )}
      </div>

      {!companyId && (
        <p className="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
          Sua conta não está vinculada a uma empresa. A seleção de empresa para o
          admin da plataforma será adicionada em breve.
        </p>
      )}

      {created && (
        <div className="mt-6 rounded-2xl border border-brand/40 bg-brand-soft p-5">
          <h2 className="font-medium text-brand-dark">Supervisor criado</h2>
          <p className="mt-1 text-sm text-slate-600">
            Anote e repasse ao supervisor. A senha é temporária — ele precisará
            trocá-la no primeiro acesso.
          </p>
          <dl className="mt-3 space-y-1 text-sm">
            <div className="flex gap-2">
              <dt className="w-32 text-slate-500">E-mail</dt>
              <dd className="font-mono">{created.email}</dd>
            </div>
            <div className="flex gap-2">
              <dt className="w-32 text-slate-500">Senha temporária</dt>
              <dd className="font-mono">{created.temporaryPassword}</dd>
            </div>
          </dl>
          <div className="mt-4 flex gap-2">
            <button
              onClick={() =>
                navigator.clipboard?.writeText(
                  `E-mail: ${created.email}\nSenha: ${created.temporaryPassword}`,
                )
              }
              className="rounded-lg border border-brand/40 bg-white px-3 py-1.5 text-sm font-medium text-brand-dark hover:bg-white/70"
            >
              Copiar
            </button>
            <button
              onClick={() => setCreated(null)}
              className="rounded-lg px-3 py-1.5 text-sm font-medium text-slate-500 hover:bg-white/50"
            >
              Fechar
            </button>
          </div>
        </div>
      )}

      {showForm && companyId && (
        <form
          onSubmit={onCreate}
          className="mt-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"
        >
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="block text-sm font-medium text-slate-700">
              Nome
              <input
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
              />
            </label>
            <label className="block text-sm font-medium text-slate-700">
              E-mail
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
              />
            </label>
            <label className="block text-sm font-medium text-slate-700">
              Telefone (opcional)
              <input
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
              />
            </label>
          </div>

          {formError && (
            <p className="mt-3 text-sm text-red-600">{formError}</p>
          )}

          <div className="mt-5 flex items-center gap-3">
            <button
              type="submit"
              disabled={submitting}
              className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
            >
              {submitting ? "Cadastrando…" : "Cadastrar supervisor"}
            </button>
            <p className="text-xs text-slate-400">
              O vínculo de contratos é feito depois, na tela do supervisor.
            </p>
          </div>
        </form>
      )}

      <div className="mt-8">
        {loading ? (
          <p className="text-sm text-slate-500">Carregando…</p>
        ) : loadError ? (
          <p className="text-sm text-red-600">{loadError}</p>
        ) : list.length === 0 ? (
          <p className="rounded-lg border border-dashed border-slate-200 p-6 text-center text-sm text-slate-500">
            Nenhum supervisor cadastrado ainda.
          </p>
        ) : (
          <ul className="divide-y divide-slate-100 overflow-hidden rounded-2xl border border-slate-200 bg-white">
            {list.map((s) => (
              <li key={s.id} className="flex items-center justify-between px-5 py-4">
                <div className="min-w-0">
                  <p className="truncate font-medium">{s.name ?? "(sem nome)"}</p>
                  <p className="truncate text-sm text-slate-500">{s.email}</p>
                </div>
                <div className="flex shrink-0 items-center gap-2">
                  <span className="hidden text-xs text-slate-400 sm:inline">
                    {(s.contractIds?.length ?? 0) === 0
                      ? "sem contratos"
                      : `${s.contractIds?.length} contrato(s)`}
                  </span>
                  <button
                    onClick={() => setViewing(s)}
                    className="rounded-lg border border-slate-300 px-3 py-1.5 text-sm font-medium hover:bg-slate-50"
                  >
                    Ver
                  </button>
                  <button
                    onClick={() => {
                      setActionError(null);
                      setConfirmDelete(s);
                    }}
                    className="rounded-lg border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
                  >
                    Excluir
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Detalhes do supervisor */}
      {viewing && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => setViewing(null)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-semibold">{viewing.name ?? "Supervisor"}</h2>
            <dl className="mt-4 space-y-2 text-sm">
              <div className="flex gap-3">
                <dt className="w-32 shrink-0 text-slate-500">E-mail</dt>
                <dd className="break-all">{viewing.email ?? "—"}</dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-32 shrink-0 text-slate-500">Telefone</dt>
                <dd>{viewing.phone ?? "—"}</dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-32 shrink-0 text-slate-500">Status</dt>
                <dd>{viewing.active === false ? "Inativo" : "Ativo"}</dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-32 shrink-0 text-slate-500">Contratos</dt>
                <dd>
                  {(viewing.contractIds?.length ?? 0) === 0
                    ? "nenhum vinculado"
                    : `${viewing.contractIds?.length} vinculado(s)`}
                </dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-32 shrink-0 text-slate-500">Criado em</dt>
                <dd>{formatDate(viewing.createdAt)}</dd>
              </div>
            </dl>
            <div className="mt-6 flex justify-between">
              <button
                onClick={() => {
                  const s = viewing;
                  setViewing(null);
                  setActionError(null);
                  setConfirmDelete(s);
                }}
                className="rounded-lg border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
              >
                Excluir
              </button>
              <button
                onClick={() => setViewing(null)}
                className="rounded-lg border border-slate-300 px-4 py-1.5 text-sm font-medium hover:bg-slate-50"
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirmar exclusão */}
      {confirmDelete && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !deleting && setConfirmDelete(null)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-semibold">Excluir supervisor</h2>
            <p className="mt-2 text-sm text-slate-600">
              Excluir <span className="font-medium">{confirmDelete.name ?? confirmDelete.email}</span>?
              Isso remove a conta de acesso e o perfil — não pode ser desfeito.
            </p>
            {actionError && <p className="mt-3 text-sm text-red-600">{actionError}</p>}
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setConfirmDelete(null)}
                disabled={deleting}
                className="rounded-lg border border-slate-300 px-4 py-1.5 text-sm font-medium hover:bg-slate-50 disabled:opacity-60"
              >
                Cancelar
              </button>
              <button
                onClick={() => onDelete(confirmDelete)}
                disabled={deleting}
                className="rounded-lg bg-red-600 px-4 py-1.5 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-60"
              >
                {deleting ? "Excluindo…" : "Excluir"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
