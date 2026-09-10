"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import {
  collection,
  doc,
  getCountFromServer,
  getDoc,
  getDocs,
  query,
  where,
} from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import { db, functions } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { useToast } from "@/lib/toast";
import { errorMessage } from "@/lib/errors";
import { Loader } from "@/components/spinner";
import {
  formatDate,
  planLabel,
  subscriptionGrantsAccess,
  subscriptionStatusLabel,
  type Company,
} from "@/lib/model";
import { ChevronLeftIcon, EyeIcon, TrashIcon } from "@/components/icons";

type Manager = {
  id: string;
  name?: string;
  email?: string | null;
  phone?: string | null;
  jobTitle?: string | null;
  active?: boolean;
  createdAt?: { toDate?: () => Date } | null;
};

type CreatedCreds = { email: string; temporaryPassword: string };

const createCompanyAdmin = httpsCallable<
  { name: string; email: string; phone?: string; companyId: string },
  { uid: string; temporaryPassword: string }
>(functions, "createCompanyAdmin");

const deleteUserAccount = httpsCallable<{ userId: string }, { ok: boolean }>(
  functions,
  "deleteUserAccount",
);

export default function CompanyDetailPage() {
  const { profile } = useAuth();
  const isPlatformAdmin = profile?.role === "platformAdmin";
  const toast = useToast();
  const params = useParams<{ id: string }>();
  const companyId = params.id;

  const [company, setCompany] = useState<Company | null>(null);
  const [managers, setManagers] = useState<Manager[]>([]);
  const [usedSeats, setUsedSeats] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [created, setCreated] = useState<CreatedCreds | null>(null);

  const [viewing, setViewing] = useState<Manager | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<Manager | null>(null);
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    if (!isPlatformAdmin || !companyId) {
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const [snap, mgrs, countSnap] = await Promise.all([
        getDoc(doc(db, "companies", companyId)),
        getDocs(
          query(
            collection(db, "users"),
            where("companyId", "==", companyId),
            where("role", "==", "companyAdmin"),
          ),
        ),
        // Assentos = TODAS as contas da empresa (todos os papéis).
        getCountFromServer(
          query(collection(db, "users"), where("companyId", "==", companyId)),
        ),
      ]);
      setCompany(
        snap.exists()
          ? ({ id: snap.id, ...(snap.data() as Omit<Company, "id">) })
          : null,
      );
      setManagers(
        mgrs.docs
          .map((d) => ({ id: d.id, ...(d.data() as Omit<Manager, "id">) }))
          .sort((a, b) => (a.name ?? "").localeCompare(b.name ?? "")),
      );
      setUsedSeats(countSnap.data().count);
    } catch {
      setLoadError("Não foi possível carregar a empresa.");
    } finally {
      setLoading(false);
    }
  }, [isPlatformAdmin, companyId]);

  useEffect(() => {
    load();
  }, [load]);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    try {
      const res = await createCompanyAdmin({
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim() || undefined,
        companyId,
      });
      setCreated({
        email: email.trim(),
        temporaryPassword: res.data.temporaryPassword,
      });
      setShowForm(false);
      setName("");
      setEmail("");
      setPhone("");
      await load();
      toast.success("Gestor cadastrado.");
    } catch (err) {
      toast.error(
        errorMessage(err, { fallback: "Falha ao cadastrar o gestor." }),
      );
    } finally {
      setSubmitting(false);
    }
  }

  async function onDelete(m: Manager) {
    setDeleting(true);
    try {
      await deleteUserAccount({ userId: m.id });
      setConfirmDelete(null);
      await load();
      toast.success("Gestor excluído.");
    } catch (err) {
      toast.error(errorMessage(err, { fallback: "Falha ao excluir o gestor." }));
    } finally {
      setDeleting(false);
    }
  }

  const atSeatLimit =
    company != null &&
    company.seats != null &&
    usedSeats != null &&
    usedSeats >= company.seats;

  const subInactive =
    company != null && !subscriptionGrantsAccess(company.subscriptionStatus);

  // Bloqueia cadastrar gestor quando a assinatura está inativa ou o plano lotou
  // (espelha o gate server-side em assertCanAddAccount).
  const blockNewManager = atSeatLimit || subInactive;

  if (!isPlatformAdmin) {
    return (
      <div className="mx-auto mt-16 max-w-md rounded-2xl border border-border bg-surface p-8 text-center">
        <h1 className="text-lg font-semibold">Acesso restrito</h1>
        <p className="mt-2 text-sm text-muted">
          Só o administrador da plataforma gerencia empresas.
        </p>
      </div>
    );
  }

  return (
    <div>
      <Link
        href="/companies"
        className="inline-flex items-center gap-1 text-sm text-muted hover:text-fg"
      >
        <ChevronLeftIcon className="h-4 w-4" />
        Empresas
      </Link>

      {loading ? (
        <div className="mt-8">
          <Loader />
        </div>
      ) : loadError ? (
        <p className="mt-8 text-sm text-red-600">{loadError}</p>
      ) : !company ? (
        <p className="mt-8 rounded-lg border border-dashed border-border p-6 text-center text-sm text-muted">
          Empresa não encontrada.
        </p>
      ) : (
        <>
          <div className="mt-4 flex flex-wrap items-center gap-3">
            <h1 className="text-2xl font-semibold">{company.name}</h1>
            <span
              className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium ${
                subscriptionGrantsAccess(company.subscriptionStatus)
                  ? "bg-green-100 text-green-700"
                  : "bg-red-100 text-red-700"
              }`}
            >
              {subscriptionStatusLabel(company.subscriptionStatus)}
            </span>
          </div>

          <dl className="mt-4 grid gap-x-6 gap-y-2 text-sm sm:grid-cols-2">
            <div className="flex gap-3">
              <dt className="w-24 shrink-0 text-muted">Documento</dt>
              <dd>{company.document || "—"}</dd>
            </div>
            <div className="flex gap-3">
              <dt className="w-24 shrink-0 text-muted">Plano</dt>
              <dd>{company.plan ? planLabel(company.plan) : "—"}</dd>
            </div>
            <div className="flex gap-3">
              <dt className="w-24 shrink-0 text-muted">Contas</dt>
              <dd>
                {usedSeats != null ? usedSeats : "—"}
                {company.seats != null
                  ? ` / ${company.seats}`
                  : company.plan === "unlimited"
                    ? " / ∞"
                    : ""}
                {company.seats != null &&
                usedSeats != null &&
                usedSeats >= company.seats ? (
                  <span className="ml-2 rounded-full bg-red-100 px-2 py-0.5 text-xs font-medium text-red-700">
                    limite atingido
                  </span>
                ) : null}
              </dd>
            </div>
          </dl>

          {/* Gestores */}
          <div className="mt-10 flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold">Gestores</h2>
              <p className="mt-1 text-sm text-muted">
                Contas de gestor (companyAdmin) desta empresa.
              </p>
            </div>
            <button
              onClick={() => {
                setShowForm((v) => !v);
              }}
              disabled={blockNewManager && !showForm}
              title={
                subInactive && !showForm
                  ? "Assinatura inativa"
                  : atSeatLimit && !showForm
                    ? "Limite de contas do plano atingido"
                    : undefined
              }
              className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
            >
              {showForm ? "Cancelar" : "Novo gestor"}
            </button>
          </div>

          {subInactive && (
            <p className="mt-4 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
              A assinatura desta empresa está{" "}
              {subscriptionStatusLabel(company.subscriptionStatus).toLowerCase()}.
              Regularize a assinatura para cadastrar novas contas.
            </p>
          )}
          {!subInactive && atSeatLimit && (
            <p className="mt-4 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
              A empresa atingiu o limite de {company.seats} contas do plano{" "}
              {company.plan ? planLabel(company.plan) : ""}. Aumente o plano para
              cadastrar mais contas.
            </p>
          )}

          {created && (
            <div className="mt-6 rounded-2xl border border-brand/40 bg-brand-soft p-5">
              <h3 className="font-medium text-brand-dark">Gestor criado</h3>
              <p className="mt-1 text-sm text-muted">
                Anote e repasse ao gestor. A senha é temporária — ele precisará
                trocá-la no primeiro acesso.
              </p>
              <dl className="mt-3 space-y-1 text-sm">
                <div className="flex gap-2">
                  <dt className="w-32 text-muted">E-mail</dt>
                  <dd className="font-mono">{created.email}</dd>
                </div>
                <div className="flex gap-2">
                  <dt className="w-32 text-muted">Senha temporária</dt>
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
                  className="rounded-lg border border-brand/40 bg-surface px-3 py-1.5 text-sm font-medium text-brand-dark hover:bg-surface/70"
                >
                  Copiar
                </button>
                <button
                  onClick={() => setCreated(null)}
                  className="rounded-lg px-3 py-1.5 text-sm font-medium text-muted hover:bg-surface/50"
                >
                  Fechar
                </button>
              </div>
            </div>
          )}

          {showForm && (
            <form
              onSubmit={onCreate}
              className="mt-6 rounded-2xl border border-border bg-surface p-6 shadow-sm"
            >
              <div className="grid gap-4 sm:grid-cols-2">
                <label className="block text-sm font-medium text-fg">
                  Nome
                  <input
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                  />
                </label>
                <label className="block text-sm font-medium text-fg">
                  E-mail
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                  />
                </label>
                <label className="block text-sm font-medium text-fg">
                  Telefone (opcional)
                  <input
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                  />
                </label>
              </div>

              <div className="mt-5">
                <button
                  type="submit"
                  disabled={submitting}
                  className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
                >
                  {submitting ? "Cadastrando…" : "Cadastrar gestor"}
                </button>
              </div>
            </form>
          )}

          <div className="mt-6">
            {managers.length === 0 ? (
              <p className="rounded-lg border border-dashed border-border p-6 text-center text-sm text-muted">
                Nenhum gestor cadastrado para esta empresa.
              </p>
            ) : (
              <ul className="divide-y divide-border overflow-hidden rounded-2xl border border-border bg-surface">
                {managers.map((m) => (
                  <li
                    key={m.id}
                    className="flex items-center justify-between px-5 py-4"
                  >
                    <div className="min-w-0">
                      <p className="truncate font-medium">
                        {m.name ?? "(sem nome)"}
                      </p>
                      <p className="truncate text-sm text-muted">{m.email}</p>
                    </div>
                    <div className="flex shrink-0 items-center gap-2">
                      <span className="mr-1 hidden text-xs text-muted sm:inline">
                        {formatDate(m.createdAt)}
                      </span>
                      <button
                        onClick={() => setViewing(m)}
                        title="Ver detalhes"
                        aria-label="Ver detalhes"
                        className="rounded-lg border border-border p-2 text-muted hover:bg-surface-2 hover:text-brand"
                      >
                        <EyeIcon />
                      </button>
                      <button
                        onClick={() => setConfirmDelete(m)}
                        title="Excluir"
                        aria-label="Excluir"
                        className="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50"
                      >
                        <TrashIcon />
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </>
      )}

      {/* Detalhes do gestor */}
      {viewing && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => setViewing(null)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-surface p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-semibold">
              {viewing.name ?? "Gestor"}
            </h2>
            <dl className="mt-4 space-y-2 text-sm">
              <div className="flex gap-3">
                <dt className="w-28 shrink-0 text-muted">E-mail</dt>
                <dd className="break-all">
                  {viewing.email ?? (
                    <span className="text-muted">
                      não gravado no perfil (login pelo Auth)
                    </span>
                  )}
                </dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-28 shrink-0 text-muted">Telefone</dt>
                <dd>{viewing.phone ?? "—"}</dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-28 shrink-0 text-muted">Cargo</dt>
                <dd>{viewing.jobTitle ?? "—"}</dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-28 shrink-0 text-muted">Status</dt>
                <dd>{viewing.active === false ? "Inativo" : "Ativo"}</dd>
              </div>
              <div className="flex gap-3">
                <dt className="w-28 shrink-0 text-muted">Criado em</dt>
                <dd>{formatDate(viewing.createdAt)}</dd>
              </div>
            </dl>
            <div className="mt-6 flex items-center justify-between">
              <button
                onClick={() => {
                  const m = viewing;
                  setViewing(null);
                  setConfirmDelete(m);
                }}
                className="inline-flex items-center gap-1.5 rounded-lg border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
              >
                <TrashIcon />
                Excluir
              </button>
              <button
                onClick={() => setViewing(null)}
                className="rounded-lg border border-border px-4 py-1.5 text-sm font-medium hover:bg-surface-2"
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirmar exclusão de gestor */}
      {confirmDelete && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !deleting && setConfirmDelete(null)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-surface p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-semibold">Excluir gestor</h2>
            <p className="mt-2 text-sm text-muted">
              Excluir{" "}
              <span className="font-medium">
                {confirmDelete.name ?? confirmDelete.email}
              </span>
              ? Isso remove a conta de acesso e o perfil — não pode ser desfeito.
            </p>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setConfirmDelete(null)}
                disabled={deleting}
                className="rounded-lg border border-border px-4 py-1.5 text-sm font-medium hover:bg-surface-2 disabled:opacity-60"
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
